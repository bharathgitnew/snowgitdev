{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELQS_OSUSR_BN7_QUOTESTATUS'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:LABEL::STRING AS LABEL,
JSONFIELD:ORDER::STRING AS ORDER_,
JSONFIELD:IS_ACTIVE::NUMBER(38,0) AS IS_ACTIVE

FROM {{ source('LZ_TELQS', 'OSUSR_BN7_QUOTESTATUS') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_BN7_QUOTESTATUS') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
LABEL,
ORDER_,
IS_ACTIVE
FROM source_data
)

,type_data as 
(
SELECT
_AUDIT_LOG_ID,
_ROW_HASH,
ID,
LABEL,
ORDER_,
IS_ACTIVE
from transform_data 
)
SELECT * from type_data