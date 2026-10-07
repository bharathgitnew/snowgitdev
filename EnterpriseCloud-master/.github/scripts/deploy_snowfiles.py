"""
Deploy SQL files to Snowflake using execute_stream and TELToken substitution.

Usage:
    python deploy_snowfiles.py <file_or_directory>

- If you pass a file: it runs that single SQL file.
- If you pass a directory: it runs all files inside that directory.
"""

import os
import sys
import json
import io
import re
import snowflake.connector
from typing import Dict, Any

DEFAULT_TELTOKEN_PATH = os.path.join(
    ".github", "scripts", "TELToken.json"
)

TOKEN_PATTERN = re.compile(r"<<[A-Za-z_]+>>")

def load_env_config(branch: str, token_path: str) -> Dict[str, Any]:
    if not os.path.isfile(token_path):
        raise FileNotFoundError(f"TELToken.json not found at: {token_path}")

    with open(token_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for env_name, env_config in data.items():
        env_branch = str(env_config.get("BRANCH", "")).lower()
        print(env_branch)
        if env_branch == branch.lower():
            print(f"[TELToken] Matched branch '{branch}' to environment '{env_name}'")
            return env_config

    raise ValueError(f"No TELToken environment found for branch '{branch}'")

def has_any_env_token(sql_text: str) -> bool:
    return bool(TOKEN_PATTERN.search(sql_text))

def apply_env_tokens(sql_text: str, env_config: Dict[str, Any]) -> str:
    for key, value in env_config.items():
        if (
            isinstance(key, str)
            and key.isupper()
            and "." not in key
            and isinstance(value, str)
        ):
            token = f"<<{key}>>"
            if token in sql_text.upper():
                sql_text = sql_text.upper().replace(token, value)
    print(f"Snow file after replacing tokens : {sql_text}.")

    return sql_text

def connect_snowflake(target_path: str):


    if target_path.startswith("Snow/SYSADMIN_"):
        role_env_var = "SNOWFLAKE_SYSADMIN_ROLE"
    else:
        role_env_var = "SNOWFLAKE_ROLE"

    conn_kwargs = {
        "account": os.environ["SNOWFLAKE_ACCOUNT"],
        "user": os.environ["SNOWFLAKE_USER"],
        "password": os.environ["SNOWFLAKE_PASSWORD"],
        "warehouse": os.environ["SNOWFLAKE_WAREHOUSE"],
        "role": os.environ[role_env_var],
        "autocommit": False,
    }
    print(f"[Snowflake] Connecting with role: {conn_kwargs['role']}", flush=True)
    conn = snowflake.connector.connect(**conn_kwargs)
    return conn

def execute_sql_file(conn, file_path: str, env_config: Dict[str, Any]) -> int:
    print(f"\n[Snowflake] Running file: {file_path}", flush=True)

    with open(file_path, "r", encoding="utf-8") as f:
        sql_text = f.read()

    if has_any_env_token(sql_text):
        sql_text = apply_env_tokens(sql_text, env_config)
    else:
        raise FileNotFoundError(f"[Snowflake] Error executing file {file_path}:\nExpect Tokens in Snowfile Only")

    error_count = 0

    sql_stream = io.StringIO(sql_text)

    try:
        for cur in conn.execute_stream(sql_stream):
            query = getattr(cur, "query", None)
            sfqid = getattr(cur, "sfqid", None)

            query_preview = ""
            if query:
                query_preview = query.replace("\n", " ")[:100] + "..."

            print(f"{sfqid or ''} {query_preview}", flush=True)

    except Exception as e:
        print(f"[Snowflake] Error executing file {file_path}:\n{e}", flush=True)
        error_count += 1

    print(f"[Snowflake] Processed file {file_path} with {error_count} errors.\n", flush=True)
    return error_count

def main():
    if len(sys.argv) != 2:
        print("Usage: python deploy_snowfiles.py <file_or_directory>")
        sys.exit(1)

    target_path = sys.argv[1]

    branch = os.getenv("DEPLOYMENT_BRANCH_TEMPLATE")
    token_path = os.getenv("TELTOKEN_PATH", DEFAULT_TELTOKEN_PATH)

    print(f"[Setup] Branch: {branch}")
    print(f"[Setup] TELToken path: {token_path}")

    env_config = load_env_config(branch, token_path)

    

    try:
        total_errors = 0

        if not os.path.isfile(target_path):
            raise FileNotFoundError(f"File not found: {target_path}")

        conn = connect_snowflake(target_path)        

        print(f"[Snowflake] Processing File: {target_path}", flush=True)
        total_errors += execute_sql_file(conn, target_path, env_config)

        if total_errors > 0:
            conn.rollback()
            raise Exception(f"Encountered {total_errors} errors during execution.")
        else:
            conn.commit()
            print("[Snowflake] All files executed successfully, transaction committed.", flush=True)

    except Exception as e:
        print(f"[Snowflake] Deployment failed: {e}", flush=True)
        sys.exit(1)
    finally:
        conn.close()

if __name__ == "__main__":
    main()
