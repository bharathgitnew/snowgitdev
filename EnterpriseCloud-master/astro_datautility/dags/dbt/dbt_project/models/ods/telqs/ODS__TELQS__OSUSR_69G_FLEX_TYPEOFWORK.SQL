{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='OSUSR_69G_FLEX_TYPEOFWORK'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:FLEXID::STRING AS FLEXID,
JSONFIELD:TYPEOFWORKID::STRING AS TYPEOFWORKID

FROM {{ source('LZ_TELQS', 'OSUSR_69G_FLEX_TYPEOFWORK') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_69G_FLEX_TYPEOFWORK') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
FLEXID,
TYPEOFWORKID
FROM source_data
)

,type_data as 
(
SELECT
_AUDIT_LOG_ID,
_ROW_HASH,
ID,
FLEXID,
TYPEOFWORKID
from transform_data 
)
SELECT * from type_data