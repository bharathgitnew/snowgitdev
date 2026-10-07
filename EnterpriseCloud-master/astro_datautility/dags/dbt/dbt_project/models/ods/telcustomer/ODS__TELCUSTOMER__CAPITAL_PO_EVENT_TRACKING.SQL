{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Event_Tracking',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        JSONFIELD:"PO_NUMBER"::STRING AS PO_NUMBER,
        JSONFIELD:"REV"::NUMBER AS REV,
        JSONFIELD:"USERID"::NUMBER AS USERID,
        REGEXP_REPLACE(JSONFIELD:"ACTION_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS ACTION_DATE,
        JSONFIELD:"EVENT_TYPE"::STRING AS EVENT_TYPE,
        JSONFIELD:"OLD_STATUS"::STRING AS OLD_STATUS,
        JSONFIELD:"NEW_STATUS"::STRING AS NEW_STATUS
        FROM {{ source("TELCUSTOMER", "CAPITAL_PO_EVENT_TRACKING") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_EVENT_TRACKING") }})
)
,transform_data as
(
    SELECT
         source_data.PO_NUMBER
        ,source_data.REV
        ,source_data.USERID
        ,source_data.ACTION_DATE
        ,source_data.EVENT_TYPE
        ,source_data.OLD_STATUS
        ,source_data.NEW_STATUS
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
)
,type_data as 
(
    select
        cast(PO_NUMBER as VARCHAR(16777216)) as PO_NUMBER,
        cast(REV as NUMBER(38,0)) as REV,
        cast(USERID as NUMBER(38,0)) as USERID,
        cast(ACTION_DATE as TIMESTAMP_NTZ(9)) as ACTION_DATE,
        cast(EVENT_TYPE as VARCHAR(16777216)) as EVENT_TYPE,
        cast(OLD_STATUS as VARCHAR(16777216)) as OLD_STATUS,
        cast(NEW_STATUS as VARCHAR(16777216)) as NEW_STATUS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data