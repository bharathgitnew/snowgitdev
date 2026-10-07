{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='REPORTING_ACCCOUNT_RISK_SCORE_HISTORY'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:date::string as RISK_SCORE_DATE,
        jsonfield:risk_score::string as RISK_SCORE
    FROM {{ source("KNOWBE4", "REPORTING_ACCCOUNT_RISK_SCORE_HISTORY") }} Account
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY jsonfield:date,
                                    jsonfield:risk_score
                                ORDER BY _filedate DESC) = 1)
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _Row_Hash,
        _FILENAME,
        _FILEDATE,
        RISK_SCORE_DATE,
        RISK_SCORE
    FROM source_data
)
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        CAST(RISK_SCORE_DATE AS DATE) AS RISK_SCORE_DATE,
        CAST(RISK_SCORE AS NUMBER(38,3)) AS RISK_SCORE 
    from transform_data
    )
select * from type_data