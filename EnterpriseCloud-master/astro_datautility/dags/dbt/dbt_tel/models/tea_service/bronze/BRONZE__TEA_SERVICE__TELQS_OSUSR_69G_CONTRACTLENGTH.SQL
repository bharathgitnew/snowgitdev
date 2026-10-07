{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELQS_OSUSR_69G_CONTRACTLENGTH'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:LABEL::STRING AS LABEL,
JSONFIELD:ORDER::STRING AS ORDER_,
JSONFIELD:VALUE::STRING AS VALUE,
JSONFIELD:IS_ACTIVE::STRING AS IS_ACTIVE

FROM {{ source('LZ_TELQS', 'OSUSR_69G_CONTRACTLENGTH') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_69G_CONTRACTLENGTH') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
LABEL,
ORDER_,
VALUE,
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
VALUE,
IS_ACTIVE
from transform_data 
)
SELECT * from type_data