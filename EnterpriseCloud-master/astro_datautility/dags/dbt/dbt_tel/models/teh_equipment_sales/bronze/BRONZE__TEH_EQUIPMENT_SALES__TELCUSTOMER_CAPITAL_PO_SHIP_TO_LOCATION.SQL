{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_CAPITAL_PO_SHIP_TO_LOCATION',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"SHIP_TO_LOCATION_ID"::STRING AS SHIP_TO_LOCATION_ID
        	,JSONFIELD:"BAAN_BPID"::STRING AS BAAN_BPID
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_SHIP_TO_LOCATION") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_SHIP_TO_LOCATION") }})
        )
,transform_data as
(
    SELECT
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        Ship_To_Location_Id
        ,Baan_BPId
        ,'{{ invocation_id }}' AS Audit_Log_Id
FROM source_data
)
,type_data as 
(
    select
        _Filename AS _Filename,
        _Filedate AS _Filedate,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(SHIP_TO_LOCATION_ID as VARCHAR(16777216)) as SHIP_TO_LOCATION_ID,
        cast(BAAN_BPID as VARCHAR(16777216)) as BAAN_BPID
from transform_data
    )
select * from type_data