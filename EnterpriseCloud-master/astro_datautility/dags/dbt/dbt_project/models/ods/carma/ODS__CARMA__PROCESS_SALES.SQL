/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\PROCESSSALES__CARMA_PROCESSSALES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\PROCESS_SALES.SQL 
-materialized incremental
-alias PROCESS_SALES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/10/2022 2:23:24 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PROCESS_SALES',
    unique_key = ['PROCESS_SALES_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"process_sales_id"::NUMBER AS process_sales_id, 
         JSONFIELD:"rma_id"::NUMBER AS rma_id, 
         JSONFIELD:"ovr_discrepancy_at_inv_wh"::NUMBER AS ovr_discrepancy_at_inv_wh, 
         JSONFIELD:"ovr_man_pack_slip_shipstamp_id"::NUMBER AS ovr_man_pack_slip_shipstamp_id, 
         JSONFIELD:"mis_relabelpart"::NUMBER AS mis_relabelpart, 
         JSONFIELD:"mis_is_rma_for_mtr"::NUMBER AS mis_is_rma_for_mtr, 
         JSONFIELD:"mis_original_part_found_at_wh"::NUMBER AS mis_original_part_found_at_wh, 
         JSONFIELD:"mis_baan_discrepancy_corrected"::NUMBER AS mis_baan_discrepancy_corrected, 
         JSONFIELD:"mis_replace_part_sent_consign"::NUMBER AS mis_replace_part_sent_consign, 
         JSONFIELD:"mis_ship_foundpart"::NUMBER AS mis_ship_foundpart, 
         JSONFIELD:"mis_ship_foundpart_shipstamp_id"::NUMBER AS mis_ship_foundpart_shipstamp_id, 
         JSONFIELD:"dam_dam_by_customer"::NUMBER AS dam_dam_by_customer, 
         JSONFIELD:"dam_part_is_repairable"::NUMBER AS dam_part_is_repairable, 
         JSONFIELD:"dam_charge_bu_for_dam_part"::NUMBER AS dam_charge_bu_for_dam_part, 
         JSONFIELD:"dam_enum_deliver_part_to_bu"::NUMBER AS dam_enum_deliver_part_to_bu, 
         JSONFIELD:"doa_under_warranty"::NUMBER AS doa_under_warranty, 
         JSONFIELD:"doa_repair_vend_credit_type_id"::NUMBER AS doa_repair_vend_credit_type_id, 
         JSONFIELD:"doa_return_part_to_vendor"::NUMBER AS doa_return_part_to_vendor, 
         JSONFIELD:"doa_adjust_doa_whse"::NUMBER AS doa_adjust_doa_whse, 
         JSONFIELD:"doa_is_part_repairable"::NUMBER AS doa_is_part_repairable, 
         JSONFIELD:"doa_return_vendor_shipstamp_id"::NUMBER AS doa_return_vendor_shipstamp_id, 
         JSONFIELD:"to_inventory_whse_shipstamp_id"::NUMBER AS to_inventory_whse_shipstamp_id, 
         JSONFIELD:"cub_type_id"::NUMBER AS cub_type_id, 
         JSONFIELD:"cub_order_num"::STRING  AS cub_order_num, 
         JSONFIELD:"cub_order_line_num"::STRING  AS cub_order_line_num, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "PROCESS_SALES") }} as s
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "PROCESS_SALES") }} as c 
                                                where s.JSONFIELD:"process_sales_id"::NUMBER = c.JSONFIELD:"process_sales_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.PROCESS_SALES_ID AS PROCESS_SALES_ID, 
        source_data.RMA_ID AS RMA_ID, 
        source_data.OVR_DISCREPANCY_AT_INV_WH AS OVR_DISCREPANCY_AT_INV_WH, 
        source_data.OVR_MAN_PACK_SLIP_SHIPSTAMP_ID AS OVR_MAN_PACK_SLIP_SHIPSTAMP_ID, 
        source_data.MIS_RELABELPART AS MIS_RELABELPART, 
        source_data.MIS_IS_RMA_FOR_MTR AS MIS_IS_RMA_FOR_MTR, 
        source_data.MIS_ORIGINAL_PART_FOUND_AT_WH AS MIS_ORIGINAL_PART_FOUND_AT_WH, 
        source_data.MIS_BAAN_DISCREPANCY_CORRECTED AS MIS_BAAN_DISCREPANCY_CORRECTED, 
        source_data.MIS_REPLACE_PART_SENT_CONSIGN AS MIS_REPLACE_PART_SENT_CONSIGN, 
        source_data.MIS_SHIP_FOUNDPART AS MIS_SHIP_FOUNDPART, 
        source_data.MIS_SHIP_FOUNDPART_SHIPSTAMP_ID AS MIS_SHIP_FOUNDPART_SHIPSTAMP_ID, 
        source_data.DAM_DAM_BY_CUSTOMER AS DAM_DAM_BY_CUSTOMER, 
        source_data.DAM_PART_IS_REPAIRABLE AS DAM_PART_IS_REPAIRABLE, 
        source_data.DAM_CHARGE_BU_FOR_DAM_PART AS DAM_CHARGE_BU_FOR_DAM_PART, 
        source_data.DAM_ENUM_DELIVER_PART_TO_BU AS DAM_ENUM_DELIVER_PART_TO_BU, 
        source_data.DOA_UNDER_WARRANTY AS DOA_UNDER_WARRANTY, 
        source_data.DOA_REPAIR_VEND_CREDIT_TYPE_ID AS DOA_REPAIR_VEND_CREDIT_TYPE_ID, 
        source_data.DOA_RETURN_PART_TO_VENDOR AS DOA_RETURN_PART_TO_VENDOR, 
        source_data.DOA_ADJUST_DOA_WHSE AS DOA_ADJUST_DOA_WHSE, 
        source_data.DOA_IS_PART_REPAIRABLE AS DOA_IS_PART_REPAIRABLE, 
        source_data.DOA_RETURN_VENDOR_SHIPSTAMP_ID AS DOA_RETURN_VENDOR_SHIPSTAMP_ID, 
        source_data.TO_INVENTORY_WHSE_SHIPSTAMP_ID AS TO_INVENTORY_WHSE_SHIPSTAMP_ID, 
        source_data.CUB_TYPE_ID AS CUB_TYPE_ID, 
        source_data.CUB_ORDER_NUM AS CUB_ORDER_NUM, 
        source_data.CUB_ORDER_LINE_NUM AS CUB_ORDER_LINE_NUM, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.ACTIVE AS ACTIVE, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(PROCESS_SALES_ID as NUMBER(38,0)) as PROCESS_SALES_ID,
        cast(RMA_ID as NUMBER(38,0)) as RMA_ID,
        cast(OVR_DISCREPANCY_AT_INV_WH as NUMBER(38,0)) as OVR_DISCREPANCY_AT_INV_WH,
        cast(OVR_MAN_PACK_SLIP_SHIPSTAMP_ID as NUMBER(38,0)) as OVR_MAN_PACK_SLIP_SHIPSTAMP_ID,
        cast(MIS_RELABELPART as NUMBER(38,0)) as MIS_RELABELPART,
        cast(MIS_IS_RMA_FOR_MTR as NUMBER(38,0)) as MIS_IS_RMA_FOR_MTR,
        cast(MIS_ORIGINAL_PART_FOUND_AT_WH as NUMBER(38,0)) as MIS_ORIGINAL_PART_FOUND_AT_WH,
        cast(MIS_BAAN_DISCREPANCY_CORRECTED as NUMBER(38,0)) as MIS_BAAN_DISCREPANCY_CORRECTED,
        cast(MIS_REPLACE_PART_SENT_CONSIGN as NUMBER(38,0)) as MIS_REPLACE_PART_SENT_CONSIGN,
        cast(MIS_SHIP_FOUNDPART as NUMBER(38,0)) as MIS_SHIP_FOUNDPART,
        cast(MIS_SHIP_FOUNDPART_SHIPSTAMP_ID as NUMBER(38,0)) as MIS_SHIP_FOUNDPART_SHIPSTAMP_ID,
        cast(DAM_DAM_BY_CUSTOMER as NUMBER(38,0)) as DAM_DAM_BY_CUSTOMER,
        cast(DAM_PART_IS_REPAIRABLE as NUMBER(38,0)) as DAM_PART_IS_REPAIRABLE,
        cast(DAM_CHARGE_BU_FOR_DAM_PART as NUMBER(38,0)) as DAM_CHARGE_BU_FOR_DAM_PART,
        cast(DAM_ENUM_DELIVER_PART_TO_BU as NUMBER(38,0)) as DAM_ENUM_DELIVER_PART_TO_BU,
        cast(DOA_UNDER_WARRANTY as NUMBER(38,0)) as DOA_UNDER_WARRANTY,
        cast(DOA_REPAIR_VEND_CREDIT_TYPE_ID as NUMBER(38,0)) as DOA_REPAIR_VEND_CREDIT_TYPE_ID,
        cast(DOA_RETURN_PART_TO_VENDOR as NUMBER(38,0)) as DOA_RETURN_PART_TO_VENDOR,
        cast(DOA_ADJUST_DOA_WHSE as NUMBER(38,0)) as DOA_ADJUST_DOA_WHSE,
        cast(DOA_IS_PART_REPAIRABLE as NUMBER(38,0)) as DOA_IS_PART_REPAIRABLE,
        cast(DOA_RETURN_VENDOR_SHIPSTAMP_ID as NUMBER(38,0)) as DOA_RETURN_VENDOR_SHIPSTAMP_ID,
        cast(TO_INVENTORY_WHSE_SHIPSTAMP_ID as NUMBER(38,0)) as TO_INVENTORY_WHSE_SHIPSTAMP_ID,
        cast(CUB_TYPE_ID as NUMBER(38,0)) as CUB_TYPE_ID,
        cast(CUB_ORDER_NUM as VARCHAR(16777216)) as CUB_ORDER_NUM,
        cast(CUB_ORDER_LINE_NUM as VARCHAR(16777216)) as CUB_ORDER_LINE_NUM,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data