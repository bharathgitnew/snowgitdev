{{ config(
      materialized='tel_incremental',
      incremental_strategy='merge',
      alias='SIMULATED_REVENUE_RECOGNITION_HISTORY',
      unique_key=['ID',
    'SNAPSHOT_DATE',
    'CST_FLAG'],
      transient=false
) }}

with source_data as (
    SELECT    
        ID
        , CURRENT_DATE() AS SNAPSHOT_DATE
        , CST_FLAG
        , CONFIDENT_LEVEL
        , GS_CATEGORY 
        , SIMULATED_INVOICE_DATE
        , SIMULATED_INVOICE_DATE_RTD
        , SIMULATED_INVOICE_DATE_PREV_RTD
        , SIMULATED_INVOICE_AMOUNT 
        , SIMULATED_INVOICE_AMOUNT_RTD
        , EXPECTED_FORECAST_STATUS
    FROM {{ ref('GOLD__TEH_SALES_TO_INSTALLATION__SIMULATED_REVENUE_RECOGNITION') }} 
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,   
        ID
        , SNAPSHOT_DATE
        , CST_FLAG
        , CONFIDENT_LEVEL
        , GS_CATEGORY
        , SIMULATED_INVOICE_DATE
        , SIMULATED_INVOICE_DATE_RTD
        , SIMULATED_INVOICE_DATE_PREV_RTD
        , SIMULATED_INVOICE_AMOUNT 
        , SIMULATED_INVOICE_AMOUNT_RTD
        , EXPECTED_FORECAST_STATUS
    from source_data
),
type_data as(
    SELECT 
        _AUDIT_LOG_ID
        , _ROW_HASH
        , ID
        , SNAPSHOT_DATE
        , CST_FLAG
        , CONFIDENT_LEVEL
        , GS_CATEGORY
        , SIMULATED_INVOICE_DATE 
        , SIMULATED_INVOICE_DATE_RTD
        , SIMULATED_INVOICE_DATE_PREV_RTD
        , SIMULATED_INVOICE_AMOUNT 
        , SIMULATED_INVOICE_AMOUNT_RTD
        , EXPECTED_FORECAST_STATUS
    From transform_data
)
SELECT * FROM type_data