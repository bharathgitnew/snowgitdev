/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.51"
*************/

{{ config(
      materialized='view',
      alias='CORE_RETURN_REASON_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        CORE_RETURN_REASON_TYPE_ID,
        NAME,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__CORE_RETURN_REASON_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data