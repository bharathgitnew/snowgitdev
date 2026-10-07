/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.19"
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
    from {{ ref('ODS__MDM__CUSTOMER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data