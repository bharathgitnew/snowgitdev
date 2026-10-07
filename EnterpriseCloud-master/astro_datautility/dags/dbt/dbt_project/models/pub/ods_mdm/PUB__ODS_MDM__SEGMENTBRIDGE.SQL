/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.31"
*************/

{{ config(
      materialized='view',
      alias='SEGMENTBRIDGE',
      transient=false
) }}

with source_data as (
    SELECT
        BU_FLAG,
        SEGMENT_CODE,
        SEGMENT_NAME,
        MACHINE_BU,
        TYPE_OF_WORK_WITH_EVAL,
        PRODUCT_TYPE,
        MACHINEBU_TYPEOFWORKWITHEVAL,
        ACCOUNT,
        TRANSFER_PRICING,
        BU_FS,
        BILL_TO_COMPANY
    from {{ ref('ODS__MDM__SEGMENTBRIDGE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data