{{ config(
    alias = 'GRANTS_AUDIT',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}

with policy_refs as (
    select 
        REF_DATABASE_NAME,
        REF_SCHEMA_NAME,
        REF_ENTITY_NAME,
        array_agg(object_construct('id', POLICY_ID, 'type', POLICY_KIND)) as SECURITY_POLICIES,
    from {{ source('SF_ACCOUNTUSAGE', 'POLICY_REFERENCES') }}
    where POLICY_STATUS = 'ACTIVE'
    group by 
        REF_DATABASE_NAME,
        REF_SCHEMA_NAME,
        REF_ENTITY_NAME
),

source_data as (
    select 
        table_grants.GRANTED_TO as GRANTED_TO,
        table_grants.GRANTEE_NAME as GRANTEE_NAME,
        table_grants.TABLE_CATALOG as DB_NAME,
        table_grants.TABLE_SCHEMA as SCHEMA_NAME,
        table_grants.NAME as TABLE_NAME,
        table_grants.MODIFIED_ON as MODIFIED_ON,
        policy_refs.SECURITY_POLICIES,
    from {{ source('SF_ACCOUNTUSAGE', 'GRANTS_TO_ROLES') }} as table_grants
    left join policy_refs
        on table_grants.TABLE_CATALOG = policy_refs.REF_DATABASE_NAME
        and table_grants.TABLE_SCHEMA = policy_refs.REF_SCHEMA_NAME
        and table_grants.NAME = policy_refs.REF_ENTITY_NAME
    where table_grants.DELETED_ON is null
        and table_grants.PRIVILEGE = 'SELECT'
        and table_grants.TABLE_CATALOG in ('SILVER', 'GOLD', 'COPPER')
        and table_grants.GRANTEE_NAME not in (table_grants.TABLE_SCHEMA || '_TEAM', 'READ_ONLY_ALL')
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        GRANTED_TO,
        GRANTEE_NAME,
        DB_NAME,
        SCHEMA_NAME,
        TABLE_NAME,
        MODIFIED_ON,
        SECURITY_POLICIES,
    from transform_data
)

select * from type_data
