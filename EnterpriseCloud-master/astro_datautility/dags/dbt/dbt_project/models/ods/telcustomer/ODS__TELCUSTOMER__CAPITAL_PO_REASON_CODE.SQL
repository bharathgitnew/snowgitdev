{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Reason_Code',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"REASON_CODE"::NUMBER AS REASON_CODE
        	,JSONFIELD:"REASON"::STRING AS REASON
        	,JSONFIELD:"TYPE"::STRING AS TYPE
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_REASON_CODE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_REASON_CODE") }})
)
,transform_data as
(
    SELECT
        source_data.REASON_CODE,
        source_data.REASON,
        source_data.TYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(REASON_CODE as NUMBER(38,0)) as REASON_CODE,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(TYPE as VARCHAR(16777216)) as TYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data