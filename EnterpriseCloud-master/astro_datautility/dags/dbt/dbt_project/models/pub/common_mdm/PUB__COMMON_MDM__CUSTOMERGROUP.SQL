/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMERGROUP',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMERCODE,
        FSTCUSTOMERGROUP,
        BAANCUSTOMERNAME,
        SALESCUSTOMERGROUP,
        CUSTOMERSHORTNAME
    from {{ ref('COMMON__MDM__CUSTOMERGROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data