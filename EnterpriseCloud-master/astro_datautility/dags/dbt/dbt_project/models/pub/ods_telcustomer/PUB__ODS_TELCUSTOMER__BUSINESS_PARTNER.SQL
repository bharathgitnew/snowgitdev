{{ config(
      materialized='view',
      alias='BUSINESS_PARTNER',
      transient=false
) }}

with source_data as (
    SELECT
        BUSINESS_PARTNER_ID,
        NAME,
        CURRENCY_CODE,
        BIS_CUSTOMER_CODE,
        TEL_REGION,
        PARENT_BUSINESS_PARTNER_ID,
        ENG_NAME,
        ACCEPT_NDA,
        NDA_MODIFIED_DATE,
        NDA_MODIFIED_BY
    from {{ ref('ODS__TELCUSTOMER__BUSINESS_PARTNER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data