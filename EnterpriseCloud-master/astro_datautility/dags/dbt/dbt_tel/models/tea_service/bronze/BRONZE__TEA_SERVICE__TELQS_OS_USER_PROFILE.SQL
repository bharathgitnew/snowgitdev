{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELQS_OS_USER_PROFILE'
) }}

with source_data as
(
SELECT
    _FILENAME,
    _FILEDATE,
    _UPLOADDATE,
    USERID,
    EMPLOYEENUMBER,
    DISPLAYNAME,
    MAILADDRESS,
    DOMAIN
FROM {{ source('LZ_TELQS', 'OS_USER_PROFILE') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OS_USER_PROFILE') }})
)
,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
    _FILENAME,
    _FILEDATE,
    _UPLOADDATE,
    USERID,
    EMPLOYEENUMBER,
    DISPLAYNAME,
    MAILADDRESS,
    DOMAIN
FROM source_data
)
,type_data as 
(
SELECT
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
    CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE, 
    CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
    USERID,
    EMPLOYEENUMBER,
    DISPLAYNAME,
    MAILADDRESS,
    DOMAIN
from transform_data 
)
SELECT * from type_data