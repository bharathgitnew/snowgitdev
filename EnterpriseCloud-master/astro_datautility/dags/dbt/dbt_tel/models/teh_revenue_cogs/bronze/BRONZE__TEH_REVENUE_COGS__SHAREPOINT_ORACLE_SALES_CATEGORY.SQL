{{ config(
materialized='tel_incremental'
,incremental_strategy='insert_overwrite'
,alias='SHAREPOINT_ORACLE_SALES_CATEGORY'
,transient=false
) }}


with source_data AS 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    jsonfield:fields.Title::STRING as SAP_CODE,
    jsonfield:fields.ORACLE_CODE::STRING as ORACLE_CODE,
    jsonfield:fields.Created::STRING as CREATED,
    jsonfield:fields.Modified::STRING as MODIFIED,
    DataItems.value:email::STRING AS CREATEDBY,
    DataItems1.value:email::STRING AS MODIFIEDBY
    FROM {{source('SHAREPOINT', 'SALES_CATEGORY')}},
    LATERAL FLATTEN (input => JsonField:createdBy) DataItems,
    LATERAL FLATTEN (input => JsonField:lastModifiedBy) DataItems1 
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('SHAREPOINT','SALES_CATEGORY') }})
)

,transform_data AS
(
    SELECT 
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        SAP_CODE,
        ORACLE_CODE,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM source_data
)

,type_data AS 
(
    SELECT 
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        SAP_CODE,
        ORACLE_CODE,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM transform_data
)

SELECT * FROM type_data