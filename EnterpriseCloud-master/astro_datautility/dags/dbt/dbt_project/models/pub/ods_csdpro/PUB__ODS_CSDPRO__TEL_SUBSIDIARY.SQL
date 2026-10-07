/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='TEL_SUBSIDIARY',
      transient=false
) }}

with source_data as (
    SELECT
        TEL_SUBSIDIARY_ID,
        GLOBAL_REGION_ID,
        ABBREVIATION,
        DESCRIPTION,
        BAAN_CO_NO,
        SORT_ORDER,
        INACTIVE_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__TEL_SUBSIDIARY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data