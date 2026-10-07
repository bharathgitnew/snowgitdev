{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='Capital_PO_Header_Max_Date_Test',
    unique_key = []
) }}

-- Full Refresh is Records from Latest File
-- Incremental is Records from Latest File

with source_data as
(
    SELECT
        REGEXP_REPLACE(JSONFIELD:"MAX_DATE", '\/Date\\(|\\)\/', '')::TIMESTAMP AS MAX_DATE
    FROM {{ source("TELCUSTOMER", "CAPITAL_PO_HEADER_MAX_DATE_TEST") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CAPITAL_PO_HEADER_MAX_DATE_TEST") }})
)
,transform_data as
(
    SELECT
        source_data.MAX_DATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(MAX_DATE as TIMESTAMP_NTZ(9)) as MAX_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data