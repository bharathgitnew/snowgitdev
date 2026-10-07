/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='PROCESS_SALES',
      transient=false
) }}

with source_data as (
    SELECT
        PROCESS_SALES_ID,
        RMA_ID,
        OVR_DISCREPANCY_AT_INV_WH,
        OVR_MAN_PACK_SLIP_SHIPSTAMP_ID,
        MIS_RELABELPART,
        MIS_IS_RMA_FOR_MTR,
        MIS_ORIGINAL_PART_FOUND_AT_WH,
        MIS_BAAN_DISCREPANCY_CORRECTED,
        MIS_REPLACE_PART_SENT_CONSIGN,
        MIS_SHIP_FOUNDPART,
        MIS_SHIP_FOUNDPART_SHIPSTAMP_ID,
        DAM_DAM_BY_CUSTOMER,
        DAM_PART_IS_REPAIRABLE,
        DAM_CHARGE_BU_FOR_DAM_PART,
        DAM_ENUM_DELIVER_PART_TO_BU,
        DOA_UNDER_WARRANTY,
        DOA_REPAIR_VEND_CREDIT_TYPE_ID,
        DOA_RETURN_PART_TO_VENDOR,
        DOA_ADJUST_DOA_WHSE,
        DOA_IS_PART_REPAIRABLE,
        DOA_RETURN_VENDOR_SHIPSTAMP_ID,
        TO_INVENTORY_WHSE_SHIPSTAMP_ID,
        CUB_TYPE_ID,
        CUB_ORDER_NUM,
        CUB_ORDER_LINE_NUM,
        INACTIVE_DT,
        CREATED_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__PROCESS_SALES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data