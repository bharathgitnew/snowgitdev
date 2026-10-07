"""
sap_to_snowflake.py
===================

From a list of SAP tables, generate everything to land + model them in
Snowflake/dbt, using the SAP data dictionary (DD02L/DD02T/DD03L/DD04T) as the
source of truth. Mirrors the SQLServer->Snowflake architecture.

Per table it produces:
  1. LZ landing snowfile   — typed CREATE TABLE(s), role header + env tokens
  2. dbt BRONZE model      — source(), technical names, audit cols, optional
                             soft-delete capture (IS_DELETED via {{ this }})
  3. dbt SILVER model      — ref(bronze), business names + max-type casts
  4. dbt SOURCE yaml       — _src/<source>.yml entries (upserted)
  5. Table-config entry    — upserted under the "extraction" key of
                             TelTools_SapR3_<config_prefix>.json
Plus a runnable getSapR3Data extract command per table.

Edit the SapModelConfig in the notebook; this file holds the logic. Snowflake is
only imported inside connect()/fetch_* so the generators unit-test offline.
"""
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

try:
    import yaml
except ImportError:
    yaml = None



def connect(connect_kwargs: dict):
    """Open a Snowflake connection from details defined in the notebook
    (cfg.connection), e.g. account / user / authenticator / warehouse / role."""
    if not connect_kwargs:
        raise ValueError(
            "No Snowflake connection details provided. Set connection={...} in the "
            "SapModelConfig in your notebook."
        )
    import snowflake.connector as sc
    return sc.connect(**connect_kwargs)


@dataclass
class SapModelConfig:

    connection: dict = field(default_factory=dict)

    # --- snowflake locations ---
    lz_database: str = "LZ_DEV"                  # DD tables + landing tables; -> <<LZ>>
    dd_schema: str = "SAP_ORACLE_LIVE"           # where DD02L/DD03L/... live
    source_name: str = "SAP_ORACLE_LIVE"         # dbt source() name
    snowflake_schema: str = "SAP_ORACLE_LIVE"    # landing schema (DDL + table cfg)
    sap_schema: str = "SAPR3"                     # SAP source schema (table cfg)

    # --- dbt / repo ---
    repo_root: Path = Path(r"C:\EnterpriseCloud")
    dbt_project: str = "dbt_tel"
    dbt_subfolder: str = "TMEA_MANUFACTURING"    # models/<subfolder>/{bronze,silver}
    source_prefix: str = "SAPO"                  # bronze alias prefix

    # --- behavior ---
    incremental_strategy: str = "insert_overwrite"   # default; override per table
    capture_deletes: bool = False                # soft-delete capture (per-table override)
    chunk_size: int = 75000
    use_safe_string_fallback: bool = True
    silver_numeric_scale: int = 10               # NUMBER(38,<scale>) in silver
    default_df_scale: int = 6

    # --- table-config file: TelTools_SapR3_<config_prefix>.json ---
    config_prefix: str = "InsertOverwrite"       # e.g. "OneTimeLoad"
    config_root_key: str = "extraction"          # entries nested under this key ("" = flat)

    # --- snowfile (roles + env tokens, mirrors the SQLServer engine) ---
    snow_ticket: str = "K.41xxx"
    lz_seq: int = 1
    bronze_seq: int = 2
    silver_seq: int = 3
    ingestion_label: Optional[str] = None        # defaults to dbt_subfolder.lower()
    lz_role: str = "SYSADMIN_DEV"                # -> <<SYSADMIN>>
    bronze_role: str = "PLATFORM_TEAM_DEV"       # -> <<PLATFORM_TEAM>>
    silver_role: str = "PLATFORM_TEAM_DEV"       # -> <<PLATFORM_TEAM>>

    # --- bronze / silver physical table location (default to landing) ---
    bronze_db: Optional[str] = None              # defaults to lz_database
    bronze_schema: Optional[str] = None          # defaults to snowflake_schema
    silver_db: Optional[str] = None              # defaults to lz_database
    silver_schema: Optional[str] = None          # defaults to snowflake_schema

    # --- extract runner (getSapR3Data) ---
    extract_module: str = "include.Python.getSapR3Data"
    extract_env: str = "PROD"
    extract_debug: bool = False
    extract_chunk_size: Optional[int] = None     # defaults to chunk_size

    # --- tables: "CDPOS" or {"table","friendly","strategy","capture_deletes"} ---
    tables: list = field(default_factory=list)

    def __post_init__(self):
        self.repo_root = Path(self.repo_root)
        if self.ingestion_label is None:
            self.ingestion_label = self.dbt_subfolder.lower()
        if self.bronze_db is None:
            self.bronze_db = self.lz_database
        if self.bronze_schema is None:
            self.bronze_schema = self.snowflake_schema
        if self.silver_db is None:
            self.silver_db = self.lz_database
        if self.silver_schema is None:
            self.silver_schema = self.snowflake_schema

    @property
    def _models_path(self) -> Path:
        return (self.repo_root / "astro_datautility" / "dags" / "dbt"
                / self.dbt_project / "models")

    @property
    def models_root(self) -> Path:
        return self._models_path / self.dbt_subfolder.lower()

    @property
    def bronze_dir(self) -> Path:
        return self.models_root / "bronze"

    @property
    def silver_dir(self) -> Path:
        return self.models_root / "silver"

    @property
    def source_yaml_file(self) -> Path:
        return self._models_path / "_src" / f"{self.source_name.lower()}.yml"

    @property
    def snow_dir(self) -> Path:
        return self.repo_root / "Snow"

    @property
    def lz_snow_file(self) -> Path:
        return self.snow_dir / f"{self.snow_ticket}__{self.lz_seq}.lz_{self.ingestion_label}__data.SQL"

    @property
    def bronze_snow_file(self) -> Path:
        return self.snow_dir / f"{self.snow_ticket}__{self.bronze_seq}.bronze_{self.ingestion_label}__data.SQL"

    @property
    def silver_snow_file(self) -> Path:
        return self.snow_dir / f"{self.snow_ticket}__{self.silver_seq}.silver_{self.ingestion_label}__data.SQL"

    @property
    def table_config_file(self) -> Path:
        return (self.repo_root / "astro_datautility" / "include" / "Configuration"
                / f"TelTools_SapR3_{self.config_prefix}.json")

    def bronze_ref(self, friendly: str) -> str:
        return f"BRONZE__{self.dbt_subfolder}__{self.source_prefix}_{friendly}"

    def bronze_alias(self, friendly: str) -> str:
        return f"{self.source_prefix}_{friendly}"

    def silver_ref(self, friendly: str) -> str:
        return f"SILVER__{self.dbt_subfolder}__{friendly}"


def normalize_table_spec(spec, cfg: "SapModelConfig") -> dict:
    if isinstance(spec, str):
        return {"table": spec.upper(), "friendly": None,
                "strategy": cfg.incremental_strategy, "capture_deletes": cfg.capture_deletes}
    return {
        "table": spec["table"].upper(),
        "friendly": spec.get("friendly"),
        "strategy": spec.get("strategy", cfg.incremental_strategy),
        "capture_deletes": spec.get("capture_deletes", cfg.capture_deletes),
    }


def _safe_ident(name: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_]+", name or ""):
        raise ValueError(f"Invalid identifier: {name!r}")
    return name


def slug(text: str, fallback: str) -> str:
    s = re.sub(r"[^0-9A-Za-z]+", "_", (text or "").strip()).strip("_").upper()
    if not s:
        s = re.sub(r"[^0-9A-Za-z]+", "_", fallback).strip("_").upper()
    if s and s[0].isdigit():
        s = "F_" + s
    return s


def _dedupe(names: list) -> list:
    seen, out = {}, []
    for n in names:
        if n in seen:
            seen[n] += 1
            out.append(f"{n}_{seen[n]}")
        else:
            seen[n] = 1
            out.append(n)
    return out


def _strip_lead_underscore(name: str) -> str:
    return name.lstrip("_") or name


def build_metadata_query(cfg: SapModelConfig) -> str:
    db, sc_ = _safe_ident(cfg.lz_database), _safe_ident(cfg.dd_schema)
    return f"""
select
    DD02L.TABNAME      as SOURCE_NAME,
    DD02T.DDTEXT       as CDS_VIEW,
    DD03L.FIELDNAME    as TECHNICAL_NAME,
    DD03L.KEYFLAG      as PK,
    DD03L.DATATYPE     as TYPE,
    DD03L.LENG         as LENGTH,
    DD03L.DECIMALS     as DECIMALS,
    DD04T.DDTEXT       as FIELD_NAME,
    DD04T.SCRTEXT_M    as COMMENTS
from "{db}"."{sc_}"."DD02L" as DD02L
left join "{db}"."{sc_}"."DD02T" as DD02T on DD02L.TABNAME  = DD02T.TABNAME
left join "{db}"."{sc_}"."DD03L" as DD03L on DD02L.TABNAME  = DD03L.TABNAME
left join "{db}"."{sc_}"."DD04T" as DD04T on DD03L.ROLLNAME = DD04T.ROLLNAME
where DD04T.DDLANGUAGE = 'E'
  and (DD03L.COMPTYPE = 'E' or DD03L.COMPTYPE is null)
  and DD03L.AS4LOCAL = 'A'
  and DD02L.TABNAME = %(table_name)s
  and DD02T.DDLANGUAGE = 'E'
order by to_number(DD03L.POSITION) asc
"""


def fetch_metadata(conn, cfg: SapModelConfig, table_name: str) -> list:
    cur = conn.cursor()
    try:
        cur.execute(build_metadata_query(cfg), {"table_name": table_name.upper()})
        cols = [c[0] for c in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        cur.close()


def fetch_landing_meta_columns(conn, cfg: SapModelConfig, table_name: str) -> list:
    """Underscore-prefixed metadata columns present in the landing table
    (e.g. _CAPTUREDATETIME, _DATAAGING). Best-effort; [] if table absent."""
    sql = (f'select COLUMN_NAME from "{_safe_ident(cfg.lz_database)}".INFORMATION_SCHEMA.COLUMNS '
           f'where TABLE_SCHEMA = %(s)s and TABLE_NAME = %(t)s order by ORDINAL_POSITION')
    cur = conn.cursor()
    try:
        cur.execute(sql, {"s": cfg.snowflake_schema, "t": table_name.upper()})
        return [r[0] for r in cur.fetchall() if r[0].startswith("_") and r[0] not in {"_FILEDATE", "_FILENAME", "_UPLOADDATE"}]
    except Exception:
        return []
    finally:
        cur.close()


CHAR_TYPES = {"CHAR", "LCHR", "STRG", "SSTR", "NUMC", "ACCP",
              "CLNT", "LANG", "CUKY", "UNIT", "REF"}
BIN_TYPES  = {"RAW", "LRAW", "RSTR"}
DEC_TYPES  = {"CURR", "QUAN", "DEC", "PREC"}
INT_TYPES  = {"INT1", "INT2", "INT4", "INT8"}
DF_TYPES   = {"D16D", "D16R", "D34D", "D34R"}


def _to_int(v) -> int:
    return int(v) if str(v).strip().lstrip("-").isdigit() else 0


def _number(precision: int, scale: int) -> str:
    p = min(max(precision, 1), 38)
    s = min(max(scale, 0), p)
    return f"NUMBER({p},{s})"


def precise_sf_type(datatype, length, decimals, df_scale=6) -> str:
    """Precise Snowflake type for the LZ landing DDL (uses LENG/DECIMALS)."""
    dt = (datatype or "").upper().strip()
    leng, dec = _to_int(length), _to_int(decimals)
    if dt in CHAR_TYPES:
        return f"VARCHAR({leng})" if leng else "VARCHAR"
    if dt in BIN_TYPES:
        return f"BINARY({leng})" if leng else "BINARY"
    if dt in DEC_TYPES:
        return _number(leng or 38, dec)
    if dt in INT_TYPES:
        return {"INT1": "NUMBER(3,0)", "INT2": "NUMBER(5,0)",
                "INT4": "NUMBER(10,0)", "INT8": "NUMBER(19,0)"}[dt]
    if dt in {"D16D", "D16R"}:
        return _number(16, dec or df_scale)
    if dt in {"D34D", "D34R"}:
        return _number(34, dec or df_scale)
    if dt == "FLTP":
        return "FLOAT"
    if dt == "DATS":
        return "DATE"
    if dt == "TIMS":
        return "TIME"
    return f"VARCHAR({leng})" if leng else "VARCHAR"


def lz_landing_type(length) -> str:
    """SAP raw-landing type: everything lands as VARCHAR, length x3 (Unicode bytes).
    e.g. CHAR 30 -> VARCHAR(90), DATS 8 -> VARCHAR(24). 0/variable -> VARCHAR max."""
    leng = _to_int(length)
    return f"VARCHAR({leng * 3})" if leng > 0 else "VARCHAR(16777216)"


def silver_sf_type(datatype, scale=10):
    """Max-width Snowflake type for the silver CAST. None => pass through."""
    dt = (datatype or "").upper().strip()
    if dt == "DATS":
        return "DATE"
    if dt == "TIMS":
        return "TIME"
    if dt in CHAR_TYPES:
        return "VARCHAR"
    if dt in DEC_TYPES or dt in DF_TYPES:
        return f"NUMBER(38,{scale})"
    if dt in INT_TYPES:
        return "NUMBER(38,0)"
    if dt == "FLTP":
        return "FLOAT"
    return None


def silver_transform_expr(business: str, datatype) -> str:
    dt = (datatype or "").upper().strip()
    if dt == "DATS":
        return f"try_to_date({business}, 'YYYYMMDD') AS {business}"
    if dt == "TIMS":
        return f"try_to_time({business}, 'HH24MISS') AS {business}"
    return business



def build_fields(rows: list) -> list:
    raw_business = [slug(r.get("FIELD_NAME"), _strip_lead_underscore(r["TECHNICAL_NAME"]))
                    for r in rows]
    business = _dedupe(raw_business)
    fields = []
    for r, biz in zip(rows, business):
        tech = r["TECHNICAL_NAME"]
        fields.append({
            "technical": tech,
            "bronze": _strip_lead_underscore(tech),
            "business": biz,
            "pk": (r.get("PK") or "").upper() == "X",
            "type": r.get("TYPE"),
            "length": r.get("LENGTH"),
            "decimals": r.get("DECIMALS"),
            "comment": r.get("COMMENTS") or r.get("FIELD_NAME") or "",
        })
    return fields


def friendly_name(rows: list, table: str, override) -> str:
    if override:
        return override.upper()
    return slug(rows[0].get("CDS_VIEW"), table)



def _q(text: str) -> str:
    return (text or "").replace("'", "''")


_LZ_META_COLS = [
    "\t_CAPTUREDATETIME TIMESTAMP_LTZ(9) NOT NULL DEFAULT CAST('0001-01-01 00:00:00' AS TIMESTAMP_LTZ(9))",
    "\t_FILENAME VARCHAR(16777216)",
    "\t_FILEDATE VARCHAR(16777216)",
    "\t_UPLOADDATE VARCHAR(16777216)",
]


def build_lz_ddl(cfg: SapModelConfig, fields: list, table: str) -> str:
    """Raw landing table: every field VARCHAR(leng*3) NOT NULL DEFAULT '',
    landing metadata at the end, then primary key. Unqualified name (relies on
    the USE DATABASE / USE SCHEMA header in the snowfile)."""
    lines, pk = [], []
    for f in fields:
        lines.append(f"\t{f['technical']} {lz_landing_type(f['length'])} NOT NULL DEFAULT ''")
        if f["pk"]:
            pk.append(f["technical"])
    lines += _LZ_META_COLS
    sep = ",\n"
    body = sep.join(lines)
    if pk:
        body += ",\n\tprimary key (" + ", ".join(pk) + ")"
    return f"create or replace TABLE {table.upper()} (\n{body}\n);"


_AUDIT_DDL_COLS = [
    '    "_AUDIT_LOG_ID" VARCHAR(128) COMMENT \'dbt invocation id\'',
    '    "_ROW_HASH" VARCHAR(128) COMMENT \'row hash\'',
    '    "_CAPTUREDATETIME" TIMESTAMP_LTZ(9) COMMENT \'capture timestamp\'',
]


def _ddl(fq: str, columns: list, table_comment: str) -> str:
    sep = ",\n"
    body = sep.join(columns)
    out = f"CREATE OR REPLACE TABLE {fq} (\n{body}\n)"
    if table_comment:
        out += f"\nCOMMENT = '{_q(table_comment)}'"
    return out + ";"


def build_bronze_ddl(cfg: SapModelConfig, fields: list, friendly: str,
                     capture_deletes: bool = False, trailing_meta=None) -> str:
    """Bronze table DDL — audit cols on top, then fields (precise landed types)."""
    fq = f'"{cfg.bronze_db}"."{cfg.bronze_schema}"."{cfg.bronze_alias(friendly)}"'
    cols = list(_AUDIT_DDL_COLS)
    for f in fields:
        line = f'    "{f["bronze"]}" {lz_landing_type(f["length"])}'
        if f["comment"]:
            line += f" COMMENT '{_q(f['comment'])}'"
        cols.append(line)
    for m in (trailing_meta or []):
        cols.append(f'    "{_strip_lead_underscore(m)}" VARCHAR(16777216)')
    if capture_deletes:
        cols.append('    "IS_DELETED" VARCHAR(3) COMMENT \'soft-delete flag (Yes/No)\'')
    return _ddl(fq, cols, f"Bronze table for {friendly}")


def build_silver_ddl(cfg: SapModelConfig, fields: list, friendly: str,
                     capture_deletes: bool = False, trailing_meta=None) -> str:
    """Silver table DDL — audit cols on top, then business-named fields (max types)."""
    fq = f'"{cfg.silver_db}"."{cfg.silver_schema}"."{friendly}"'
    cols = list(_AUDIT_DDL_COLS)
    for f in fields:
        st = silver_sf_type(f["type"], cfg.silver_numeric_scale)
        if st is None:  # passthrough -> keep landed type
            st = lz_landing_type(f["length"])
        line = f'    "{f["business"]}" {st}'
        if f["comment"]:
            line += f" COMMENT '{_q(f['comment'])}'"
        cols.append(line)
    for m in (trailing_meta or []):
        cols.append(f'    "{_strip_lead_underscore(m)}" VARCHAR(16777216)')
    if capture_deletes:
        cols.append('    "IS_DELETED" VARCHAR(3) COMMENT \'soft-delete flag (Yes/No)\'')
    return _ddl(fq, cols, f"Silver table for {friendly}")


def apply_env_tokens(sql: str, cfg: SapModelConfig, db_tokens=None) -> str:
    repls = [(cfg.bronze_role, "<<PLATFORM_TEAM>>"),
             (cfg.silver_role, "<<PLATFORM_TEAM>>"),
             (cfg.lz_role, "<<SYSADMIN>>")]
    repls += list(db_tokens or [])
    for src, token in repls:
        if src:
            sql = re.sub(rf"(?i)\b{re.escape(src)}\b", token, sql)
    return sql


def _snowfile(role: str, ddl_chunks: list, cfg: SapModelConfig, db_tokens) -> str:
    body = "\n\n".join(ddl_chunks)
    return apply_env_tokens(f"USE ROLE {role};\n\n{body}\n", cfg, db_tokens)


def build_lz_snowfile(cfg: SapModelConfig, ddl_chunks: list) -> str:
    header = f"USE DATABASE {cfg.lz_database};\n\nUSE SCHEMA {cfg.snowflake_schema};\n\n"
    return header + "\n".join(ddl_chunks) + "\n"


def build_bronze_snowfile(cfg: SapModelConfig, ddl_chunks: list) -> str:
    return _snowfile(cfg.bronze_role, ddl_chunks, cfg, [(cfg.bronze_db, "<<BRONZE>>")])


def build_silver_snowfile(cfg: SapModelConfig, ddl_chunks: list) -> str:
    return _snowfile(cfg.silver_role, ddl_chunks, cfg, [(cfg.silver_db, "<<SILVER>>")])


def _config_block(strategy: str, alias: str, unique_key: list) -> str:
    uk = "[" + ",".join(f"'{k}'" for k in unique_key) + "]"
    return (
        "{{ config(\n"
        "    materialized='tel_incremental',\n"
        f"    incremental_strategy='{strategy}',\n"
        f"    alias='{alias}',\n"
        f"    unique_key = {uk},\n"
        "    transient=false\n"
        ") }}"
    )


def _body_columns(fields: list, trailing_meta: list):
    body = [(f["technical"], f["bronze"]) for f in fields]
    body += [(m, _strip_lead_underscore(m)) for m in (trailing_meta or [])]
    return body


def _bronze_simple(cfg, fields, table, friendly, strategy, trailing_meta):
    unique_key = [f["bronze"] for f in fields if f["pk"]] if strategy == "merge" else []
    body = _body_columns(fields, trailing_meta)
    src = ["        _CAPTUREDATETIME"] + [f"        {t}" for t, _ in body]
    xfm = (["        '{{ invocation_id }}' AS _AUDIT_LOG_ID",
            "        SHA2('hash_me') AS _ROW_HASH",
            "        _CAPTUREDATETIME"]
           + [f"        {t} AS {o}" for t, o in body])
    typ = (["        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID",
            "        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH",
            "        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME"]
           + [f"        {o}" for _, o in body])
    sep = ",\n"
    cfg_block = _config_block(strategy, cfg.bronze_alias(friendly), unique_key)
    src_sql, xfm_sql, typ_sql = sep.join(src), sep.join(xfm), sep.join(typ)
    source_ref = f"{{{{ source('{cfg.source_name}', '{table.upper()}') }}}}"
    return f"""{cfg_block}

with source_data as (
    SELECT
{src_sql}
    FROM {source_ref}
),

transform_data as (
    SELECT
{xfm_sql}
    FROM source_data
),

type_data as (
    SELECT
{typ_sql}
    FROM transform_data
)

SELECT * FROM type_data
"""


def _bronze_with_deletes(cfg, fields, table, friendly, trailing_meta):
    pk_out = [f["bronze"] for f in fields if f["pk"]]
    if not pk_out:
        raise ValueError(
            f"{table}: capture_deletes needs primary keys, but none are flagged in DD03L."
        )
    body = _body_columns(fields, trailing_meta)
    outs = [o for _, o in body]
    sep = ",\n"

    src = ["        _CAPTUREDATETIME"] + [f"        {t} AS {o}" for t, o in body]

    deleted = (["        tgt._AUDIT_LOG_ID",
                "        tgt._ROW_HASH",
                "        tgt._CAPTUREDATETIME"]
               + [f"        tgt.{o}" for o in outs])
    join = ("\n      AND ").join(f"tgt.{c} = src.{c}" for c in pk_out)
    where = ("\n      AND ").join(f"src.{c} IS NULL" for c in pk_out)

    branch1 = (["        '{{ invocation_id }}' AS _AUDIT_LOG_ID",
                "        SHA2('hash_me') AS _ROW_HASH",
                "        _CAPTUREDATETIME"]
               + [f"        {o}" for o in outs]
               + ["        'No' AS IS_DELETED"])
    branch2 = (["        _AUDIT_LOG_ID",
                "        _ROW_HASH",
                "        _CAPTUREDATETIME"]
               + [f"        {o}" for o in outs]
               + ["        'Yes' AS IS_DELETED"])
    typ = (["        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID",
            "        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH",
            "        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME"]
           + [f"        {o}" for o in outs]
           + ["        IS_DELETED"])

    cfg_block = _config_block("merge", cfg.bronze_alias(friendly), pk_out)
    src_sql = sep.join(src)
    del_sql = sep.join(deleted)
    b1_sql, b2_sql = sep.join(branch1), sep.join(branch2)
    typ_sql = sep.join(typ)
    source_ref = f"{{{{ source('{cfg.source_name}', '{table.upper()}') }}}}"
    this_ref = "{{ this }}"
    return f"""{cfg_block}

with source_data as (
    SELECT
{src_sql}
    FROM {source_ref}
),

transform_is_deleted as (
    SELECT
{del_sql}
    FROM {this_ref} tgt
    LEFT JOIN source_data src
      ON {join}
    WHERE {where}
),

transform_data as (
    SELECT
{b1_sql}
    FROM source_data
    UNION
    SELECT
{b2_sql}
    FROM transform_is_deleted
),

type_data as (
    SELECT
{typ_sql}
    FROM transform_data
)

SELECT * FROM type_data
"""


def build_bronze_model(cfg, fields, table, friendly, strategy,
                       trailing_meta=None, capture_deletes=False) -> str:
    
    if capture_deletes:
        return _bronze_with_deletes(cfg, fields, table, friendly, trailing_meta)
    return _bronze_simple(cfg, fields, table, friendly, strategy, trailing_meta)


def build_silver_model(cfg, fields, friendly, strategy, trailing_meta=None,
                       capture_deletes=False) -> str:
    trailing_meta = trailing_meta or []
    unique_key = [f["business"] for f in fields if f["pk"]] if strategy == "merge" else []

    src = ["        _CAPTUREDATETIME"]
    xfm = ["        '{{ invocation_id }}' AS _AUDIT_LOG_ID",
           "        SHA2('hash_me') AS _ROW_HASH",
           "        _CAPTUREDATETIME"]
    typ = ["        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID",
           "        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH",
           "        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME"]

    for f in fields:
        biz = f["business"]
        src.append(f"        {f['bronze']} AS {biz}")
        xfm.append(f"        {silver_transform_expr(biz, f['type'])}")
        st = silver_sf_type(f["type"], cfg.silver_numeric_scale)
        typ.append(f"        CAST({biz} AS {st}) AS {biz}" if st else f"        {biz}")

    for m in trailing_meta:
        o = _strip_lead_underscore(m)
        src.append(f"        {o}")
        xfm.append(f"        {o}")
        typ.append(f"        {o}")

    if capture_deletes:   # propagate the soft-delete flag from bronze
        src.append("        IS_DELETED")
        xfm.append("        IS_DELETED")
        typ.append("        IS_DELETED")

    sep = ",\n"
    cfg_block = _config_block(strategy, friendly, unique_key)
    src_sql, xfm_sql, typ_sql = sep.join(src), sep.join(xfm), sep.join(typ)
    bronze_ref = f"{{{{ ref('{cfg.bronze_ref(friendly)}') }}}}"
    return f"""{cfg_block}

with source_data as (
    SELECT
{src_sql}
    FROM {bronze_ref}
),

transform_data as (
    SELECT
{xfm_sql}
    FROM source_data
),

type_data as (
    SELECT
{typ_sql}
    FROM transform_data
)

SELECT * FROM type_data
"""



def build_source_doc(cfg: SapModelConfig, tables: list) -> dict:
    doc = {}
    if cfg.source_yaml_file.exists() and yaml is not None:
        loaded = yaml.safe_load(cfg.source_yaml_file.read_text(encoding="utf-8"))
        if isinstance(loaded, dict):
            doc = loaded

    version = doc.get("version", 2)
    sources = doc.get("sources") or []
    src_name = cfg.source_name.upper()

    block = next((s for s in sources if s.get("name") == src_name), None)
    if block is None:
        block = {
            "name": src_name,
            "description": f"Landing Zone - For {src_name} Schema",
            "database": "{{ env_var('SNOWFLAKE_LZ') }}",
            "schema": cfg.snowflake_schema.upper(),
            "tables": [],
        }
        sources.append(block)

    block.setdefault("tables", [])
    by_name = {t["name"]: t for t in block["tables"]}
    for t in tables:
        by_name[t.upper()] = {
            "name": t.upper(),
            "identifier": t.upper(),
            "description": f"Landing table for {t.upper()} from SAP",
        }
    block["tables"] = list(by_name.values())

    rebuilt = {"version": version, "sources": sources}
    for k, v in doc.items():
        if k not in rebuilt:
            rebuilt[k] = v
    return rebuilt


def write_source_yaml(cfg: SapModelConfig, tables: list) -> Path:
    if yaml is None:
        raise RuntimeError("PyYAML required for source YAML (pip install pyyaml).")
    doc = build_source_doc(cfg, tables)
    return _write(cfg.source_yaml_file, yaml.safe_dump(doc, sort_keys=False))


def build_table_config_entry(cfg, fields, table, strategy) -> dict:
    pks = [f["technical"] for f in fields if f["pk"]]
    primary_key = ",".join(pks) if strategy == "merge" else ""
    strategy = 'insert_overwrite' if strategy == 'merge' else strategy # Force Only Insert Overwrite for merge strategy in table config
    return {
        "is_active": True,
        "chunk_size": cfg.chunk_size,
        "table": table.upper(),
        "schema": cfg.sap_schema,
        "incremental_strategy": strategy,
        "use_safe_string_fallback": cfg.use_safe_string_fallback,
        "snowflake_table": table.upper(),
        "snowflake_schema": cfg.snowflake_schema,
        "primary_key": primary_key,
    }


def upsert_table_config(cfg: SapModelConfig, entries: dict) -> Path:
    path = cfg.table_config_file
    data = json.loads(path.read_text(encoding="utf-8") or "{}") if path.exists() else {}
    if cfg.config_root_key:
        bucket = data.setdefault(cfg.config_root_key, {})
    else:
        bucket = data
    bucket.update(entries)
    return _write(path, json.dumps(data, indent=4))


def build_extract_commands(cfg: SapModelConfig) -> list:
    cfg_path = cfg.table_config_file
    chunk = cfg.extract_chunk_size or cfg.chunk_size
    debug = "True" if cfg.extract_debug else "False"
    cmds = []
    for spec in cfg.tables:
        t = normalize_table_spec(spec, cfg)
        cmds.append(
            f"python -m {cfg.extract_module} "
            f"--config-file {cfg_path} "
            f"--extraction-name {t['table']} "
            f"--env {cfg.extract_env} "
            f"--chunk-size {chunk} "
            f"--debug {debug}"
        )
    return cmds


def run_extracts(cfg: SapModelConfig, dry_run: bool = True) -> list:
    """Print (and optionally run) the getSapR3Data command for each table."""
    import subprocess
    cmds = build_extract_commands(cfg)
    cwd = str(cfg.repo_root / "astro_datautility")
    results = []
    for cmd in cmds:
        print(f"$ {cmd}")
        if dry_run:
            continue
        r = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True)
        print(f"  return code: {r.returncode}")
        if r.stdout:
            print(r.stdout)
        if r.stderr:
            print(r.stderr)
        results.append((cmd, r.returncode))
    if dry_run:
        print("\n(dry run — call run_extracts(cfg, dry_run=False) to execute)")
    return results


def _write(path: Path, text: str) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def write_bronze_model(cfg, fields, table, friendly, strategy,
                       trailing_meta=None, capture_deletes=False) -> Path:
    sql = build_bronze_model(cfg, fields, table, friendly, strategy,
                             trailing_meta, capture_deletes)
    return _write(cfg.bronze_dir / f"{cfg.bronze_ref(friendly)}.sql", sql)


def write_silver_model(cfg, fields, friendly, strategy, trailing_meta=None,
                       capture_deletes=False) -> Path:
    sql = build_silver_model(cfg, fields, friendly, strategy, trailing_meta, capture_deletes)
    return _write(cfg.silver_dir / f"{cfg.silver_ref(friendly)}.sql", sql)


def generate_all(cfg: SapModelConfig, conn=None, write_ddl: bool = True,
                 write_source: bool = True) -> dict:
    own_conn = conn is None
    if own_conn:
        print("Connecting to Snowflake ...")
        conn = connect(cfg.connection)

    results, config_entries, src_tables = {}, {}, []
    lz_chunks, bronze_chunks, silver_chunks = [], [], []
    try:
        for spec in cfg.tables:
            t = normalize_table_spec(spec, cfg)
            table, strategy, cap = t["table"], t["strategy"], t["capture_deletes"]
            tag = "merge+deletes" if cap else strategy
            print(f"  -> {table} ({tag})")

            rows = fetch_metadata(conn, cfg, table)
            if not rows:
                print(f"     !! no metadata for {table}, skipping")
                continue

            fields = build_fields(rows)
            friendly = friendly_name(rows, table, t["friendly"])
            metas = fetch_landing_meta_columns(conn, cfg, table)
            trailing = [m for m in metas if m.upper() != "_CAPTUREDATETIME"]

            results[table] = {
                "friendly": friendly,
                "bronze": write_bronze_model(cfg, fields, table, friendly, strategy,
                                             trailing, capture_deletes=cap),
                "silver": write_silver_model(cfg, fields, friendly, strategy, trailing,
                                             capture_deletes=cap),
            }
            config_entries[table] = build_table_config_entry(cfg, fields, table, strategy)
            src_tables.append(table)
            if write_ddl:
                lz_chunks.append(build_lz_ddl(cfg, fields, table))
                bronze_chunks.append(build_bronze_ddl(cfg, fields, friendly, cap, trailing))
                silver_chunks.append(build_silver_ddl(cfg, fields, friendly, cap, trailing))

        if config_entries:
            results["_table_config"] = upsert_table_config(cfg, config_entries)
        if write_source and src_tables:
            results["_source_yaml"] = write_source_yaml(cfg, src_tables)
        if write_ddl and lz_chunks:
            results["_lz_snowfile"] = _write(cfg.lz_snow_file,
                                             build_lz_snowfile(cfg, lz_chunks))
            results["_bronze_snowfile"] = _write(cfg.bronze_snow_file,
                                                 build_bronze_snowfile(cfg, bronze_chunks))
            results["_silver_snowfile"] = _write(cfg.silver_snow_file,
                                                 build_silver_snowfile(cfg, silver_chunks))
    finally:
        if own_conn:
            conn.close()
    return results