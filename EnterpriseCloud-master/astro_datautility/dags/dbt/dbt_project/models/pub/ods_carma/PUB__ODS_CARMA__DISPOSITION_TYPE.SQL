/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.51"
*************/

{{ config(
      materialized='view',
      alias='DISPOSITION_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        DISP_TYPE_ID,
        ACRONYM,
        NAME,
        DESCRIPTION,
        IS_PRELIMINARY_DISPOSITION,
        IS_FINAL_DISPOSITION,
        SORT_ORDER,
        INACTIVE_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__DISPOSITION_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data