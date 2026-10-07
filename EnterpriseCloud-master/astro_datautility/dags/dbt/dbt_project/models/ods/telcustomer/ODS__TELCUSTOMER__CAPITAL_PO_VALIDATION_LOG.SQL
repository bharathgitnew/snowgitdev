{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Validation_Log',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,JSONFIELD:"PO_NUMBER"::STRING AS PO_NUMBER
        	,JSONFIELD:"LINE_NUMBER"::STRING AS LINE_NUMBER
        	,JSONFIELD:"REV"::NUMBER AS REV
        	,JSONFIELD:"FIELD"::STRING AS FIELD
        	,JSONFIELD:"MESSAGE"::STRING AS MESSAGE
        	,JSONFIELD:"STATUS"::STRING AS STATUS
        	,JSONFIELD:"REASON_CODE"::NUMBER AS REASON_CODE
        	,JSONFIELD:"REASON"::STRING AS REASON
        	,JSONFIELD:"TYPE"::STRING AS TYPE
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_VALIDATION_LOG") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_VALIDATION_LOG") }})
        )
,transform_data as
(
    SELECT
         PO_NUMBER
        ,LINE_NUMBER
        ,REV
        ,FIELD
        ,MESSAGE
        ,STATUS
        ,REASON_CODE
        ,REASON
        ,TYPE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(LINE_NUMBER as VARCHAR(16777216)) as LINE_NUMBER,
        cast(REV as NUMBER(38,0)) as REV,
        cast(FIELD as VARCHAR(16777216)) as FIELD,
        cast(MESSAGE as VARCHAR(16777216)) as MESSAGE,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(REASON_CODE as NUMBER(38,0)) as REASON_CODE,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(TYPE as VARCHAR(16777216)) as TYPE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data