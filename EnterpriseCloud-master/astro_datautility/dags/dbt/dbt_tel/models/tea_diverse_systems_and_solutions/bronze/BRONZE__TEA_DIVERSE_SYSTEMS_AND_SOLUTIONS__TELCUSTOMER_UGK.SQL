{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='TELCUSTOMER_UGK',
    unique_key = ['UGK_ID']
) }}

with source_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:"UGK_ID"::NUMBER AS UGK_ID
        ,JSONFIELD:"BU"::STRING AS BU
        ,JSONFIELD:"DOC_NUMBER"::STRING AS DOC_NUMBER
        ,JSONFIELD:"NAME"::STRING AS NAME
        ,JSONFIELD:"LANGUAGE"::STRING AS LANGUAGE
        ,JSONFIELD:"FILENAME"::STRING AS FILENAME
        ,JSONFIELD:"ACL_RULE"::STRING AS ACL_RULE
        ,JSONFIELD:"ACL_APPLIES_TO"::STRING AS ACL_APPLIES_TO
        ,REGEXP_REPLACE(JSONFIELD:"CREATE_DT", '\/Date\\(|\\)\/', '')::TIMESTAMP AS CREATE_DT
        ,JSONFIELD:"UPDATE_BY"::STRING AS UPDATE_BY
        ,REGEXP_REPLACE(JSONFIELD:"UPDATE_DT", '\/Date\\(|\\)\/', '')::TIMESTAMP AS UPDATE_DT
        ,JSONFIELD:"ACTIVE"::NUMBER AS ACTIVE
        ,JSONFIELD:"PUBLISH_MONTH"::STRING AS PUBLISH_MONTH
        ,JSONFIELD:"PUBLISH_YEAR"::STRING AS PUBLISH_YEAR
        ,JSONFIELD:"BENEFIT_FORMAT"::STRING AS BENEFIT_FORMAT
    FROM {{ source("TELCUSTOMER", "UGK") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TELCUSTOMER", "UGK") }})
)

,transform_data as
(
    SELECT
        UGK_ID,
        BU,
        DOC_NUMBER,
        NAME,
        LANGUAGE,
        FILENAME,
        ACL_RULE,
        ACL_APPLIES_TO,
        CREATE_DT,
        UPDATE_BY,
        UPDATE_DT,
        ACTIVE,
        PUBLISH_MONTH,
        PUBLISH_YEAR,
        BENEFIT_FORMAT,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash
    FROM source_data
)

,type_data as 
(
    select
        cast(UGK_ID as NUMBER(38,0)) as UGK_ID,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(DOC_NUMBER as VARCHAR(16777216)) as DOC_NUMBER,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(LANGUAGE as VARCHAR(16777216)) as LANGUAGE,
        cast(FILENAME as VARCHAR(16777216)) as FILENAME,
        cast(ACL_RULE as VARCHAR(16777216)) as ACL_RULE,
        cast(ACL_APPLIES_TO as VARCHAR(16777216)) as ACL_APPLIES_TO,
        cast(CREATE_DT as TIMESTAMP_NTZ(9)) as CREATE_DT,
        cast(UPDATE_BY as VARCHAR(16777216)) as UPDATE_BY,
        cast(UPDATE_DT as TIMESTAMP_NTZ(9)) as UPDATE_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(PUBLISH_MONTH as VARCHAR(16777216)) as PUBLISH_MONTH,
        cast(PUBLISH_YEAR as VARCHAR(16777216)) as PUBLISH_YEAR,
        cast(BENEFIT_FORMAT as VARCHAR(16777216)) as BENEFIT_FORMAT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data