{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEL_CUSTOMER_EQUIPMENT_QUOTE_TRACKING'
) }}

with source_data as
(
select
    EQUIPMENT_QUOTE_TRACKING_ID,
    REQUEST_TYPE,
    QUOTE_ID                    as REQUEST_NO,
    ifnull(QUOTE_SEQ, 0)        as REVISION_NO,
    REQUEST_TYPE || '-' || QUOTE_ID || '-' || lpad(ifnull(QUOTE_SEQ, 0), 2, '0') as QUOTE_TRACKING_KEY,
    ACTION,
    ACTION_DATE                 as ACTION_TIMESTAMP,
    to_date(ACTION_DATE)        as ACTION_DATE,
    _FILEDATE                   as DATA_SNAPSHOT
from {{ref('BRONZE__TEH_EQUIPMENT_SALES__TELCUSTOMER_EQUIPMENT_QUOTE_TRACKING')}}
),
transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        EQUIPMENT_QUOTE_TRACKING_ID,
        REQUEST_TYPE,
        REQUEST_NO,
        REVISION_NO,
        QUOTE_TRACKING_KEY,
        ACTION,
        ACTION_TIMESTAMP,
        ACTION_DATE,
        DATA_SNAPSHOT
    from source_data
)
select * from transform_data