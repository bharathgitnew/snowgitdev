{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['CLIENT','COUNTER_FOR_RECORDS_IN_TIME_RECORDING'],
    alias='SAPO_TABLE_WITH_DELETION_TIME_OF_DELETED_CATS_RECORDS'
) }}
with source_data as(
    SELECT 
        _CAPTUREDATETIME,
        MANDT AS CLIENT,
        COUNTER AS COUNTER_FOR_RECORDS_IN_TIME_RECORDING,
        PERNR AS PERSONNEL_NUMBER,
        TRY_TO_DATE(WORKDATE,'YYYYMMDD') AS DATE,
        TRY_TO_DATE(LAEDA,'YYYYMMDD') AS DATE_OF_LAST_CHANGE,
        TO_CHAR(LAETM::TIMESTAMP, 'HH24:MI:SS') AS LAST_CHANGED_AT
FROM {{ source("SAP_ORACLE_LIVE", "CATSDEL") }}
),
Transform_data as (
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
        CLIENT,
        COUNTER_FOR_RECORDS_IN_TIME_RECORDING,
        PERSONNEL_NUMBER,
        DATE,
        DATE_OF_LAST_CHANGE,
        LAST_CHANGED_AT
    FROM source_data
),
type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        CLIENT,
        COUNTER_FOR_RECORDS_IN_TIME_RECORDING,
        cast(PERSONNEL_NUMBER AS NUMERIC(38,0)) AS PERSONNEL_NUMBER,
        cast(DATE AS DATE) AS DATE,
        cast(DATE_OF_LAST_CHANGE AS DATE) AS DATE_OF_LAST_CHANGE,
        LAST_CHANGED_AT as LAST_CHANGED_AT
    FROM Transform_data
)
SELECT * FROM type_data