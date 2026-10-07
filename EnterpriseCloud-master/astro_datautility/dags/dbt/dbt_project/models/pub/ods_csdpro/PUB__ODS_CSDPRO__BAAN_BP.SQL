/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='BAAN_BP',
      transient=false
) }}

with source_data as (
    SELECT
        BAAN_BP_ID,
        TEL_SUBSIDIARY_ID,
        NAME,
        INACTIVE_DATE,
        CREATED_DATE,
        MODIFIED_DATE--,
       -- _FILEDATE,
       -- _FILENAME
    from {{ ref('ODS__CSDPRO__BAAN_BP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data