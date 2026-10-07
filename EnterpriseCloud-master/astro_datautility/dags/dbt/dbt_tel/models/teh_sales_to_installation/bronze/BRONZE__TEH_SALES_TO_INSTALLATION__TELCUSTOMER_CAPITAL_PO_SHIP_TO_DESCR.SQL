{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TELCUSTOMER_CAPITAL_PO_SHIP_TO_DESCR',
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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,source_data.BAAN_BPID,
        source_data.DESCR
        FROM source_data
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        BAAN_BPID,
        DESCR
    from transform_data
    )
select * from type_data