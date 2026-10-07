/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.22"
*************/

{{ config(
      materialized='view',
      alias='FINANCIALSEGMENT',
      transient=false
) }}

with source_data as (
    SELECT
        SEGMENTCODE,
        ALTERNATENAME,
        SHORTNAME,
        GROUPNAME
    from {{ ref('ODS__MDM__FINANCIALSEGMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data