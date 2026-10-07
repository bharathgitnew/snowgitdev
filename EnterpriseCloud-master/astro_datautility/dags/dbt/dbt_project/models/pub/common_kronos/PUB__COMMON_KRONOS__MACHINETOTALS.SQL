/************
Model file generated from dbtGeneratePubViews: 02.03.2023.17.18.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINETOTALS',
      transient=false
) }}

with source_data as (
    SELECT
        CONCESSION,
        ERROR,
        FCN_HOURS,
        MACHINE_SERIAL_NUMBER,
        MODIFICATION,
        PAID_SERVICE_HOURS,
        PRE_STARTUP_HOURS,
        PRE_WARRANTY_HOURS,
        SERVICE_CONTRACT_HOURS,
        STARTUP_HOURS,
        TECHNICAL_SUPPORT,
        TRAINING,
        TSC_SERVICE,
        USED_EQUIPMENT,
        WARRANTY_HOURS
    from {{ ref('COMMON__KRONOS__MACHINETOTALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data