/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.27"
*************/

{{ config(
      materialized='view',
      alias='ORACLEEPBCSACCOUNT',
      transient=false
) }}

with source_data as (
    SELECT
        ORACLEACCOUNTID,
        ORACLEACCOUNTNAME,
        ORACLEEPBCSACCOUNTNUMBERINDW,
        ORACLEEPBCSACCOUNTNAMEINDW,
        FINANCIALACCOUNTGROUP,
        BAANACCOUNTFORBUDGET
    from {{ ref('ODS__MDM__ORACLEEPBCSACCOUNT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data