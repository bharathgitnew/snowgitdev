/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.27"
*************/

{{ config(
      materialized='view',
      alias='BAAN_FAB',
      transient=false
) }}

with source_data as (
    SELECT
        BAAN_FAB_ID,
        BAAN_BP_ID,
        NAME,
        STREET_ADDRESS,
        CITY,
        STATE_PROVINCE,
        POSTAL_CODE,
        COUNTRY,
        INACTIVE_DATE,
        BAAN_FAB_CODE,
        CREATED_DATE,
        MODIFIED_DATE--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__BAAN_FAB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data