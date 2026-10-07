import os
import json
import time
import uuid
import logging
import warnings
import calendar
import tracemalloc
from queue import Full, Queue
from threading import Event, Thread
import oracledb
import pandas as pd
from pathlib import Path
from contextlib import contextmanager
from datetime import date, datetime, timedelta
from argparse import ArgumentParser
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)
from include.Python.TELTools import (
    getAzureSecret,
    load_control_table,
    readControlTable
)
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

# Azure SDK — kills the request/response header dumps
for name in ("azure", "azure.core.pipeline.policies.http_logging_policy",
             "azure.identity", "azure.identity._internal.get_token_mixin"):
    logging.getLogger(name).setLevel(logging.WARNING)

# Snowflake connector — kills "Number of results in first chunk", OCSP, version banner
for name in ("snowflake.connector", "snowflake.connector.connection",
             "snowflake.connector.cursor", "snowflake.connector.network"):
    logging.getLogger(name).setLevel(logging.WARNING)

# pandas / FutureWarning noise
warnings.filterwarnings("ignore", message=".*only supports SQLAlchemy connectable.*")
warnings.filterwarnings("ignore", message=".*is_datetime64tz_dtype is deprecated.*")
warnings.filterwarnings("ignore", category=FutureWarning,
                        module=r"snowflake\.connector\..*")
for name in ("urllib3.connectionpool",
             "snowflake.connector.vendored.urllib3.connectionpool"):
    logging.getLogger(name).setLevel(logging.ERROR)

PROFILE = False

@contextmanager
def _timed(label, rows=None, cols=None):
    if not PROFILE:
        yield
        return
    start = time.perf_counter()
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        extra = ""
        if rows is not None and cols is not None:
            extra = f" | {rows:,} rows x {cols} cols"
        print(f"    PROFILE | {label:<34} | {elapsed:8.3f}s{extra}")

DEBUG = False
QUEUE_MAX_SIZE = 0
_QUEUE_PUT_TIMEOUT_SECONDS = 2
_QUEUE_BACKPRESSURE_RATIO = 0.80
_QUEUE_BACKPRESSURE_SLEEP_SECONDS = 20
_QUEUE_SENTINEL = object()

_MERGE_QUERY = '''
    SELECT
        P.TABKEY        AS "_PRIMARY_TAB_KEY",
        P.CHNGIND       AS "_CHANGE_TYPE",
        H.UDATE         AS "_UDATE",
        H.UTIME         AS "_UTIME",
        CASE WHEN P.CHNGIND = 'D' THEN 'Y' ELSE 'N' END AS "_DELETE_FLAG",
        KEY.*
    FROM SAPR3.CDPOS P
    INNER JOIN SAPR3.CDHDR H
        ON  P.MANDANT    = H.MANDANT
        AND P.OBJECTCLAS = H.OBJECTCLAS
        AND P.OBJECTID   = H.OBJECTID
        AND P.CHANGENR   = H.CHANGENR
    INNER JOIN {schema}.{table} KEY
        ON P.TABKEY = {primary_key}
    WHERE P.TABNAME = '{table}'
      AND (
            H.UDATE > '{update_date_part}'
         OR (H.UDATE = '{update_date_part}' AND H.UTIME >= '{update_time_part}')
      )
'''

_SNOWFLAKE_INCREMENTAL_END_QUERY = '''
    SELECT MAX("_UDATE" || "_UTIME") AS MAX_CHANGE_DATETIME
    FROM {db}.{schema}.{table}
'''


def get_kadky_filter():
    today = date.today()

    last_day = calendar.monthrange(today.year, today.month)[1]
    is_last_day = today.day == last_day
    is_first_day = today.day == 1

    current_month = today.strftime('%Y%m') + '01'

    kadky_values = ['00000000', current_month]

    if is_first_day or is_last_day:
        last_month = (today.replace(day=1) - timedelta(days=1)).replace(day=1)
        last_month_str = last_month.strftime('%Y%m') + '01'
        kadky_values.append(last_month_str)

    return kadky_values


def get_gjahr_filter():
    current_year = date.today().year

    years = [str(year) for year in range(current_year - 1, current_year + 3)]
    return years


def build_gjahr_query(table: str, years: list = None):
    if years is None:
        years = get_gjahr_filter()

    in_clause = ', '.join(f"'{y}'" for y in years)
    print(f"  BUILD GJAHR QUERY | Table: {table} | Years: {years}")
    query = f"SELECT * FROM {table} WHERE GJAHR IN ({in_clause})"
    print(f"  FINAL GJAHR QUERY | {query}")
    return query


_QUERY_FILTER_FUNCTIONS = {
    "get_kadky_filter": get_kadky_filter,
    "get_gjahr_filter": get_gjahr_filter,
}


def _resolve_query_filter_function(function_name):
    fn = _QUERY_FILTER_FUNCTIONS.get(function_name)
    if fn is None:
        available = ", ".join(sorted(_QUERY_FILTER_FUNCTIONS.keys()))
        raise ValueError(
            f"Unsupported query_filter_function: {function_name}. "
            f"Supported values: {available}"
        )
    return fn


def _build_insert_overwrite_queries(table_data):
    schema = table_data.get('schema')
    table = table_data.get('table')
    base_from = f" FROM {schema}.{table}"

    where_clause = ""
    filter_function_name = table_data.get("query_filter_function")
    if filter_function_name:
        filter_column = table_data.get("query_filter_column", "KADKY")
        filter_values = _resolve_query_filter_function(filter_function_name)()

        if not isinstance(filter_values, (list, tuple, set)) or not filter_values:
            raise ValueError(
                f"query_filter_function '{filter_function_name}' must return a non-empty list/tuple/set"
            )

        in_clause = ", ".join(f"'{str(v)}'" for v in filter_values)
        where_clause = f" WHERE {filter_column} IN ({in_clause})"

        print(
            f"  QUERY FILTER | Function: {filter_function_name}"
            f" | Column: {filter_column}"
            f" | Values: {list(filter_values)}"
        )

    query = f"SELECT *{base_from}{where_clause}"
    count_query = f"SELECT COUNT(*){base_from}{where_clause}"
    return query, count_query


class SnowflakeUploadError(Exception):
    """Raised when putSnowflakeDataFrame returns a failed signal"""
    pass


class SnowflakeConnectionError(Exception):
    pass


def _sf_execute(cur, sql, context=""):
    if not DEBUG:
        cur.execute(sql)
        return

    start = time.perf_counter()
    cur.execute(sql)
    elapsed = time.perf_counter() - start
    rows = cur.rowcount if cur.rowcount is not None else -1
    short_sql = " ".join(sql.split())[:120]
    print(
        f"  SF QUERY | {context} | TIME: {elapsed:.2f}s | ROWS: {rows}"
        f"\n           | SQL: {short_sql}"
    )


def _generate_temp_table_name(base_table):
    return f"{base_table}__{uuid.uuid4().hex[:8].upper()}__TEMP"


def _drop_stale_temp_tables(snowflake_conn, db, schema, base_table):
    query = f"""
        SELECT TABLE_NAME
        FROM {db}.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = '{schema}'
          AND TABLE_NAME ILIKE '{base_table}__%__TEMP'
    """
    try:
        with snowflake_conn.cursor() as cur:
            _sf_execute(cur, query, context="stale TEMP check")
            rows = cur.fetchall()

        stale_tables = [
            row[0] for row in rows
            if row[0].upper().startswith(f"{base_table}__") and row[0].upper().endswith("__TEMP")
        ]

        if not stale_tables:
            print(f"  TEMP CLEANUP | No stale TEMP tables found for {base_table}")
            return

        print(f"  TEMP CLEANUP | Found {len(stale_tables)} stale TEMP table(s) — dropping ...")
        for stale in stale_tables:
            with snowflake_conn.cursor() as cur:
                _sf_execute(cur, f'DROP TABLE IF EXISTS {db}.{schema}."{stale}"', context="drop stale TEMP")
            print(f"  TEMP CLEANUP | Dropped : {db}.{schema}.{stale}")

    except Exception as e:
        print(f"  TEMP CLEANUP | WARNING: Could not check/drop stale TEMP tables | {e}")


def _create_temp_table_like(snowflake_conn, db, schema, main_table, temp_table):
    ddl = (
        f'CREATE TABLE IF NOT EXISTS {db}.{schema}."{temp_table}" '
        f'LIKE {db}.{schema}."{main_table}"'
    )
    print(f"  TEMP TABLE | Creating : {db}.{schema}.{temp_table}")
    with snowflake_conn.cursor() as cur:
        _sf_execute(cur, ddl, context="create TEMP")
    print(f"  TEMP TABLE | Created successfully.")


def _insert_overwrite_from_temp(snowflake_conn, db, schema, main_table, temp_table):
    sql = (
        f'INSERT OVERWRITE INTO {db}.{schema}."{main_table}" '
        f'SELECT * FROM {db}.{schema}."{temp_table}"'
    )
    print(f"  INSERT OVERWRITE | Starting : {temp_table} -> {main_table} ...")
    start = time.perf_counter()
    with snowflake_conn.cursor() as cur:
        _sf_execute(cur, sql, context="INSERT OVERWRITE")
    elapsed = time.perf_counter() - start
    print(f"  INSERT OVERWRITE | Complete | TIME : {elapsed:.2f}s")


def _drop_temp_table(snowflake_conn, db, schema, temp_table):
    sql = f'DROP TABLE IF EXISTS {db}.{schema}."{temp_table}"'
    print(f"  TEMP TABLE | Dropping : {db}.{schema}.{temp_table}")
    try:
        with snowflake_conn.cursor() as cur:
            _sf_execute(cur, sql, context="drop TEMP")
        print(f"  TEMP TABLE | Dropped successfully.")
    except Exception as e:
        print(f"  TEMP TABLE | WARNING: Could not drop temp table {temp_table} | {e}")


@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type(SnowflakeConnectionError),
    reraise=True,
    before_sleep=lambda rs: (
        print("-" * 60),
        print(f"  RETRY ATTEMPT : {rs.attempt_number} / 3"),
        print(f"  WAIT TIME     : {rs.next_action.sleep:.1f}s"),
        print(f"  REASON        : {rs.outcome.exception()}"),
        print("-" * 60)
    )
)
def _connect_to_snowflake(db, schema):
    db_account   = os.environ.get('SNOWFLAKE_ACCOUNT')
    db_username  = os.environ.get('SNOWFLAKE_USER')
    db_password  = os.environ.get('SNOWFLAKE_SECRET')
    db_warehouse = os.environ.get('SNOWFLAKE_WAREHOUSE')
    db_role      = os.environ.get('SNOWFLAKE_ROLE')

    try:
        conn = snowflake.connector.connect(
            account   = db_account,
            user      = db_username,
            password  = db_password,
            database  = db,
            schema    = schema,
            warehouse = db_warehouse,
            role      = db_role
        )
        return conn
    except Exception as e:
        raise SnowflakeConnectionError(
            f"Failed to connect to Snowflake db: {db}, schema: {schema} | Reason: {e}"
        )


def _get_max_incremental_from_snowflake(snowflake_conn, db, schema, table, fallback_date):
    query = _SNOWFLAKE_INCREMENTAL_END_QUERY.format(
        db=db,
        schema=schema,
        table=table
    )
    try:
        with snowflake_conn.cursor() as cur:
            _sf_execute(cur, query, context="max incremental")
            row = cur.fetchone()
            if row and row[0]:
                print(f"  MAX INCREMENTAL (Snowflake LZ) : {row[0]}")
                return row[0]
    except Exception as e:
        print(f"  WARNING: Could not query Snowflake LZ for max incremental | {e}")

    fallback = _serialize(fallback_date, format="%Y%m%d%H%M%S")
    print(f"  MAX INCREMENTAL (fallback)     : {fallback}")
    return fallback


def _prepare_dataframe(conn, db, schema, tableName, df, fileName, fileDate, normalize_nulls=False):
    n_rows = len(df)

    with _timed("prepare:total", rows=n_rows, cols=len(df.columns)):
        headerless = list(df.columns) == list(range(len(df.columns)))
        if headerless:
            query = f"""
                SELECT COLUMN_NAME
                FROM {db}.INFORMATION_SCHEMA.COLUMNS
                WHERE
                    TABLE_SCHEMA = '{schema}' AND
                    TABLE_NAME   = '{tableName}' AND
                    COLUMN_NAME NOT IN ('_FILENAME', '_FILEDATE', '_UPLOADDATE', '_CAPTUREDATETIME')
                ORDER BY ORDINAL_POSITION
            """
            with _timed("prepare:headerless_col_query"):
                results = conn.cursor().execute(query)
                sf_columns = list(results.fetch_pandas_all()['COLUMN_NAME']) if results else list(df.columns)
            df.columns = sf_columns

        df = df.rename(str.upper, axis='columns')

        query = f"""
            SELECT COLUMN_NAME, DATA_TYPE
            FROM {db}.INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{tableName}'
        """
        with _timed("prepare:metadata_query"):
            results = conn.cursor().execute(query)
            sf_metadata = results.fetch_pandas_all() if results else pd.DataFrame(columns=['COLUMN_NAME', 'DATA_TYPE'])
        sf_columns = set(sf_metadata['COLUMN_NAME']) if not sf_metadata.empty else set()

        df_columns = set(df.columns)
        columns_to_remove = df_columns - sf_columns
        if columns_to_remove:
            print(f"  DATAFRAME PREPARATION | Removing columns not in Snowflake: {', '.join(columns_to_remove)}")
            df = df.drop(columns=columns_to_remove)

        if normalize_nulls and not sf_metadata.empty:
            numeric_types = {
                "NUMBER", "DECIMAL", "NUMERIC",
                "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "BYTEINT",
                "FLOAT", "FLOAT4", "FLOAT8", "DOUBLE", "DOUBLE PRECISION", "REAL"
            }
            numeric_columns = [
                row.COLUMN_NAME
                for row in sf_metadata.itertuples(index=False)
                if row.COLUMN_NAME in df.columns and str(row.DATA_TYPE).upper() in numeric_types
            ]
            object_columns = [column for column in df.columns if column not in numeric_columns]

            if numeric_columns:
                with _timed("normalize:numeric (to_numeric+fillna)", rows=n_rows, cols=len(numeric_columns)):
                    for column in numeric_columns:
                        df[column] = pd.to_numeric(df[column], errors="coerce").fillna(0)

            if object_columns:
                with _timed("normalize:object_where_notna", rows=n_rows, cols=len(object_columns)):
                    object_frame = df[object_columns].where(df[object_columns].notna(), "")

                with _timed("normalize:object_regex_replace", rows=n_rows, cols=len(object_columns)):
                    object_frame = object_frame.replace(to_replace=r"^\s+$", value="", regex=True)

                with _timed("normalize:object_dict_replace", rows=n_rows, cols=len(object_columns)):
                    object_frame = object_frame.replace({
                        "None": " ", "none": " ", "NaN": " ", "nan": " ", "NULL": " ", "null": " ",
                    })

                with _timed("normalize:object_writeback", rows=n_rows, cols=len(object_columns)):
                    df[object_columns] = object_frame

            print(
                "  DATAFRAME PREPARATION | Null normalization enabled"
                f" | Numeric NaN -> 0 (cols: {len(numeric_columns)})"
                f" | Object None -> '' (cols: {len(object_columns)})"
            )

        with _timed("prepare:assign_audit_and_reorder", rows=n_rows, cols=len(df.columns)):
            capture_datetime = str(fileDate)
            df = df.assign(
                _CAPTUREDATETIME=capture_datetime,
                _FILENAME=fileName,
                _FILEDATE=str(fileDate),
                _UPLOADDATE=str(datetime.now())
            )
            audit_fields = ['_CAPTUREDATETIME', '_FILENAME', '_FILEDATE', '_UPLOADDATE']
            other_cols = [c for c in df.columns if c not in audit_fields]
            result = df[other_cols + audit_fields]

    return result

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    retry=retry_if_exception_type(SnowflakeUploadError),
    reraise=True,
    before_sleep=lambda rs: (
        print("-" * 60),
        print(f"  RETRY ATTEMPT : {rs.attempt_number} / 3"),
        print(f"  WAIT TIME     : {rs.next_action.sleep:.1f}s"),
        print(f"  REASON        : {rs.outcome.exception()}"),
        print("-" * 60)
    )
)
def _upload_chunk_to_snowflake(conn, db, schema, tableName, df, fileName, fileDate, i, normalize_nulls=False):
    try:
        prep_start = time.perf_counter()
        df_prepared = _prepare_dataframe(
            conn, db, schema, tableName, df, fileName, fileDate,
            normalize_nulls=normalize_nulls
        )
        prep_elapsed = time.perf_counter() - prep_start

        write_start = time.perf_counter()
        success, num_chunks, num_rows, output = write_pandas(
            conn=conn,
            df=df_prepared,
            table_name=tableName,
            database=db,
            schema=schema,
            auto_create_table=True
        )
        write_elapsed = time.perf_counter() - write_start

        if PROFILE:
            total = prep_elapsed + write_elapsed
            prep_pct = (prep_elapsed / total * 100) if total else 0
            write_pct = (write_elapsed / total * 100) if total else 0
            print(
                f"  PROFILE | CHUNK {i} SPLIT | prepare: {prep_elapsed:7.2f}s ({prep_pct:4.1f}%)"
                f" | write_pandas: {write_elapsed:7.2f}s ({write_pct:4.1f}%)"
            )

        if not success:
            raise SnowflakeUploadError(
                f"Upload failed on chunk {i} | Rows: {num_rows} | Output: {output}"
            )

        return {
            "success": success,
            "num_chunks": num_chunks,
            "num_rows": num_rows,
            "snowflake": f"Uploaded to {db}.{schema}.{tableName}"
        }

    except SnowflakeUploadError:
        raise
    except Exception as e:
        raise SnowflakeUploadError(f"Unexpected error on chunk {i} | Reason: {e}")


def _serialize(value, format="%Y%m%d%H%M%S"):
    if isinstance(value, datetime):
        return value.replace(tzinfo=None, microsecond=0).strftime(format)

    if isinstance(value, str):
        for fmt in [format, '%Y-%m-%d %H:%M:%S', '%Y-%m-%d', "%Y%m%d%H%M%S"]:
            try:
                return datetime.strptime(value, fmt).strftime(format)
            except ValueError:
                continue

    raise TypeError(f"Unsupported type or unrecognized format: {type(value)} | {value}")


def _parse_bool(value):
    if isinstance(value, bool):
        return value

    normalized = str(value).strip().lower()
    if normalized in {"true", "t", "1", "yes", "y"}:
        return True
    if normalized in {"false", "f", "0", "no", "n"}:
        return False

    raise ValueError(f"Invalid boolean value: {value}")


def _collect_active_configurations(_all_configurations, extraction_name):
    return (
        v
        for k, v in _all_configurations.get("extraction").items()
        if v.get("is_active") and k == extraction_name
    )


def _open_configurations(config_file_name):
    return json.loads(
        Path(config_file_name).read_text()
    )


def get_oracle_connection(config, env):
    if env == 'PROD':
        _secret = 'PROD'
        connection_data = config.get("connection", {}).get(_secret, {})
    elif env == 'DEV':
        _secret = 'QA'
        connection_data = config.get("connection", {}).get(env, {})
    else:
        _secret = 'QA'
        connection_data = config.get("connection", {}).get(env, {})

    secret = getAzureSecret(connection_data.get("secret").replace("<<ENV>>", _secret)).value
    user   = getAzureSecret(connection_data.get("user").replace("<<ENV>>", _secret)).value

    print(f"-> Establishing Oracle connection to {connection_data.get('database')} for environment: {env}")
    print(f"   - Using host: {connection_data.get('host')}")

    dsn = oracledb.makedsn(
        host=connection_data['host'],
        port=connection_data["port"],
        service_name=connection_data["database"]
    )

    connection = oracledb.connect(
        user=user,
        password=secret,
        dsn=dsn,
        retry_count=connection_data["retry_count"],
        retry_delay=connection_data["retry_delay"],
        tcp_connect_timeout=connection_data["tcp_connect_timeout"],
        expire_time=1
    )

    return connection


def _format_bytes(num_bytes):
    for unit in ("B", "KB", "MB", "GB"):
        if abs(num_bytes) < 1024.0:
            return f"{num_bytes:.1f} {unit}"
        num_bytes /= 1024.0
    return f"{num_bytes:.1f} TB"


def _parse_queue_max_size(value):
    queue_size = int(value)
    if queue_size < 0:
        raise ValueError(f"Queue max size must be greater than or equal to 0: {value}")
    return queue_size


def _use_safe_string_fallback(table_data):
    return _parse_bool(table_data.get("use_safe_string_fallback", False))


def _use_null_normalization(table_data):
    return _parse_bool(table_data.get("normalize_object_none_and_numeric_nan", False))


def _requires_manual_stringification(value):
    return isinstance(value, (bytes, bytearray, memoryview, oracledb.LOB))


def _stringify_oracle_value(value):
    if value is None:
        return None

    if isinstance(value, oracledb.LOB):
        return _stringify_oracle_value(value.read())

    if isinstance(value, memoryview):
        value = value.tobytes()
    elif isinstance(value, bytearray):
        value = bytes(value)

    if isinstance(value, bytes):
        return value.hex().upper()

    return value


def _coerce_chunk_to_strings(chunk):
    normalized_columns = []

    for column_name in chunk.select_dtypes(include=["object"]).columns.tolist():
        series = chunk[column_name]
        if not series.map(_requires_manual_stringification).any():
            continue

        chunk[column_name] = series.map(_stringify_oracle_value)
        normalized_columns.append(column_name)

    if DEBUG and normalized_columns:
        print(
            "  ORACLE NORMALIZATION | "
            f"Converted binary/LOB columns to strings: {', '.join(normalized_columns)}"
        )

    return chunk.astype(str)


def _get_queue_depth(work_queue):
    try:
        return work_queue.qsize()
    except NotImplementedError:
        return None


def _log_oracle_queue_put(chunk_number, chunk_rows, work_queue, oracle_fetch_elapsed, queue_put_elapsed):
    queue_depth = _get_queue_depth(work_queue)
    if queue_depth is None:
        print(
            f"  ORACLE -> QUEUE | Chunk: {chunk_number} | Rows staged: {chunk_rows:,}"
            f" | Oracle fetch: {oracle_fetch_elapsed:.2f}s"
            f" | Queue put: {queue_put_elapsed:.2f}s"
        )
        return

    print(
        f"  ORACLE -> QUEUE | Chunk: {chunk_number} | Rows staged: {chunk_rows:,}"
        f" | Oracle fetch: {oracle_fetch_elapsed:.2f}s"
        f" | Queue put: {queue_put_elapsed:.2f}s"
        f" | Queue depth: {queue_depth}"
    )


def _maybe_slow_oracle_producer(work_queue, chunk_number):
    if work_queue.maxsize <= 0:
        return

    queue_depth = _get_queue_depth(work_queue)
    if queue_depth is None:
        return

    high_watermark = max(1, int(work_queue.maxsize * _QUEUE_BACKPRESSURE_RATIO))
    if queue_depth < high_watermark:
        return

    utilization = (queue_depth / work_queue.maxsize) * 100
    print(
        f"  ORACLE BACKPRESSURE | Chunk: {chunk_number}"
        f" | Queue depth: {queue_depth} / {work_queue.maxsize} ({utilization:.1f}%)"
        f" | Sleeping: {_QUEUE_BACKPRESSURE_SLEEP_SECONDS}s"
    )
    time.sleep(_QUEUE_BACKPRESSURE_SLEEP_SECONDS)


def _enqueue_queue_item(work_queue, item, consumer_error):
    while True:
        if consumer_error.is_set():
            raise RuntimeError("Snowflake consumer stopped before Oracle producer finished")

        try:
            work_queue.put(item, timeout=_QUEUE_PUT_TIMEOUT_SECONDS)
            return
        except Full:
            continue


def _snowflake_consumer_worker(
    work_queue,
    consumer_state,
    consumer_error,
    db,
    schema,
    table_name,
    serialized_date,
    file_date,
    total_rows=None,
    normalize_nulls=False
):
    snowflake_connection = None

    try:
        snowflake_connection = _connect_to_snowflake(db=db, schema=schema)

        while True:
            payload = work_queue.get()
            if payload is _QUEUE_SENTINEL:
                work_queue.task_done()
                break

            chunk = payload["chunk"]
            chunk_number = payload["chunk_number"]
            chunk_rows = payload["chunk_rows"]
            chunk_start = time.perf_counter()

            try:
                messages = _upload_chunk_to_snowflake(
                    conn=snowflake_connection,
                    db=db,
                    schema=schema,
                    tableName=table_name,
                    df=chunk,
                    fileName=f"{table_name}_{serialized_date}_{chunk_number}_{uuid.uuid4()}.csv",
                    fileDate=file_date,
                    i=chunk_number,
                    normalize_nulls=normalize_nulls
                )

                consumer_state["rows_loaded"] += chunk_rows

                _pretty = (
                    f"\nChunk {chunk_number} uploaded \n" +
                    "".join(f"[{index}] {log} | {output}\n" for index, (log, output) in enumerate(messages.items(), 1))
                )
                print(_pretty)

                chunk_elapsed = time.perf_counter() - chunk_start
                if total_rows:
                    pct = (consumer_state["rows_loaded"] / total_rows) * 100
                    bar_filled = int(min(pct, 100) // 5)
                    bar = "#" * bar_filled + "-" * (20 - bar_filled)
                    print(
                        f"  SNOWFLAKE <- QUEUE | [{bar}] {pct:6.2f}%"
                        f"  |  Chunk: {chunk_number}  |  Rows: {consumer_state['rows_loaded']:,} / {total_rows:,}"
                        f" |   TIME : {chunk_elapsed:.2f}s"
                    )
                else:
                    print(
                        f"  SNOWFLAKE <- QUEUE | Chunk: {chunk_number}"
                        f" | Rows: {consumer_state['rows_loaded']:,}"
                        f" | TIME : {chunk_elapsed:.2f}s"
                    )

                if DEBUG:
                    current_mem, peak_mem = tracemalloc.get_traced_memory()
                    print(f" MEM (current): {_format_bytes(current_mem)}  |  MEM (peak): {_format_bytes(peak_mem)}")

            finally:
                del chunk
                work_queue.task_done()

    except Exception as e:
        consumer_state["error"] = e
        consumer_error.set()
    finally:
        if snowflake_connection is not None:
            snowflake_connection.close()


def _run_oracle_queue_pipeline(
    reader,
    table_data,
    run_date,
    serialized_date,
    sf_db,
    sf_schema,
    sf_table,
    total_rows=None,
    add_merge_metadata=False,
    use_safe_string_fallback=False
):
    use_null_normalization = _use_null_normalization(table_data)
    work_queue = Queue(maxsize=QUEUE_MAX_SIZE)
    consumer_state = {"rows_loaded": 0, "error": None}
    consumer_error = Event()
    consumer_thread = Thread(
        target=_snowflake_consumer_worker,
        kwargs={
            "work_queue": work_queue,
            "consumer_state": consumer_state,
            "consumer_error": consumer_error,
            "db": sf_db,
            "schema": sf_schema,
            "table_name": sf_table,
            "serialized_date": serialized_date,
            "file_date": run_date,
            "total_rows": total_rows,
            "normalize_nulls": use_null_normalization,
        },
        daemon=True,
        name=f"snowflake-consumer-{sf_table.lower()}"
    )
    consumer_thread.start()

    producer_error = None

    try:
        reader_iter = iter(reader)
        i = 0

        while True:
            if consumer_error.is_set():
                break

            oracle_fetch_start = time.perf_counter()
            try:
                chunk = next(reader_iter)
            except StopIteration:
                break
            oracle_fetch_elapsed = time.perf_counter() - oracle_fetch_start
            i += 1

            if add_merge_metadata:
                chunk = _add_merge_metadata_columns(
                    chunk=chunk,
                    primary_key=table_data.get("primary_key"),
                    run_date=run_date
                )

            if use_safe_string_fallback:
                chunk = _coerce_chunk_to_strings(chunk)

            chunk_rows = len(chunk)
            queue_put_start = time.perf_counter()
            _enqueue_queue_item(
                work_queue=work_queue,
                item={
                    "chunk_number": i,
                    "chunk": chunk,
                    "chunk_rows": chunk_rows,
                },
                consumer_error=consumer_error
            )
            queue_put_elapsed = time.perf_counter() - queue_put_start
            _log_oracle_queue_put(i, chunk_rows, work_queue, oracle_fetch_elapsed, queue_put_elapsed)
            _maybe_slow_oracle_producer(work_queue, i)

    except Exception as e:
        producer_error = e
    finally:
        reader.close()

        if not consumer_error.is_set():
            _enqueue_queue_item(work_queue, _QUEUE_SENTINEL, consumer_error)

        consumer_thread.join()

    if consumer_state["error"] is not None:
        raise consumer_state["error"]

    if producer_error is not None:
        raise producer_error

    return consumer_state["rows_loaded"]


def _add_merge_metadata_columns(chunk, primary_key, run_date):
    if not primary_key:
        raise ValueError("Primary key not defined for merge full reload")

    key_columns = [item.strip() for item in primary_key.split(",") if item.strip()]
    if not key_columns:
        raise ValueError("Primary key not defined for merge full reload")

    available_columns = {col.upper(): col for col in chunk.columns}
    missing_key_columns = [col for col in key_columns if col.upper() not in available_columns]
    if missing_key_columns:
        raise ValueError(f"Primary key columns not found in source data: {','.join(missing_key_columns)}")

    key_column_names = [available_columns[col.upper()] for col in key_columns]

    chunk["_PRIMARY_TAB_KEY"] = (
        chunk[key_column_names]
        .apply(lambda column: column.map(_stringify_oracle_value))
        .fillna("")
        .astype(str)
        .agg("".join, axis=1)
    )
    chunk["_CHANGE_TYPE"]  = "I"
    chunk["_UDATE"]        = _serialize(run_date, format="%Y%m%d")
    chunk["_UTIME"]        = _serialize(run_date, format="%H%M%S")
    chunk["_DELETE_FLAG"]  = "N"

    metadata_columns = ["_PRIMARY_TAB_KEY", "_CHANGE_TYPE", "_UDATE", "_UTIME", "_DELETE_FLAG"]
    return chunk[metadata_columns + [col for col in chunk.columns if col not in metadata_columns]]


def _run_insert_overwrite(
    connection,
    table_data,
    chunksize,
    run_date,
    control_incremental_value=None,
    add_merge_metadata=False,
    use_snowflake_max_for_incremental_end=False
):
    schema = table_data.get('schema')
    table  = table_data.get('table')
    query, count_query = _build_insert_overwrite_queries(table_data)
    use_safe_string_fallback = _use_safe_string_fallback(table_data)

    with connection.cursor() as cursor:
        cursor.execute(count_query)
        total_rows = cursor.fetchone()[0]

    serialized_date      = _serialize(run_date, format='%Y-%m-%d_%H_%M_%S_%f')
    total_rows_processed = 0

    sf_db      = os.getenv("SNOWFLAKE_LZ")
    sf_schema  = table_data.get("snowflake_schema")
    sf_table   = table_data.get("snowflake_table")
    temp_table = _generate_temp_table_name(sf_table)

    print("=" * 60)
    print(f"  STRATEGY   : INSERT OVERWRITE (via TEMP table)")
    print(f"  SOURCE     : {schema}.{table}")
    print(f"  TEMP TABLE : {sf_db}.{sf_schema}.{temp_table}")
    print(f"  MAIN TABLE : {sf_db}.{sf_schema}.{sf_table}")
    print(f"  TOTAL ROWS : {total_rows:,}")
    print(f"  CHUNK SIZE : {chunksize:,}")
    print(f"  QUEUE SIZE : {'UNBOUNDED' if QUEUE_MAX_SIZE == 0 else f'{QUEUE_MAX_SIZE:,}'}")
    print("=" * 60)

    sf_conn = _connect_to_snowflake(db=sf_db, schema=sf_schema)
    try:
        _drop_stale_temp_tables(sf_conn, sf_db, sf_schema, sf_table)
        _create_temp_table_like(sf_conn, sf_db, sf_schema, sf_table, temp_table)
    finally:
        sf_conn.close()

    if DEBUG:
        tracemalloc.start()

    overall_start = time.perf_counter()
    cold_start    = time.perf_counter()

    if use_safe_string_fallback:
        reader = pd.read_sql(query, con=connection, chunksize=chunksize)
    else:
        reader = pd.read_sql(query, con=connection, chunksize=chunksize, dtype=str)

    cold_start_elapsed = time.perf_counter() - cold_start
    print(f"\n  COLD START from Oracle | TIME: {cold_start_elapsed:.2f}s")

    try:
        total_rows_processed = _run_oracle_queue_pipeline(
            reader=reader,
            table_data=table_data,
            run_date=run_date,
            serialized_date=serialized_date,
            sf_db=sf_db,
            sf_schema=sf_schema,
            sf_table=temp_table,
            total_rows=total_rows,
            add_merge_metadata=add_merge_metadata,
            use_safe_string_fallback=use_safe_string_fallback
        )

        sf_conn_overwrite = _connect_to_snowflake(db=sf_db, schema=sf_schema)
        try:
            _insert_overwrite_from_temp(sf_conn_overwrite, sf_db, sf_schema, sf_table, temp_table)
        finally:
            sf_conn_overwrite.close()

    except Exception:
        print("  ERROR detected — cleaning up TEMP table ...")
        sf_conn_cleanup = None
        try:
            sf_conn_cleanup = _connect_to_snowflake(db=sf_db, schema=sf_schema)
            _drop_temp_table(sf_conn_cleanup, sf_db, sf_schema, temp_table)
        except Exception as cleanup_err:
            print(f"  WARNING: TEMP table cleanup failed | {cleanup_err}")
        finally:
            if sf_conn_cleanup is not None:
                sf_conn_cleanup.close()
        raise

    finally:
        if DEBUG:
            tracemalloc.stop()

    overall_elapsed = time.perf_counter() - overall_start

    sf_conn_drop = _connect_to_snowflake(db=sf_db, schema=sf_schema)
    try:
        _drop_temp_table(sf_conn_drop, sf_db, sf_schema, temp_table)
    finally:
        sf_conn_drop.close()

    overall_start_load_control = time.perf_counter()

    incremental_start_value = control_incremental_value or _serialize(run_date, format="%Y%m%d%H%M%S")
    incremental_end_value   = incremental_start_value

    if use_snowflake_max_for_incremental_end:
        sf_conn_for_query = _connect_to_snowflake(db=sf_db, schema=sf_schema)
        try:
            incremental_end_value = _get_max_incremental_from_snowflake(
                snowflake_conn=sf_conn_for_query,
                db=sf_db,
                schema=sf_schema,
                table=sf_table,
                fallback_date=run_date
            )
        finally:
            sf_conn_for_query.close()

    _load_control_table_status = load_control_table(
        CURRENT_TIMESTAMP=_serialize(run_date, format='%Y-%m-%d %H:%M:%S'),
        Incremental_Start_Value=incremental_start_value,
        Incremental_End_Value=incremental_end_value,
        Extraction_Start_Time=_serialize(run_date, format='%Y-%m-%d %H:%M:%S'),
        Extraction_End_Time=_serialize(datetime.now(), format='%Y-%m-%d %H:%M:%S'),
        MAX_FILE_DATE=_serialize(run_date, format='%Y-%m-%d'),
        rows_loaded=total_rows_processed,
        db=sf_db,
        schema=sf_schema,
        table_name=sf_table
    )

    if _load_control_table_status.get("status") is False:
        raise RuntimeError(
            f"Failed to update load control table"
            f" | STATUS : {_load_control_table_status.get('status')}"
            f" | REASON : {_load_control_table_status.get('message')}"
        )

    overall_elapsed_load_control = time.perf_counter() - overall_start_load_control

    print("=" * 60)
    print(f"  COMPLETE          : {total_rows_processed:,} rows processed")
    print(f"  TOTAL TIME        : {overall_elapsed:.2f}s")
    print(f"  LOAD CONTROL TIME : {overall_elapsed_load_control:.2f}s")
    print("=" * 60)


def _run_merge(connection, table_data, chunksize, run_date, full_load=False):

    sf_db     = os.getenv("SNOWFLAKE_LZ")
    sf_schema = table_data.get("snowflake_schema")
    sf_table  = table_data.get("snowflake_table")
    use_safe_string_fallback = _use_safe_string_fallback(table_data)

    if full_load:
        if not table_data.get("primary_key"):
            raise ValueError(
                f"Primary key not defined for table {table_data.get('schema')}.{table_data.get('table')}"
            )

        sf_conn_for_query = _connect_to_snowflake(db=sf_db, schema=sf_schema)
        try:
            incremental_end_date = _get_max_incremental_from_snowflake(
                snowflake_conn=sf_conn_for_query,
                db=sf_db,
                schema=sf_schema,
                table=sf_table,
                fallback_date=run_date
            )
        finally:
            sf_conn_for_query.close()

        incremental_end_date = (
            datetime.strptime(incremental_end_date, "%Y%m%d%H%M%S") - timedelta(days=1)
        ).strftime("%Y%m%d%H%M%S")

        print(f"  FULL LOAD CONTROL DATE : {incremental_end_date}")
        _run_insert_overwrite(
            connection,
            table_data,
            chunksize,
            run_date,
            control_incremental_value=incremental_end_date,
            add_merge_metadata=True,
            use_snowflake_max_for_incremental_end=True
        )

    else:
        schema      = table_data.get('schema')
        table       = table_data.get('table')
        primary_key = table_data.get('primary_key')

        if not primary_key:
            raise ValueError(f"Primary key not defined for table {schema}.{table}")

        control_table_entry, function_messages = readControlTable(
            db=sf_db,
            schema=sf_schema,
            table_name=sf_table
        )

        if control_table_entry:
            last_extraction_time = _serialize(control_table_entry, format="%Y%m%d%H%M%S")
        else:
            last_extraction_time = _serialize('1990-01-01', format="%Y%m%d%H%M%S")

        update_date_part = last_extraction_time[:8]
        update_time_part = last_extraction_time[8:]

        query = _MERGE_QUERY.format(
            schema=schema,
            table=table,
            primary_key=" || ".join(f"KEY.{item}" for item in primary_key.split(",")),
            update_date_part=update_date_part,
            update_time_part=update_time_part
        )

        serialized_date      = _serialize(run_date, format='%Y-%m-%d_%H_%M_%S_%f')
        total_rows_processed = 0

        print("=" * 60)
        print(f"  STRATEGY              : MERGE")
        print(f"  TABLE                 : {schema}.{table}")
        print(f"  CHUNK SIZE            : {chunksize:,}")
        print(f"  QUEUE SIZE            : {'UNBOUNDED' if QUEUE_MAX_SIZE == 0 else f'{QUEUE_MAX_SIZE:,}'}")
        print(f"  LAST EXTRACTION DATE  : {last_extraction_time}")
        print(f"  QUERY                 : {query}")
        print("=" * 60)

        if DEBUG:
            tracemalloc.start()

        overall_start = time.perf_counter()
        cold_start    = time.perf_counter()

        if use_safe_string_fallback:
            reader = pd.read_sql(query, con=connection, chunksize=chunksize)
        else:
            reader = pd.read_sql(query, con=connection, chunksize=chunksize, dtype=str)

        cold_start_elapsed = time.perf_counter() - cold_start
        print(f"\n COLD START from Oracle | TIME: {cold_start_elapsed:.2f}s")

        try:
            total_rows_processed = _run_oracle_queue_pipeline(
                reader=reader,
                table_data=table_data,
                run_date=run_date,
                serialized_date=serialized_date,
                sf_db=sf_db,
                sf_schema=sf_schema,
                sf_table=sf_table,
                use_safe_string_fallback=use_safe_string_fallback
            )
        finally:
            if DEBUG:
                tracemalloc.stop()

        overall_elapsed = time.perf_counter() - overall_start
        overall_start_load_control = time.perf_counter()

        print('*' * 60)
        print(f"\n  UPDATING LOAD CONTROL TABLE FOR {sf_table} ...\n")

        sf_conn_for_query = _connect_to_snowflake(db=sf_db, schema=sf_schema)
        try:
            incremental_end_date = _get_max_incremental_from_snowflake(
                snowflake_conn=sf_conn_for_query,
                db=sf_db,
                schema=sf_schema,
                table=sf_table,
                fallback_date=run_date
            )
        finally:
            sf_conn_for_query.close()

        print(f"  INCREMENTAL END DATE (from Snowflake LZ) : {incremental_end_date}\n")

        _load_control_table_status = load_control_table(
            CURRENT_TIMESTAMP=_serialize(run_date, format='%Y-%m-%d %H:%M:%S'),
            Incremental_Start_Value=last_extraction_time,
            Incremental_End_Value=incremental_end_date,
            Extraction_Start_Time=_serialize(run_date, format='%Y-%m-%d %H:%M:%S'),
            Extraction_End_Time=_serialize(datetime.now(), format='%Y-%m-%d %H:%M:%S'),
            MAX_FILE_DATE=_serialize(run_date, format='%Y-%m-%d'),
            rows_loaded=total_rows_processed,
            db=sf_db,
            schema=sf_schema,
            table_name=sf_table
        )

        if _load_control_table_status.get("status") is False:
            raise RuntimeError(
                f"Failed to update load control table"
                f" | STATUS : {_load_control_table_status.get('status')}"
                f" | REASON : {_load_control_table_status.get('message')}"
            )

        overall_elapsed_load_control = time.perf_counter() - overall_start_load_control

        print(f"\n  LOAD CONTROL STATUS : {_load_control_table_status.get('status')}")
        print('*' * 60)

        print("=" * 60)
        print(f"  COMPLETE   : {total_rows_processed:,} rows processed")
        print(f"  TOTAL TIME : {overall_elapsed:.2f}s")
        print(f"  LOAD CONTROL TIME : {overall_elapsed_load_control:.2f}s")
        print("=" * 60)


def _build_parser():
    parser = ArgumentParser(description="Extract data from Oracle and upload to Snowflake")
    parser.add_argument("--config-file",      required=True,  help="Path to the JSON configuration file")
    parser.add_argument("--extraction-name",   required=True,  help="Name of the extraction configuration to use")
    parser.add_argument("--env",               required=True,  help="Environment to use for secret retrieval (e.g., dev, prod)")
    parser.add_argument("--chunk-size",        type=int, default=200_000, help="Number of records per chunk")
    parser.add_argument("--run-date",          type=lambda s: _serialize(s), required=False, default=None, help="Run date e.g. '2024-01-15 14:30:45'")
    parser.add_argument("--full-reload",       type=_parse_bool, required=False, default=False, help="Full reload flag")
    parser.add_argument("--queue-max-size",    type=_parse_queue_max_size, required=False, default=5, help="Maximum Oracle-to-Snowflake queue size. Use 0 for unbounded queue")
    parser.add_argument("--debug",             type=_parse_bool, required=False, default=False, help="Enable debug mode")
    return parser


def main(config_file, extraction_name, env, chunk_size=200_000, run_date=None, full_reload=False, debug=False, queue_max_size=0):
    global DEBUG, QUEUE_MAX_SIZE

    ENV            = env
    CHUNK_SIZE     = chunk_size
    RUN_DATE       = run_date if run_date is not None else datetime.now().replace(microsecond=0)
    FULL_RELOAD    = bool(full_reload)
    DEBUG          = bool(debug)
    QUEUE_MAX_SIZE = _parse_queue_max_size(queue_max_size)

    if DEBUG:
        print(f"-> Debug mode enabled")
        print(f"    -Config file path: {config_file}")
        print(f"    -Extraction name: {extraction_name}")
        print(f"    -Environment: {ENV}")
        print(f"    -Chunk size: {CHUNK_SIZE}")
        print(f"    -Queue max size: {QUEUE_MAX_SIZE} ({'unbounded' if QUEUE_MAX_SIZE == 0 else 'bounded'})")
        print(f"    -Run date: {RUN_DATE}")
        print(f"    -Full reload: {FULL_RELOAD}")

    try:
        _configuration = _open_configurations(config_file)
    except FileNotFoundError:
        raise FileNotFoundError(f"Config file not found | PATH : {config_file}")
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in config file | PATH : {config_file} | REASON : {e}") from e

    table_data = next(_collect_active_configurations(_configuration, extraction_name), None)

    if table_data is None:
        raise ValueError(
            f"No active configuration found"
            f" | Extraction Name : {extraction_name}"
            f" | Config File     : {config_file}"
        )

    try:
        connection = get_oracle_connection(_configuration, ENV)
    except oracledb.DatabaseError as e:
        raise ConnectionError(f"Oracle Database error | ENV : {ENV} | REASON : {e}") from e
    except Exception as e:
        raise ConnectionError(f"Unexpected error during Oracle connection | ENV : {ENV} | REASON : {e}") from e

    try:
        if table_data.get('incremental_strategy') == "insert_overwrite":
            _run_insert_overwrite(connection, table_data, CHUNK_SIZE, RUN_DATE)

        elif table_data.get('incremental_strategy') == "merge":
            _run_merge(connection, table_data, CHUNK_SIZE, RUN_DATE, full_load=FULL_RELOAD)

        else:
            raise NotImplementedError(
                f"Incremental strategy not supported"
                f" | STRATEGY : {table_data.get('incremental_strategy')}"
                f" | TABLE    : {table_data.get('schema')}.{table_data.get('table')}"
            )

    except RuntimeError as e:
        raise RuntimeError(
            f"Strategy failed | TABLE : {table_data.get('schema')}.{table_data.get('table')} | REASON : {e}"
        ) from e
    except Exception as e:
        raise RuntimeError(
            f"Unexpected error | TABLE : {table_data.get('schema')}.{table_data.get('table')} | REASON : {e}"
        ) from e
    finally:
        connection.close()


if __name__ == "__main__":
    parser = _build_parser()
    args = parser.parse_args()
    main(
        config_file=args.config_file,
        extraction_name=args.extraction_name,
        env=args.env,
        chunk_size=args.chunk_size,
        run_date=args.run_date,
        full_reload=args.full_reload,
        debug=args.debug,
        queue_max_size=args.queue_max_size
    )
