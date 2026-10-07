/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='MACHINEMODELGROUP',
      transient=false
) }}

with source_data as (
    SELECT
        BU,
        SWLH_MODEL,
        MODEL_CATEGORY,
        MODEL_SUB_CATEGORY
    from {{ ref('COMMON__MDM__MACHINEMODELGROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data