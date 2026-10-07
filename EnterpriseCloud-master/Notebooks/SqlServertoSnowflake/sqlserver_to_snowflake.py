"""
sqlserver_to_snowflake.py
=========================

Generate Snowflake landing DDL, dbt bronze models, dbt source YAML, and the
TelTools extract / connector configs from a SQL Server source - driven by a
single PipelineConfig object.

=========================
"""

from __future__ import annotations

import json
import re
from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional

try:
    import yaml
except ImportError:
    yaml = None


MSSQL_TO_SNOWFLAKE: dict[str, str] = {
    "bit": "BOOLEAN",
    "tinyint": "NUMBER(38,2)",
    "smallint": "NUMBER(38,2)",
    "int": "NUMBER(38,2)",
    "bigint": "NUMBER(38,2)",
    "decimal": "NUMBER(38,2)",
    "numeric": "NUMBER(38,2)",
    "money": "NUMBER(38,2)",
    "smallmoney": "NUMBER(38,2)",
    "float": "FLOAT",
    "real": "FLOAT",
    "date": "DATE",
    "time": "TIME",
    "datetime": "TIMESTAMP_NTZ",
    "datetime2": "TIMESTAMP_NTZ",
    "smalldatetime": "TIMESTAMP_NTZ",
    "datetimeoffset": "TIMESTAMP_NTZ",
    "char": "CHAR",
    "varchar": "VARCHAR",
    "text": "VARCHAR",
    "nchar": "CHAR",
    "nvarchar": "VARCHAR",
    "ntext": "VARCHAR",
    "binary": "BINARY",
    "varbinary": "BINARY",
    "image": "BINARY",
    "cursor": "VARCHAR",
    "geography": "GEOGRAPHY",
    "geometry": "GEOGRAPHY",
    "hierarchyid": "VARCHAR",
    "json": "VARIANT",
    "vector": "VECTOR",
    "rowversion": "BINARY",
    "sql_variant": "VARIANT",
    "table": "VARIANT",
    "uniqueidentifier": "VARCHAR",
    "xml": "VARCHAR",
}

_DATE_LIKE = {"TIMESTAMP_NTZ", "TIMESTAMP_TZ", "DATE"}

def map_sql_type(sql_type: str) -> str:
    return MSSQL_TO_SNOWFLAKE.get(sql_type.lower(), "VARCHAR")


def normalize_identifier(text: str) -> str:
    if text.strip() == "%":
        return "PERCENT"
    s = re.sub(r"[^a-zA-Z0-9]", "_", text).strip("_")
    s = re.sub(r"_+", "_", s)
    if s and s[0].isdigit():
        return f'"{s.upper()}"'
    return s.upper()

@dataclass
class PipelineConfig:

    server: str
    database: str
    connection_name: str
    password_name: str
    landing_schema: str
    dbt_subfolder: str
    repo_root: Path
    tables: list[tuple]

    username: Optional[str] = None
    password: Optional[str] = None
    driver: str = "{SQL Server Native Client 11.0}"
    retry_count: int = 5
    retry_delay: int = 60

    landing_db: str = "LZ_DEV"
    dbt_project: str = "dbt_tel"
    dbt_source_name: Optional[str] = None

    model_prefix: Optional[str] = None
    model_alias_prefix: Optional[str] = None

    bronze_db: Optional[str] = None
    bronze_schema: Optional[str] = None

    bronze_tests: list[str] = None
    bronze_tests_filename: Optional[str] = None

    lz_role: str = "SYSADMIN_DEV"
    bronze_role: str = "PLATFORM_TEAM_DEV"

    snow_ticket: str = "K.41xxx"
    ingestion_label: Optional[str] = None
    lz_seq: int = 1
    bronze_seq: int = 2

    def __post_init__(self) -> None:
        self.repo_root = Path(self.repo_root)
        if self.dbt_source_name is None:
            self.dbt_source_name = self.landing_schema
        # if self.model_prefix is None:
        #     self.model_prefix = self.landing_schema
        # if self.model_alias_prefix is None:
        #     self.model_alias_prefix = self.landing_schema
        if self.bronze_db is None:
            self.bronze_db = self.landing_db
        if self.bronze_schema is None:
            self.bronze_schema = self.landing_schema
        if self.ingestion_label is None:
            self.ingestion_label = self.landing_schema.lower()
        if self.bronze_tests is None:
            self.bronze_tests = ["has_data", "recently_run"]
        if self.bronze_tests_filename is None:
            self.bronze_tests_filename = f"_{self.dbt_source_name.lower()}__bronze.yml"

    @property
    def trusted_connection(self) -> str:
        return "no" if self.username else "yes"

    @property
    def alias_prefix(self) -> str:
        return (self.model_alias_prefix or "").strip().upper()

    def with_alias_prefix(self, name: str) -> str:
        """Join alias_prefix + '_' + name, but if alias_prefix is blank/None
        just return name unchanged (no stray leading underscore)."""
        seg = self.alias_prefix
        return f"{seg}_{name}" if seg else name

    @property
    def bronze_prefix(self) -> str:
        base = f"BRONZE__{self.dbt_subfolder}".upper()
        seg = (self.model_prefix or "").strip().upper()
        return f"{base}__{seg}" if seg else base

    def bronze_model_stem(self, sf_table: str) -> str:
        base = f"BRONZE__{self.dbt_subfolder}".upper()
        seg = (self.model_prefix or "").strip().upper()
        table = sf_table.upper()
        return f"{base}__{seg}_{table}" if seg else f"{base}__{table}"

    @property
    def _models_path(self) -> Path:
        return self.repo_root / "astro_datautility" / "dags" / "dbt" / self.dbt_project / "models"

    @property
    def bronze_path(self) -> Path:
        return self._models_path / self.dbt_subfolder.lower() / "bronze"

    @property
    def bronze_tests_yaml_file(self) -> Path:
        return self.bronze_path / self.bronze_tests_filename

    @property
    def source_path(self) -> Path:
        return self._models_path / "_src"

    @property
    def source_yaml_file(self) -> Path:
        return self.source_path / f"{self.dbt_source_name.lower()}.yml"

    @property
    def _config_dir(self) -> Path:
        return self.repo_root / "astro_datautility" / "include" / "Configuration"

    @property
    def master_config_file(self) -> Path:
        return self._config_dir / "TelTools_SQLServer_Connectors.json"

    @property
    def extract_config_file(self) -> Path:
        return self._config_dir / f"TelTools_SQLServer_{self.connection_name}_Extract.json"

    @property
    def snow_dir(self) -> Path:
        return self.repo_root / "Snow"

    @property
    def lz_snow_file(self) -> Path:
        return self.snow_dir / f"{self.snow_ticket}__{self.lz_seq}.lz_{self.ingestion_label}__data.SQL"

    @property
    def bronze_snow_file(self) -> Path:
        return self.snow_dir / f"{self.snow_ticket}__{self.bronze_seq}.bronze_{self.ingestion_label}__data.SQL"

    def pyodbc_kwargs(self) -> dict:
        kw = {
            "Server": self.server,
            "Database": self.database,
            "Trusted_Connection": self.trusted_connection,
        }
        if self.username:
            kw["user"] = self.username
            kw["password"] = self.password
        return kw

@dataclass
class TableMeta:
    database: str
    schema: str
    table: str
    columns: "OrderedDict[str, str]"
    row_count: Optional[int] = None

    @property
    def sf_table(self) -> str:
        return self.table.upper()

    @property
    def load_keys(self) -> list[str]:
        return list(self.columns.keys())


class SqlServerInspector:

    def __init__(self, cfg: PipelineConfig):
        self.cfg = cfg
        self._conn = None

    def __enter__(self) -> "SqlServerInspector":
        import pyodbc
        import struct
        import datetime
        from datetime import timedelta, timezone

        def _handle_datetimeoffset(value):
            y, mo, d, h, mi, s, frac_ns, tz_min = struct.unpack("<hhhhhhIh", value[:18])
            return datetime.datetime(
                y, mo, d, h, mi, s, frac_ns // 1000,
                tzinfo=timezone(timedelta(minutes=tz_min)),
            ).isoformat()

        self._conn = pyodbc.connect(f"Driver={self.cfg.driver};", **self.cfg.pyodbc_kwargs())
        self._conn.add_output_converter(-155, _handle_datetimeoffset)
        return self

    def __exit__(self, *exc) -> bool:
        if self._conn is not None:
            self._conn.close()
            self._conn = None
        return False

    def _table_exists(self, db: str, schema: str, table: str) -> bool:
        cur = self._conn.cursor()
        try:
            cur.execute(
                f"SELECT 1 FROM {db}.INFORMATION_SCHEMA.TABLES "
                f"WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?",
                schema, table,
            )
            return cur.fetchone() is not None
        finally:
            cur.close()

    def _columns(self, db: str, schema: str, table: str) -> "OrderedDict[str, str]":
        cur = self._conn.cursor()
        try:
            cur.execute(
                f"SELECT COLUMN_NAME, DATA_TYPE FROM {db}.INFORMATION_SCHEMA.COLUMNS "
                f"WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION",
                schema, table,
            )
            return OrderedDict((name, map_sql_type(dtype)) for name, dtype in cur.fetchall())
        finally:
            cur.close()

    def _row_count(self, db: str, schema: str, table: str) -> int:
        cur = self._conn.cursor()
        try:
            cur.execute(f"SELECT COUNT(*) FROM {db}.{schema}.{table}")
            return int(cur.fetchone()[0])
        finally:
            cur.close()

    def inspect(self, with_counts: bool = False) -> list[TableMeta]:
        metas: list[TableMeta] = []
        for db, schema, table in self.cfg.tables:
            if not self._table_exists(db, schema, table):
                raise LookupError(f"Object missing in DB: [{db}].[{schema}].[{table}]")
            cols = self._columns(db, schema, table)
            count = self._row_count(db, schema, table) if with_counts else None
            metas.append(TableMeta(db, schema, table, cols, count))
        return metas

def landing_ddl(meta: TableMeta, cfg: PipelineConfig) -> str:
    fq = f"{cfg.landing_db}.{cfg.landing_schema.upper()}.{meta.sf_table}"
    return (
        f"CREATE OR REPLACE TABLE {fq} (\n"
        f"    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',\n"
        f"    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',\n"
        f"    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',\n"
        f"    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'\n"
        f")\n"
        f"COMMENT = 'Landing table for [{meta.database}].[{meta.schema}].[{meta.table}]';"
    )


def bronze_ddl(meta: TableMeta, cfg: PipelineConfig) -> str:
    fq = f"{cfg.bronze_db}.{cfg.bronze_schema.upper()}.{cfg.with_alias_prefix(meta.sf_table)}"
    housekeeping = [
        "\t_FILEDATE TIMESTAMP_NTZ(9)",
        "\t_FILENAME VARCHAR",
        "\t_UPLOADDATE VARCHAR",
        "\t_AUDIT_LOG_ID VARCHAR(128)",
        "\t_ROW_HASH VARCHAR(128)",
    ]
    columns = [
        f"\t{normalize_identifier(col.upper())} {sf_type}"
        for col, sf_type in meta.columns.items()
    ]
    body = ",\n".join(housekeeping + columns)
    return (
        f"CREATE OR REPLACE TABLE {fq} (\n{body}\n)\n"
        f"COMMENT = 'Bronze table for [{meta.database}].[{meta.schema}].[{meta.table}]';"
    )


def bronze_model(meta: TableMeta, cfg: PipelineConfig) -> str:
    src = cfg.dbt_source_name
    source_table = meta.sf_table
    keys = meta.load_keys
    sf_type = {k.lower(): v for k, v in meta.columns.items()}

    L: list[str] = []
    L.append("/************")
    L.append(" Model file generated by the SQLServerToSnowflake utility.")
    L.append(" Do not edit by hand - regenerate instead.")
    L.append("*************/\n")
    L.append("{{ config(")
    L.append("\tmaterialized='tel_incremental',")
    L.append("\tincremental_strategy='insert_overwrite',")
    L.append(f"\talias='{cfg.with_alias_prefix(source_table)}',")
    L.append("\ttransient=false,")
    L.append(f'\ttags=["{cfg.alias_prefix}"]' if cfg.alias_prefix else "\ttags=[]")
    L.append(") }}\n")

    L.append("with source_data as (")
    L.append("\tSELECT")
    L.append("\t\t_FILEDATE,")
    L.append("\t\t_FILENAME,")
    L.append("\t\t_UPLOADDATE,")
    for col in keys:
        dtype = sf_type.get(col.lower(), "VARCHAR")
        ident = normalize_identifier(col.upper())
        if dtype in _DATE_LIKE:
            L.append(
                f"\t\tREGEXP_REPLACE(JSONFIELD:\"{col}\", "
                f"'\\/Date\\\\(|\\\\)\\/', '')::{dtype} AS {ident},"
            )
        else:
            L.append(f'\t\tJSONFIELD:"{col}"::{dtype} AS {ident},')
    L[-1] = L[-1].rstrip(",")
    L.append(f'\tFROM {{{{ source("{src}", "{source_table}") }}}}')
    L.append(
        "\tWHERE _FILEDATE = ("
        f"SELECT MAX(RUN_TIME) FROM {{{{ source('{src}', 'CONTROLTABLE') }}}} "
        f"WHERE TABLE_NAME ILIKE '%{source_table}%')"
    )
    L.append("),\n")

    # hash_parts = ", ".join(f"TO_VARCHAR({normalize_identifier(c.upper())})" for c in keys)
    # hash_expr = f"SHA2(CONCAT_WS('||', {hash_parts}))" if keys else "SHA2('')"
    L.append("transform_data as (")
    L.append("\tSELECT")
    L.append("\t\t_FILEDATE,")
    L.append("\t\t_FILENAME,")
    L.append("\t\t_UPLOADDATE,")
    L.append("\t\t'{{ invocation_id }}' AS _AUDIT_LOG_ID,")
    L.append(f"\t\tSHA2('hash_me') AS _ROW_HASH,")
    for col in keys:
        L.append(f"\t\t{normalize_identifier(col.upper())},")
    L[-1] = L[-1].rstrip(",")
    L.append("\tFROM source_data")
    L.append("),\n")

    L.append("type_data as (")
    L.append("\tSELECT")
    L.append("\t\tCAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,")
    L.append("\t\t_FILENAME,")
    L.append("\t\t_UPLOADDATE,")
    L.append("\t\tCAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,")
    L.append("\t\tCAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,")
    for col in keys:
        ident = normalize_identifier(col.upper())
        dtype = sf_type.get(col.lower(), "VARCHAR")
        if dtype != "VARCHAR":
            L.append(f"\t\tCAST({ident} AS {dtype}) AS {ident},")
        else:
            L.append(f"\t\t{ident},")
    L[-1] = L[-1].rstrip(",")
    L.append("\tFROM transform_data")
    L.append(")\n")

    L.append("SELECT * FROM type_data")
    return "\n".join(L)


def bronze_model_filename(meta: TableMeta, cfg: PipelineConfig) -> str:
    return f"{cfg.bronze_model_stem(meta.sf_table)}.sql"


def bronze_model_name(meta: TableMeta, cfg: PipelineConfig) -> str:
    return cfg.bronze_model_stem(meta.sf_table)

def _read_json(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {}


def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def build_master_connector(cfg: PipelineConfig) -> dict:
    data = _read_json(cfg.master_config_file)
    data[cfg.connection_name] = {
        "connections": cfg.connection_name.lower(),
        "servername": cfg.server,
        "database": cfg.database,
        "username": cfg.username,
        "password": cfg.password_name,
        "outputfolder": cfg.connection_name.lower(),
    }
    return data


def build_extract_config(cfg: PipelineConfig, metas: Iterable[TableMeta],
                         mode: str = "merge") -> dict:
 
    data = _read_json(cfg.extract_config_file)
    existing = data.get(cfg.connection_name, {}) if mode == "merge" else {}

    by_identity: "OrderedDict[tuple, dict]" = OrderedDict()
    for ds in existing.values():
        by_identity[(ds.get("schema"), ds.get("table"))] = ds

    for m in metas:
        by_identity[(m.schema, m.table)] = {
            "schema": m.schema,
            "table": m.table,
            "Incremental": "NULL",
            "sftablename": m.sf_table,
            "filter": "",
        }

    data[cfg.connection_name] = {
        f"DataSet{i}": ds for i, ds in enumerate(by_identity.values(), start=1)
    }
    return data


def build_source_doc(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> dict:

    doc: dict = {}
    if cfg.source_yaml_file.exists() and yaml is not None:
        loaded = yaml.safe_load(cfg.source_yaml_file.read_text(encoding="utf-8"))
        if isinstance(loaded, dict):
            doc = loaded

    version = doc.get("version", 2)
    sources = doc.get("sources") or []

    src_name = cfg.dbt_source_name.upper()
    block = next((s for s in sources if s.get("name") == src_name), None)
    if block is None:
        block = {
            "name": src_name,
            "description": f"Landing Zone - For {src_name} Schema",
            "database": "{{ env_var('SNOWFLAKE_LZ') }}",
            "schema": cfg.landing_schema.upper(),
            "tables": [],
        }
        sources.append(block)

    block.setdefault("tables", [])
    tables_by_name = OrderedDict((t["name"], t) for t in block["tables"])
    for m in metas:
        tables_by_name[m.sf_table] = {
            "name": m.sf_table,
            "identifier": m.sf_table,
            "description": (
                f"Landing table for {m.sf_table} from SQLServer "
                f"[{m.database}].[{m.schema}].[{m.table}]"
            ),
        }
    block["tables"] = list(tables_by_name.values())

    rebuilt = {"version": version, "sources": sources}
    for key, value in doc.items():
        if key not in rebuilt:
            rebuilt[key] = value
    return rebuilt


def build_bronze_tests_doc(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> dict:
    doc: dict = {}
    if cfg.bronze_tests_yaml_file.exists() and yaml is not None:
        loaded = yaml.safe_load(cfg.bronze_tests_yaml_file.read_text(encoding="utf-8"))
        if isinstance(loaded, dict):
            doc = loaded

    version = doc.get("version", 2)
    models = doc.get("models") or []

    models_by_name = OrderedDict((m.get("name"), m) for m in models if m.get("name"))
    for meta in metas:
        name = bronze_model_name(meta, cfg)
        entry = models_by_name.get(name, {"name": name})
        entry["name"] = name
        entry["tests"] = list(cfg.bronze_tests)
        models_by_name[name] = entry

    rebuilt = {"version": version, "models": list(models_by_name.values())}
    for key, value in doc.items():
        if key not in rebuilt:
            rebuilt[key] = value
    return rebuilt


def build_extract_commands(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> list[str]:
    cfg_path = cfg.extract_config_file
    return [
        f"python -m include.Python.TelTools_SQLServer {cfg_path} {m.table}"
        for m in metas
    ]

def write_master_connector(cfg: PipelineConfig) -> Path:
    _write_text(cfg.master_config_file, json.dumps(build_master_connector(cfg), indent=2))
    return cfg.master_config_file


def write_extract_config(cfg: PipelineConfig, metas: Iterable[TableMeta],
                         mode: str = "merge") -> Path:
    metas = list(metas)
    _write_text(cfg.extract_config_file,
                json.dumps(build_extract_config(cfg, metas, mode), indent=2))
    return cfg.extract_config_file


def write_source_yaml(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> Path:
    if yaml is None:
        raise RuntimeError("PyYAML is required to write the source YAML (pip install pyyaml).")
    doc = build_source_doc(cfg, list(metas))
    _write_text(cfg.source_yaml_file, yaml.safe_dump(doc, sort_keys=False))
    return cfg.source_yaml_file


def write_bronze_tests_yaml(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> Path:
    if yaml is None:
        raise RuntimeError("PyYAML is required to write the bronze tests YAML (pip install pyyaml).")
    doc = build_bronze_tests_doc(cfg, list(metas))
    _write_text(cfg.bronze_tests_yaml_file, yaml.safe_dump(doc, sort_keys=False))
    return cfg.bronze_tests_yaml_file


def write_bronze_models(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> list[Path]:
    written: list[Path] = []
    for m in metas:
        path = cfg.bronze_path / bronze_model_filename(m, cfg)
        _write_text(path, bronze_model(m, cfg))
        written.append(path)
    return written


def apply_env_tokens(sql: str, cfg: PipelineConfig, layer: str = "lz") -> str:
    roles = [
        (cfg.bronze_role, "<<PLATFORM_TEAM>>"),
        (cfg.lz_role, "<<SYSADMIN>>"),
    ]
    dbs = [(cfg.bronze_db, "<<BRONZE>>")] if layer == "bronze" else [(cfg.landing_db, "<<LZ>>")]
    for src, token in roles + dbs:
        sql = re.sub(rf"(?i)\b{re.escape(src)}\b", token, sql)
    return sql


def write_lz_ddl(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> Path:

    body = "\n\n".join(landing_ddl(m, cfg) for m in metas)
    sql = apply_env_tokens(f"USE ROLE {cfg.lz_role};\n\n{body}\n", cfg, layer="lz")
    _write_text(cfg.lz_snow_file, sql)
    return cfg.lz_snow_file


def write_bronze_ddl(cfg: PipelineConfig, metas: Iterable[TableMeta]) -> Path:

    body = "\n\n".join(bronze_ddl(m, cfg) for m in metas)
    sql = apply_env_tokens(f"USE ROLE {cfg.bronze_role};\n\n{body}\n", cfg, layer="bronze")
    _write_text(cfg.bronze_snow_file, sql)
    return cfg.bronze_snow_file