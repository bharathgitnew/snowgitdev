{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Ship_To_Descr',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"BAAN_BPID"::STRING AS BAAN_BPID
        	,JSONFIELD:"DESCR"::STRING AS DESCR
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_SHIP_TO_DESCR") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_SHIP_TO_DESCR") }})
)
,transform_data as
(
    SELECT
        source_data.BAAN_BPID,
        source_data.DESCR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(BAAN_BPID as VARCHAR(16777216)) as BAAN_BPID,
        cast(DESCR as VARCHAR(16777216)) as DESCR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data