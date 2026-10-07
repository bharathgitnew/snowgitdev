/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.29"
*************/

{{ config(
      materialized='view',
      alias='TEL_OFFICE',
      transient=false
) }}

with source_data as (
    SELECT
        TEL_OFFICE_ID,
        DESCRIPTION,
        OFFICE_CODE,
        ADDRESS,
        CITY,
        POSTAL_CODE,
        COUNTRY,
        STATE_PROVINCE,
        SORT_ORDER,
        INACTIVE_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__TEL_OFFICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data