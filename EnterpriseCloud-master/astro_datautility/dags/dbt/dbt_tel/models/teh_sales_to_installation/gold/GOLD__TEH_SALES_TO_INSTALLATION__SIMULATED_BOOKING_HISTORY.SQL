{{ config(
      materialized='tel_incremental',
      incremental_strategy='merge',
      alias='SIMULATED_BOOKING_HISTORY',
      unique_key=['ID',
    'SNAPSHOT_DATE'],
      transient=false
) }}

with SIRFIS_LIFECYCLE as (
    select 
    ID
    , BOOKING_DATE
    , BOOKING_DATE_STD
    , EXPECTED_FORECAST_STATUS
    , READ_ONLY
    from {{ ref('GOLD__TEH_SALES_TO_INSTALLATION__SIRFIS_LIFECYCLE') }}
),

SIRFIS_PRICING as (
    select * from {{ ref('GOLD__TEH_SALES_TO_INSTALLATION__SIRFIS_PRICING') }}
),

source_data as (
    SELECT DISTINCT
        F.ID,
        CURRENT_DATE() AS SNAPSHOT_DATE,
        F.BOOKING_DATE,
        F.BOOKING_DATE_STD,
        P.PRICE_ESTIMATE, 
        F.EXPECTED_FORECAST_STATUS
    FROM SIRFIS_LIFECYCLE F
    LEFT JOIN SIRFIS_PRICING P
    ON F.ID = P.ID
    WHERE F.EXPECTED_FORECAST_STATUS <> 'DELETED' 
    AND UPPER(F.READ_ONLY) = 'NO'
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,   
        ID,
        SNAPSHOT_DATE,
        BOOKING_DATE,
        BOOKING_DATE_STD,
        PRICE_ESTIMATE, 
        EXPECTED_FORECAST_STATUS
    from source_data
),
type_data as(
    SELECT 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ID,
        SNAPSHOT_DATE, 
        BOOKING_DATE,
        BOOKING_DATE_STD,
        PRICE_ESTIMATE, 
        EXPECTED_FORECAST_STATUS
    From transform_data
)
SELECT * FROM type_data