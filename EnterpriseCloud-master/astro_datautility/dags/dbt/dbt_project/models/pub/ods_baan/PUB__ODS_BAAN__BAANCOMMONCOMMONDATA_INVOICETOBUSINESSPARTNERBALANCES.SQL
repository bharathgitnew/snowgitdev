/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.57"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        COMPANY,
        CURRENTYEAR,
        DEPARTMENT,
        INVOICEBALANCE,
        INVOICETOBUSINESSPARTNER,
        OPENBILLINGREQUESTAMOUNT,
        ORDER_BALANCE,
        TURNOVER1,
        TURNOVER2,
        TURNOVER3,
        TURNOVER_TOVR_1_1,
        TURNOVER_TOVR_1_2,
        TURNOVER_TOVR_1_3,
        TURNOVER_TOVR_2_1,
        TURNOVER_TOVR_2_2,
        TURNOVER_TOVR_2_3,
        TURNOVER_TOVR_3_1,
        TURNOVER_TOVR_3_2,
        TURNOVER_TOVR_3_3,
        TURNOVER_TOVR_4_1,
        TURNOVER_TOVR_4_2,
        TURNOVER_TOVR_4_3
    from {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data