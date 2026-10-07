{{ config(
        materialized='incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BAANV_TAX_FY23',
    	transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        TRANSACTION_TYPE,
        DOCUMENT,
        LINE AS LINE_NUMBER,
        ORIGINAL_COMPANY,
        FISCAL_YEAR,
        LEDGER_ACC AS LEDGER_ACCOUNT,
        DOC_DATE AS DOCUMENT_DATE,
        AMOUNT,
        CURRENCY,
        RATE,
        BOL.T$RATD AS RATE_DATE,
        BOL.T$RATE$1 AS RATE_1,
        BOL.T$RTYP AS EXCHANGE_RATE,
        AMOUNT_IN_HC,
        DC_DESC,
        REFERENCE AS TEXT_DESC
    FROM {{ ref('COMMON__BAAN__FINALIZEDTRANSACTIONS') }} FT
    LEFT JOIN {{ source("BAAN_ORACLE_LIVE", "TTFGLD106201") }} BOL 
        ON FT.TRANSACTION_TYPE = BOL.t$otyp 
        AND FT.DOCUMENT = BOL.t$odoc 
        AND FT.LINE = BOL.t$olin 
        AND FT.SEQUENCE_NUMBER = BOL.t$osrl 
        AND FT.BACKGROUND_SEQUENCE_NO = BOL.t$osrn
    WHERE FT.FISCAL_YEAR = '2023'
),

TRANSFORM_DATA AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        TRANSACTION_TYPE,
        DOCUMENT,
        LINE_NUMBER,
        ORIGINAL_COMPANY,
        FISCAL_YEAR,
        LEDGER_ACCOUNT,   
        DOCUMENT_DATE,    
        AMOUNT,
        CURRENCY,
        RATE,
        RATE_DATE,
        RATE_1,
        EXCHANGE_RATE,
        AMOUNT_IN_HC,
        DC_DESC,
        TEXT_DESC
    FROM SOURCE_DATA
),

TYPE_DATA AS (
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
 	    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_REFRESHDATE AS timestamp_ntz) AS _REFRESHDATE,
        TRANSACTION_TYPE,
        DOCUMENT,
        LINE_NUMBER,
        ORIGINAL_COMPANY,
        FISCAL_YEAR,
        LEDGER_ACCOUNT,   
        DOCUMENT_DATE,    
        AMOUNT,
        CURRENCY,
        RATE,
        RATE_DATE,
        RATE_1,
        EXCHANGE_RATE,
        AMOUNT_IN_HC,
        DC_DESC,
        TEXT_DESC
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA