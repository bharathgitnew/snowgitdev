{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_SAP_SALES_CATEGORY'
) }}

with source_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
		_UPLOADDATE,
        BAAN_PRODUCT_TYPE,
        BAAN_PRODUCT_TYPE_NAME,
        SAP_SALES_CATEGORY,
        SAP_SALES_CATEGORY_NAME
    FROM {{ source("FILE", "SAP_SALES_CATEGORY") }}

    where _UPLOADDATE = (select max(_UPLOADDATE) from {{ source("FILE", "SAP_SALES_CATEGORY") }})

)

,transform_data as
(
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _UPLOADDATE,
        BAAN_PRODUCT_TYPE,
        BAAN_PRODUCT_TYPE_NAME,
        SAP_SALES_CATEGORY,
        SAP_SALES_CATEGORY_NAME
FROM source_data
)

,type_data as
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(BAAN_PRODUCT_TYPE AS VARCHAR(16777216)) AS BAAN_PRODUCT_TYPE,
        CAST(BAAN_PRODUCT_TYPE_NAME AS VARCHAR(16777216)) AS BAAN_PRODUCT_TYPE_NAME,
        CAST(SAP_SALES_CATEGORY AS VARCHAR(16777216)) AS SAP_SALES_CATEGORY,
        CAST(SAP_SALES_CATEGORY_NAME AS VARCHAR(16777216)) AS SAP_SALES_CATEGORY_NAME
from transform_data
    )
select * from type_data