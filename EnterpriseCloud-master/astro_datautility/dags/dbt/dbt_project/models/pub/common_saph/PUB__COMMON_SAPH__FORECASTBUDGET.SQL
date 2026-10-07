/************
Model file generated from dbtGeneratePubViews: 12.22.2022.10.52.54"
*************/

{{ config(
      materialized='view',
      alias='FORECASTBUDGET',
      transient=false
) }}

with source_data as (
    SELECT
        ACCOUNT,
        FILE_ACCOUNT,
        ENTITY,
        DEPARTMENTCODE,
        SEGMENTCODE,
        OFFICECODE,
        FINANCIALPRODUCTCODE,
        CUSTOMERCODE,
        UD6,
        UD7,
        VERSION,
        SCENARIO,
        YEAR,
        PERIOD,
        CURRENCY,
        AMOUNT,
        _FILEDATE,
        SCENARIOCREATEDDATE,
        DISPLAYBUDGETFLAG
    from {{ ref('COMMON__SAPH__FORECASTBUDGET') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data