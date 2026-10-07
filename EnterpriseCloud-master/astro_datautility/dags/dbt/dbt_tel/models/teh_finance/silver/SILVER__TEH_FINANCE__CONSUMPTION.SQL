/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-Carma\Consumption.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\carma\Consumption.SQL
-materialized incremental
-alias Consumption
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema CARMA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 1/25/2022 3:06:11 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='Consumption',
    unique_key = []
) }}

with source_data as
(
    SELECT cso.orig_ncdr_nbr AS ncdr,
         cso.orig_service_order_nbr AS service_order,
         cso_li.service_order_activity_nbr AS so_activity_line,
         cso_li.service_order_line_nbr AS so_line,
         cso_li.baan_inv_item_id AS part_number,
         cso_li.qty_ordered,
         cso_li.qty_remaining,
         cso_li.op_comments AS op_cmts,
         cso_li.serial_number,
         cso_li.serial_number_core AS core_serial_number,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.serial_number
           ELSE NULL
         END AS serial_number_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.serial_number_core
           ELSE NULL
         END AS serial_number_core_post_consumption,
         cso_li.created_dt,
         cso_li.created_user_id,
         CASE
           WHEN subquery.rma_id IS NOT NULL AND
             subquery.last_updated_dt > cso_li.last_updated_dt THEN subquery.last_updated_dt
           ELSE cso_li.last_updated_dt
         END AS last_updated_dt,
         CASE
           WHEN subquery.rma_id IS NOT NULL AND
             subquery.last_updated_dt > cso_li.last_updated_dt THEN subquery.last_updated_user_id
           ELSE cso_li.last_updated_user_id
         END AS last_updated_user_id,
         cso_li.process_status,
         cso_li.process_error,
         cso_li.process_error_message,
         cso_li.process_dt,
         cso_li.qty_consumed,
         cso_li.consumption_cmts,
         cso_li.planned_consumption_dt,
         CASE cso_li.is_fcn_order
           WHEN 1 THEN 'Yes'
           ELSE 'No'
         END AS fcn_warehouse_return,
         CASE cso_li.fcn_warehouse_return_id
           WHEN 0 THEN NULL
           ELSE cso_li.fcn_warehouse_return_id
         END AS fcn_warehouse_return2,
         CASE
           WHEN cso_li.rma_id <> 0 THEN CAST(cso_li.rma_id AS varchar(6))
           ELSE NULL
         END AS rma,
         cso_li.qty_returned,
         CASE cso_li.return_reason_type_id
           WHEN 0 THEN NULL
           ELSE rrt.name
         END AS return_reason,
         CASE cso_li.is_package_open
           WHEN 1 THEN 'Yes'
           WHEN 2 THEN 'No'
           ELSE NULL
         END AS is_package_open,
         CASE cso_li.is_exposed_to_copper
           WHEN 1 THEN 'Yes'
           WHEN 2 THEN 'No'
           ELSE NULL
         END AS is_exposed_to_copper,
         cso_li.return_cmts,
         cso_li.rma_gen_user_id,
         cso_li.rma_gen_dt,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN 'Yes'
           ELSE 'No'
         END AS part_returned_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN CAST(subquery.rma_id AS varchar(6))
           ELSE NULL
         END AS post_consumption_rma,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.qty_returned
           ELSE NULL
         END AS qty_returned_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.return_reason
           ELSE NULL
         END AS post_consumption_return_reason,
         CASE
           WHEN subquery.is_unused_part_return = 1 AND
             subquery.is_package_open = 1 THEN 'Yes'
           WHEN subquery.is_unused_part_return = 1 AND
             subquery.is_package_open = 2 THEN 'No'
           ELSE NULL
         END AS is_package_open_post_consumption,
         CASE
           WHEN subquery.is_unused_part_return = 1 AND
             subquery.is_exposed_to_copper = 1 THEN 'Yes'
           WHEN subquery.is_unused_part_return = 1 AND
             subquery.is_exposed_to_copper = 2 THEN 'No'
           ELSE NULL
         END AS is_exposed_to_copper_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.return_cmts
           ELSE NULL
         END AS post_consumption_return_cmts,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.rma_gen_user_id
           ELSE NULL
         END AS rma_gen_user_id_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 1 THEN subquery.rma_gen_dt
           ELSE NULL
         END AS rma_gen_dt_post_consumption,
         CASE
           WHEN cso_li.returning_a_core = 1 OR
             subquery.is_unused_part_return = 0 THEN 'Yes'
           ELSE 'No'
         END AS cores_returned,
         CASE
           WHEN cso_li.rma_id_core_return <> 0 THEN CAST(cso_li.rma_id_core_return AS varchar(6))
           ELSE NULL
         END AS core_rma,
         cso_li.qty_returned_cores,
         CASE cso_li.core_return_reason_type_id
           WHEN 0 THEN NULL
           ELSE crrt_unionall.name
         END AS core_return_reason,
         CASE cso_li.is_exposed_to_copper_core
           WHEN 1 THEN 'Yes'
           WHEN 2 THEN 'No'
           ELSE NULL
         END AS is_core_exposed_to_copper,
         cso_li.core_return_cmts,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN 'Yes'
           ELSE 'No'
         END AS core_returned_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN CAST(subquery.rma_id AS varchar(6))
           ELSE NULL
         END AS core_rma_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.qty_returned
           ELSE 0
         END AS qty_returned_cores_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.return_reason
           ELSE NULL
         END AS core_return_reason_post_consumption,
         CASE
           WHEN subquery.is_unused_part_return = 0 AND
             subquery.is_exposed_to_copper = 1 THEN 'Yes'
           WHEN subquery.is_unused_part_return = 0 AND
             subquery.is_exposed_to_copper = 2 THEN 'No'
           ELSE NULL
         END AS is_core_exposed_to_copper_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.return_cmts
           ELSE NULL
         END AS core_return_cmts_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.rma_gen_user_id
           ELSE NULL
         END AS core_rma_gen_user_id_post_consumption,
         CASE subquery.is_unused_part_return
           WHEN 0 THEN subquery.rma_gen_dt
           ELSE NULL
         END AS core_rma_gen_dt_post_consumption
        FROM {{ ref('BRONZE__TEH_FINANCE__CARMA_CSO') }} AS cso
        INNER JOIN {{ ref('BRONZE__TEH_FINANCE__CARMA_CSO_LINE_ITEM') }} AS cso_li
         ON cso.cso_id = cso_li.cso_id
        LEFT OUTER JOIN (SELECT
         pcpr.post_consume_part_return_id,
         pcpr.cso_line_item_id,
         pcpr.rma_id,
         pcpr.qty_returned,
         pcpr.is_unused_part_return,
         pcpr.is_package_open,
         pcpr.is_exposed_to_copper,
         pcpr.return_cmts,
         pcpr.decontamination_id,
         pcpr.is_rma_generated,
         pcpr.rma_gen_dt,
         pcpr.rma_gen_user_id,
         pcpr.created_dt,
         pcpr.created_user_id,
         pcpr.last_updated_dt,
         pcpr.last_updated_user_id,
         pcpr.serial_number,
         pcpr.serial_number_core,
         rrt.name AS return_reason
        FROM {{ ref('BRONZE__TEH_FINANCE__CARMA_POST_CONSUME_PART_RETURN') }} AS pcpr
        INNER JOIN {{ ref('BRONZE__TEH_FINANCE__CARMA_RETURN_REASON_TYPE') }} AS rrt
         ON pcpr.return_reason_type_id = rrt.return_reason_type_id
        WHERE (pcpr.active = 1)
        AND (pcpr.is_unused_part_return = 1)
        UNION ALL
        SELECT
         pcpr_unionall.post_consume_part_return_id,
         pcpr_unionall.cso_line_item_id,
         pcpr_unionall.rma_id,
         pcpr_unionall.qty_returned,
         pcpr_unionall.is_unused_part_return,
         pcpr_unionall.is_package_open,
         pcpr_unionall.is_exposed_to_copper,
         pcpr_unionall.return_cmts,
         pcpr_unionall.decontamination_id,
         pcpr_unionall.is_rma_generated,
         pcpr_unionall.rma_gen_dt,
         pcpr_unionall.rma_gen_user_id,
         pcpr_unionall.created_dt,
         pcpr_unionall.created_user_id,
         pcpr_unionall.last_updated_dt,
         pcpr_unionall.last_updated_user_id,
         pcpr_unionall.serial_number,
         pcpr_unionall.serial_number_core,
         crrt.name AS return_reason
        FROM {{ ref('BRONZE__TEH_FINANCE__CARMA_POST_CONSUME_PART_RETURN') }} AS pcpr_unionall
        INNER JOIN {{ ref('BRONZE__TEH_FINANCE__CARMA_CORE_RETURN_REASON_TYPE') }} AS crrt
         ON pcpr_unionall.return_reason_type_id = crrt.core_return_reason_type_id
        WHERE (pcpr_unionall.active = 1)
        AND (pcpr_unionall.is_unused_part_return = 0)) AS subquery
         ON cso_li.cso_line_item_id = subquery.cso_line_item_id
        LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__CARMA_RETURN_REASON_TYPE') }} AS rrt
         ON cso_li.return_reason_type_id = rrt.return_reason_type_id
        LEFT OUTER JOIN {{ ref('BRONZE__TEH_FINANCE__CARMA_CORE_RETURN_REASON_TYPE') }} AS crrt_unionall
         ON cso_li.core_return_reason_type_id = crrt_unionall.core_return_reason_type_id
        WHERE (cso.active = 1)
        AND (cso_li.active = 1)
        ORDER BY service_order, ncdr
        )
,transform_data as
(
    SELECT
        source_data.CONSUMPTION_CMTS,
        source_data.CORES_RETURNED,
        source_data.CORE_RETURNED_POST_CONSUMPTION,
        source_data.CORE_RETURN_CMTS,
        source_data.CORE_RETURN_CMTS_POST_CONSUMPTION,
        source_data.CORE_RETURN_REASON,
        source_data.CORE_RETURN_REASON_POST_CONSUMPTION,
        source_data.CORE_RMA,
        source_data.CORE_RMA_GEN_DT_POST_CONSUMPTION,
        source_data.CORE_RMA_GEN_USER_ID_POST_CONSUMPTION,
        source_data.CORE_RMA_POST_CONSUMPTION,
        source_data.CORE_SERIAL_NUMBER,
        source_data.CREATED_DT,
        source_data.CREATED_USER_ID,
        source_data.FCN_WAREHOUSE_RETURN,
        source_data.FCN_WAREHOUSE_RETURN2,
        source_data.IS_CORE_EXPOSED_TO_COPPER,
        source_data.IS_CORE_EXPOSED_TO_COPPER_POST_CONSUMPTION,
        source_data.IS_EXPOSED_TO_COPPER,
        source_data.IS_EXPOSED_TO_COPPER_POST_CONSUMPTION,
        source_data.IS_PACKAGE_OPEN,
        source_data.IS_PACKAGE_OPEN_POST_CONSUMPTION,
        source_data.LAST_UPDATED_DT,
        source_data.LAST_UPDATED_USER_ID,
        source_data.NCDR,
        source_data.OP_CMTS,
        source_data.PART_NUMBER,
        source_data.PART_RETURNED_POST_CONSUMPTION,
        source_data.PLANNED_CONSUMPTION_DT,
        source_data.POST_CONSUMPTION_RETURN_CMTS,
        source_data.POST_CONSUMPTION_RETURN_REASON,
        source_data.POST_CONSUMPTION_RMA,
        source_data.PROCESS_DT,
        source_data.PROCESS_ERROR,
        source_data.PROCESS_ERROR_MESSAGE,
        source_data.PROCESS_STATUS,
        source_data.QTY_CONSUMED,
        source_data.QTY_ORDERED,
        source_data.QTY_REMAINING,
        source_data.QTY_RETURNED,
        source_data.QTY_RETURNED_CORES,
        source_data.QTY_RETURNED_CORES_POST_CONSUMPTION,
        source_data.QTY_RETURNED_POST_CONSUMPTION,
        source_data.RETURN_CMTS,
        source_data.RETURN_REASON,
        source_data.RMA,
        source_data.RMA_GEN_DT,
        source_data.RMA_GEN_DT_POST_CONSUMPTION,
        source_data.RMA_GEN_USER_ID,
        source_data.RMA_GEN_USER_ID_POST_CONSUMPTION,
        source_data.SERIAL_NUMBER,
        source_data.SERIAL_NUMBER_CORE_POST_CONSUMPTION,
        source_data.SERIAL_NUMBER_POST_CONSUMPTION,
        source_data.SERVICE_ORDER,
        source_data.SO_ACTIVITY_LINE,
        source_data.SO_LINE, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh. 
        FROM source_data
        )
,type_data as 
(
    select
        cast(NCDR as VARCHAR(16777216)) as NCDR,
        cast(SERVICE_ORDER as VARCHAR(16777216)) as SERVICE_ORDER,
        cast(SO_ACTIVITY_LINE as VARCHAR(16777216)) as SO_ACTIVITY_LINE,
        cast(SO_LINE as VARCHAR(16777216)) as SO_LINE,
        cast(PART_NUMBER as VARCHAR(16777216)) as PART_NUMBER,
        cast(QTY_ORDERED as NUMBER(38,0)) as QTY_ORDERED,
        cast(QTY_REMAINING as NUMBER(38,0)) as QTY_REMAINING,
        cast(OP_CMTS as VARCHAR(16777216)) as OP_CMTS,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(CORE_SERIAL_NUMBER as VARCHAR(16777216)) as CORE_SERIAL_NUMBER,
        cast(SERIAL_NUMBER_POST_CONSUMPTION as VARCHAR(16777216)) as SERIAL_NUMBER_POST_CONSUMPTION,
        cast(SERIAL_NUMBER_CORE_POST_CONSUMPTION as VARCHAR(16777216)) as SERIAL_NUMBER_CORE_POST_CONSUMPTION,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(CREATED_USER_ID as VARCHAR(16777216)) as CREATED_USER_ID,
        cast(LAST_UPDATED_DT as TIMESTAMP_NTZ(9)) as LAST_UPDATED_DT,
        cast(LAST_UPDATED_USER_ID as VARCHAR(16777216)) as LAST_UPDATED_USER_ID,
        cast(PROCESS_STATUS as NUMBER(38,0)) as PROCESS_STATUS,
        cast(PROCESS_ERROR as NUMBER(38,0)) as PROCESS_ERROR,
        cast(PROCESS_ERROR_MESSAGE as VARCHAR(16777216)) as PROCESS_ERROR_MESSAGE,
        cast(PROCESS_DT as TIMESTAMP_NTZ(9)) as PROCESS_DT,
        cast(QTY_CONSUMED as NUMBER(38,0)) as QTY_CONSUMED,
        cast(CONSUMPTION_CMTS as VARCHAR(16777216)) as CONSUMPTION_CMTS,
        cast(PLANNED_CONSUMPTION_DT as TIMESTAMP_NTZ(9)) as PLANNED_CONSUMPTION_DT,
        cast(FCN_WAREHOUSE_RETURN as VARCHAR(16777216)) as FCN_WAREHOUSE_RETURN,
        cast(FCN_WAREHOUSE_RETURN2 as NUMBER(38,0)) as FCN_WAREHOUSE_RETURN2,
        cast(RMA as VARCHAR(16777216)) as RMA,
        cast(QTY_RETURNED as NUMBER(38,0)) as QTY_RETURNED,
        cast(RETURN_REASON as VARCHAR(16777216)) as RETURN_REASON,
        cast(IS_PACKAGE_OPEN as VARCHAR(16777216)) as IS_PACKAGE_OPEN,
        cast(IS_EXPOSED_TO_COPPER as VARCHAR(16777216)) as IS_EXPOSED_TO_COPPER,
        cast(RETURN_CMTS as VARCHAR(16777216)) as RETURN_CMTS,
        cast(RMA_GEN_USER_ID as VARCHAR(16777216)) as RMA_GEN_USER_ID,
        cast(RMA_GEN_DT as TIMESTAMP_NTZ(9)) as RMA_GEN_DT,
        cast(PART_RETURNED_POST_CONSUMPTION as VARCHAR(16777216)) as PART_RETURNED_POST_CONSUMPTION,
        cast(POST_CONSUMPTION_RMA as VARCHAR(16777216)) as POST_CONSUMPTION_RMA,
        cast(QTY_RETURNED_POST_CONSUMPTION as NUMBER(38,0)) as QTY_RETURNED_POST_CONSUMPTION,
        cast(POST_CONSUMPTION_RETURN_REASON as VARCHAR(16777216)) as POST_CONSUMPTION_RETURN_REASON,
        cast(IS_PACKAGE_OPEN_POST_CONSUMPTION as VARCHAR(16777216)) as IS_PACKAGE_OPEN_POST_CONSUMPTION,
        cast(IS_EXPOSED_TO_COPPER_POST_CONSUMPTION as VARCHAR(16777216)) as IS_EXPOSED_TO_COPPER_POST_CONSUMPTION,
        cast(POST_CONSUMPTION_RETURN_CMTS as VARCHAR(16777216)) as POST_CONSUMPTION_RETURN_CMTS,
        cast(RMA_GEN_USER_ID_POST_CONSUMPTION as VARCHAR(16777216)) as RMA_GEN_USER_ID_POST_CONSUMPTION,
        cast(RMA_GEN_DT_POST_CONSUMPTION as TIMESTAMP_NTZ(9)) as RMA_GEN_DT_POST_CONSUMPTION,
        cast(CORES_RETURNED as VARCHAR(16777216)) as CORES_RETURNED,
        cast(CORE_RMA as VARCHAR(16777216)) as CORE_RMA,
        cast(QTY_RETURNED_CORES as NUMBER(38,0)) as QTY_RETURNED_CORES,
        cast(CORE_RETURN_REASON as VARCHAR(16777216)) as CORE_RETURN_REASON,
        cast(IS_CORE_EXPOSED_TO_COPPER as VARCHAR(16777216)) as IS_CORE_EXPOSED_TO_COPPER,
        cast(CORE_RETURN_CMTS as VARCHAR(16777216)) as CORE_RETURN_CMTS,
        cast(CORE_RETURNED_POST_CONSUMPTION as VARCHAR(16777216)) as CORE_RETURNED_POST_CONSUMPTION,
        cast(CORE_RMA_POST_CONSUMPTION as VARCHAR(16777216)) as CORE_RMA_POST_CONSUMPTION,
        cast(QTY_RETURNED_CORES_POST_CONSUMPTION as NUMBER(38,0)) as QTY_RETURNED_CORES_POST_CONSUMPTION,
        cast(CORE_RETURN_REASON_POST_CONSUMPTION as VARCHAR(16777216)) as CORE_RETURN_REASON_POST_CONSUMPTION,
        cast(IS_CORE_EXPOSED_TO_COPPER_POST_CONSUMPTION as VARCHAR(16777216)) as IS_CORE_EXPOSED_TO_COPPER_POST_CONSUMPTION,
        cast(CORE_RETURN_CMTS_POST_CONSUMPTION as VARCHAR(16777216)) as CORE_RETURN_CMTS_POST_CONSUMPTION,
        cast(CORE_RMA_GEN_USER_ID_POST_CONSUMPTION as VARCHAR(16777216)) as CORE_RMA_GEN_USER_ID_POST_CONSUMPTION,
        cast(CORE_RMA_GEN_DT_POST_CONSUMPTION as TIMESTAMP_NTZ(9)) as CORE_RMA_GEN_DT_POST_CONSUMPTION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data

