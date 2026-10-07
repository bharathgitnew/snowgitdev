{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_CAPITAL_PO_CHANGE_LOG',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"PO_NUMBER"::STRING AS PO_NUMBER
        	,JSONFIELD:"LINE_NUMBER"::STRING AS LINE_NUMBER
        	,JSONFIELD:"REV"::NUMBER AS REV
        	,JSONFIELD:"CHANGE_TYPE_ID"::NUMBER AS CHANGE_TYPE_ID
        	,JSONFIELD:"OLD_VALUE"::STRING AS OLD_VALUE
        	,JSONFIELD:"NEW_VALUE"::STRING AS NEW_VALUE
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_CHANGE_LOG") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_CHANGE_LOG") }})
)
,transform_data as
(
    SELECT
        source_data._FILEDATE,
        source_data._FILENAME,
        source_data.PO_NUMBER,
        source_data.LINE_NUMBER,
        source_data.REV,
        source_data.CHANGE_TYPE_ID,
        source_data.OLD_VALUE,
        source_data.NEW_VALUE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH
        FROM source_data
)
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(LINE_NUMBER as VARCHAR(16777216)) as LINE_NUMBER,
        cast(REV as NUMBER(38,0)) as REV,
        cast(CHANGE_TYPE_ID as NUMBER(38,0)) as CHANGE_TYPE_ID,
        cast(OLD_VALUE as VARCHAR(16777216)) as OLD_VALUE,
        cast(NEW_VALUE as VARCHAR(16777216)) as NEW_VALUE
    from transform_data
    )
select * from type_data