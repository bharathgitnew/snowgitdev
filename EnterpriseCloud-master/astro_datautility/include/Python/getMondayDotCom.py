import requests
import json
import time
import argparse
from datetime import datetime, timezone, timedelta
import sys
import os
import include.Python.TELTools as TT


# CONFIG_FILE_PATH = r'C:\Users\223163\Documents\gh\EnterpriseCloud\astro_datautility\include\Configuration\TelTools_Monday.json'
CONFIG_FILE_PATH = '/usr/local/airflow/include/Configuration/TelTools_Monday.json'

MONDAY_URL = "https://api.monday.com/v2"
DEFAULT_LIMIT_PER_PAGE = 200
DEFAULT_ACTIVITY_LOG_LIMIT_PER_PAGE = 1000
DEFAULT_FULL_LOAD_START_TIME = "1900-01-01T00:00:00Z"
DEFAULT_INCREMENTAL_END_TIME = "9999-12-31T23:59:59Z"
MAX_ACTIVITY_LOG_RECORDS_PER_WINDOW = 10000
MIN_ACTIVITY_LOG_WINDOW_SPAN = timedelta(microseconds=1)
MAX_ACTIVITY_LOG_WINDOW_SPLIT_DEPTH = 24

ENV = os.environ.get('SNOWFLAKE_ENV', 'DEV')
LZ_DB = os.environ.get("SNOWFLAKE_LZ", 'LZ_DEV')

FETCH_QUERY = """
query FetchIncrementalData($boardId: [ID!], $limit: Int!, $since_time: CompareValue!) {
  complexity {
    before
    after
    reset_in_x_seconds
  }
  boards(ids: $boardId) {
    name
    items_page(
      limit: $limit
      query_params: {
        rules: [
          {
            column_id: "__last_updated__"
            operator: between
            compare_value: $since_time
            compare_attribute: "UPDATED_AT"
          }
        ]
      }
    ) {
      cursor
      items {
        id
        name
        updated_at
        created_at
        column_values {
          column {
            title
          }
          id
          type
          text
          value

          ... on StatusValue {
            id
            index
            label
            text
          }

          ... on DateValue {
            date
            time
          }

          ... on TextValue {
            text
            value
          }

          ... on NumbersValue {
            number
            id
            symbol
            direction
          }

          ... on FormulaValue {
            id
            value
            display_value
          }

          ... on PeopleValue {
            persons_and_teams {
              id
              kind
            }
          }

          ... on CreationLogValue {
            created_at
            creator {
              id
              name
            }
          }

          ... on LastUpdatedValue {
            updated_at
            value
          }

          ... on TimelineValue {
            from
            to
          }

          ... on DependencyValue {
            linked_item_ids
            linked_items {
              id
            }
          }

          ... on LongTextValue {
            text
            value
          }

          ... on DropdownValue {
            values {
              label
              id
            }
            column {
              id
            }
          }

          ... on FileValue {
            id
            files {
              ... on FileAssetValue {
                asset_id
              }
            }
          }

          ... on LinkValue {
            url
            url_text
          }

          ... on MirrorValue {
            display_value
            id
          }

          ... on ItemIdValue {
            value
            text
          }
        }
        subitems {
          id
          name
          updated_at
          created_at
          column_values {
            column {
              title
            }
            id
            type
            text
            value

            ... on StatusValue {
              id
              index
              label
              text
            }

            ... on DateValue {
              date
              time
            }

            ... on TextValue {
              text
              value
            }

            ... on NumbersValue {
              number
              id
              symbol
              direction
            }

            ... on FormulaValue {
              id
              value
              display_value
            }

            ... on PeopleValue {
              persons_and_teams {
                id
                kind
              }
            }

            ... on CreationLogValue {
              created_at
              creator {
                id
                name
              }
            }

            ... on LastUpdatedValue {
              updated_at
              value
            }

            ... on TimelineValue {
              from
              to
            }

            ... on DependencyValue {
              linked_item_ids
              linked_items {
                id
              }
            }

            ... on LongTextValue {
              text
              value
            }

            ... on DropdownValue {
              values {
                label
                id
              }
              column {
                id
              }
            }

            ... on FileValue {
              id
              files {
                ... on FileAssetValue {
                  asset_id
                }
              }
            }

            ... on LinkValue {
              url
              url_text
            }

            ... on MirrorValue {
              display_value
              id
            }

            ... on ItemIdValue {
              value
              text
            }
          }
        }
      }
    }
  }
}
""".replace('\n', ' ').replace('  ', ' ')

FETCH_QUERY_PAGINATED = """
query FetchPaginatedData($limit: Int!, $cursor: String!) {
  complexity {
    before
    after
    reset_in_x_seconds
  }
  next_items_page(limit: $limit, cursor: $cursor) {
    cursor
    items {
      id
      name
      updated_at
      created_at
      column_values {
        column {
          title
        }
        id
        type
        text
        value

        ... on StatusValue {
          id
          label
          index
          text
        }

        ... on DateValue {
          date
          time
        }

        ... on TextValue {
          text
          value
        }

        ... on NumbersValue {
          number
          id
          symbol
          direction
        }

        ... on FormulaValue {
          id
          value
          display_value
        }

        ... on PeopleValue {
          persons_and_teams {
            id
            kind
          }
        }

        ... on CreationLogValue {
          created_at
          creator {
            id
            name
          }
        }

        ... on LastUpdatedValue {
          updated_at
          value
        }

        ... on TimelineValue {
          from
          to
        }

        ... on DependencyValue {
          linked_item_ids
          linked_items {
            id
          }
        }

        ... on LongTextValue {
          text
          value
        }

        ... on DropdownValue {
          values {
            label
            id
          }
          column {
            id
          }
        }

        ... on FileValue {
          id
          files {
            ... on FileAssetValue {
              asset_id
            }
          }
        }

        ... on LinkValue {
          url
          url_text
        }

        ... on MirrorValue {
          display_value
          id
        }

        ... on ItemIdValue {
          value
          text
        }
      }
      subitems {
        id
        name
        updated_at
        created_at
        column_values {
          column {
            title
          }
          id
          type
          text
          value

          ... on StatusValue {
            id
            index
            label
            text
          }

          ... on DateValue {
            date
            time
          }

          ... on TextValue {
            text
            value
          }

          ... on NumbersValue {
            number
            id
            symbol
            direction
          }

          ... on FormulaValue {
            id
            value
            display_value
          }

          ... on PeopleValue {
            persons_and_teams {
              id
              kind
            }
          }

          ... on CreationLogValue {
            created_at
            creator {
              id
              name
            }
          }

          ... on LastUpdatedValue {
            updated_at
            value
          }

          ... on TimelineValue {
            from
            to
          }

          ... on DependencyValue {
            linked_item_ids
            linked_items {
              id
            }
          }

          ... on LongTextValue {
            text
            value
          }

          ... on DropdownValue {
            values {
              label
              id
            }
            column {
              id
            }
          }

          ... on FileValue {
            id
            files {
              ... on FileAssetValue {
                asset_id
              }
            }
          }

          ... on LinkValue {
            url
            url_text
          }

          ... on MirrorValue {
            display_value
            id
          }

          ... on ItemIdValue {
            value
            text
          }
        }
      }
    }
  }
}
""".replace('\n', ' ').replace('  ', ' ')

FETCH_ACTIVITY_LOGS_QUERY = """
query FetchBoardActivityLogs($boardId: [ID!], $from: ISO8601DateTime!, $to: ISO8601DateTime!, $limit: Int!, $page: Int!) {
  complexity {
    before
    after
    reset_in_x_seconds
  }
  boards(ids: $boardId) {
    id
    name
    activity_logs(
      from: $from
      to: $to
      limit: $limit
      page: $page
    ) {
      id
      event
      data
      entity
      user_id
      account_id
      created_at
    }
  }
}
""".replace('\n', ' ').replace('  ', ' ')


class MondayIngestionError(Exception):
    pass


def get_api_key():
    try:
        api_key = TT.getAzureSecret('MONDAY-API-KEY-Y').value
        return api_key, "Success", 0
    except Exception as e:
        return None, f"Failed to fetch API key from KeyVault: {str(e)}", 1


def parse_arguments():
    parser = argparse.ArgumentParser(description='Monday.com to Snowflake Ingestion')

    parser.add_argument(
        '--boards',
        type=str,
        help='Comma-separated list of board names to process (case-insensitive)'
    )

    parser.add_argument(
        '--full-load',
        '--FULL-LOAD',
        '--Full-Load',
        action='store_true',
        dest='full_load',
        help='Full load mode - fetch all data from 1900-01-01T00:00:00Z'
    )

    return parser.parse_args()


def read_config_file(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as json_file:
            return json.load(json_file)
    else:
        raise FileNotFoundError(f"Config file not found at {file_path}")


def fetch_with_retry(query, variables, headers, max_retries=5):
    for attempt in range(max_retries):
        try:
            response = requests.post(
                MONDAY_URL,
                json={'query': query, 'variables': variables},
                headers=headers,
                timeout=60
            )

            if response.status_code >= 400 and response.status_code not in [429, 500, 503]:
                raise Exception(f"HTTP {response.status_code}: {response.text}")

            if response.status_code in [429, 500, 503]:
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    if response.status_code == 429:
                        try:
                            body = response.json()
                            retry_after = body.get('retry_in_seconds')
                            if retry_after:
                                wait_time = max(wait_time, int(retry_after))
                                print(f"    Rate limited (429). Server says retry in {retry_after}s, waiting {wait_time}s...")
                            else:
                                print(f"    Rate limited (429), retrying in {wait_time}s...")
                        except Exception:
                            print(f"    Rate limited (429), retrying in {wait_time}s...")
                    else:
                        print(f"    HTTP {response.status_code}, retrying in {wait_time}s...")
                    time.sleep(wait_time)
                    continue
                else:
                    raise Exception(f"Max retries reached for HTTP {response.status_code}")

            data = response.json()

            if 'errors' in data:
                raise Exception(f"GraphQL Error: {data['errors']}")

            return data

        except requests.exceptions.Timeout:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt
                print(f"    Request timeout (attempt {attempt + 1}/{max_retries}), retrying in {wait_time}s...")
                time.sleep(wait_time)
                continue
            else:
                raise Exception("Request timeout after max retries")
        except Exception as e:
            if attempt < max_retries - 1 and "transient" in str(e).lower():
                continue
            raise e

    return None


def get_extract_type(board_config):
    return str(board_config.get('EXTRACT_TYPE', 'BOARD_ITEMS')).upper()


def parse_utc_iso_timestamp(timestamp_value):
  if isinstance(timestamp_value, datetime):
    parsed_timestamp = timestamp_value
  else:
    normalized_timestamp = str(timestamp_value).strip()
    if normalized_timestamp.endswith("Z"):
      normalized_timestamp = normalized_timestamp[:-1] + "+00:00"
    parsed_timestamp = datetime.fromisoformat(normalized_timestamp)

  if parsed_timestamp.tzinfo is None:
    parsed_timestamp = parsed_timestamp.replace(tzinfo=timezone.utc)

  return parsed_timestamp.astimezone(timezone.utc)


def format_utc_iso_timestamp(timestamp_value):
  if timestamp_value.tzinfo is None:
    timestamp_value = timestamp_value.replace(tzinfo=timezone.utc)

  return timestamp_value.astimezone(timezone.utc).isoformat(timespec='microseconds').replace("+00:00", "Z")


def get_current_utc_timestamp():
  return format_utc_iso_timestamp(datetime.now(timezone.utc).replace(microsecond=0))


def convert_activity_log_created_at(timestamp_value):
  try:
    unix_seconds = int(timestamp_value) / 10000000
    return format_utc_iso_timestamp(datetime.fromtimestamp(unix_seconds, timezone.utc))
  except (TypeError, ValueError, OSError, OverflowError):
    return None


def split_activity_log_window(window_start, window_end):
  if window_end <= window_start:
    return None

  midpoint = window_start + ((window_end - window_start) / 2)
  left_end = midpoint - MIN_ACTIVITY_LOG_WINDOW_SPAN

  if midpoint <= window_start or left_end < window_start or midpoint > window_end:
    return None

  return ((window_start, left_end), (midpoint, window_end))


def fetch_activity_log_window_batches(board_id, window_start, window_end, limit_per_page, headers, activity_board_name):
  page_number = 0
  total_window_records = 0
  max_created_at = None
  page_batches = []

  window_start_iso = format_utc_iso_timestamp(window_start)
  window_end_iso = format_utc_iso_timestamp(window_end)

  while True:
    page_number += 1

    try:
      data = fetch_with_retry(
        FETCH_ACTIVITY_LOGS_QUERY,
        {
          "boardId": [int(board_id)],
          "from": window_start_iso,
          "to": window_end_iso,
          "limit": limit_per_page,
          "page": page_number
        },
        headers
      )

      if not data:
        return {
          'status': 'FAILED',
          'error': f"No data returned from API for window {window_start_iso} to {window_end_iso}",
          'activity_board_name': activity_board_name,
          'page_batches': [],
          'total_window_records': total_window_records,
          'max_created_at': max_created_at,
          'loaded_pages': len(page_batches)
        }

      complexity_info = data.get('data', {}).get('complexity')
      if complexity_info:
        remaining = complexity_info.get('after')
        reset_in = complexity_info.get('reset_in_x_seconds')
        if remaining is not None and remaining < 100000:
          wait = reset_in if reset_in and reset_in > 0 else 60
          print(f"    Low complexity budget ({remaining}). Waiting {wait}s for reset...")
          time.sleep(wait)

      boards = data.get('data', {}).get('boards', [])
      if not boards:
        return {
          'status': 'SUCCESS',
          'error': None,
          'activity_board_name': activity_board_name,
          'page_batches': page_batches,
          'total_window_records': total_window_records,
          'max_created_at': max_created_at,
          'loaded_pages': len(page_batches)
        }

      activity_board_name = boards[0].get('name') or activity_board_name
      records = boards[0].get('activity_logs') or []

      if len(records) == 0:
        return {
          'status': 'SUCCESS',
          'error': None,
          'activity_board_name': activity_board_name,
          'page_batches': page_batches,
          'total_window_records': total_window_records,
          'max_created_at': max_created_at,
          'loaded_pages': len(page_batches)
        }

      if page_number == 1:
        print(f"  Page 1: {len(records)} records")
      elif page_number % 10 == 0:
        print(f"  Page {page_number}: {total_window_records} records fetched in current window")

      page_batches.append({
        'page_number': page_number,
        'records': enrich_activity_log_records(records, board_id, activity_board_name)
      })
      total_window_records += len(records)

      page_timestamps = [
        parse_utc_iso_timestamp(timestamp)
        for timestamp in [convert_activity_log_created_at(record.get('created_at')) for record in records]
        if timestamp
      ]

      if page_timestamps:
        page_max_created_at = max(page_timestamps)
        if max_created_at is None or page_max_created_at > max_created_at:
          max_created_at = page_max_created_at

      if total_window_records >= MAX_ACTIVITY_LOG_RECORDS_PER_WINDOW:
        return {
          'status': 'SATURATED',
          'error': None,
          'activity_board_name': activity_board_name,
          'page_batches': [],
          'total_window_records': total_window_records,
          'max_created_at': max_created_at,
          'loaded_pages': len(page_batches)
        }

      if len(records) < limit_per_page:
        return {
          'status': 'SUCCESS',
          'error': None,
          'activity_board_name': activity_board_name,
          'page_batches': page_batches,
          'total_window_records': total_window_records,
          'max_created_at': max_created_at,
          'loaded_pages': len(page_batches)
        }

      time.sleep(1)

    except Exception as e:
      return {
        'status': 'FAILED',
        'error': f"Window {window_start_iso} to {window_end_iso} fetch failed on page {page_number}: {str(e)}",
        'activity_board_name': activity_board_name,
        'page_batches': [],
        'total_window_records': total_window_records,
        'max_created_at': max_created_at,
        'loaded_pages': len(page_batches)
      }


def enrich_activity_log_records(records, board_id, board_name):
    enriched_records = []
    for record in records:
        enriched_record = dict(record)
        enriched_record['board_id'] = str(board_id)
        enriched_record['board_name'] = board_name
        enriched_records.append(enriched_record)
    return enriched_records


def fetch_and_load_board(board_name, board_config, full_load, script_start_time, headers):
    board_start_time = datetime.now()

    board_id = board_config['BOARD_ID']
    sf_schema = board_config['SNOWFLAKE_SCHEMA_NAME']
    sf_table = board_config['SNOWFLAKE_TABLE_NAME']
    limit_per_page = board_config.get('LIMIT_PER_PAGE', DEFAULT_LIMIT_PER_PAGE)

    print(f"\nProcessing {board_name} (ID: {board_id})")
    print(f"Target: {LZ_DB}.{sf_schema}.{sf_table}")

    if full_load:
        since_time = DEFAULT_FULL_LOAD_START_TIME
        print("Mode: FULL LOAD")
    else:
        print("Mode: INCREMENTAL")
        last_fetch, messages = TT.readControlTable(LZ_DB, sf_schema, sf_table)

        if 'FAIL_SIGNAL' in messages:
            error_msg = f"Cannot access control table {LZ_DB}.{sf_schema}.CONTROLTABLE"
            print(f"Failed: {error_msg}")
            return {
                'status': 'FAILED',
                'board_name': board_name,
                'records_loaded': 0,
                'error': error_msg,
                'base_filename': f"{board_name}_control_table_error",
                'LZ_DB': LZ_DB,
                'sf_schema': sf_schema,
                'sf_table': sf_table
            }

        if last_fetch:
            since_time = last_fetch
            if not since_time:
                since_time = DEFAULT_FULL_LOAD_START_TIME
                print("Could not parse last fetch time, using default")
        else:
            since_time = DEFAULT_FULL_LOAD_START_TIME

        print(f"Fetching from: {since_time}")

    base_filename = f"{board_name}_{board_start_time.strftime('%Y%m%d_%H%M%S')}"

    page_number = 0
    total_records_loaded = 0
    max_updated_at = since_time
    current_cursor = None
    has_next_page = True
    fetch_error = None
    load_error = None

    while has_next_page:
        page_number += 1

        try:
            if current_cursor is None:
                query = FETCH_QUERY
                variables = {
                    "boardId": [int(board_id)],
                    "limit": limit_per_page,
                  "since_time": [since_time, DEFAULT_INCREMENTAL_END_TIME]
                }
            else:
                query = FETCH_QUERY_PAGINATED
                variables = {
                    "limit": limit_per_page,
                    "cursor": current_cursor
                }

            data = fetch_with_retry(query, variables, headers)

            if not data:
                fetch_error = "No data returned from API"
                print(f"  Page {page_number}: {fetch_error}")
                break

            complexity_info = data.get('data', {}).get('complexity')
            if complexity_info:
                remaining = complexity_info.get('after')
                reset_in = complexity_info.get('reset_in_x_seconds')
                if remaining is not None and remaining < 100000:
                    wait = reset_in if reset_in and reset_in > 0 else 60
                    print(f"    Low complexity budget ({remaining}). Waiting {wait}s for reset...")
                    time.sleep(wait)

            if current_cursor is None:
              boards = data.get('data', {}).get('boards', [])
              if not boards:
                if page_number == 1:
                  print("  No new records")
                has_next_page = False
                break
              items_page = boards[0].get('items_page', {})
            else:
              items_page = data.get('data', {}).get('next_items_page', {})

            records = items_page.get('items', [])

            if len(records) == 0:
                has_next_page = False
                break

            if page_number == 1:
                print(f"Fetching data...")
                print(f"Page 1: {len(records)} records")
            elif page_number % 10 == 0:
                print(f"Page {page_number}: {total_records_loaded} total records loaded")

            page_filename = f"{base_filename}_page_{page_number:03d}"

            try:
                messages = TT.putSnowflakeDataFrame(
                    LZ_DB,
                    sf_schema,
                    sf_table,
                    records,
                    page_filename,
                    board_start_time,
                    len(records)
                )

                if 'FAIL_SIGNAL' not in messages:
                    total_records_loaded += len(records)

                    try:
                        page_max_timestamp = max([r['updated_at'] for r in records])
                        page_max_datetime = page_max_timestamp

                        if page_max_datetime and page_max_datetime > max_updated_at:
                            max_updated_at = page_max_datetime
                    except (KeyError, ValueError) as e:
                        print(f"  Page {page_number}: Cannot extract updated_at - {e}")
                        load_error = f"Cannot extract updated_at from records: {e}"
                        break
                else:
                    load_error = f"Cannot load data to target table: {messages}"
                    print(f"  Page {page_number}: Load failed - {messages}")
                    break

            except Exception as e:
                load_error = f"Cannot load data to target table: {str(e)}"
                print(f"  Page {page_number}: Load exception - {e}")
                break

            current_cursor = items_page.get('cursor')
            if current_cursor and records:
                has_next_page = True
                time.sleep(1)
            else:
                has_next_page = False

        except Exception as e:
            fetch_error = f"Page {page_number} fetch failed: {str(e)}"
            print(f"  Page {page_number}: Fetch exception - {e}")
            break

    board_end_time = datetime.now()

    if page_number > 1 and page_number % 10 != 0 and total_records_loaded > 0:
        print(f"Loaded {total_records_loaded} total records across {page_number} pages")

    if fetch_error is None and load_error is None:
        status = 'SUCCESS'
        error_message = None
        print(f"Completed. Loaded {total_records_loaded} records")
    elif (fetch_error or load_error) and total_records_loaded > 0:
        status = 'PARTIAL'
        error_message = fetch_error or load_error
        print(f"Partial completion. Loaded {total_records_loaded} records before error: {error_message}")
    else:
        status = 'FAILED'
        error_message = fetch_error or load_error or "Unknown error"
        print(f"Failed: {error_message}")

    if load_error:
        print(f"Skipping control table update due to load failure")
        return {
            'status': 'FAILED',
            'board_name': board_name,
            'records_loaded': total_records_loaded,
            'error': error_message,
            'base_filename': base_filename,
            'LZ_DB': LZ_DB,
            'sf_schema': sf_schema,
            'sf_table': sf_table
        }

    try:
        if status in ['SUCCESS', 'PARTIAL']:
            print(f"Updating control table with max timestamp: {max_updated_at}")
            TT.loadControlTable(
                LZ_DB,
                sf_schema,
                script_start_time,
                since_time,
                max_updated_at,
                board_start_time.strftime('%Y-%m-%d %H:%M:%S'),
                board_end_time.strftime('%Y-%m-%d %H:%M:%S'),
                board_name,
                max_updated_at,
                total_records_loaded
            )
    except Exception as e:
        print(f"Warning: Control table update failed - {e}")
        print("Data loaded successfully but next run may re-fetch same records")
        if status == 'SUCCESS':
            status = 'CONTROL_TABLE_FAILED'
            error_message = f"Control table update failed: {str(e)}"
        elif status == 'PARTIAL':
            error_message = f"{error_message}; Also control table update failed: {str(e)}"

    return {
        'status': status,
        'board_name': board_name,
        'records_loaded': total_records_loaded,
        'error': error_message,
        'base_filename': base_filename,
        'LZ_DB': LZ_DB,
        'sf_schema': sf_schema,
        'sf_table': sf_table
    }


def fetch_and_load_activity_logs(board_name, board_config, full_load, script_start_time, headers):
    board_start_time = datetime.now()
    extraction_window_end = get_current_utc_timestamp()

    board_id = board_config['BOARD_ID']
    sf_schema = board_config['SNOWFLAKE_SCHEMA_NAME']
    sf_table = board_config['SNOWFLAKE_TABLE_NAME']
    limit_per_page = board_config.get('LIMIT_PER_PAGE', DEFAULT_ACTIVITY_LOG_LIMIT_PER_PAGE)

    print(f"\nProcessing {board_name} (ID: {board_id})")
    print(f"Target: {LZ_DB}.{sf_schema}.{sf_table}")
    print("Extract Type: ACTIVITY_LOG")

    if full_load:
        since_time = DEFAULT_FULL_LOAD_START_TIME
        print("Mode: FULL LOAD")
    else:
        print("Mode: INCREMENTAL")
        last_fetch, messages = TT.readControlTable(LZ_DB, sf_schema, sf_table)

        if 'FAIL_SIGNAL' in messages:
            error_msg = f"Cannot access control table {LZ_DB}.{sf_schema}.CONTROLTABLE"
            print(f"Failed: {error_msg}")
            return {
                'status': 'FAILED',
                'board_name': board_name,
                'records_loaded': 0,
                'error': error_msg,
                'base_filename': f"{board_name}_control_table_error",
                'LZ_DB': LZ_DB,
                'sf_schema': sf_schema,
                'sf_table': sf_table
            }

        if last_fetch:
            since_time = last_fetch
            if not since_time:
                since_time = DEFAULT_FULL_LOAD_START_TIME
                print("Could not parse last fetch time, using default")
        else:
            since_time = DEFAULT_FULL_LOAD_START_TIME

    print(f"Fetching from: {since_time}")
    print(f"Fetching to: {extraction_window_end}")

    base_filename = f"{board_name}_{board_start_time.strftime('%Y%m%d_%H%M%S')}"

    total_records_loaded = 0
    max_created_at = None
    fetch_error = None
    load_error = None
    activity_board_name = board_config.get('BOARD_NAME', board_name)
    loaded_page_count = 0
    processed_window_count = 0
    window_stack = [
      (
        parse_utc_iso_timestamp(since_time),
        parse_utc_iso_timestamp(extraction_window_end),
        0
      )
    ]

    while window_stack:
      window_start, window_end, split_depth = window_stack.pop()

      if window_end < window_start:
        continue

      processed_window_count += 1
      window_start_iso = format_utc_iso_timestamp(window_start)
      window_end_iso = format_utc_iso_timestamp(window_end)

      print(f"Window {processed_window_count}: {window_start_iso} -> {window_end_iso}")

      window_result = fetch_activity_log_window_batches(
        board_id,
        window_start,
        window_end,
        limit_per_page,
        headers,
        activity_board_name
      )

      activity_board_name = window_result.get('activity_board_name') or activity_board_name

      if window_result['status'] == 'FAILED':
        fetch_error = window_result['error']
        print(f"  Window {processed_window_count}: {fetch_error}")
        break

      if window_result['status'] == 'SATURATED':
        split_windows = split_activity_log_window(window_start, window_end)

        if split_windows is None or split_depth >= MAX_ACTIVITY_LOG_WINDOW_SPLIT_DEPTH:
          fetch_error = (
            f"Window {window_start_iso} to {window_end_iso} hit monday's 10000-record cap "
            f"and could not be split further"
          )
          print(f"  Window {processed_window_count}: {fetch_error}")
          break

        older_window, newer_window = split_windows
        print(
          "  Window hit monday's 10000-record cap. Splitting into "
          f"{format_utc_iso_timestamp(older_window[0])} -> {format_utc_iso_timestamp(older_window[1])} and "
          f"{format_utc_iso_timestamp(newer_window[0])} -> {format_utc_iso_timestamp(newer_window[1])}"
        )

        window_stack.append((newer_window[0], newer_window[1], split_depth + 1))
        window_stack.append((older_window[0], older_window[1], split_depth + 1))
        continue

      if window_result['loaded_pages'] == 0:
        continue

      print(
        f"  Window complete: {window_result['total_window_records']} records "
        f"across {window_result['loaded_pages']} pages"
      )

      if total_records_loaded == 0:
        print("Fetching activity log data...")

      for page_batch in window_result['page_batches']:
        page_filename = (
          f"{base_filename}_window_{processed_window_count:03d}_page_{page_batch['page_number']:03d}"
        )

        try:
          messages = TT.putSnowflakeDataFrame(
            LZ_DB,
            sf_schema,
            sf_table,
            page_batch['records'],
            page_filename,
            board_start_time,
            len(page_batch['records'])
          )

          if 'FAIL_SIGNAL' not in messages:
            total_records_loaded += len(page_batch['records'])
            loaded_page_count += 1
          else:
            load_error = f"Cannot load data to target table: {messages}"
            print(f"  Window {processed_window_count}: Load failed - {messages}")
            break

        except Exception as e:
          load_error = f"Cannot load data to target table: {str(e)}"
          print(f"  Window {processed_window_count}: Load exception - {e}")
          break

      if load_error:
        break

      window_max_created_at = window_result.get('max_created_at')
      if window_max_created_at and (max_created_at is None or window_max_created_at > max_created_at):
        max_created_at = window_max_created_at

    board_end_time = datetime.now()

    if loaded_page_count > 0:
      print(
        f"Loaded {total_records_loaded} total records across {loaded_page_count} loaded pages "
        f"in {processed_window_count} windows"
      )

    if fetch_error is None and load_error is None:
        status = 'SUCCESS'
        error_message = None
        print(f"Completed. Loaded {total_records_loaded} records")
    elif (fetch_error or load_error) and total_records_loaded > 0:
        status = 'PARTIAL'
        error_message = fetch_error or load_error
        print(f"Partial completion. Loaded {total_records_loaded} records before error: {error_message}")
    else:
        status = 'FAILED'
        error_message = fetch_error or load_error or "Unknown error"
        print(f"Failed: {error_message}")

    if load_error:
        print("Skipping control table update due to load failure")
        return {
            'status': 'FAILED',
            'board_name': board_name,
            'records_loaded': total_records_loaded,
            'error': error_message,
            'base_filename': base_filename,
            'LZ_DB': LZ_DB,
            'sf_schema': sf_schema,
            'sf_table': sf_table
        }

    if status == 'PARTIAL':
        print("Skipping control table update due to partial activity log extraction")

    try:
      if status == 'SUCCESS':
        max_file_date = format_utc_iso_timestamp(max_created_at) if max_created_at else extraction_window_end
        print(f"Updating control table with window end: {extraction_window_end}")
        TT.loadControlTable(
          LZ_DB,
          sf_schema,
          script_start_time,
          since_time,
          extraction_window_end,
          board_start_time.strftime('%Y-%m-%d %H:%M:%S'),
          board_end_time.strftime('%Y-%m-%d %H:%M:%S'),
          board_name,
          max_file_date,
          total_records_loaded
        )
    except Exception as e:
        print(f"Warning: Control table update failed - {e}")
        print("Data loaded successfully but next run may re-fetch the same window")
        if status == 'SUCCESS':
            status = 'CONTROL_TABLE_FAILED'
            error_message = f"Control table update failed: {str(e)}"

    return {
        'status': status,
        'board_name': board_name,
        'records_loaded': total_records_loaded,
        'error': error_message,
        'base_filename': base_filename,
        'LZ_DB': LZ_DB,
        'sf_schema': sf_schema,
        'sf_table': sf_table
    }


def run_ingestion(boards=None, full_load=False):
    script_start_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    print("Starting Monday.com ingestion")
    print(f"Environment: {ENV}, Database: {LZ_DB}")
    if boards:
        print(f"Processing boards: {boards}")
    if full_load:
        print("Full load mode")

    try:
        api_key, msg, status_code = get_api_key()
        if status_code != 0:
            raise MondayIngestionError(f"Failed to get API key: {msg}")
    except MondayIngestionError:
        raise
    except Exception as e:
        raise MondayIngestionError(f"Error fetching API key: {e}")

    headers = {
        "Authorization": api_key,
        "API-Version": "2025-04",
        "Content-Type": "application/json"
    }

    start_time = time.time()

    try:
        config = read_config_file(CONFIG_FILE_PATH)
    except Exception as e:
        raise MondayIngestionError(f"Error loading config: {e}")

    print(f"Config loaded: {len(config)} entries found")

    valid_boards = {
        k: v for k, v in config.items()
        if v.get('ACTIVE', '').upper() == 'TRUE'
    }

    if not valid_boards:
        raise MondayIngestionError("No active boards found in configuration")

    print(f"Found {len(valid_boards)} active extracts")

    if boards:
        board_list_input = [b.strip() for b in boards.split(',')]
        board_lookup = {k.lower(): k for k in valid_boards.keys()}

        filtered_boards = {}
        missing_boards = []

        for board_input in board_list_input:
            board_lower = board_input.lower()
            if board_lower in board_lookup:
                actual_key = board_lookup[board_lower]
                filtered_boards[actual_key] = valid_boards[actual_key]
            else:
                missing_boards.append(board_input)

        if missing_boards:
            print(f"Warning: These boards not found in config: {', '.join(missing_boards)}")

        if not filtered_boards:
            raise MondayIngestionError("No valid boards match the filter")

        print(f"Filtered to {len(filtered_boards)} boards: {', '.join(filtered_boards.keys())}")
        valid_boards = filtered_boards

    boards_to_process = sorted(valid_boards.items())

    successful = []
    partial = []
    failed = []
    control_table_issues = []
    total_records = 0

    for board_name, board_config in boards_to_process:
        try:
            extract_type = get_extract_type(board_config)

            if extract_type == 'ACTIVITY_LOG':
                result = fetch_and_load_activity_logs(board_name, board_config, full_load, script_start_time, headers)
            elif extract_type in ['BOARD_ITEMS', 'ITEMS']:
                result = fetch_and_load_board(board_name, board_config, full_load, script_start_time, headers)
            else:
                raise MondayIngestionError(f"Unsupported EXTRACT_TYPE '{extract_type}' for {board_name}")

            if result['status'] == 'SUCCESS':
                successful.append(board_name)
                total_records += result['records_loaded']
            elif result['status'] == 'PARTIAL':
                partial.append(result)
                total_records += result['records_loaded']
            elif result['status'] == 'CONTROL_TABLE_FAILED':
                control_table_issues.append(result)
                total_records += result['records_loaded']
            else:
                failed.append(result)

        except Exception as e:
            print(f"Unexpected error processing {board_name}: {e}")
            failed.append({
                'status': 'FAILED',
                'board_name': board_name,
                'records_loaded': 0,
                'error': f"Unexpected error: {str(e)}",
                'base_filename': f"{board_name}_error",
                'LZ_DB': LZ_DB,
                'sf_schema': board_config.get('SNOWFLAKE_SCHEMA_NAME', 'N/A'),
                'sf_table': board_config.get('SNOWFLAKE_TABLE_NAME', 'N/A')
            })

        time.sleep(2)

    execution_time = time.time() - start_time

    print(f"\nCompleted in {execution_time:.1f}s")
    print(f"Processed {len(boards_to_process)} boards: {len(successful)} succeeded, {len(partial)} partial, {len(failed)} failed")
    if control_table_issues:
        print(f"Warning: {len(control_table_issues)} boards loaded but control table not updated")
    print(f"Total records: {total_records:,}")

    if failed:
        print("\nFailed boards:")
        for f in failed:
            print(f"  {f['board_name']}: {f['error']}")

    if partial:
        print("\nPartial loads:")
        for p in partial:
            print(f"  {p['board_name']}: {p['records_loaded']} records loaded, then error: {p['error']}")
        print("\nCleanup queries available if needed:")
        for p in partial:
            print(f"  DELETE FROM {p['LZ_DB']}.{p['sf_schema']}.{p['sf_table']} WHERE _FILENAME LIKE '{p['base_filename']}_page_%';")

    if control_table_issues:
        print("\nControl table update failures:")
        for c in control_table_issues:
            print(f"  {c['board_name']}: {c['records_loaded']} records loaded successfully")
            print(f"    Issue: {c['error']}")
            print(f"    Action: Manually update {c['LZ_DB']}.{c['sf_schema']}.CONTROLTABLE or expect duplicates on next run")

    result_summary = {
        'successful': successful,
        'partial': partial,
        'failed': failed,
        'control_table_issues': control_table_issues,
        'total_records': total_records,
        'execution_time': execution_time,
        'boards_processed': len(boards_to_process)
    }

    if failed or partial or control_table_issues:
        print("\nCompleted with issues")
        raise MondayIngestionError(
            f"Ingestion completed with issues: {len(failed)} failed, {len(partial)} partial, "
            f"{len(control_table_issues)} control table issues"
        )

    print("\nCompleted successfully")
    return result_summary


def main():
    try:
        args = parse_arguments()
    except Exception as e:
        print(f"Error parsing arguments: {e}")
        sys.exit(1)

    try:
        run_ingestion(boards=args.boards, full_load=args.full_load)
        sys.exit(0)
    except MondayIngestionError as e:
        print(f"Ingestion error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()