/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='BU',
      transient=false
) }}

with source_data as (
    SELECT
        BU_ID,
        BUCODE,
        DESCRIPTION,
        SORT_ORDER,
        INACTIVE_DATE,
        BAAN_BU_NBR--,
        --_FILEDATE,
        --_FILENAME
    from {{ ref('ODS__CSDPRO__BU') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data