/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMER',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMERID,
        CUSTOMERSHORTNAME,
        CUSTOMERGROUP,
        CUSTOMERGROUPTEL,
        GROUPFINANCIALNAME,
        SALESCUSTOMERGROUP
    from {{ ref('COMMON__MDM__CUSTOMER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data