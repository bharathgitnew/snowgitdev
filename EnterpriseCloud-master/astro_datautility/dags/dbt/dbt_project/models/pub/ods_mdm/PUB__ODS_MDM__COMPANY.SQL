/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.17"
*************/

{{ config(
      materialized='view',
      alias='COMPANY',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANYCODE,
        COMPANYNAME,
        LONGNAME,
        ACTIVEINDICATOR
    from {{ ref('ODS__MDM__COMPANY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data