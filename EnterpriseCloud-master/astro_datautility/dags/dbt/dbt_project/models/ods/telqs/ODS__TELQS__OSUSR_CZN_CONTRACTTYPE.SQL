{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='OSUSR_CZN_CONTRACTTYPE'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:LABEL::STRING AS LABEL,
JSONFIELD:ORDER::STRING AS _ORDER,
JSONFIELD:IS_ACTIVE::NUMBER(38,0) AS IS_ACTIVE,
JSONFIELD:PRICEMETHOD::STRING AS PRICEMETHOD

FROM {{ source('LZ_TELQS', 'OSUSR_CZN_CONTRACTTYPE') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_CZN_CONTRACTTYPE') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
LABEL,
_ORDER,
IS_ACTIVE,
PRICEMETHOD
FROM source_data
)

,type_data as 
(
SELECT
_AUDIT_LOG_ID,
_ROW_HASH,
ID,
LABEL,
_ORDER,
IS_ACTIVE,
PRICEMETHOD
from transform_data 
)
SELECT * from type_data