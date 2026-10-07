{{ config(
    alias = 'NCDR_PARTS_HISTORY',
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['NCDR_PART_AUDIT_ID'],
) }}

with source_data as (
    select
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"NCDR_PART_AUDIT_ID"::string as NCDR_PART_AUDIT_ID,
        JSONFIELD:"NCDR_PART_ID"::string as NCDR_PART_ID,
        JSONFIELD:"NCDR_NUMBER"::string as NCDR_NUMBER,
        JSONFIELD:"PART_NUMBER"::string as PART_NUMBER,
        JSONFIELD:"QUANTITY"::string as QUANTITY,
        JSONFIELD:"UNIT_OF_MEASURE"::string as UNIT_OF_MEASURE,
        JSONFIELD:"READY_BY_FACTORY"::string as READY_BY_FACTORY,
        JSONFIELD:"URL_REFERENCE"::string as URL_REFERENCE,
        JSONFIELD:"DESCRIPTION"::string as DESCRIPTION,
        JSONFIELD:"CREATE_DATE"::string as CREATE_DATE,
        JSONFIELD:"NCDR_PART_AUDIT_EVENT_ID"::string as NCDR_PART_AUDIT_EVENT_ID,
        JSONFIELD:"EVENT_DESCRIPTION"::string as EVENT_DESCRIPTION,
        JSONFIELD:"EMPLOYEE_NUMBER"::string as EMPLOYEE_NUMBER,
        JSONFIELD:"EMPLOYEE_NAME"::string as EMPLOYEE_NAME,
    from {{ source('NOW', 'NCDR_PARTS_HISTORY') }}
    where _FILEDATE > (select ifnull(max(_FILEDATE), '1900-01-01') from {{ this }})
    qualify row_number() over(partition by NCDR_PART_AUDIT_ID order by CREATE_DATE desc, _FILEDATE desc, _UPLOADDATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        *
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        _FILENAME,
        NCDR_PART_AUDIT_ID,
        NCDR_PART_ID,
        NCDR_NUMBER,
        PART_NUMBER,
        QUANTITY,
        UNIT_OF_MEASURE,
        READY_BY_FACTORY,
        URL_REFERENCE,
        DESCRIPTION,
        CREATE_DATE::timestamp::string AS CREATE_DATE,
        NCDR_PART_AUDIT_EVENT_ID,
        EVENT_DESCRIPTION,
        EMPLOYEE_NUMBER,
        EMPLOYEE_NAME,
    from transform_data
)

select * from type_data
