{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Ship_To_Location',
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
         Ship_To_Location_Id
        ,Baan_BPId
        ,'{{ invocation_id }}' AS Audit_Log_Id
    FROM source_data
)
,type_data as 
(
    select
        cast(SHIP_TO_LOCATION_ID as VARCHAR(16777216)) as SHIP_TO_LOCATION_ID,
        cast(BAAN_BPID as VARCHAR(16777216)) as BAAN_BPID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data