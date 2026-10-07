{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELQS_OSUSR_BN7_SERVICEQUOTEWITHCONTRACT'
) }}

with source_data as
(
SELECT
JSONFIELD:ID::STRING AS ID,
JSONFIELD:SERVICECONTRACTQUOTEMASTERID::STRING AS SERVICECONTRACTQUOTEMASTERID,
JSONFIELD:CONTRACTTYPEID::STRING AS CONTRACTTYPEID

FROM {{ source('LZ_TELQS', 'OSUSR_bn7_ServiceQuoteWithContract') }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source('LZ_TELQS', 'OSUSR_bn7_ServiceQuoteWithContract') }})
)

,transform_data as
(
SELECT
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
 SHA2('hash_me') AS _ROW_HASH,
ID,
SERVICECONTRACTQUOTEMASTERID,
CONTRACTTYPEID
FROM source_data
)

,type_data as 
(
SELECT
_AUDIT_LOG_ID,
_ROW_HASH,
ID,
SERVICECONTRACTQUOTEMASTERID,
CONTRACTTYPEID
from transform_data 
)
SELECT * from type_data