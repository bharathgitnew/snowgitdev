/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINE_MODEL_GROUP',
      transient=false
) }}

with source_data as (
    SELECT
        BU,
        SWLH_MODEL,
        MODEL_CATEGORY,
        MODEL_SUB_CATEGORY
    from {{ ref('ODS__MDM__MACHINE_MODEL_GROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data