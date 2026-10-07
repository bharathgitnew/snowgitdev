{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='CUSTOMER_GROUP'
) }}


with source_data as
(
    SELECT
        CUSTCODE,
        FINANCE,
        PARTS,
        SERVICE,
        SALES,
        CREATEDATE,
        CUSTNAME
    FROM {{ ref('ODS__LEGACY93__CUSTOMER_GROUP') }}
)

,transform_data as 
(
    SELECT
        CUSTCODE,
        FINANCE,
        PARTS,
        SERVICE,
        SALES,
        CREATEDATE,
        CUSTNAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(CUSTCODE as VARCHAR(16777216)) as CUSTCODE,
        cast(FINANCE as VARCHAR(16777216)) as FINANCE,
        cast(PARTS as VARCHAR(16777216)) as PARTS,
        cast(SERVICE as VARCHAR(16777216)) as SERVICE,
        cast(SALES as VARCHAR(16777216)) as SALES,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(CUSTNAME as VARCHAR(16777216)) as CUSTNAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
)
select * from type_data