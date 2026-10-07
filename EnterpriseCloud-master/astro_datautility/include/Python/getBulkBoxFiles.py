import logging


logging.getLogger("boxsdk").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)
logging.getLogger("azure").setLevel(logging.WARNING)

from argparse import ArgumentParser
import os
import io
import sys
import uuid
import tempfile
from pathlib import Path, PurePosixPath
from datetime import datetime, timezone
import base64
import pandas as pd
from boxsdk import Client, JWTAuth
from azure.storage.blob import ContainerClient, BlobClient
from datetime import timedelta
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame, getSnowFlakeConn
from include.Python.getBoxFile import _open_configurations, _get_connection_client

#364222667712 testing ─────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────
SUPPORTED_EXTENSIONS = ['.png']


path       = Path(os.getcwd()).joinpath(*["include", "Configuration", "TelTools_getBoxFile_FILE.json"])
config     = _open_configurations(path)

LZ_DB      = os.environ["SNOWFLAKE_LZ"]
SCHEMA     = "FILE"
BATCH_ID   = str(uuid.uuid4())

# BINARY_TYPES     = {".png", ".pdf"}
# STRUCTURED_TYPES = {".csv", ".xlsx", ".xls"}


# ── Azure Blob config ─────────────────────────
ENV = os.environ['SNOWFLAKE_ENV']
if ENV=="PROD":
    BLOB_ROOT_FOLDER = "raw"   # root folder in container e.g. box_files/raw/png/<folder_id>/
else:
    BLOB_ROOT_FOLDER = "raw_test"   # root folder in container e.g. box_files/raw/png/<folder_id>/


# ─────────────────────────────────────────────
# AZURE BLOB HELPERS
# ─────────────────────────────────────────────
def get_container_client(src_key="AZURE-STORAGE-SAPAPI-SAS-SFSA"):
    """Return a ContainerClient using SAS key from Key Vault."""
    sas_key = getAzureSecret(src_key).value
    sas_key = sas_key.replace("/sapapi?","/box?")
    return ContainerClient.from_container_url(sas_key)


def build_blob_name(folder_path, item, ext):
    """
    Build blob path mirroring Box folder structure.
    folder_path : /Dept_TTCA_Productivity/_Etch_Larity/Tool_Productivity/Larity/Wafer Maps
    ext         : .png
    Result      : Dept_TTCA_Productivity/_Etch_Larity/.../Wafer Maps/png/id_filename.png
    
    """

    ext_folder = ext.replace(".", "")  

    # clean folder path strip leading slash
    clean_path = folder_path.strip("/")

    return f"{BLOB_ROOT_FOLDER}/{clean_path}/{ext_folder}/{item.id}_{item.name}"


def upload_to_blob(container_client, file_bytes, blob_name):
    """Upload bytes to Azure Blob. Returns blob_name on success."""
    blob_client = container_client.get_blob_client(blob_name)
    blob_client.upload_blob(file_bytes, overwrite=True)
    return blob_name


def get_blob_url(container_client, blob_name, pbi_sas_key="AZURE-STORAGE-BOX-SAS-SFSA"):
    """
    Build a read-only SAS URL for Power BI consumption.
    Uses the read-only SAS key stored in Key Vault.
    """
    pbi_sas   = getAzureSecret(pbi_sas_key).value
    base, token = pbi_sas.split("?", 1)
    return f"{base}/{blob_name}?{token}"


# ─────────────────────────────────────────────
# ROW BUILDERS
# ─────────────────────────────────────────────
def build_binary_row(item, folder_path, ext, batch_id, now, file_bytes, blob_name=None, image_url=None):
    row = shared_fields(item, folder_path, ext, batch_id, now)
    #row["FILE_CONTENT"] = base64.b64encode(file_bytes).decode("utf-8")
    row["BLOB_NAME"]    = blob_name    # Azure Blob path
    row["OBJECT_URL"]    = image_url    # read-only SAS URL for Power BI
    return row


def build_structure_row(item, folder_path, ext, batch_id, now, records, blob_name=None, image_url=None):
    row = shared_fields(item, folder_path, ext, batch_id, now)
    row["JSONFIELD"]  = records
    row["ROW_COUNT"]  = len(records)
    return row


# ─────────────────────────────────────────────
# BOX DOWNLOAD HELPERS
# ─────────────────────────────────────────────
def ingest_binary_file(box_client, f):
    print(f"Downloading binary file: {f['item'].name} ({f['EXT']})")
    buf = io.BytesIO()
    box_client.file(f["item"].id).download_to(buf)
    buf.seek(0)
    file_bytes = buf.read()
    del buf
    return file_bytes


def ingest_structured_file(box_client, f):
    print(f"Downloading structured file: {f['item'].name} ({f['EXT']})")
    buf = io.BytesIO()
    box_client.file(f["item"].id).download_to(buf)
    buf.seek(0)

    ext = f["EXT"]
    if ext == ".csv":
        df_data = pd.read_csv(buf, dtype=str)
    elif ext in (".xlsx", ".xls"):
        df_data = pd.read_excel(buf, dtype=str)
    del buf

    return df_data.to_dict(orient="records")



def resolve_path(box_client, file_item):
    try:
        full  = box_client.file(file_item.id).get(fields=["path_collection"])
        parts = [e["name"] for e in full.path_collection["entries"]
                 if e["name"] != "All Files"]
        return "/" + "/".join(parts)
    except Exception:
        return ""


def crawl_box(box_client, folder_id, _depth=0):
    offset = 0
    limit  = 1000
    while True:
        items = box_client.folder(folder_id).get_items(
            limit=limit, offset=offset,
            fields=["id", "name", "type", "size", "created_at",
                    "modified_at", "created_by", "modified_by",
                    "shared_link", "parent"],
        )
        batch = list(items)
        if not batch:
            break
        for item in batch:
            if item.type == "file":
                yield {
                    "item":        item,
                    "folder_path": resolve_path(box_client, item),
                    "depth":       _depth,
                }
            elif item.type == "folder":
                yield from crawl_box(box_client, item.id, _depth + 1)
        offset += limit
        if len(batch) < limit:
            break


def get_ext(name):
    s = PurePosixPath(name).suffix.lower()
    return s if s else "no_extension"


def box_ts(ts_str):
    if not ts_str:
        return None
    try:
        dt =  datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M:%S%z")
    except Exception:
        return None


def shared_fields(item, folder_path, ext, batch_id, now):
    return {
        "BOX_FILE_ID":      item.id,
        "BOX_FILE_NAME":    item.name,
        "BOX_FOLDER_PATH":  folder_path,
        "BOX_FOLDER_ID":    item.parent.id if item.parent else None,
        "BOX_CREATED_AT":   box_ts(getattr(item, "created_at",  None)),
        "BOX_MODIFIED_AT":  box_ts(getattr(item, "modified_at", None)),
        "BOX_CREATED_BY":   getattr(getattr(item, "created_by",  None), "login", None),
        "BOX_MODIFIED_BY":  getattr(getattr(item, "modified_by", None), "login", None),
        "FILE_EXTENSION":   ext,
        "FILE_SIZE_BYTES":  getattr(item, "size", None),
        "INGESTED_AT":      now,
        "INGEST_BATCH_ID":  batch_id,
    }


# ROW_BUILDERS = {
#     ".png": build_binary_row,
#     ".pdf": build_binary_row,
#     ".csv": build_binary_row,
#     ".txt": build_binary_row,
#     ".xlsx": build_binary_row,
#     ".xls": build_binary_row,
# }

#crawl once, filter by extensions
def get_box_manifest(box_client, folder_id, ext_filters: list,
                     mode: str = "folder", watermark=None):
    """
    mode = 'folder' : crawl folder recursively, filter by ext_filters
    mode = 'file'   : folder_id is actually a file ID return just that one file
    """
    if mode == "file":
        item        = box_client.file(folder_id).get(
            fields=["id", "name", "type", "size", "created_at",
                    "modified_at", "created_by", "modified_by",
                    "shared_link", "parent"]
        )
        ext         = get_ext(item.name)
        folder_path = resolve_path(box_client, item)

        # ── incremental check for single file ─────────────────
        if watermark:
            modified_at = box_ts(getattr(item, "modified_at", None))
            if modified_at and modified_at <= watermark:
                print(f"  Skipping {item.name}, not modified since {watermark}")
                return []

        print(f"Single file mode: {item.name} ({ext})")
        return [{
            "item":        item,
            "folder_path": folder_path,
            "BOX_FILE_ID": item.id,
            "SIZE_BYTES":  getattr(item, "size", None),
            "EXT":         ext,
        }]

    # ── folder mode ───────────────────────────────────────────
    filters  = {e.lower() if e.startswith(".") else f".{e.lower()}" for e in ext_filters}
    files    = []
    skipped  = 0

    for file_meta in crawl_box(box_client, folder_id, _depth=0):
        item = file_meta["item"]
        ext  = get_ext(item.name)

        if ext not in filters:
            continue

        # ── incremental filter ────────────────────────────────
        if watermark:
            modified_at = box_ts(getattr(item, "modified_at", None))
            if modified_at and modified_at <= watermark:
                skipped += 1
                continue   # not changed since last run

        files.append({
            "item":        item,
            "folder_path": file_meta["folder_path"],
            "BOX_FILE_ID": item.id,
            "SIZE_BYTES":  getattr(item, "size", None),
            "EXT":         ext,
        })

    from collections import Counter
    counts     = Counter(f["EXT"] for f in files)
    mode_label = f"INCREMENTAL since {watermark}" if watermark else "FULL LOAD"

    print(f"Box manifest [{mode_label}]:")
    for ext, cnt in counts.items():
        print(f"  {ext:<15} {cnt} files")
    print(f"  {'TOTAL':<15} {len(files)} files")
    if watermark:
        print(f"  {'SKIPPED':<15} {skipped} files (not modified)")

    return files


def ingest_file(box_client, container_client, f, folder_id, batch_id, now):
    item = f["item"]
    ext  = f["EXT"]
    blob_name = None
    obj_url = None

    
    payload = ingest_binary_file(box_client, f)

    blob_name = build_blob_name(f["folder_path"], item, ext)
    upload_to_blob(container_client, payload, blob_name)
    obj_url = get_blob_url(container_client, blob_name)
    print(f"Uploaded to blob item: {item.name}")

    row = build_binary_row(item, f["folder_path"], ext, batch_id, now, payload, blob_name, obj_url)

    return "SUCCESS", "Ingested successfully", row


def get_watermark(folder_id, table):
    messages = []
    conn, messages = getSnowFlakeConn(LZ_DB, SCHEMA, messages)

    if "FAIL_SIGNAL" in messages:
        print(f"  Could not connect to Snowflake for watermark — full load")
        return None

    try:
        cursor = conn.cursor()
        cursor.execute(f"""
            SELECT MAX(_FILEDATE)
            FROM {LZ_DB}.{SCHEMA}.{table}
            WHERE _FILENAME = '{folder_id}'
        """)
        row = cursor.fetchone()

        if not row or row[0] is None:
            print(f"No watermark found,full load")
            return None

        last_run  = datetime.strptime(str(row[0])[:26], "%Y-%m-%d %H:%M:%S.%f")
        watermark = (last_run - timedelta(days=1)).strftime("%Y-%m-%d %H:%M:%S.%f")

        print(f"Last run  : {str(row[0])[:26]}")
        print(f"Watermark : {watermark} (day-1 buffer)")
        return watermark

    except Exception as e:
        print(f" Watermark query failed,full load: {e}")
        return None

    finally:
        try:
            conn.close()
        except Exception:
            pass


    # ── 1. download from Box ──────────────────
    # if ext in BINARY_TYPES:
    #     payload = ingest_binary_file(box_client, f)
    # elif ext in STRUCTURED_TYPES:
    #     payload = ingest_structured_file(box_client, f)
    # else:
    #     return "FAILED", f"Unsupported extension: {ext}", None

    # ── 2. upload to Azure Blob (binary only) ─
    

    # if ext in BINARY_TYPES:
    #     blob_name = build_blob_name(folder_id, item, ext)
    #     upload_to_blob(container_client, payload, blob_name)
    #     obj_url = get_blob_url(container_client, blob_name)
    #     print(f"  Uploaded to blob : {blob_name}")

    # ── 3. build row + write to Snowflake ─────
    # builder = ROW_BUILDERS[ext]
    # row = builder(item, f["folder_path"], ext, batch_id, now, payload, blob_name, obj_url)
    # if ext in BINARY_TYPES:
    #     row = builder(item, f["folder_path"], ext, batch_id, now, payload, blob_name, image_url)
    # else:
    #     row = builder(item, f["folder_path"], ext, batch_id, now, payload)


    # return "SUCCESS", "Ingested successfully", row
    # df  = pd.DataFrame([row])
    # msg = putSnowflakeDataFrame(LZ_DB, SCHEMA, TABLE_MAP[ext], df, item.name, now)

    # if "FAIL_SIGNAL" in msg:
    #     return "FAILED", msg
    # return "SUCCESS", msg



def summarize_audit(box_manifest, blob_results, sf_results, container_client, folder_path, batch_id, folder_id):
    """
    blob_results : BOX_FILE_ID --> (status, message)
    sf_results   : TABLE_NAME  --> (status, message)
    Writes audit summary to blob: <folder_path>/audit/audit_<batch_id>.txt
    """
    total        = len(box_manifest)
    blob_success = 0
    blob_failed  = 0

    for file_id, value in blob_results.items():
        status = value[0]
        if status == "SUCCESS":
            blob_success += 1
        elif status == "FAILED":
            blob_failed += 1

    missing = []
    for f in box_manifest:
        if f["BOX_FILE_ID"] not in blob_results:
            missing.append(f)

    sf_success = 0
    sf_failed  = 0
    for table_name, value in sf_results.items():
        if value[0] == "SUCCESS":
            sf_success += 1
        elif value[0] == "FAILED":
            sf_failed += 1

    # ── build audit text ──────────────────────────────────────
    lines = []
    lines.append("=" * 65)
    lines.append("AUDIT SUMMARY")
    lines.append("=" * 65)
    lines.append(f"  Batch ID             : {batch_id}")
    lines.append(f"  Folder path          : {folder_path}")
    lines.append(f"  Box manifest total   : {total}")
    lines.append(f"  Blob upload success  : {blob_success}")
    lines.append(f"  Blob upload failed   : {blob_failed}")
    lines.append(f"  Missing from audit   : {len(missing)}")
    lines.append(f"  SF tables success    : {sf_success}")
    lines.append(f"  SF tables failed     : {sf_failed}")

    if blob_failed > 0:
        lines.append("")
        lines.append("Blob upload failures:")
        for f in box_manifest:
            file_id = f["BOX_FILE_ID"]
            if file_id not in blob_results:
                continue
            if blob_results[file_id][0] == "FAILED":
                lines.append(f"  [FAILED] {f['item'].name:<40} {blob_results[file_id][1]}")

    if missing:
        lines.append("")
        lines.append("Never processed:")
        for f in missing:
            lines.append(f"  [MISSING] {f['item'].name}")

    if sf_failed > 0:
        lines.append("")
        lines.append("Snowflake write failures:")
        for table_name, value in sf_results.items():
            if value[0] == "FAILED":
                lines.append(f"  [FAILED] {table_name:<30} {value[1]}")

    lines.append("=" * 65)
    all_ok = blob_failed == 0 and len(missing) == 0 and sf_failed == 0
    lines.append("All files successfully loaded" if all_ok else
                 f"Blob failed: {blob_failed} | SF failed: {sf_failed} | Missing: {len(missing)}")
    lines.append("=" * 65)

    audit_text = "\n".join(lines)

    print(f"AUDIT | batch={batch_id} | total={total} | success={blob_success} | failed={blob_failed} | missing={len(missing)} | sf_failed={sf_failed}")

    blob_name   = f"{BLOB_ROOT_FOLDER}/audit/audit_{folder_id}_{batch_id}.txt"

    try:
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(audit_text.encode("utf-8"), overwrite=True)
        print(f"Audit saved to blob: {blob_name}")
    except Exception as e:
        print(f"Failed to save audit to blob: {e}")

    return blob_success, blob_failed, len(missing), sf_failed



def main(folder_id, file_types, mode, table):
    print("=" * 65)
    print("Batch    : %s" % BATCH_ID)
    print("Folder   : %s" % folder_id)
    print("=" * 65)
    print("Blob root folder: %s" % BLOB_ROOT_FOLDER)
    print(f"File types: {file_types}, Type: {type(file_types)}")

    box_client       = _get_connection_client(config)
    container_client = get_container_client()        # Azure Blob connection
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f")
    watermark = get_watermark(folder_id, table)
    box_manifest = get_box_manifest(
        box_client, 
        folder_id,
        ext_filters=file_types,     # ['.png', '.pdf', '.csv']
        mode=mode,                  # file/folder
        watermark=watermark,        # None = full load, date = incremental
    )

    if not box_manifest:
        print("No matching files found. Exiting.")
        return

    # ── Step 2: loop — download + blob upload + accumulate rows ──
    blob_results  = {}   # BOX_FILE_ID --> (status, message)
    rows_by_table = {}   # TABLE_NAME  --> [row, row, ...]

    for i, f in enumerate(box_manifest, 1):
        item = f["item"]
        ext  = f["EXT"]
        print(f"[{i}/{len(box_manifest)}] {item.name} ({ext})")

        status, msg, row = ingest_file(
            box_client, container_client, f,
            folder_id, BATCH_ID, now
        )
        blob_results[f["BOX_FILE_ID"]] = (status, msg)
        print(f"  [{status}] {msg}")

        # only accumulate successful rows
        if status == "SUCCESS" and row is not None:
            table_name = table
            if table_name not in rows_by_table:
                rows_by_table[table_name] = []
            rows_by_table[table_name].append(row)

    # ── Step 3: one Snowflake write per table ─
    print("\nWriting to Snowflake...")
    sf_results = {}   # TABLE_NAME --> (status, message)

    for table_name, rows in rows_by_table.items():
        print(f"  {table_name}::{len(rows)} rows")
        df  = pd.DataFrame(rows)
        msg = putSnowflakeDataFrame(LZ_DB, SCHEMA, table_name, df, folder_id, now)

        if "FAIL_SIGNAL" in msg:
            sf_results[table_name] = ("FAILED", msg)
        else:
            sf_results[table_name] = ("SUCCESS", msg)

        print(f"  [{sf_results[table_name][0]}] {table_name}")

    audit_folder_path = box_manifest[0]["folder_path"] if box_manifest else "unknown"

    blob_success, blob_failed, missing, sf_failed = summarize_audit(
        box_manifest, blob_results, sf_results,container_client, audit_folder_path, BATCH_ID, folder_id
    )

    if blob_failed > 0 or missing > 0 or sf_failed > 0:
        raise Exception(
            f"Pipeline failed ::: "
            f"blob_failed={blob_failed}, "
            f"missing={missing}, "
            f"sf_failed={sf_failed}, "
            f"blob_success={blob_success}"
        )

# ─────────────────────────────────────────────
# CLI ENTRY POINT
# ─────────────────────────────────────────────
def _build_parser():
    parser = ArgumentParser(description="Extract files from Box and load into Snowflake + Azure Blob")
    parser.add_argument("--folder_id",  required=True, help="Box folder ID to crawl")
    parser.add_argument("--file_types", required=True, nargs="+", help="File extensions e.g. .png .pdf")
    parser.add_argument("--mode", required=True, help="Mode: 'file' or 'folder'")
    parser.add_argument("--table", required=True, help="Target table name")
    return parser


if __name__ == "__main__":
    parser = _build_parser()
    args   = parser.parse_args()
    main(
        folder_id  = args.folder_id,
        file_types = args.file_types,
        mode       = args.mode,
        table      = args.table
    )