/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.13"
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
    from {{ ref('COMMON__MDM__TYPEOFWORKBRIDGE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data