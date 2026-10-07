{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_Delivery_Type',
    unique_key = ['DELIVERY_TYPE']
) }}


with source_data as (
    SELECT 
        JSONFIELD:Delivery_Type::String as DELIVERY_TYPE,
        JSONFIELD:Description::String as DESCRIPTION,
        JSONFIELD:Direction::String as DIRECTION,
        JSONFIELD:Max_Lines_Per_Shipment::Int as MAX_LINES_PER_SHIPMENT,
        JSONFIELD:Requires_CI::Boolean as REQUIRES_CI,
        _filedate as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM {{ source('THREEPL','TPL_DELIVERY_TYPE') }}
    {% if is_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY DELIVERY_TYPE ORDER BY _FILEDATE DESC )) = 1
),

transform_data as(
    select
        DELIVERY_TYPE,
        DESCRIPTION,
        DIRECTION,
        MAX_LINES_PER_SHIPMENT,
        REQUIRES_CI,
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH
    from source_data
),

type_data as(
    select
        CAST(DELIVERY_TYPE as VARCHAR(16777216)) as DELIVERY_TYPE,
        CAST(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        CAST(DIRECTION as VARCHAR(16777216)) as DIRECTION,
        CAST(MAX_LINES_PER_SHIPMENT as NUMBER(38,10)) as MAX_LINES_PER_SHIPMENT,
        CAST(REQUIRES_CI as BOOLEAN) as REQUIRES_CI,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data