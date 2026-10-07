{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TELCUSTOMER_CDI_VISIT',
    unique_key = ['ID']
) }}

with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,lower(JSONFIELD:"ID"::STRING) AS ID
        ,lower(JSONFIELD:"cdi_anonymousvisitorid_Id"::STRING) AS cdi_anonymousvisitorid_Id
        ,JSONFIELD:"cdi_anonymousvisitorid_Name"::STRING AS cdi_anonymousvisitorid_Name
        ,JSONFIELD:"cdi_browser"::STRING AS cdi_browser
        ,JSONFIELD:"cdi_campaigncode"::STRING AS cdi_campaigncode
        ,lower(JSONFIELD:"cdi_campaignid_Id"::STRING) AS cdi_campaignid_Id
        ,JSONFIELD:"cdi_campaignid_Name"::STRING AS cdi_campaignid_Name
        ,JSONFIELD:"cdi_city"::STRING AS cdi_city
        ,JSONFIELD:"cdi_company"::STRING AS cdi_company
        ,lower(JSONFIELD:"cdi_contactid_Id"::STRING) AS cdi_contactid_Id
        ,JSONFIELD:"cdi_contactid_Name"::STRING AS cdi_contactid_Name
        ,JSONFIELD:"cdi_country"::STRING AS cdi_country
        ,lower(JSONFIELD:"cdi_domainid_Id")::STRING AS cdi_domainid_Id
        ,JSONFIELD:"cdi_domainid_Name"::STRING AS cdi_domainid_Name
        ,JSONFIELD:"cdi_duration"::NUMBER AS cdi_duration
        ,JSONFIELD:"cdi_email"::STRING AS cdi_email
        ,REGEXP_REPLACE(JSONFIELD:"cdi_endedon", '\/Date\\(|\\)\/', '')::TIMESTAMP AS cdi_endedon
        ,JSONFIELD:"cdi_entrypage"::STRING AS cdi_entrypage
        ,JSONFIELD:"cdi_exitpage"::STRING AS cdi_exitpage
        ,JSONFIELD:"cdi_firstvisit"::STRING AS cdi_firstvisit
        ,JSONFIELD:"cdi_ip"::STRING AS cdi_ip
        ,lower(JSONFIELD:"cdi_iporganizationid_Id"::STRING) AS cdi_iporganizationid_Id
        ,JSONFIELD:"cdi_iporganizationid_Name"::STRING AS cdi_iporganizationid_Name
        ,JSONFIELD:"cdi_latitude"::STRING AS cdi_latitude
        ,JSONFIELD:"cdi_longitude"::STRING AS cdi_longitude
        ,JSONFIELD:"cdi_os"::STRING AS cdi_os
        ,JSONFIELD:"cdi_postalcode"::STRING AS cdi_postalcode
        ,JSONFIELD:"cdi_referrer"::STRING AS cdi_referrer
        ,JSONFIELD:"cdi_referringhost"::STRING AS cdi_referringhost
        ,JSONFIELD:"cdi_score"::NUMBER AS cdi_score
        ,JSONFIELD:"cdi_source"::STRING AS cdi_source
        ,REGEXP_REPLACE(JSONFIELD:"cdi_startedon", '\/Date\\(|\\)\/', '')::TIMESTAMP AS cdi_startedon
        ,JSONFIELD:"cdi_state"::STRING AS cdi_state
        ,JSONFIELD:"cdi_time"::STRING AS cdi_time
        ,JSONFIELD:"cdi_totalpages"::STRING AS cdi_totalpages
        ,JSONFIELD:"cdi_visitorkey"::STRING AS cdi_visitorkey
        ,REGEXP_REPLACE(JSONFIELD:"CreatedOn", '\/Date\\(|\\)\/', '')::TIMESTAMP AS CreatedOn
        ,JSONFIELD:"statecode"::STRING AS statecode
        ,JSONFIELD:"statuscode"::STRING AS statuscode
        ,JSONFIELD:"cdi_bounce"::STRING AS cdi_bounce
    FROM {{ source("TELCUSTOMER", "CDI_VISIT") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CDI_VISIT") }})
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
        CDI_CITY,
        CDI_COMPANY,
        CDI_CONTACTID_ID,
        CDI_CONTACTID_NAME,
        CDI_COUNTRY,
        CDI_DOMAINID_ID,
        CDI_DOMAINID_NAME,
        CDI_DURATION,
        CDI_EMAIL,
        CDI_ENDEDON,
        CDI_ENTRYPAGE,
        CDI_EXITPAGE,
        CDI_FIRSTVISIT,
        CDI_IP,
        CDI_IPORGANIZATIONID_ID,
        CDI_IPORGANIZATIONID_NAME,
        CDI_LATITUDE,
        CDI_LONGITUDE,
        CDI_OS,
        CDI_POSTALCODE,
        CDI_REFERRER,
        CDI_REFERRINGHOST,
        CDI_SCORE,
        CDI_SOURCE,
        CDI_STARTEDON,
        CDI_STATE,
        CDI_TIME,
        CDI_TOTALPAGES,
        CDI_VISITORKEY,
        CREATEDON,
        STATECODE,
        STATUSCODE,
        CDI_BOUNCE,
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
        cast(CDI_CITY as VARCHAR(16777216)) as CDI_CITY,
        cast(CDI_COMPANY as VARCHAR(16777216)) as CDI_COMPANY,
        cast(CDI_CONTACTID_ID as VARCHAR(16777216)) as CDI_CONTACTID_ID,
        cast(CDI_CONTACTID_NAME as VARCHAR(16777216)) as CDI_CONTACTID_NAME,
        cast(CDI_COUNTRY as VARCHAR(16777216)) as CDI_COUNTRY,
        cast(CDI_DOMAINID_ID as VARCHAR(16777216)) as CDI_DOMAINID_ID,
        cast(CDI_DOMAINID_NAME as VARCHAR(16777216)) as CDI_DOMAINID_NAME,
        cast(CDI_DURATION as NUMBER(38,0)) as CDI_DURATION,
        cast(CDI_EMAIL as VARCHAR(16777216)) as CDI_EMAIL,
        cast(CDI_ENDEDON as TIMESTAMP_NTZ(9)) as CDI_ENDEDON,
        cast(CDI_ENTRYPAGE as VARCHAR(16777216)) as CDI_ENTRYPAGE,
        cast(CDI_EXITPAGE as VARCHAR(16777216)) as CDI_EXITPAGE,
        cast(CDI_FIRSTVISIT as VARCHAR(16777216)) as CDI_FIRSTVISIT,
        cast(CDI_IP as VARCHAR(16777216)) as CDI_IP,
        cast(CDI_IPORGANIZATIONID_ID as VARCHAR(16777216)) as CDI_IPORGANIZATIONID_ID,
        cast(CDI_IPORGANIZATIONID_NAME as VARCHAR(16777216)) as CDI_IPORGANIZATIONID_NAME,
        cast(CDI_LATITUDE as VARCHAR(16777216)) as CDI_LATITUDE,
        cast(CDI_LONGITUDE as VARCHAR(16777216)) as CDI_LONGITUDE,
        cast(CDI_OS as VARCHAR(16777216)) as CDI_OS,
        cast(CDI_POSTALCODE as VARCHAR(16777216)) as CDI_POSTALCODE,
        cast(CDI_REFERRER as VARCHAR(16777216)) as CDI_REFERRER,
        cast(CDI_REFERRINGHOST as VARCHAR(16777216)) as CDI_REFERRINGHOST,
        cast(CDI_SCORE as NUMBER(38,0)) as CDI_SCORE,
        cast(CDI_SOURCE as VARCHAR(16777216)) as CDI_SOURCE,
        cast(CDI_STARTEDON as TIMESTAMP_NTZ(9)) as CDI_STARTEDON,
        cast(CDI_STATE as VARCHAR(16777216)) as CDI_STATE,
        cast(CDI_TIME as VARCHAR(16777216)) as CDI_TIME,
        cast(CDI_TOTALPAGES as VARCHAR(16777216)) as CDI_TOTALPAGES,
        cast(CDI_VISITORKEY as VARCHAR(16777216)) as CDI_VISITORKEY,
        cast(CREATEDON as TIMESTAMP_NTZ(9)) as CREATEDON,
        cast(STATECODE as VARCHAR(16777216)) as STATECODE,
        cast(STATUSCODE as VARCHAR(16777216)) as STATUSCODE,
        cast(CDI_BOUNCE as VARCHAR(16777216)) as CDI_BOUNCE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data