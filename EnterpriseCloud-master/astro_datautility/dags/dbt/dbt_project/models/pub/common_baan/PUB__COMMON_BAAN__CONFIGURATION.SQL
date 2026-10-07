/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.58"
*************/

{{ config(
      materialized='view',
      alias='CONFIGURATION',
      transient=false
) }}

with source_data as (
    SELECT
        CONFIGURATIONID,
        BU,
        FABID,
        DESCRIPTION,
        ADDRESSID,
        RESPOSIBLEEMPLOYEEID,
        EXPIRATIONDATE,
        ISEXPIRED
    from {{ ref('COMMON__BAAN__CONFIGURATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data