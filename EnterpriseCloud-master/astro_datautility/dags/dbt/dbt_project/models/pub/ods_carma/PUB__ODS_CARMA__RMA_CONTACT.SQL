/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.53"
*************/

{{ config(
      materialized='view',
      alias='RMA_CONTACT',
      transient=false
) }}

with source_data as (
    SELECT
        RMA_CONTACT_ID,
        REQUEST_SALES_ID,
        RMA_CONTACT_TYPE_ID,
        EMPLOYEE_ID,
        FIRST_NAME,
        LAST_NAME,
        PHONE,
        EMAIL,
        COMMENTS,
        INACTIVE_DT,
        CREATED_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__RMA_CONTACT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data