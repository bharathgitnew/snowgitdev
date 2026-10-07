import argparse
import os
import snowflake.connector

TABLE_EXISTENCE_SQL = (
    "SELECT 1 FROM {db}.INFORMATION_SCHEMA.TABLES "
    "WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}' LIMIT 1;"
)

RAP_EXISTENCE_SQL = (
    "SELECT COUNT(*) FROM TABLE( {db}.INFORMATION_SCHEMA.POLICY_REFERENCES( "
    "  ref_entity_name => '{db}.{schema}.{table}', ref_entity_domain => 'TABLE' "
    ") ) WHERE POLICY_KIND = 'ROW_ACCESS_POLICY';"
)

RAP_APPLICATION_SQL = (
    "ALTER TABLE {db}.{schema}.{table} "
    "ADD ROW ACCESS POLICY {pdb}.{pschema}.{pname} ON ({cols});"
)

CMP_EXISTENCE_SQL = (
    "SELECT COUNT(*) FROM TABLE( ADMIN.INFORMATION_SCHEMA.POLICY_REFERENCES( "
    "  policy_name => '{pdb}.{pschema}.{pname}' "
    ") ) WHERE POLICY_KIND = 'MASKING_POLICY' "
    "AND REF_DATABASE_NAME = '{db}' AND REF_SCHEMA_NAME = '{schema}' "
    "AND REF_ENTITY_NAME = '{table}' AND UPPER(REF_ENTITY_DOMAIN) = 'TABLE' "
    "AND REF_COLUMN_NAME = '{col}';"
)

CMP_APPLICATION_SQL = (
    "ALTER TABLE {db}.{schema}.{table} "
    "ALTER COLUMN {col} SET MASKING POLICY {pdb}.{pschema}.{pname};"
)


def clean_sql(sql):
    return sql.replace("[", "").replace("]", "").replace('"', "").strip()


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--policy-refs", required=True)
    return p.parse_args()


def sf_connect(user, password, account, warehouse, role):
    return snowflake.connector.connect(
        user=user,
        password=password,
        account=account,
        warehouse=warehouse,
        role=role,
        autocommit=False,
    )


def table_exists(cur, db, schema, table):
    cur.execute(TABLE_EXISTENCE_SQL.format(db=db, schema=schema, table=table))
    return cur.fetchone() is not None


def rap_exists(cur, db, schema, table):
    cur.execute(RAP_EXISTENCE_SQL.format(db=db, schema=schema, table=table))
    return int(cur.fetchone()[0]) > 0


def cmp_exists(cur, pdb, pschema, pname, db, schema, table, col):
    cur.execute(
        CMP_EXISTENCE_SQL.format(
            pdb=pdb,
            pschema=pschema,
            pname=pname,
            db=db,
            schema=schema,
            table=table,
            col=col,
        )
    )
    return int(cur.fetchone()[0]) > 0


def parse_policy_refs(policy_refs):
    items = [x for x in policy_refs.split("||") if x.strip()]
    parsed = []
    for it in items:
        parts = it.split("|")
        if len(parts) != 4:
            continue
        kind, policy_fq, target_fq, extra = parts[0].strip(), parts[1].strip(), parts[2].strip(), parts[3].strip()
        pdb, pschema, pname = policy_fq.split(".", 2)
        tdb, tschema, ttable = target_fq.split(".", 2)
        parsed.append((kind, pdb, pschema, pname, tdb, tschema, ttable, extra))
    return parsed


def main():
    args = parse_args()

    user = os.environ.get("SNOWFLAKE_USER", "")
    password = os.environ.get("SNOWFLAKE_PASSWORD", "")
    account = os.environ.get("SNOWFLAKE_ACCOUNT", "")
    warehouse = os.environ.get("SNOWFLAKE_WAREHOUSE", "DEVELOPER_WH")

    masking_user = os.environ.get("SNOWFLAKE_MASKING_USER", user)
    masking_password = os.environ.get("SNOWFLAKE_MASKING_PASSWORD", password)

    if not user or not password or not account:
        print("Missing env vars: SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ACCOUNT")
        return

    parsed = parse_policy_refs(args.policy_refs)
    if not parsed:
        print("[Done] No policies to apply")
        return

    sys_conn = sf_connect(user, password, account, warehouse, "SYSADMIN")
    sys_cur = sys_conn.cursor()

    mask_conn = sf_connect(masking_user, masking_password, account, warehouse, "MASKING_POLICY_OWNER")
    mask_cur = mask_conn.cursor()

    applied_any = False
    print(parsed)

    for kind, pdb, pschema, pname, db, schema, table, extra in parsed:
        fq_table = f"{db}.{schema}.{table}"
        fq_policy = f"{pdb}.{pschema}.{pname}"

        print(f"[Snowflake] Checking table -> {fq_table}")
        if not table_exists(sys_cur, db, schema, table):
            print(f"[Snowflake] SKIP (table not found) -> {fq_table}")
            continue

        if kind == "ROW_ACCESS_POLICY":
            print(f"[Snowflake] RAP check -> {fq_policy} ON {fq_table}")

            try:
                if rap_exists(sys_cur, db, schema, table):
                    print(f"[Snowflake] SKIP (RAP exists) -> {fq_policy} ON {fq_table}")
                    continue

                raw_sql = RAP_APPLICATION_SQL.format(
                    db=db,
                    schema=schema,
                    table=table,
                    pdb=pdb,
                    pschema=pschema,
                    pname=pname,
                    cols=extra,
                )
                sql = clean_sql(raw_sql)

                print(f"[Snowflake] APPLY RAP -> {fq_policy} ON {fq_table}")
                print(f"[Snowflake] SQL -> {sql}")

                sys_cur.execute(sql)
                applied_any = True
            except Exception as e:
                print(f"[Snowflake] ERROR applying RAP -> {e}")

        elif kind == "MASKING_POLICY":
            col = extra
            fq_column = f"{fq_table}.{col}"

            print(f"[Snowflake] CMP check -> {fq_policy} ON {fq_column}")

            try:
                if cmp_exists(sys_cur, pdb, pschema, pname, db, schema, table, col):
                    print(f"[Snowflake] SKIP (CMP exists) -> {fq_policy} ON {fq_column}")
                    continue

                raw_sql = CMP_APPLICATION_SQL.format(
                    db=db,
                    schema=schema,
                    table=table,
                    col=col,
                    pdb=pdb,
                    pschema=pschema,
                    pname=pname,
                )
                sql = clean_sql(raw_sql)

                print(f"[Snowflake] APPLY CMP -> {fq_policy} ON {fq_column}")
                print(f"[Snowflake] SQL -> {sql}")

                mask_cur.execute(sql)
                applied_any = True
            except Exception as e:
                print(f"[Snowflake] ERROR applying CMP -> {e}")

        else:
            print(f"[Snowflake] SKIP (unknown kind) -> {kind} for {fq_table}")

    if applied_any:
        try:
            sys_conn.commit()
        except Exception as e:
            print(f"[Snowflake] SYSADMIN COMMIT FAILED -> {e}")
            raise
        try:
            mask_conn.commit()
        except Exception as e:
            print(f"[Snowflake] MASKING COMMIT FAILED -> {e}")
            raise
        print("[Done] Committed")
    else:
        print("[Done] No changes")

    try:
        sys_cur.close()
    except Exception:
        pass
    try:
        mask_cur.close()
    except Exception:
        pass
    try:
        sys_conn.close()
    except Exception:
        pass
    try:
        mask_conn.close()
    except Exception:
        pass


if __name__ == "__main__":
    main()
