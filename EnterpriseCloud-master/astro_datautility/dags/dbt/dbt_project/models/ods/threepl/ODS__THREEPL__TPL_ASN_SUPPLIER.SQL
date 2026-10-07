{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_ASN_Supplier',
    unique_key = ['Supplier']
) }}


with source_data as (
    SELECT 
        JSONFIELD:Supplier::String as SUPPLIER,
        JSONFIELD:ASN_Enabled::Boolean as ASN_ENABLED,
        _filedate as _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM {{ source('THREEPL','TPL_ASN_SUPPLIER') }}
    {% if is_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
	QUALIFY (ROW_NUMBER() OVER (PARTITION BY Supplier ORDER BY _FILEDATE DESC )) = 1
),

transform_data as(
    select
        SUPPLIER,
        ASN_ENABLED,
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH
    from source_data
),

type_data as(
    select
        CAST(SUPPLIER as VARCHAR(16777216)) as SUPPLIER,
        CAST(ASN_ENABLED as BOOLEAN) as ASN_ENABLED,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data