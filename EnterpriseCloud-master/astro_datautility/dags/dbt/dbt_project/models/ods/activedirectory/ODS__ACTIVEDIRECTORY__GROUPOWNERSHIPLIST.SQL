-- modeled after ODS__ACTIVEDIRECTORY__GROUPMEMBERSHIPLIST.SQL
{{ config(
    alias='GROUPOWNERSHIPLIST',
    materialized='incremental',
    incremental_strategy='insert_overwrite',
) }}


with source_data as (
    select
        _FILEDATE,
        JSONFIELD:"groups_id"::STRING as GROUPID,
        JSONFIELD:"id"::STRING as OWNERID,
        JSONFIELD:"displayName"::STRING as OWNERNAME,
    from {{ source("ACTIVEDIRECTORY", "GROUPOWNERSHIP") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("ACTIVEDIRECTORY", "GROUPOWNERSHIP") }}) -- TODO: this should use a CONTROLTABLE ideally but doesn't look like we have one created for AD schema
        and JSONFIELD:"@odata.type"::string = '#microsoft.graph.user'
        and GROUPID is not null
        and OWNERID is not null
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        sha2('hash_me') as _ROW_HASH,
        *,
    from source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        GROUPID,
        OWNERID,
        OWNERNAME,
    from transform_data
)

select * from type_data