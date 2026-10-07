/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.33.11"
*************/

{{ config(
      materialized='view',
      alias='RMA_CUSTOMER_EMPLOYEE_CONTACT',
      transient=false
) }}

with source_data as (
    SELECT
        REQUEST_SALES_ID,
        CUSTOMER_PRIMARY_CONTACT,
        CUSTOMER_PRIMARY_EMAIL,
        CUSTOMER_SECONDARY_CONTACT,
        CUSTOMER_SECONDARY_EMAIL,
        EMPLOYEE_PRIMARY_CONTACT,
        EMPLOYEE_SECONDARY_CONTACT
    from {{ ref('COMMON__CARMA__RMA_CUSTOMER_EMPLOYEE_CONTACT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data