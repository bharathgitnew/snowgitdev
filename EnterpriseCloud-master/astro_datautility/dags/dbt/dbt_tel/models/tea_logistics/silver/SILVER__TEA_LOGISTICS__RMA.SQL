/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Carma\RMA.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\carma\RMA.SQL
-materialized incremental
-alias RMA
-incremental_strategy delete
-envVariable <<ODS>>
-sourceSchema CARMA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 1/25/2022 3:06:11 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    alias='RMA',
    unique_key = []
) }}

with source_data as
(
SELECT
    CAST(a.rma_id AS varchar(6)) AS rma_id,
    a.rma_num AS rma,
    CASE a.is_request_approved
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS rma_request_approved,
      CASE a.is_replacement_part_needed
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS replacement_part_needed,
      CASE a.is_replacement_part_avail
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS replacement_part_available,
      CASE a.is_replacement_part_debited
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS replacement_part_charged,
      CASE a.is_generated_by_consumption
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS generated_thru_consumption,
      CASE k.part_needed_by_tea
    WHEN 0 THEN 'No'
    WHEN 1 THEN 'Yes'
    ELSE NULL
  END AS part_needed_by_tea,
      CASE
    WHEN a.prelim_disp_id <> 0 THEN e.acronym
    ELSE NULL
  END AS preliminary_disp_type,
      CASE h.has_part_been_received
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS part_received,
      CASE
    WHEN a.final_disp_id <> 0 THEN ee.acronym
    ELSE NULL
  END AS final_disp_type,
      CASE g.dam_part_is_repairable
    WHEN 0 THEN 'No'
    WHEN 1 THEN 'Yes'
    ELSE NULL
  END AS final_disp_part_repairable,
      CASE a.credit_the_rma
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS pending_credit_issued,
      CAST(a.credit_percent_dscnt_2decimals AS NUMBER(8, 2))
  / 100 AS refund_percentage,
      CAST(CAST(a.pending_credit_amt_pennies AS NUMBER(18, 2)) / 100 AS NUMBER(18, 2)) AS extended_refund_amt,
      a.pending_credit_line_num AS refund_line,
      CASE a.core_credited_during_request
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS core_credited,
      CASE
    WHEN a.final_dam_disp_id <> 0 THEN f.name
    ELSE NULL
  END AS final_dmg_disp_type,
      CASE
    WHEN a.further_dam_disp_id <> 0 THEN ff.name
    ELSE NULL
  END AS further_dmg_disp_type,
      CASE i.is_cus_direct_requested
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS customer_directly_requested,
  i.req_sale_id,
      CASE a.is_cust_paid_repair_requested
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS customer_paid_repair_request,
      a.baan_bp_id,
      CASE a.is_generated_by_consumption
    WHEN 1 THEN k.baan_fab_id
    ELSE i.baan_fab_id
  END AS baan_fab_id,
      c.description AS rma_origin_type,
      CASE a.is_nisa_approved
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS nisa_approved,
      a.nisa_reference_number AS nisa_ref,
      CASE a.is_rma_for_nisa_request
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS rma_from_nisa_request,
      a.nisa_id,
      a.orig_service_order_nbr AS service_order,
      a.orig_ncdr_nbr AS ncdr,
      a.orig_sales_order_nbr AS sales_order,
      a.order_line_nbr AS order_line,
      a.orig_customer_po_nbr AS customer_po,
      CASE a.is_sales_order_core
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS sales_order_core_return,
      CASE a.is_special_rma
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS special_rma,
      CASE a.special_rma_type
    WHEN 1 THEN 'No-Bogai'
    WHEN 2 THEN 'Warehouse Transfers'
    WHEN 3 THEN 'CON Service Order'
    WHEN 4 THEN 'PDS Service Order'
    WHEN
      5 THEN 'CNP Service Order'
    WHEN 6 THEN 'FRF Service Order'
    WHEN 7 THEN 'FRW Service Order'
    ELSE NULL
  END AS special_rma_type,
      a.special_rma_mtr_num AS delivered_special_rma_mtr,
      a.from_warehouse_code,
      a.to_warehouse_code,
      CASE
    WHEN a.part_scrap_disp_type_id <> 0 THEN d.name
    ELSE NULL
  END AS scrap_part_determination,
      a.part_scrap_adjust_form_num AS scrap_part_adjust_form,
      a.part_scrap_entered_date AS scrap_part_date,
      CASE
    WHEN a.ncdr_type_id <> 0 THEN b.name
    ELSE NULL
  END AS ncdr_return_type,
      CASE a.is_consignment_rma
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS consignment_rma,
      CASE a.is_post_consume_part_return
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS post_consumption_return,
      CASE a.is_customer_billable
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS customer_billable,
      a.serial_number AS serial,
      a.baan_inv_item_id AS part,
      a.baan_inv_item_description AS user_entered_part_desc,
      a.item_quantity AS qty_returned,
      CASE a.is_far_rma
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS far_rma,
      i.cust_descr AS customer_fse_problem_desc,
      CASE a.is_decontamination_entered
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS decon_info_entered,
      CASE a.is_decontamination_approved
    WHEN 1 THEN 'Yes'
    ELSE 'No'
  END AS decon_approved,
      a.assigned_fse_id,
      a.created_user_id,
      a.updated_user_id,
      a.submitted_user_id,
      a.issued_user_id,
      a.received_user_id,
      a.inspected_user_id,
      a.investigated_user_id,
      a.cancelled_user_id,
      a.closed_user_id AS deleted_user_id,
      a.completed_user_id,
      a.saved_role_id,
      a.created_dt,
      a.updated_dt,
      a.submitted_dt,
      a.issued_dt,
      a.received_dt,
      a.inspected_dt,
      a.investigated_dt,
      a.cancelled_dt,
      a.closed_dt AS deleted_dt,
      a.completed_dt,
      a.replacement_part_shipstamp_id,
      a.part_scrap_repwhse_shipstamp_id,
      a.part_scrap_return_shipstamp_id,
      a.into_storage_location_ship_id AS into_storage_location_shipstamp_id,
      a.into_location_warehouse_id,
      a.returned_to_cust_shipstamp_id,
      a.return_to_tel_shipstamp_id,
      g.to_inventory_whse_shipstamp_id,
      CASE a.is_generated_by_consumption
    WHEN 1 THEN k.in_transit_shipstamp_id
    ELSE i.in_transit_shipstamp_id
  END AS in_transit_shipstamp_id,
      a.cpr_rejected_on_create_page,
      a.MANUFACTURING_PART_NUM,
      a.PRODUCTION_ORDER_NUM,
      a.PART_LOCATION_CPR,
      a.BU_REJECTION_DATE,
      a.ORIGINAL_ITEM_DESCRIPTION,
      a.ORIGINAL_TYPE_OF_REPAIR,
      a.PART_NUMBER_HAS_BEEN_CORRECTED,
      a.PART_NUM_PRIOR_BU_CORRECT,
      a.BU_REJECTION_COMMENTS,
      a.original_part_num,
      a.sales_force_ref_num,
      a.tkms_ref_id,
      a.tel_serial_num
FROM {{ ref('BRONZE__TEA_LOGISTICS__CARMA_RMA') }} AS a
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_NCDR_TYPE') }} AS b
    ON a.ncdr_type_id = b.ncdr_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_ORDER_TYPE') }} AS c
    ON a.order_type_id = c.order_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_PART_SCRAP_DISP_TYPE') }} AS d
    ON a.part_scrap_disp_type_id = d.part_scrap_disp_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_DISPOSITION_TYPE') }} AS e
    ON a.prelim_disp_id = e.disp_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_DISPOSITION_TYPE') }} AS ee
    ON a.final_disp_id = ee.disp_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_DMG_LIABILITY_DISP_TYPE') }} AS f
    ON a.final_dam_disp_id = f.dmg_liability_disp_type_id
    INNER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_DMG_LIABILITY_DISP_TYPE') }} AS ff
    ON a.further_dam_disp_id = ff.dmg_liability_disp_type_id
    LEFT OUTER JOIN (SELECT
        process_sales_id,
        rma_id,
        ovr_discrepancy_at_inv_wh,
        ovr_man_pack_slip_shipstamp_id,
        mis_relabelpart,
        mis_is_rma_for_mtr,
        mis_original_part_found_at_wh,
        mis_baan_discrepancy_corrected,
        mis_replace_part_sent_consign,
        mis_ship_foundpart,
        mis_ship_foundpart_shipstamp_id,
        dam_dam_by_customer,
        dam_part_is_repairable,
        dam_charge_bu_for_dam_part,
        dam_enum_deliver_part_to_bu,
        doa_under_warranty,
        doa_repair_vend_credit_type_id,
        doa_return_part_to_vendor,
        doa_adjust_doa_whse,
        doa_is_part_repairable,
        doa_return_vendor_shipstamp_id,
        to_inventory_whse_shipstamp_id,
        cub_type_id,
        cub_order_num,
        cub_order_line_num,
        inactive_dt,
        created_dt,
        active
    FROM {{ ref('BRONZE__TEA_LOGISTICS__CARMA_PROCESS_SALES') }} AS gg
    WHERE (active = 1)
        AND (process_sales_id = (SELECT
            MAX(process_sales_id) AS Expr1
        FROM {{ ref('BRONZE__TEA_LOGISTICS__CARMA_PROCESS_SALES') }}
        WHERE (rma_id = gg.rma_id))
)) AS g
    ON a.rma_id = g.rma_id
    LEFT OUTER JOIN (SELECT
        receive_request_id,
        rma_id,
        qty_received,
        received_dt,
        damaged_in_transit,
        rma_overage_accepted,
        qty_overage,
        damaged_further_in_transit,
        inbound_shipping_carrier,
        inbound_tracking_nbr,
        has_part_been_received,
        has_part_been_expired,
        has_refused_delivery,
        inactive_dt,
        created_dt,
        active,
        receiving_users_action,
        reopen_dt,
        reopen_user_id
    FROM {{ ref('BRONZE__TEA_LOGISTICS__CARMA_RECEIVE_REQUEST') }} AS hh
    WHERE (active = 1)
        AND (receive_request_id = (SELECT
            MAX(receive_request_id) AS Expr1
        FROM {{ ref('BRONZE__TEA_LOGISTICS__CARMA_RECEIVE_REQUEST') }}
        WHERE (rma_id = hh.rma_id))
)) AS h
    ON a.rma_id = h.rma_id
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_REQUEST_SALES') }}  AS i
    ON a.rma_id = i.rma_id
    LEFT OUTER JOIN {{ ref('BRONZE__TEA_LOGISTICS__CARMA_REQUEST_SERVICE') }}  AS k
    ON a.rma_id = k.rma_id
WHERE (a.active = 1)
ORDER BY rma_id, rma
)
,transform_data as

(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh. 
    ASSIGNED_FSE_ID,
    BAAN_BP_ID,
    BAAN_FAB_ID,
    BU_REJECTION_COMMENTS,
    BU_REJECTION_DATE,
    CANCELLED_DT,
    CANCELLED_USER_ID,
    COMPLETED_DT,
    COMPLETED_USER_ID,
    CONSIGNMENT_RMA,
    CORE_CREDITED,
    CPR_REJECTED_ON_CREATE_PAGE,
    CREATED_DT,
    CREATED_USER_ID,
    CUSTOMER_BILLABLE,
    CUSTOMER_DIRECTLY_REQUESTED,
    CUSTOMER_FSE_PROBLEM_DESC,
    CUSTOMER_PAID_REPAIR_REQUEST,
    CUSTOMER_PO,
    CUSTOMER_PRIMARY_CONTACT,
    CUSTOMER_PRIMARY_EMAIL,
    CUSTOMER_SECONDARY_CONTACT,
    CUSTOMER_SECONDARY_EMAIL,
    DECON_APPROVED,
    DECON_INFO_ENTERED,
    DELETED_DT,
    DELETED_USER_ID,
    DELIVERED_SPECIAL_RMA_MTR,
    EMPLOYEE_PRIMARY_CONTACT,
    EMPLOYEE_SECONDARY_CONTACT,
    EXTENDED_REFUND_AMT,
    FAR_RMA,
    FINAL_DISP_PART_REPAIRABLE,
    FINAL_DISP_TYPE,
    FINAL_DMG_DISP_TYPE,
    FROM_WAREHOUSE_CODE,
    FURTHER_DMG_DISP_TYPE,
    GENERATED_THRU_CONSUMPTION,
    INSPECTED_DT,
    INSPECTED_USER_ID,
    INTO_LOCATION_WAREHOUSE_ID,
    INTO_STORAGE_LOCATION_SHIPSTAMP_ID,
    INVESTIGATED_DT,
    INVESTIGATED_USER_ID,
    IN_TRANSIT_SHIPSTAMP_ID,
    ISSUED_DT,
    ISSUED_USER_ID,
    MANUFACTURING_PART_NUM,
    NCDR,
    NCDR_RETURN_TYPE,
    NISA_APPROVED,
    NISA_ID,
    NISA_REF,
    ORDER_LINE,
    ORIGINAL_ITEM_DESCRIPTION,
    ORIGINAL_PART_NUM,
    ORIGINAL_TYPE_OF_REPAIR,
    PART,
    PART_LOCATION_CPR,
    PART_NEEDED_BY_TEA,
    PART_NUMBER_HAS_BEEN_CORRECTED,
    PART_NUM_PRIOR_BU_CORRECT,
    PART_RECEIVED,
    PART_SCRAP_REPWHSE_SHIPSTAMP_ID,
    PART_SCRAP_RETURN_SHIPSTAMP_ID,
    PENDING_CREDIT_ISSUED,
    POST_CONSUMPTION_RETURN,
    PRELIMINARY_DISP_TYPE,
    PRODUCTION_ORDER_NUM,
    QTY_RETURNED,
    RECEIVED_DT,
    RECEIVED_USER_ID,
    REFUND_LINE,
    REFUND_PERCENTAGE,
    REPLACEMENT_PART_AVAILABLE,
    REPLACEMENT_PART_CHARGED,
    REPLACEMENT_PART_NEEDED,
    REPLACEMENT_PART_SHIPSTAMP_ID,
    RETURNED_TO_CUST_SHIPSTAMP_ID,
    RETURN_TO_TEL_SHIPSTAMP_ID,
    RMA,
    RMA_FROM_NISA_REQUEST,
    RMA_ID,
    RMA_ORIGIN_TYPE,
    RMA_REQUEST_APPROVED,
    SALES_FORCE_REF_NUM,
    SALES_ORDER,
    SALES_ORDER_CORE_RETURN,
    SAVED_ROLE_ID,
    SCRAP_PART_ADJUST_FORM,
    SCRAP_PART_DATE,
    SCRAP_PART_DETERMINATION,
    SERIAL,
    SERVICE_ORDER,
    SPECIAL_RMA,
    SPECIAL_RMA_TYPE,
    SUBMITTED_DT,
    SUBMITTED_USER_ID,
    TEL_SERIAL_NUM,
    TKMS_REF_ID,
    TO_INVENTORY_WHSE_SHIPSTAMP_ID,
    TO_WAREHOUSE_CODE,
    UPDATED_DT,
    UPDATED_USER_ID,
    USER_ENTERED_PART_DESC
FROM Source_Data
LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'RMA_CUSTOMER_EMPLOYEE_CONTACT') }} 
ON RMA_CUSTOMER_EMPLOYEE_CONTACT.REQUEST_SALES_ID = Source_Data.REQ_SALE_ID
)
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(RMA_ID as VARCHAR(16777216)) as RMA_ID,
        cast(RMA as VARCHAR(16777216)) as RMA,
        cast(RMA_REQUEST_APPROVED as VARCHAR(16777216)) as RMA_REQUEST_APPROVED,
        cast(REPLACEMENT_PART_NEEDED as VARCHAR(16777216)) as REPLACEMENT_PART_NEEDED,
        cast(REPLACEMENT_PART_AVAILABLE as VARCHAR(16777216)) as REPLACEMENT_PART_AVAILABLE,
        cast(REPLACEMENT_PART_CHARGED as VARCHAR(16777216)) as REPLACEMENT_PART_CHARGED,
        cast(GENERATED_THRU_CONSUMPTION as VARCHAR(16777216)) as GENERATED_THRU_CONSUMPTION,
        cast(PART_NEEDED_BY_TEA as VARCHAR(16777216)) as PART_NEEDED_BY_TEA,
        cast(PRELIMINARY_DISP_TYPE as VARCHAR(16777216)) as PRELIMINARY_DISP_TYPE,
        cast(PART_RECEIVED as VARCHAR(16777216)) as PART_RECEIVED,
        cast(FINAL_DISP_TYPE as VARCHAR(16777216)) as FINAL_DISP_TYPE,
        cast(FINAL_DISP_PART_REPAIRABLE as VARCHAR(16777216)) as FINAL_DISP_PART_REPAIRABLE,
        cast(PENDING_CREDIT_ISSUED as VARCHAR(16777216)) as PENDING_CREDIT_ISSUED,
        cast(REFUND_PERCENTAGE as NUMBER(38,0)) as REFUND_PERCENTAGE,
        cast(EXTENDED_REFUND_AMT as NUMBER(38,0)) as EXTENDED_REFUND_AMT,
        cast(REFUND_LINE as NUMBER(38,0)) as REFUND_LINE,
        cast(CORE_CREDITED as VARCHAR(16777216)) as CORE_CREDITED,
        cast(FINAL_DMG_DISP_TYPE as VARCHAR(16777216)) as FINAL_DMG_DISP_TYPE,
        cast(FURTHER_DMG_DISP_TYPE as VARCHAR(16777216)) as FURTHER_DMG_DISP_TYPE,
        cast(CUSTOMER_DIRECTLY_REQUESTED as VARCHAR(16777216)) as CUSTOMER_DIRECTLY_REQUESTED,
        cast(CUSTOMER_PAID_REPAIR_REQUEST as VARCHAR(16777216)) as CUSTOMER_PAID_REPAIR_REQUEST,
        cast(BAAN_BP_ID as VARCHAR(16777216)) as BAAN_BP_ID,
        cast(BAAN_FAB_ID as VARCHAR(16777216)) as BAAN_FAB_ID,
        cast(RMA_ORIGIN_TYPE as VARCHAR(16777216)) as RMA_ORIGIN_TYPE,
        cast(NISA_APPROVED as VARCHAR(16777216)) as NISA_APPROVED,
        cast(NISA_REF as VARCHAR(16777216)) as NISA_REF,
        cast(RMA_FROM_NISA_REQUEST as VARCHAR(16777216)) as RMA_FROM_NISA_REQUEST,
        cast(NISA_ID as NUMBER(38,0)) as NISA_ID,
        cast(SERVICE_ORDER as VARCHAR(16777216)) as SERVICE_ORDER,
        cast(NCDR as VARCHAR(16777216)) as NCDR,
        cast(SALES_ORDER as VARCHAR(16777216)) as SALES_ORDER,
        cast(ORDER_LINE as VARCHAR(16777216)) as ORDER_LINE,
        cast(CUSTOMER_PO as VARCHAR(16777216)) as CUSTOMER_PO,
        cast(SALES_ORDER_CORE_RETURN as VARCHAR(16777216)) as SALES_ORDER_CORE_RETURN,
        cast(SPECIAL_RMA as VARCHAR(16777216)) as SPECIAL_RMA,
        cast(SPECIAL_RMA_TYPE as VARCHAR(16777216)) as SPECIAL_RMA_TYPE,
        cast(DELIVERED_SPECIAL_RMA_MTR as VARCHAR(16777216)) as DELIVERED_SPECIAL_RMA_MTR,
        cast(FROM_WAREHOUSE_CODE as VARCHAR(16777216)) as FROM_WAREHOUSE_CODE,
        cast(TO_WAREHOUSE_CODE as VARCHAR(16777216)) as TO_WAREHOUSE_CODE,
        cast(SCRAP_PART_DETERMINATION as VARCHAR(16777216)) as SCRAP_PART_DETERMINATION,
        cast(SCRAP_PART_ADJUST_FORM as VARCHAR(16777216)) as SCRAP_PART_ADJUST_FORM,
        cast(SCRAP_PART_DATE as TIMESTAMP_NTZ(9)) as SCRAP_PART_DATE,
        cast(NCDR_RETURN_TYPE as VARCHAR(16777216)) as NCDR_RETURN_TYPE,
        cast(CONSIGNMENT_RMA as VARCHAR(16777216)) as CONSIGNMENT_RMA,
        cast(POST_CONSUMPTION_RETURN as VARCHAR(16777216)) as POST_CONSUMPTION_RETURN,
        cast(CUSTOMER_BILLABLE as VARCHAR(16777216)) as CUSTOMER_BILLABLE,
        cast(SERIAL as VARCHAR(16777216)) as SERIAL,
        cast(PART as VARCHAR(16777216)) as PART,
        cast(USER_ENTERED_PART_DESC as VARCHAR(16777216)) as USER_ENTERED_PART_DESC,
        cast(QTY_RETURNED as NUMBER(38,0)) as QTY_RETURNED,
        cast(FAR_RMA as VARCHAR(16777216)) as FAR_RMA,
        cast(CUSTOMER_FSE_PROBLEM_DESC as VARCHAR(16777216)) as CUSTOMER_FSE_PROBLEM_DESC,
        cast(DECON_INFO_ENTERED as VARCHAR(16777216)) as DECON_INFO_ENTERED,
        cast(DECON_APPROVED as VARCHAR(16777216)) as DECON_APPROVED,
        cast(ASSIGNED_FSE_ID as VARCHAR(16777216)) as ASSIGNED_FSE_ID,
        cast(CREATED_USER_ID as VARCHAR(16777216)) as CREATED_USER_ID,
        cast(UPDATED_USER_ID as VARCHAR(16777216)) as UPDATED_USER_ID,
        cast(SUBMITTED_USER_ID as VARCHAR(16777216)) as SUBMITTED_USER_ID,
        cast(ISSUED_USER_ID as VARCHAR(16777216)) as ISSUED_USER_ID,
        cast(RECEIVED_USER_ID as VARCHAR(16777216)) as RECEIVED_USER_ID,
        cast(INSPECTED_USER_ID as VARCHAR(16777216)) as INSPECTED_USER_ID,
        cast(INVESTIGATED_USER_ID as VARCHAR(16777216)) as INVESTIGATED_USER_ID,
        cast(CANCELLED_USER_ID as VARCHAR(16777216)) as CANCELLED_USER_ID,
        cast(DELETED_USER_ID as VARCHAR(16777216)) as DELETED_USER_ID,
        cast(COMPLETED_USER_ID as VARCHAR(16777216)) as COMPLETED_USER_ID,
        cast(SAVED_ROLE_ID as VARCHAR(16777216)) as SAVED_ROLE_ID,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(UPDATED_DT as TIMESTAMP_NTZ(9)) as UPDATED_DT,
        cast(SUBMITTED_DT as TIMESTAMP_NTZ(9)) as SUBMITTED_DT,
        cast(ISSUED_DT as TIMESTAMP_NTZ(9)) as ISSUED_DT,
        cast(RECEIVED_DT as TIMESTAMP_NTZ(9)) as RECEIVED_DT,
        cast(INSPECTED_DT as TIMESTAMP_NTZ(9)) as INSPECTED_DT,
        cast(INVESTIGATED_DT as TIMESTAMP_NTZ(9)) as INVESTIGATED_DT,
        cast(CANCELLED_DT as TIMESTAMP_NTZ(9)) as CANCELLED_DT,
        cast(DELETED_DT as TIMESTAMP_NTZ(9)) as DELETED_DT,
        cast(COMPLETED_DT as TIMESTAMP_NTZ(9)) as COMPLETED_DT,
        cast(REPLACEMENT_PART_SHIPSTAMP_ID as NUMBER(38,0)) as REPLACEMENT_PART_SHIPSTAMP_ID,
        cast(PART_SCRAP_REPWHSE_SHIPSTAMP_ID as NUMBER(38,0)) as PART_SCRAP_REPWHSE_SHIPSTAMP_ID,
        cast(PART_SCRAP_RETURN_SHIPSTAMP_ID as NUMBER(38,0)) as PART_SCRAP_RETURN_SHIPSTAMP_ID,
        cast(INTO_STORAGE_LOCATION_SHIPSTAMP_ID as NUMBER(38,0)) as INTO_STORAGE_LOCATION_SHIPSTAMP_ID,
        cast(INTO_LOCATION_WAREHOUSE_ID as NUMBER(38,0)) as INTO_LOCATION_WAREHOUSE_ID,
        cast(RETURNED_TO_CUST_SHIPSTAMP_ID as NUMBER(38,0)) as RETURNED_TO_CUST_SHIPSTAMP_ID,
        cast(RETURN_TO_TEL_SHIPSTAMP_ID as NUMBER(38,0)) as RETURN_TO_TEL_SHIPSTAMP_ID,
        cast(TO_INVENTORY_WHSE_SHIPSTAMP_ID as NUMBER(38,0)) as TO_INVENTORY_WHSE_SHIPSTAMP_ID,
        cast(IN_TRANSIT_SHIPSTAMP_ID as NUMBER(38,0)) as IN_TRANSIT_SHIPSTAMP_ID,
        cast(CPR_REJECTED_ON_CREATE_PAGE as NUMBER(38,0)) as CPR_REJECTED_ON_CREATE_PAGE,
        cast(MANUFACTURING_PART_NUM as VARCHAR(16777216)) as MANUFACTURING_PART_NUM,
        cast(PRODUCTION_ORDER_NUM as VARCHAR(16777216)) as PRODUCTION_ORDER_NUM,
        cast(PART_LOCATION_CPR as VARCHAR(16777216)) as PART_LOCATION_CPR,
        cast(BU_REJECTION_DATE as TIMESTAMP_NTZ(9)) as BU_REJECTION_DATE,
        cast(ORIGINAL_ITEM_DESCRIPTION as VARCHAR(16777216)) as ORIGINAL_ITEM_DESCRIPTION,
        cast(ORIGINAL_TYPE_OF_REPAIR as VARCHAR(16777216)) as ORIGINAL_TYPE_OF_REPAIR,
        cast(PART_NUMBER_HAS_BEEN_CORRECTED as NUMBER(38,0)) as PART_NUMBER_HAS_BEEN_CORRECTED,
        cast(PART_NUM_PRIOR_BU_CORRECT as VARCHAR(16777216)) as PART_NUM_PRIOR_BU_CORRECT,
        cast(BU_REJECTION_COMMENTS as VARCHAR(16777216)) as BU_REJECTION_COMMENTS,
        cast(ORIGINAL_PART_NUM as VARCHAR(16777216)) as ORIGINAL_PART_NUM,
        cast(SALES_FORCE_REF_NUM as VARCHAR(16777216)) as SALES_FORCE_REF_NUM,
        cast(TKMS_REF_ID as VARCHAR(16777216)) as TKMS_REF_ID,
        cast(TEL_SERIAL_NUM as VARCHAR(16777216)) as TEL_SERIAL_NUM,
        cast(CUSTOMER_PRIMARY_CONTACT as VARCHAR(16777216)) as CUSTOMER_PRIMARY_CONTACT,
        cast(CUSTOMER_PRIMARY_EMAIL as VARCHAR(16777216)) as CUSTOMER_PRIMARY_EMAIL,
        cast(CUSTOMER_SECONDARY_CONTACT as VARCHAR(16777216)) as CUSTOMER_SECONDARY_CONTACT,
        cast(CUSTOMER_SECONDARY_EMAIL as VARCHAR(16777216)) as CUSTOMER_SECONDARY_EMAIL,
        cast(EMPLOYEE_PRIMARY_CONTACT as VARCHAR(16777216)) as EMPLOYEE_PRIMARY_CONTACT,
        cast(EMPLOYEE_SECONDARY_CONTACT as VARCHAR(16777216)) as EMPLOYEE_SECONDARY_CONTACT
    from transform_data
    )
select * from type_data