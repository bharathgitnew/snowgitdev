{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='TELCUSTOMER_EQUIPMENT_QUOTE_TRACKING',
        transient=false
) }}

with source_data as(
select
    _FILENAME,
    _FILEDATE,
    _UPLOADDATE,
    JSONFIELD:"EQUIPMENT_QUOTE_TRACKING_ID"::INT AS "EQUIPMENT_QUOTE_TRACKING_ID",
    JSONFIELD:"QUOTE_ID"::NUMBER AS "QUOTE_ID",
    JSONFIELD:"ACTION"::VARCHAR AS "ACTION",
    JSONFIELD:"USERID"::NUMBER AS "USERID",
    REGEXP_REPLACE(JSONFIELD:"ACTION_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS ACTION_DATE,
    JSONFIELD:"REQUEST_TYPE"::VARCHAR AS "REQUEST_TYPE",
    JSONFIELD:"QUOTE_SEQ"::NUMBER AS "QUOTE_SEQ"
from {{ source("TELCUSTOMER", "EQUIPMENT_QUOTE_TRACKING") }}
where _FILEDATE = (select max(_FILEDATE) from {{ source("TELCUSTOMER", "EQUIPMENT_QUOTE_TRACKING") }})
),

transform_data as (
select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        EQUIPMENT_QUOTE_TRACKING_ID,
        QUOTE_ID,
        ACTION,
        USERID,
        ACTION_DATE,
        REQUEST_TYPE,
        QUOTE_SEQ
from source_data
),

type_data as (
select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        CAST(EQUIPMENT_QUOTE_TRACKING_ID as NUMBER) as EQUIPMENT_QUOTE_TRACKING_ID,
        CAST(QUOTE_ID as NUMBER) as QUOTE_ID,
        CAST(ACTION as VARCHAR) as ACTION,
        CAST(USERID as NUMBER) as USERID,
        CAST(ACTION_DATE as TIMESTAMP_NTZ(9)) as ACTION_DATE,
        CAST(REQUEST_TYPE as VARCHAR) as REQUEST_TYPE,
        CAST(QUOTE_SEQ as NUMBER) as QUOTE_SEQ
from transform_data
)

select * from type_data