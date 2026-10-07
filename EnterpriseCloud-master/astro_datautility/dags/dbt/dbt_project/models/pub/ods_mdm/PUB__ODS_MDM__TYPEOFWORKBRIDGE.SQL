/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.33"
*************/

{{ config(
      materialized='view',
      alias='TYPEOFWORKBRIDGE',
      transient=false
) }}

with source_data as (
    SELECT
        TYPE_OF_WORK_WITH_EVAL,
        FS_PRODUCT_FLAG,
        BILLBACK_FLAG,
        PRODUCT_TYPE,
        FACOTRY_OR_TEL,
        TOW_FS
    from {{ ref('ODS__MDM__TYPEOFWORKBRIDGE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data