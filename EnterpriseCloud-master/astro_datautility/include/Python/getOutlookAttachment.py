import os
import base64
import zipfile
import tempfile
import shutil
import fnmatch
from datetime import datetime, timezone
from pathlib import Path

from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_result, before_sleep_log
import logging

from include.Python.TELTools import (
    load_config,
    read_runtime_config,
    load_control_table,
    process_file_content,
    getAzureSecret
)
from include.Python.getMSGraphData import getGraphToken, buildGraphURL, requestGraphData

logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S'))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)

logging.getLogger('azure').setLevel(logging.WARNING)
logging.getLogger('msal').setLevel(logging.WARNING)
logging.getLogger('snowflake.connector').setLevel(logging.WARNING)

# CONFIG_FILE_PATH = r'C:\Users\223163\Documents\master_repo\EnterpriseCloud\astro_datautility\include\Configuration\TelTools_Outlook_Attachment_Extract.json'
CONFIG_FILE_PATH = '/usr/local/airflow/include/Configuration/TelTools_Outlook_Attachment_Extract.json'


def _is_status_failed(result):
    """Retry condition: returns True when a status-dict result indicates failure."""
    return isinstance(result, dict) and not result.get('status', True)


_api_retry = retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    retry=retry_if_result(_is_status_failed),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)


_snowflake_retry = retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=3, max=60),
    retry=retry_if_result(_is_status_failed),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)


def build_filter(sender, subject_prefix, has_attach, last_run, current_run=None):
    filters = []
    if sender:
        if isinstance(sender, list):
            sender_conditions = [f"from/emailAddress/address eq '{s}'" for s in sender]
            filters.append(f"({' or '.join(sender_conditions)})")
        else:
            filters.append(f"from/emailAddress/address eq '{sender}'")
    if subject_prefix:
        filters.append(f"startsWith(subject,'{subject_prefix}')")
    if has_attach:
        filters.append("hasAttachments eq true")
    if last_run:
        if isinstance(last_run, str):
            iso_date = last_run.replace(' ', 'T')
            if not iso_date.endswith('Z'):
                iso_date += 'Z'
        else:
            iso_date = last_run.strftime('%Y-%m-%dT%H:%M:%SZ')
        filters.append(f"receivedDateTime gt {iso_date}")
    if current_run:
        if isinstance(current_run, str):
            iso_current = current_run.replace(' ', 'T')
            if not iso_current.endswith('Z'):
                iso_current += 'Z'
        else:
            iso_current = current_run.strftime('%Y-%m-%dT%H:%M:%SZ')
        filters.append(f"receivedDateTime le {iso_current}")
    return ' and '.join(filters) if filters else None


def resolve_file_config(filename, files_config):
    for file_cfg in files_config:
        if fnmatch.fnmatch(filename, file_cfg['file_pattern']):
            return file_cfg
    return None


def save_failed_file(content, filename, debug_cfg):
    if not debug_cfg or not debug_cfg.get('save_failed_attachments', {}).get('enabled'):
        return

    try:
        save_dir = Path(debug_cfg['save_failed_attachments'].get('path', './failed_attachments'))
        save_dir.mkdir(parents=True, exist_ok=True)

        safe_filename = filename.replace('/', '_').replace('\\', '_')
        save_path = save_dir / safe_filename

        if isinstance(content, bytes):
            with open(save_path, 'wb') as f:
                f.write(content)
        elif isinstance(content, str) and os.path.exists(content):
            shutil.copy2(content, save_path)
        else:
            logger.warning(f"Cannot save failed file {filename}: invalid content type")
            return

        logger.info(f"Saved failed file to: {save_path}")
    except Exception as e:
        logger.warning(f"Failed to save file {filename}: {e}")


def process_zip(attach, email_id, start_time, db, table_name, table_cfg, debug_cfg=None):
    zip_path = None
    extract_dir = None
    loaded = 0
    failed = 0
    filtered_ext = 0
    filtered_name = 0
    details = []

    schema = table_cfg['schema']
    files_config = table_cfg['files']

    try:
        zip_name = attach.get('name', 'unknown.zip')
        logger.info(f"  Processing ZIP {zip_name}")

        content_b64 = attach.get('contentBytes')
        if not content_b64:
            failed += 1
            details.append((email_id, zip_name, 'failed', 'No content', table_name, 0))
            return {
                'files_extracted': 0, 'filtered_by_ext': 0, 'filtered_by_name': 0,
                'loaded': loaded, 'failed': failed, 'details': details
            }

        content = base64.b64decode(content_b64)

        with tempfile.NamedTemporaryFile(mode='wb', delete=False, suffix='.zip') as tf:
            tf.write(content)
            zip_path = tf.name

        extract_dir = tempfile.mkdtemp()

        with zipfile.ZipFile(zip_path, 'r') as zf:
            zf.extractall(extract_dir)

        files = []
        for root, dirs, filelist in os.walk(extract_dir):
            for f in filelist:
                files.append(os.path.join(root, f))

        logger.info(f"  Extracted {len(files)} files from ZIP")

        for fpath in files:
            try:
                fname = os.path.basename(fpath)
                ext = Path(fname).suffix.lower().lstrip('.')

                file_cfg = resolve_file_config(fname, files_config)
                if not file_cfg:
                    logger.info(f"Filtered {fname} (no matching file pattern)")
                    filtered_name += 1
                    continue

                if ext not in file_cfg['supported_file_types']:
                    logger.info(f"Filtered {fname} (unsupported file type: .{ext})")
                    filtered_ext += 1
                    continue

                logger.info(f"Processing {fname} -> {table_name}")

                with open(fpath, 'rb') as f:
                    file_bytes = f.read()
                file_content = file_bytes.decode('utf-8')

                run_time_ntz = start_time.replace(tzinfo=None)
                result = _snowflake_retry(process_file_content)(
                    content=file_content,
                    file_name=fname,
                    last_extraction_time=run_time_ntz,
                    db=db,
                    schema=schema,
                    table=table_name,
                    delimiter=file_cfg.get('delimiter', ','),
                    skip_header=file_cfg.get('skip_header', False),
                    ignore_header=file_cfg.get('ignore_header', False),
                    section=fname,
                    RUN_TIME=run_time_ntz,
                    file_format=file_cfg.get('file_format'),
                    convert_to_json=file_cfg.get('convert_to_json', True)
                )

                if not result['status']:
                    failed += 1
                    details.append((email_id, f"{zip_name}/{fname}", 'failed', result['message'], table_name, 0))
                    save_failed_file(fpath, f"{zip_name}_{fname}", debug_cfg)
                else:
                    loaded += 1
                    details.append((email_id, f"{zip_name}/{fname}", 'loaded', f"Success ({result['data']} rows)", table_name, result['data']))

            except Exception as e:
                failed += 1
                details.append((email_id, f"{zip_name}/{fname}", 'failed', str(e), table_name, 0))
                logger.error(f"Failed {fname}: {e}")

        return {
            'files_extracted': len(files),
            'filtered_by_ext': filtered_ext,
            'filtered_by_name': filtered_name,
            'loaded': loaded,
            'failed': failed,
            'details': details
        }

    except Exception as e:
        logger.error(f"  ZIP error: {e}")
        return {
            'files_extracted': 0, 'filtered_by_ext': 0, 'filtered_by_name': 0,
            'loaded': 0, 'failed': 1,
            'details': [(email_id, attach.get('name', 'unknown'), 'failed', str(e), table_name, 0)]
        }
    finally:
        if zip_path and os.path.exists(zip_path):
            try:
                os.remove(zip_path)
            except Exception as e:
                logger.warning(f"  Cleanup failed for temp zip {zip_path}: {e}")
        if extract_dir and os.path.exists(extract_dir):
            try:
                shutil.rmtree(extract_dir)
            except Exception as e:
                logger.warning(f"  Cleanup failed for temp dir {extract_dir}: {e}")


def main(tables=None):
    logger.info("=" * 60)
    logger.info("EMAIL ATTACHMENT PROCESSOR")
    logger.info("=" * 60)

    try:
        logger.info(f"Loading config from {CONFIG_FILE_PATH}")
        cfg_result = load_config(CONFIG_FILE_PATH)
        if not cfg_result['status']:
            raise Exception(cfg_result['message'])
        cfg = cfg_result['data']
        logger.info("Config loaded")

        db = os.environ.get('SNOWFLAKE_LZ')
        if not db:
            raise Exception("SNOWFLAKE_LZ environment variable is not set")
        logger.info(f"Using database: {db}")

        start_time = datetime.now(timezone.utc)
        logger.info(f"Started at {start_time} (UTC)")

        logger.info("Fetching client secret")
        client_secret = getAzureSecret(cfg['graph_api']['client_secret']).value
        logger.info("Client secret retrieved")

        logger.info("Getting access token")
        token_result = _api_retry(getGraphToken)(
            cfg['graph_api']['client_id'],
            client_secret,
            cfg['graph_api']['tenant_id'],
            cfg['graph_api']['oauth_url']
        )

        if not token_result['status']:
            raise Exception(token_result['message'])

        token = token_result['data']
        logger.info("Token acquired")

        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json',
            'ConsistencyLevel': 'eventual'
        }

        sf_cfg = cfg['snowflake']
        available_tables = list(sf_cfg.keys())
        invalid_tables = []
        if tables:
            invalid_tables = [t for t in tables if t not in available_tables]
            for t in invalid_tables:
                logger.warning(f"Table '{t}' not found in config")
            target_tables = {t: sf_cfg[t] for t in tables if t in sf_cfg}
        else:
            target_tables = sf_cfg

        logger.info(f"Tables to process: {', '.join(target_tables.keys()) if target_tables else 'NONE'}")

        debug_cfg = cfg.get('debug')
        if debug_cfg and debug_cfg.get('save_failed_attachments', {}).get('enabled'):
            save_path = debug_cfg['save_failed_attachments'].get('path', './failed_attachments')
            logger.info(f"Debug mode: saving failed attachments to {save_path}")

        total_emails_fetched = 0
        total_emails_with_zip = 0
        total_zips = 0
        total_files_extracted = 0
        total_filtered_ext = 0
        total_filtered_name = 0
        total_loaded = 0
        total_failed = 0
        total_email_errors = 0
        total_unsupported = 0
        all_details = []
        tables_last_runs = {}
        table_failed = {}
        table_email_errors = {}
        table_loaded_rows = {}

        for table_name, table_cfg in target_tables.items():
            logger.info("-" * 60)
            logger.info(f"PROCESSING TABLE: {table_name}")
            logger.info("-" * 60)

            table_failed[table_name] = 0
            table_email_errors[table_name] = 0
            table_loaded_rows[table_name] = 0

            schema = table_cfg['schema']
            user_email = table_cfg['user_email']

            logger.info("Checking last run")
            runtime_result = read_runtime_config(db, schema)

            last_run = None
            if runtime_result['status'] and runtime_result['data']:
                tbl_last_run = runtime_result['data'].get(table_name)
                if tbl_last_run:
                    last_run = str(tbl_last_run)
                    logger.info(f"Last run for {table_name}: {last_run}")
            if not last_run:
                logger.info("No previous run, fetching all emails")

            tables_last_runs[table_name] = last_run

            allowed_types = set()
            for fc in table_cfg['files']:
                for at in fc.get('allowed_attachment_types', []):
                    allowed_types.add(at)

            filter_str = build_filter(
                table_cfg.get('sender_email'),
                table_cfg.get('subject_starts_with'),
                table_cfg.get('has_attachments'),
                last_run,
                current_run=start_time
            )

            logger.info("Fetching emails")
            params = {
                '$select': 'id,subject,from,receivedDateTime'
            }
            if filter_str:
                params['$filter'] = filter_str

            messages_url = buildGraphURL(
                cfg['graph_api']['base_url'],
                'users',
                resource_id=user_email,
                subresource='mailFolders/Inbox/messages',
                params=params
            )

            email_result = _api_retry(requestGraphData)(messages_url, headers)

            if not email_result['status']:
                logger.error(f"Email fetch failed for {table_name}: {email_result['message']}")
                total_email_errors += 1
                table_email_errors[table_name] += 1
                all_details.append((None, table_name, 'email_error', f"Email fetch failed: {email_result['message']}", table_name, 0))
                continue

            emails = email_result['data'] or []
            emails = sorted(emails, key=lambda x: x.get('receivedDateTime', ''))
            logger.info(f"Fetched {len(emails)} emails")
            total_emails_fetched += len(emails)

            for email in emails:
                try:
                    eid = email.get('id')
                    subj = email.get('subject', 'No Subject')
                    logger.info(f"Processing email: subject='{subj}', id={eid}")

                    attach_url = buildGraphURL(
                        cfg['graph_api']['base_url'],
                        'users',
                        resource_id=user_email,
                        subresource='messages',
                        extra_path=f"{eid}/attachments"
                    )

                    attach_result = _api_retry(requestGraphData)(attach_url, headers)

                    if not attach_result['status']:
                        logger.error(f"Attachment fetch failed for email {subj}: {attach_result['message']}")
                        total_email_errors += 1
                        table_email_errors[table_name] += 1
                        all_details.append((eid, subj, 'email_error', f"Attachment fetch failed: {attach_result['message']}", table_name, 0))
                        continue

                    attachments = attach_result['data']

                    if not attachments:
                        logger.info("No attachments")
                        continue

                    logger.info(f"Found {len(attachments)} attachments")

                    has_zip = False
                    for att in attachments:
                        name = att.get('name', '')
                        ext = Path(name).suffix.lower().lstrip('.')

                        if ext not in allowed_types:
                            logger.info(f"  Filtered attachment {name} (not an allowed attachment type: .{ext})")
                            continue

                        if ext == 'zip':
                            has_zip = True
                            total_zips += 1
                            result = process_zip(att, eid, start_time, db, table_name, table_cfg, debug_cfg)
                            total_files_extracted += result['files_extracted']
                            total_filtered_ext += result['filtered_by_ext']
                            total_filtered_name += result['filtered_by_name']
                            total_loaded += result['loaded']
                            total_failed += result['failed']
                            table_failed[table_name] += result['failed']
                            table_loaded_rows[table_name] += sum(rows for _, _, status, _, _, rows in result['details'] if status == 'loaded')
                            all_details.extend(result['details'])
                        else:
                            logger.warning(f"  Attachment type '.{ext}' allowed but not yet supported (coming soon): {name}")
                            total_unsupported += 1

                    if has_zip:
                        total_emails_with_zip += 1

                except Exception as e:
                    logger.error(f"Email error ({subj}): {e}")
                    total_email_errors += 1
                    table_email_errors[table_name] += 1
                    all_details.append((eid, subj, 'email_error', str(e), table_name, 0))
                    continue

        end_time = datetime.now(timezone.utc)
        runtime = (end_time - start_time).total_seconds()

        logger.info("Updating control table (per-table)")
        fmt = '%Y-%m-%d %H:%M:%S.%f'
        start_time_str = start_time.strftime(fmt)[:-3]
        end_time_str = end_time.strftime(fmt)[:-3]

        tables_updated = []
        tables_skipped = []
        for tbl in target_tables:
            tbl_failures = table_failed.get(tbl, 0)
            tbl_errors = table_email_errors.get(tbl, 0)
            tbl_rows = table_loaded_rows.get(tbl, 0)

            if tbl_failures > 0 or tbl_errors > 0:
                logger.info(f"Skipping control table update for {tbl} (failed={tbl_failures}, email_errors={tbl_errors})")
                tables_skipped.append(tbl)
                continue

            if tbl_rows == 0:
                logger.info(f"Skipping control table update for {tbl} (no rows loaded)")
                continue

            tbl_cfg = target_tables[tbl]
            control_result = _snowflake_retry(load_control_table)(
                CURRENT_TIMESTAMP=start_time_str,
                Incremental_Start_Value=tables_last_runs.get(tbl),
                Incremental_End_Value=start_time_str,
                Extraction_Start_Time=start_time_str,
                Extraction_End_Time=end_time_str,
                table_name=tbl,
                MAX_FILE_DATE=start_time_str,
                rows_loaded=tbl_rows,
                schema=tbl_cfg['schema'],
                db=db
            )
            if not control_result['status']:
                logger.error(f"Control update failed for {tbl}")
                tables_skipped.append(tbl)
            else:
                logger.info(f"Control table updated for {tbl} ({tbl_rows} rows)")
                tables_updated.append(tbl)

        control_updated = len(tables_updated) > 0 and len(tables_skipped) == 0

        files_to_process = total_loaded + total_failed

        logger.info("=" * 60)
        logger.info("SUMMARY")
        logger.info("=" * 60)
        logger.info(f"Tables processed:              {len(target_tables)}")
        logger.info(f"Emails fetched:                {total_emails_fetched}")
        logger.info(f"Emails with zip attachments:   {total_emails_with_zip}")
        logger.info(f"Zip files processed:           {total_zips}")
        logger.info(f"Files extracted from zips:     {total_files_extracted}")
        logger.info(f"  Filtered by extension:      -{total_filtered_ext}")
        logger.info(f"  Filtered by filename:       -{total_filtered_name}")
        logger.info(f"Files to process:              {files_to_process}")
        logger.info(f"  Loaded successfully:         {total_loaded}")
        logger.info(f"  Failed to load:              {total_failed}")
        logger.info(f"Email errors:                  {total_email_errors}")
        logger.info(f"Unsupported attachment types:  {total_unsupported}")
        if tables_updated:
            logger.info(f"Control table updated:         {', '.join(tables_updated)}")
        if tables_skipped:
            logger.info(f"Control table skipped:         {', '.join(tables_skipped)}")
        logger.info(f"Runtime:                       {int(runtime)}s")
        logger.info("=" * 60)

        failed_items = [(eid, fname, msg) for eid, fname, status, msg, _tbl, _rows in all_details if status == 'failed']
        error_items = [(eid, fname, msg) for eid, fname, status, msg, _tbl, _rows in all_details if status == 'email_error']

        def group_by_email(items):
            grouped = {}
            for eid, fname, msg in items:
                if eid not in grouped:
                    grouped[eid] = []
                grouped[eid].append((fname, msg))
            return grouped

        if failed_items:
            logger.error("FAILED FILES:")
            for eid, files in group_by_email(failed_items).items():
                logger.error(f"  {eid}:")
                for fname, err in files:
                    logger.error(f"{fname}: {err}")

        if error_items:
            logger.error("EMAIL ERRORS:")
            for eid, errors in group_by_email(error_items).items():
                logger.error(f"  {eid}:")
                for name, err in errors:
                    logger.error(f"{name}: {err}")

        if invalid_tables:
            logger.error(f"INVALID TABLES: {', '.join(invalid_tables)}")

        if total_failed > 0 or total_email_errors > 0 or invalid_tables or total_unsupported > 0:
            errors = []
            if total_failed > 0:
                errors.append(f"{total_failed} file(s) failed")
            if total_email_errors > 0:
                errors.append(f"{total_email_errors} email error(s)")
            if invalid_tables:
                errors.append(f"invalid table(s): {', '.join(invalid_tables)}")
            if total_unsupported > 0:
                errors.append(f"{total_unsupported} unsupported attachment type(s)")
            raise Exception(f"Processing failed: {', '.join(errors)}")

        logger.info("Done")

    except Exception as e:
        logger.error(f"Critical error: {e}")
        raise


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--tables', type=str, default=None, help='Comma-separated list of table names to process')
    args = parser.parse_args()
    tables = [t.strip() for t in args.tables.split(',')] if args.tables else None
    main(tables=tables)
