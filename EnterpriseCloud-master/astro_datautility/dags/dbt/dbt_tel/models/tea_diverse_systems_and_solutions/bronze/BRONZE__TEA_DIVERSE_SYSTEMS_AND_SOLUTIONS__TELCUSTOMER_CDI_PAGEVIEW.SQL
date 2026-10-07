{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TELCUSTOMER_CDI_PAGEVIEW',
    unique_key = ['ID']
) }}

with source_data as
(
    SELECT DISTINCT
        _FILENAME
        ,_FILEDATE
        ,lower(JSONFIELD:"ID"::STRING) AS ID
        ,lower(JSONFIELD:"cdi_anonymousvisitorid_Id"::STRING) AS cdi_anonymousvisitorid_Id
        ,JSONFIELD:"cdi_anonymousvisitorid_Name"::STRING AS cdi_anonymousvisitorid_Name
        ,JSONFIELD:"cdi_browser"::STRING AS cdi_browser
        ,JSONFIELD:"cdi_campaigncode"::STRING AS cdi_campaigncode
        ,lower(JSONFIELD:"cdi_campaignid_Id"::STRING) AS cdi_campaignid_Id
        ,JSONFIELD:"cdi_campaignid_Name"::STRING AS cdi_campaignid_Name
        ,lower(JSONFIELD:"cdi_contactid_Id"::STRING) AS cdi_contactid_Id
        ,lower(JSONFIELD:"cdi_domainid_Id"::STRING) AS cdi_domainid_Id
        ,JSONFIELD:"cdi_domainid_Name"::STRING AS cdi_domainid_Name
        ,JSONFIELD:"cdi_duration"::NUMBER AS cdi_duration
        ,JSONFIELD:"cdi_email"::STRING AS cdi_email
        ,JSONFIELD:"cdi_host"::STRING AS cdi_host
        ,JSONFIELD:"cdi_ip"::STRING AS cdi_ip
        ,lower(JSONFIELD:"cdi_iporganizationid_Id"::STRING) AS cdi_iporganizationid_Id
        ,JSONFIELD:"cdi_iporganizationid_Name"::STRING AS cdi_iporganizationid_Name
        ,lower(JSONFIELD:"cdi_leadid_Id"::STRING) AS cdi_leadid_Id
        ,JSONFIELD:"cdi_leadid_Name"::STRING AS cdi_leadid_Name
        ,JSONFIELD:"cdi_os"::STRING AS cdi_os
        ,JSONFIELD:"cdi_referrer"::STRING AS cdi_referrer
        ,JSONFIELD:"cdi_score"::NUMBER AS cdi_score
        ,JSONFIELD:"cdi_source"::NUMBER AS cdi_source
        ,JSONFIELD:"cdi_time"::STRING AS cdi_time
        ,JSONFIELD:"cdi_title"::STRING AS cdi_title
        ,JSONFIELD:"cdi_type"::NUMBER AS cdi_type
        ,JSONFIELD:"cdi_typename"::STRING AS cdi_typename
        ,JSONFIELD:"cdi_uri"::STRING AS cdi_uri
        ,REGEXP_REPLACE(JSONFIELD:"cdi_viewedon", '\/Date\\(|\\)\/', '')::TIMESTAMP AS cdi_viewedon
        ,lower(JSONFIELD:"cdi_visitid_Id"::STRING) AS cdi_visitid_Id
        ,JSONFIELD:"cdi_visitid_Name"::STRING AS cdi_visitid_Name
        ,JSONFIELD:"cdi_visitorkey"::STRING AS cdi_visitorkey
        ,REGEXP_REPLACE(JSONFIELD:"CreatedOn", '\/Date\\(|\\)\/', '')::TIMESTAMP AS CreatedOn
        ,JSONFIELD:"statecode"::NUMBER AS statecode
        ,JSONFIELD:"statuscode"::NUMBER AS statuscode
    FROM {{ source("TELCUSTOMER", "CDI_PAGEVIEW") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CDI_PAGEVIEW") }})
)

,transform_data as
(
    SELECT
        ID,
        CDI_ANONYMOUSVISITORID_ID,
        CDI_ANONYMOUSVISITORID_NAME,
        CDI_BROWSER,
        CDI_CAMPAIGNCODE,
        CDI_CAMPAIGNID_ID,
        CDI_CAMPAIGNID_NAME,
        CDI_CONTACTID_ID,
        CDI_DOMAINID_ID,
        CDI_DOMAINID_NAME,
        CDI_DURATION,
        CDI_EMAIL,
        CDI_HOST,
        CDI_IP,
        CDI_IPORGANIZATIONID_ID,
        CDI_IPORGANIZATIONID_NAME,
        CDI_LEADID_ID,
        CDI_LEADID_NAME,
        CDI_OS,
        CDI_REFERRER,
        CDI_SCORE,
        CDI_SOURCE,
        CDI_TIME,
        CDI_TITLE,
        CDI_TYPE,
        CDI_TYPENAME,
        CDI_URI,
        CDI_VIEWEDON,
        CDI_VISITID_ID,
        CDI_VISITID_NAME,
        CDI_VISITORKEY,
        CREATEDON,
        STATECODE,
        STATUSCODE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash
    FROM source_data

)
,type_data as 
(
    select
        cast(ID as VARCHAR(16777216)) as ID,
        cast(CDI_ANONYMOUSVISITORID_ID as VARCHAR(16777216)) as CDI_ANONYMOUSVISITORID_ID,
        cast(CDI_ANONYMOUSVISITORID_NAME as VARCHAR(16777216)) as CDI_ANONYMOUSVISITORID_NAME,
        cast(CDI_BROWSER as VARCHAR(16777216)) as CDI_BROWSER,
        cast(CDI_CAMPAIGNCODE as VARCHAR(16777216)) as CDI_CAMPAIGNCODE,
        cast(CDI_CAMPAIGNID_ID as VARCHAR(16777216)) as CDI_CAMPAIGNID_ID,
        cast(CDI_CAMPAIGNID_NAME as VARCHAR(16777216)) as CDI_CAMPAIGNID_NAME,
        cast(CDI_CONTACTID_ID as VARCHAR(16777216)) as CDI_CONTACTID_ID,
        cast(CDI_DOMAINID_ID as VARCHAR(16777216)) as CDI_DOMAINID_ID,
        cast(CDI_DOMAINID_NAME as VARCHAR(16777216)) as CDI_DOMAINID_NAME,
        cast(CDI_DURATION as NUMBER(38,0)) as CDI_DURATION,
        cast(CDI_EMAIL as VARCHAR(16777216)) as CDI_EMAIL,
        cast(CDI_HOST as VARCHAR(16777216)) as CDI_HOST,
        cast(CDI_IP as VARCHAR(16777216)) as CDI_IP,
        cast(CDI_IPORGANIZATIONID_ID as VARCHAR(16777216)) as CDI_IPORGANIZATIONID_ID,
        cast(CDI_IPORGANIZATIONID_NAME as VARCHAR(16777216)) as CDI_IPORGANIZATIONID_NAME,
        cast(CDI_LEADID_ID as VARCHAR(16777216)) as CDI_LEADID_ID,
        cast(CDI_LEADID_NAME as VARCHAR(16777216)) as CDI_LEADID_NAME,
        cast(CDI_OS as VARCHAR(16777216)) as CDI_OS,
        cast(CDI_REFERRER as VARCHAR(16777216)) as CDI_REFERRER,
        cast(CDI_SCORE as NUMBER(38,0)) as CDI_SCORE,
        cast(CDI_SOURCE as NUMBER(38,0)) as CDI_SOURCE,
        cast(CDI_TIME as VARCHAR(16777216)) as CDI_TIME,
        cast(CDI_TITLE as VARCHAR(16777216)) as CDI_TITLE,
        cast(CDI_TYPE as NUMBER(38,0)) as CDI_TYPE,
        cast(CDI_TYPENAME as VARCHAR(16777216)) as CDI_TYPENAME,
        cast(CDI_URI as VARCHAR(16777216)) as CDI_URI,
        cast(CDI_VIEWEDON as TIMESTAMP_NTZ(9)) as CDI_VIEWEDON,
        cast(CDI_VISITID_ID as VARCHAR(16777216)) as CDI_VISITID_ID,
        cast(CDI_VISITID_NAME as VARCHAR(16777216)) as CDI_VISITID_NAME,
        cast(CDI_VISITORKEY as VARCHAR(16777216)) as CDI_VISITORKEY,
        cast(CREATEDON as TIMESTAMP_NTZ(9)) as CREATEDON,
        cast(STATECODE as NUMBER(38,0)) as STATECODE,
        cast(STATUSCODE as NUMBER(38,0)) as STATUSCODE,
        -- cast(_IsDefault as varchar(128)) as _IsDefault,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data