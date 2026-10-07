{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='CUSTOMER_GROUP'
) }}


with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"CustCode"::STRING AS CustCode
        ,JSONFIELD:"Finance"::STRING AS Finance
        ,JSONFIELD:"Parts"::STRING AS Parts
        ,JSONFIELD:"Service"::STRING AS Service
        ,JSONFIELD:"Sales"::STRING AS Sales
        ,REGEXP_REPLACE(JSONFIELD:"CreateDate", '\/Date\\(|\\)\/', '')::TIMESTAMP AS CreateDate
        ,JSONFIELD:"CustName"::STRING AS CustName
    FROM {{ source("LEGACY93", "CUSTOMER_GROUP") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LEGACY93", "CUSTOMER_GROUP") }})
)

,transform_data as 
(
    SELECT
        CustCode,
        Finance,
        Parts,
        Service,
        Sales,
        CreateDate,
        CustName,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(CUSTCODE as VARCHAR(16777216)) as CUSTCODE,
        cast(FINANCE as VARCHAR(16777216)) as FINANCE,
        cast(PARTS as VARCHAR(16777216)) as PARTS,
        cast(SERVICE as VARCHAR(16777216)) as SERVICE,
        cast(SALES as VARCHAR(16777216)) as SALES,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(CUSTNAME as VARCHAR(16777216)) as CUSTNAME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
)
select * from type_data