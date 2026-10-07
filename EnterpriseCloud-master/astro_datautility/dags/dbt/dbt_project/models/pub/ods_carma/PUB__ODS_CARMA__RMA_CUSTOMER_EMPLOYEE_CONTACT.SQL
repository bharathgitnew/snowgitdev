/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.53"
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
    from {{ source('ODS__CARMA', 'RMA_CUSTOMER_EMPLOYEE_CONTACT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data