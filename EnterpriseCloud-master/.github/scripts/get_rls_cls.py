from pathlib import Path
import argparse
import os
import re
import snowflake.connector
from collections import namedtuple

RowAccessPolicy = namedtuple(
    "RowAccessPolicy",
    ["created_on", "name", "database_name", "schema_name", "kind", "owner", "comment", "owner_role_type", "options"],
)

ColumnMaskingPolicy = namedtuple(
    "ColumnMaskingPolicy",
    ["created_on", "name", "database_name", "schema_name", "kind", "owner", "comment", "owner_role_type", "options"],
)

PolicyReference = namedtuple(
    "PolicyReference",
    [
        "POLICY_DB",
        "POLICY_SCHEMA",
        "POLICY_NAME",
        "POLICY_KIND",
        "REF_DATABASE_NAME",
        "REF_SCHEMA_NAME",
        "REF_ENTITY_NAME",
        "REF_ENTITY_DOMAIN",
        "REF_COLUMN_NAME",
        "REF_ARG_COLUMN_NAMES",
        "TAG_DATABASE",
        "TAG_SCHEMA",
        "TAG_NAME",
        "POLICY_STATUS",
    ],
)

SQL_FETCH_ROW_ACCESS_POLICIES = "SHOW ROW ACCESS POLICIES IN DATABASE {database};"
SQL_FETCH_COLUMN_MASKING_POLICIES = "SHOW MASKING POLICIES IN DATABASE {database};"
SQL_FETCH_POLICY_REFS = (
    "SELECT * FROM TABLE( ADMIN.INFORMATION_SCHEMA.POLICY_REFERENCES "
    "( policy_name=>'{pdb}.{pschema}.{pname}' ) );"
)

DATABASES_BY_ENV = {
    "BUILD": ["LZ_BUILD", "ODS_BUILD", "COMMON_BUILD", "PUB_BUILD"],
    "SIT": ["LZ_SIT", "ODS_SIT", "COMMON_SIT", "PUB_SIT"],
    "QA": ["LZ_QA", "ODS_QA", "COMMON_QA", "PUB_QA"],
    "PROD": ["LZ_PROD", "ODS", "COMMON", "PUB"],
}

ALIAS_RE = re.compile(r"alias\s*=\s*['\"]([^'\"]+)['\"]", re.IGNORECASE)


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--changed-files", required=True)
    p.add_argument("--env", required=True)
    p.add_argument("--policy-db", default="ADMIN")
    return p.parse_args()


def get_env(env):
    env = (env or "").strip().upper()
    return env if env in DATABASES_BY_ENV else "SIT"


def get_paths(changed_files):
    return [Path(x) for x in changed_files.split("||") if x.strip()]


def extract_alias(path):
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return "NO ALIAS"
    m = ALIAS_RE.search(text)
    return m.group(1) if m else "NO ALIAS"


def build_required_references(paths, env):
    required = []
    for path in paths:
        alias = extract_alias(path).upper()

        parent = path.parent
        if "dbt_project" in path.parts:
            schema = parent.stem.upper()
            database = f"{parent.parent.stem.upper()}_{env}"
        else:
            database = f"{parent.stem.upper()}_{env}"
            schema = parent.parent.stem.upper()

        required.append(f"{database}.{schema}.{alias}")
    return required


def sf_connect(user, password, account, warehouse, role):
    return snowflake.connector.connect(
        user=user,
        password=password,
        account=account,
        warehouse=warehouse,
        role=role,
        autocommit=True,
    )


def fetch_row_access_policies(cur, db):
    cur.execute(SQL_FETCH_ROW_ACCESS_POLICIES.format(database=db))
    return [RowAccessPolicy(*row) for row in cur.fetchall()]


def fetch_masking_policies(cur, db):
    cur.execute(SQL_FETCH_COLUMN_MASKING_POLICIES.format(database=db))
    return [ColumnMaskingPolicy(*row) for row in cur.fetchall()]


def fetch_policy_refs(cur, pdb, pschema, pname):
    cur.execute(SQL_FETCH_POLICY_REFS.format(pdb=pdb, pschema=pschema, pname=pname))
    return [PolicyReference(*row) for row in cur.fetchall()]


def write_github_output(name, value):
    out = os.environ.get("GITHUB_OUTPUT")
    if not out:
        print(f"{name}={value}")
        return
    with open(out, "a", encoding="utf-8") as f:
        f.write(f"{name}={value}\n")


def main():
    args = parse_args()
    env = get_env(args.env)

    paths = get_paths(args.changed_files)
    required_references = build_required_references(paths, env)
    required_refs_set = set(required_references)

    allowed_dbs = set(DATABASES_BY_ENV.get(env, DATABASES_BY_ENV["BUILD"]))

    user = os.environ.get("SNOWFLAKE_USER", "")
    password = os.environ.get("SNOWFLAKE_PASSWORD", "")
    account = os.environ.get("SNOWFLAKE_ACCOUNT", "")
    warehouse = os.environ.get("SNOWFLAKE_WAREHOUSE", "DEVELOPER_WH")

    if not user or not password or not account:
        print("Missing env vars: SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ACCOUNT")
        write_github_output("has_policies", "false")
        write_github_output("policy_refs", "")
        return

    conn = sf_connect(user, password, account, warehouse, "SYSADMIN")
    cur = conn.cursor()

    policy_refs = []

    row_access_policies = fetch_row_access_policies(cur, args.policy_db)
    masking_policies = fetch_masking_policies(cur, args.policy_db)

    remaining = set(required_refs_set)
    for rap in row_access_policies:
        if not remaining:
            break
        for pref in fetch_policy_refs(cur, rap.database_name, rap.schema_name, rap.name):
            key = f"{pref.REF_DATABASE_NAME}.{pref.REF_SCHEMA_NAME}.{pref.REF_ENTITY_NAME}"
            if key in remaining:
                policy_refs.append(pref)
                remaining.discard(key)
                if not remaining:
                    break

    remaining = set(required_refs_set)
    for mp in masking_policies:
        if not remaining:
            break
        for pref in fetch_policy_refs(cur, mp.database_name, mp.schema_name, mp.name):
            key = f"{pref.REF_DATABASE_NAME}.{pref.REF_SCHEMA_NAME}.{pref.REF_ENTITY_NAME}"
            if key in remaining:
                policy_refs.append(pref)
                remaining.discard(key)
                if not remaining:
                    break

    required_policies = [p for p in policy_refs if p.REF_DATABASE_NAME in allowed_dbs]

    lines = []
    for p in required_policies:
        if p.POLICY_KIND == "ROW_ACCESS_POLICY":
            target = f"{p.REF_DATABASE_NAME}.{p.REF_SCHEMA_NAME}.{p.REF_ENTITY_NAME}"
            pol = f"{p.POLICY_DB}.{p.POLICY_SCHEMA}.{p.POLICY_NAME}"
            cols = (p.REF_ARG_COLUMN_NAMES or "").replace("\n", " ").replace("\r", " ")
            lines.append(f"ROW_ACCESS_POLICY|{pol}|{target}|{cols}")
        elif p.POLICY_KIND == "MASKING_POLICY":
            target = f"{p.REF_DATABASE_NAME}.{p.REF_SCHEMA_NAME}.{p.REF_ENTITY_NAME}"
            pol = f"{p.POLICY_DB}.{p.POLICY_SCHEMA}.{p.POLICY_NAME}"
            col = p.REF_COLUMN_NAME or ""
            lines.append(f"MASKING_POLICY|{pol}|{target}|{col}")

    policy_out = "||".join(lines)
    has_policies = "true" if lines else "false"

    write_github_output("has_policies", has_policies)
    write_github_output("policy_refs", policy_out)

    try:
        cur.close()
    except Exception:
        pass
    try:
        conn.close()
    except Exception:
        pass


if __name__ == "__main__":
    main()
