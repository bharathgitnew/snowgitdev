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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,Ship_To_Location_Id
        ,Baan_BPId
    FROM source_data
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        SHIP_TO_LOCATION_ID,
        BAAN_BPID
    from transform_data
    )
select * from type_data