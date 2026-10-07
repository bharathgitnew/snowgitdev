{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TELCUSTOMER_CONTACT',
    unique_key = ['ID']
) }}

with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"ID"::STRING AS ID
        ,JSONFIELD:"employeeid"::STRING AS employeeid
        ,JSONFIELD:"cdi_totalscore"::NUMBER AS cdi_totalscore
        ,JSONFIELD:"cdi_visitorkey"::STRING AS cdi_visitorkey
        ,REGEXP_REPLACE(JSONFIELD:"cdi_identifiedon", '\/Date\\(|\\)\/', '')::TIMESTAMP AS cdi_identifiedon
        ,JSONFIELD:"tmktg_TotalPageViews"::NUMBER AS tmktg_TotalPageViews
        ,REGEXP_REPLACE(JSONFIELD:"tmktg_TotalPageViews_Date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS tmktg_TotalPageViews_Date
        ,JSONFIELD:"tmktg_TotalPageViews_State"::NUMBER AS tmktg_TotalPageViews_State
        ,JSONFIELD:"tmktg_TotalVisits"::NUMBER AS tmktg_TotalVisits
        ,REGEXP_REPLACE(JSONFIELD:"tmktg_TotalVisits_Date", '\/Date\\(|\\)\/', '')::TIMESTAMP AS tmktg_TotalVisits_Date
        ,JSONFIELD:"tmktg_TotalVisits_State"::NUMBER AS tmktg_TotalVisits_State
        ,REGEXP_REPLACE(JSONFIELD:"ModifiedOn", '\/Date\\(|\\)\/', '')::TIMESTAMP AS ModifiedOn
    FROM {{ source("TELCUSTOMER", "CONTACT") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "CONTACT") }})
)

,transform_data as
(
    SELECT
        ID,
        EMPLOYEEID,
        CDI_TOTALSCORE,
        CDI_VISITORKEY,
        CDI_IDENTIFIEDON,
        TMKTG_TOTALPAGEVIEWS,
        TMKTG_TOTALPAGEVIEWS_DATE,
        TMKTG_TOTALPAGEVIEWS_STATE,
        TMKTG_TOTALVISITS,
        TMKTG_TOTALVISITS_DATE,
        TMKTG_TOTALVISITS_STATE,
        MODIFIEDON,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash
    FROM source_data
)
,type_data as 
(
    select
        cast(ID as VARCHAR(16777216)) as ID,
        cast(EMPLOYEEID as VARCHAR(16777216)) as EMPLOYEEID,
        cast(CDI_TOTALSCORE as NUMBER(38,0)) as CDI_TOTALSCORE,
        cast(CDI_VISITORKEY as VARCHAR(16777216)) as CDI_VISITORKEY,
        cast(CDI_IDENTIFIEDON as TIMESTAMP_NTZ(9)) as CDI_IDENTIFIEDON,
        cast(TMKTG_TOTALPAGEVIEWS as NUMBER(38,0)) as TMKTG_TOTALPAGEVIEWS,
        cast(TMKTG_TOTALPAGEVIEWS_DATE as TIMESTAMP_NTZ(9)) as TMKTG_TOTALPAGEVIEWS_DATE,
        cast(TMKTG_TOTALPAGEVIEWS_STATE as NUMBER(38,0)) as TMKTG_TOTALPAGEVIEWS_STATE,
        cast(TMKTG_TOTALVISITS as NUMBER(38,0)) as TMKTG_TOTALVISITS,
        cast(TMKTG_TOTALVISITS_DATE as TIMESTAMP_NTZ(9)) as TMKTG_TOTALVISITS_DATE,
        cast(TMKTG_TOTALVISITS_STATE as NUMBER(38,0)) as TMKTG_TOTALVISITS_STATE,
        cast(MODIFIEDON as TIMESTAMP_NTZ(9)) as MODIFIEDON,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data