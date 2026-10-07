{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='OSUSR_BN7_ADVANCEFILTERDATACONTRACTTYPE'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:USERID::STRING AS USERID,
JSONFIELD:CONTRACTTYPEID::STRING AS CONTRACTTYPEID

FROM {{ source('LZ_TELQS', 'OSUSR_BN7_ADVANCEFILTERDATACONTRACTTYPE') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_BN7_ADVANCEFILTERDATACONTRACTTYPE') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
USERID,
CONTRACTTYPEID
FROM source_data
)

,type_data as 
(
SELECT
_AUDIT_LOG_ID,
_ROW_HASH,
ID,
USERID,
CONTRACTTYPEID
from transform_data 
)
SELECT * from type_data