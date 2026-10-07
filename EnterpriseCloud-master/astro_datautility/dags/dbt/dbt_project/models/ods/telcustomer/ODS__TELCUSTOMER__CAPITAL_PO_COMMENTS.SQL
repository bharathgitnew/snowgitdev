{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Comments',
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
        	,JSONFIELD:"REV"::NUMBER AS REV
        	,JSONFIELD:"COMMENT_ID"::NUMBER AS COMMENT_ID
        	,REGEXP_REPLACE(JSONFIELD:"comment_dt", '\/Date\\(|\\)\/', '')::TIMESTAMP AS COMMENT_DT
        	,JSONFIELD:"userid"::NUMBER AS USERID
        	,JSONFIELD:"descr"::STRING AS DESCR
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_COMMENTS") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_COMMENTS") }})
)
,transform_data as
(
    SELECT
        source_data.PO_NUMBER,
        source_data.REV,
        source_data.COMMENT_ID,
        source_data.COMMENT_DT,
        source_data.USERID,
        source_data.DESCR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(REV as NUMBER(38,0)) as REV,
        cast(COMMENT_ID as NUMBER(38,0)) as COMMENT_ID,
        cast(COMMENT_DT as TIMESTAMP_NTZ(9)) as COMMENT_DT,
        cast(USERID as NUMBER(38,0)) as USERID,
        cast(DESCR as VARCHAR(16777216)) as DESCR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data