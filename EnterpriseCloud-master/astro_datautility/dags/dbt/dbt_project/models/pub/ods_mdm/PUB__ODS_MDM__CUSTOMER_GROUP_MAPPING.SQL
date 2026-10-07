/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.19"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMER_GROUP_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMERCODE,
        FSTCUSTOMERGROUP,
        BAANCUSTOMERNAME,
        SALESCUSTOMERGROUP,
        CUSTOMERSHORTNAME
    from {{ ref('ODS__MDM__CUSTOMER_GROUP_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data