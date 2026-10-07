/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='POST_CONSUME_PART_RETURN',
      transient=false
) }}

with source_data as (
    SELECT
        POST_CONSUME_PART_RETURN_ID,
        CSO_LINE_ITEM_ID,
        RMA_ID,
        QTY_RETURNED,
        IS_UNUSED_PART_RETURN,
        RETURN_CMTS,
        IS_PACKAGE_OPEN,
        IS_EXPOSED_TO_COPPER,
        RETURN_REASON_TYPE_ID,
        DECONTAMINATION_ID,
        IS_RMA_GENERATED,
        RMA_GEN_DT,
        RMA_GEN_USER_ID,
        CREATED_DT,
        CREATED_USER_ID,
        LAST_UPDATED_DT,
        LAST_UPDATED_USER_ID,
        INACTIVE_DT,
        INACTIVE_USER_ID,
        ACTIVE,
        SERIAL_NUMBER,
        SERIAL_NUMBER_CORE,
        QVICS_RTISS_TKMS_NUM
    from {{ ref('ODS__CARMA__POST_CONSUME_PART_RETURN') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data