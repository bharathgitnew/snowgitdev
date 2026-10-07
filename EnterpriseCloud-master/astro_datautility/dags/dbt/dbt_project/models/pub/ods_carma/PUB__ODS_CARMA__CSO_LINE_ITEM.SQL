/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.51"
*************/

{{ config(
      materialized='view',
      alias='CSO_LINE_ITEM',
      transient=false
) }}

with source_data as (
    SELECT
        CSO_LINE_ITEM_ID,
        RMA_ID,
        RMA_ID_CORE_RETURN,
        CSO_ID,
        BAAN_INV_ITEM_ID,
        SERVICE_ORDER_LINE_NBR,
        QTY_ORDERED,
        QTY_CONSUMED,
        RETURNING_A_CORE,
        QTY_RETURNED,
        QTY_RETURNED_CORES,
        QTY_REMAINING,
        QTY_REMAINING_CORE_RETURN,
        QTY_RECEIVED_CONSIGNMENT,
        CONSUMPTION_CMTS,
        RETURN_CMTS,
        OP_COMMENTS,
        CORE_RETURN_CMTS,
        IS_PACKAGE_OPEN,
        IS_EXPOSED_TO_COPPER,
        IS_EXPOSED_TO_COPPER_CORE,
        RETURN_REASON_TYPE_ID,
        CORE_RETURN_REASON_TYPE_ID,
        IS_FCN_ORDER,
        FCN_WAREHOUSE_RETURN_ID,
        DECONTAMINATION_ID,
        IS_LINE_COMPLETED_IN_BAAN,
        LINE_COMPL_IN_BAAN_DT,
        LINE_COMPL_IN_BAAN_USER_ID,
        LINE_COMPL_IN_BAAN_MSG,
        PROCESS_STATUS,
        PROCESS_ERROR,
        PROCESS_ERROR_MESSAGE,
        PROCESS_DT,
        IS_SPLIT_LINE_ITEM,
        SPLIT_LINE_ITEM_INTO_BAAN_DT,
        SPLIT_LINE_ITEM_USER_ID,
        SPLIT_LINE_ITEM_INTO_BAAN_MSG,
        OP_MODIFIED_DT,
        OP_MODIFIED_USER_ID,
        OP_MERGED_DT,
        OP_MERGED_USER_ID,
        OP_DELETED_BY_MERGE,
        IS_RMA_GENERATED,
        RMA_GEN_DT,
        RMA_GEN_USER_ID,
        PLANNED_CONSUMPTION_DT,
        POST_CONSUME_RETURN_AUTHORIZED,
        POST_CONSUME_RETURN_COMPLETE,
        CREATED_DT,
        CREATED_USER_ID,
        LAST_UPDATED_DT,
        LAST_UPDATED_USER_ID,
        INACTIVE_DT,
        INACTIVE_USER_ID,
        ACTIVE,
        SERIAL_NUMBER,
        SERIAL_NUMBER_CORE,
        SERVICE_ORDER_ACTIVITY_NBR,
        POST_CONSUME_CORE_AUTHORIZED,
        POST_CONSUME_CORE_COMPLETE,
        QVICS_RTISS_TKMS_NUM
    from {{ ref('ODS__CARMA__CSO_LINE_ITEM') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data