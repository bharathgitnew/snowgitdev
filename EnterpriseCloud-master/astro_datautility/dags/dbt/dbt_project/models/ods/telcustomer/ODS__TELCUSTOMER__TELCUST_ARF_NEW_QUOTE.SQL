{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TelCust_Arf_New_Quote',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        JSONFIELD:"reqtype"::STRING AS reqtype,
        JSONFIELD:"company"::STRING AS company,
        JSONFIELD:"arf_type"::STRING AS arf_type,
        JSONFIELD:"request_number"::NUMBER AS request_number,
        JSONFIELD:"rev"::NUMBER AS rev,
        REGEXP_REPLACE(JSONFIELD:"status_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS status_date,
        JSONFIELD:"product_line"::STRING AS product_line,
        JSONFIELD:"requestor_id"::NUMBER AS requestor_id,
        JSONFIELD:"requestor"::STRING AS requestor,
        JSONFIELD:"requestor_phone"::STRING AS requestor_phone,
        JSONFIELD:"requestor_email"::STRING AS requestor_email,
        JSONFIELD:"approver_id"::NUMBER AS approver_id,
        JSONFIELD:"approver"::STRING AS approver,
        JSONFIELD:"approver_phone"::STRING AS approver_phone,
        JSONFIELD:"approver_email"::STRING AS approver_email,
        JSONFIELD:"model"::STRING AS model,
        JSONFIELD:"fabs"::STRING AS fabs,
        JSONFIELD:"nodes"::STRING AS nodes,
        JSONFIELD:"processes"::STRING AS processes,
        JSONFIELD:"node_from_other"::STRING AS node_from_other,
        JSONFIELD:"node_to_other"::STRING AS node_to_other,
        JSONFIELD:"process_from_other"::STRING AS process_from_other,
        JSONFIELD:"process_to_other"::STRING AS process_to_other,
        JSONFIELD:"NODE_OTHER"::STRING AS NODE_OTHER,
        JSONFIELD:"PROCESS_OTHER"::STRING AS PROCESS_OTHER,
        JSONFIELD:"description"::STRING AS description,
        JSONFIELD:"priority_flag"::STRING AS priority_flag,
        REGEXP_REPLACE(JSONFIELD:"data_load_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS data_load_date,
        JSONFIELD:"tel_comment"::STRING AS tel_comment,
        REGEXP_REPLACE(JSONFIELD:"request_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS request_date,
        REGEXP_REPLACE(JSONFIELD:"request_revision_date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS request_revision_date
        FROM {{ source("TELCUSTOMER", "TELCUST_ARF_NEW_QUOTE") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "TELCUST_ARF_NEW_QUOTE") }})
        )
,transform_data as
(
    SELECT
         source_data.REQTYPE
        ,source_data.COMPANY
        ,source_data.ARF_TYPE
        ,source_data.REQUEST_NUMBER
        ,source_data.REV
        ,source_data.STATUS_DATE
        ,source_data.PRODUCT_LINE
        ,source_data.REQUESTOR_ID
        ,source_data.REQUESTOR
        ,source_data.REQUESTOR_PHONE
        ,source_data.REQUESTOR_EMAIL
        ,source_data.APPROVER_ID
        ,source_data.APPROVER
        ,source_data.APPROVER_PHONE
        ,source_data.APPROVER_EMAIL
        ,source_data.MODEL
        ,source_data.FABS
        ,source_data.NODES
        ,source_data.PROCESSES
        ,source_data.NODE_FROM_OTHER
        ,source_data.NODE_TO_OTHER
        ,source_data.PROCESS_FROM_OTHER
        ,source_data.PROCESS_TO_OTHER
        ,source_data.NODE_OTHER
        ,source_data.PROCESS_OTHER
        ,source_data.DESCRIPTION
        ,source_data.PRIORITY_FLAG
        ,source_data.DATA_LOAD_DATE
        ,source_data.TEL_COMMENT
        ,source_data.REQUEST_DATE
        ,source_data.REQUEST_REVISION_DATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(REQTYPE as VARCHAR(16777216)) as REQTYPE,
        cast(COMPANY as VARCHAR(16777216)) as COMPANY,
        cast(ARF_TYPE as VARCHAR(16777216)) as ARF_TYPE,
        cast(REQUEST_NUMBER as NUMBER(38,0)) as REQUEST_NUMBER,
        cast(REV as NUMBER(38,0)) as REV,
        cast(STATUS_DATE as TIMESTAMP_NTZ(9)) as STATUS_DATE,
        cast(PRODUCT_LINE as VARCHAR(16777216)) as PRODUCT_LINE,
        cast(REQUESTOR_ID as NUMBER(38,0)) as REQUESTOR_ID,
        cast(REQUESTOR as VARCHAR(16777216)) as REQUESTOR,
        cast(REQUESTOR_PHONE as VARCHAR(16777216)) as REQUESTOR_PHONE,
        cast(REQUESTOR_EMAIL as VARCHAR(16777216)) as REQUESTOR_EMAIL,
        cast(APPROVER_ID as NUMBER(38,0)) as APPROVER_ID,
        cast(APPROVER as VARCHAR(16777216)) as APPROVER,
        cast(APPROVER_PHONE as VARCHAR(16777216)) as APPROVER_PHONE,
        cast(APPROVER_EMAIL as VARCHAR(16777216)) as APPROVER_EMAIL,
        cast(MODEL as VARCHAR(16777216)) as MODEL,
        cast(FABS as VARCHAR(16777216)) as FABS,
        cast(NODES as VARCHAR(16777216)) as NODES,
        cast(PROCESSES as VARCHAR(16777216)) as PROCESSES,
        cast(NODE_FROM_OTHER as VARCHAR(16777216)) as NODE_FROM_OTHER,
        cast(NODE_TO_OTHER as VARCHAR(16777216)) as NODE_TO_OTHER,
        cast(PROCESS_FROM_OTHER as VARCHAR(16777216)) as PROCESS_FROM_OTHER,
        cast(PROCESS_TO_OTHER as VARCHAR(16777216)) as PROCESS_TO_OTHER,
        cast(NODE_OTHER as VARCHAR(16777216)) as NODE_OTHER,
        cast(PROCESS_OTHER as VARCHAR(16777216)) as PROCESS_OTHER,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(PRIORITY_FLAG as VARCHAR(16777216)) as PRIORITY_FLAG,
        cast(DATA_LOAD_DATE as TIMESTAMP_NTZ(9)) as DATA_LOAD_DATE,
        cast(TEL_COMMENT as VARCHAR(16777216)) as TEL_COMMENT,
        cast(REQUEST_DATE as TIMESTAMP_NTZ(9)) as REQUEST_DATE,
        cast(REQUEST_REVISION_DATE as TIMESTAMP_NTZ(9)) as REQUEST_REVISION_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data