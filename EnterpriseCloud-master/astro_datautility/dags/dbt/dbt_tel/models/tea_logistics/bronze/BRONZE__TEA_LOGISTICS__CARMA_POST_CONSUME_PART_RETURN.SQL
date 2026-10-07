/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\POSTCONSUMEPARTRETURN__CARMA_POSTCONSUMEPARTRETURN.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\POST_CONSUME_PART_RETURN.SQL 
-materialized incremental
-alias POST_CONSUME_PART_RETURN 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/10/2022 2:23:24 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='CARMA_POST_CONSUME_PART_RETURN',
    unique_key = ['POST_CONSUME_PART_RETURN_ID']
) }}


with source_data as 
(
    SELECT 
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"post_consume_part_return_id"::NUMBER AS post_consume_part_return_id, 
         JSONFIELD:"cso_line_item_id"::NUMBER AS cso_line_item_id, 
         JSONFIELD:"rma_id"::NUMBER AS rma_id, 
         JSONFIELD:"qty_returned"::NUMBER AS qty_returned, 
         JSONFIELD:"is_unused_part_return"::NUMBER AS is_unused_part_return, 
         JSONFIELD:"return_cmts"::STRING  AS return_cmts, 
         JSONFIELD:"is_package_open"::NUMBER AS is_package_open, 
         JSONFIELD:"is_exposed_to_copper"::NUMBER AS is_exposed_to_copper, 
         JSONFIELD:"return_reason_type_id"::NUMBER AS return_reason_type_id, 
         JSONFIELD:"decontamination_id"::NUMBER AS decontamination_id, 
         JSONFIELD:"is_rma_generated"::NUMBER AS is_rma_generated, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"rma_gen_dt" ,'/Date()/')) AS rma_gen_dt, 
         JSONFIELD:"rma_gen_user_id"::STRING  AS rma_gen_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"created_user_id"::STRING  AS created_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"last_updated_dt" ,'/Date()/')) AS last_updated_dt, 
         JSONFIELD:"last_updated_user_id"::STRING  AS last_updated_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
         JSONFIELD:"inactive_user_id"::STRING  AS inactive_user_id, 
         JSONFIELD:"active"::NUMBER AS active, 
         JSONFIELD:"serial_number"::STRING  AS serial_number, 
         JSONFIELD:"serial_number_core"::STRING  AS serial_number_core, 
         JSONFIELD:"QVICS_RTISS_TKMS_NUM"::STRING  AS QVICS_RTISS_TKMS_NUM  
        FROM {{ source("CARMA", "POST_CONSUME_PART_RETURN") }} as s  
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source("CARMA", "POST_CONSUME_PART_RETURN") }} as c 
                                                where s.JSONFIELD:"post_consume_part_return_id"::NUMBER = c.JSONFIELD:"post_consume_part_return_id"::NUMBER ) 
        )
,transform_data as
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.POST_CONSUME_PART_RETURN_ID AS POST_CONSUME_PART_RETURN_ID, 
        source_data.CSO_LINE_ITEM_ID AS CSO_LINE_ITEM_ID, 
        source_data.RMA_ID AS RMA_ID, 
        source_data.QTY_RETURNED AS QTY_RETURNED, 
        source_data.IS_UNUSED_PART_RETURN AS IS_UNUSED_PART_RETURN, 
        source_data.RETURN_CMTS AS RETURN_CMTS, 
        source_data.IS_PACKAGE_OPEN AS IS_PACKAGE_OPEN, 
        source_data.IS_EXPOSED_TO_COPPER AS IS_EXPOSED_TO_COPPER, 
        source_data.RETURN_REASON_TYPE_ID AS RETURN_REASON_TYPE_ID, 
        source_data.DECONTAMINATION_ID AS DECONTAMINATION_ID, 
        source_data.IS_RMA_GENERATED AS IS_RMA_GENERATED, 
        source_data.RMA_GEN_DT AS RMA_GEN_DT, 
        source_data.RMA_GEN_USER_ID AS RMA_GEN_USER_ID, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.CREATED_USER_ID AS CREATED_USER_ID, 
        source_data.LAST_UPDATED_DT AS LAST_UPDATED_DT, 
        source_data.LAST_UPDATED_USER_ID AS LAST_UPDATED_USER_ID, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.INACTIVE_USER_ID AS INACTIVE_USER_ID, 
        source_data.ACTIVE AS ACTIVE, 
        source_data.SERIAL_NUMBER AS SERIAL_NUMBER, 
        source_data.SERIAL_NUMBER_CORE AS SERIAL_NUMBER_CORE, 
        source_data.QVICS_RTISS_TKMS_NUM AS QVICS_RTISS_TKMS_NUM
        FROM source_data
        )
,type_data as 
(
    select
        CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(POST_CONSUME_PART_RETURN_ID as NUMBER(38,0)) as POST_CONSUME_PART_RETURN_ID,
        cast(CSO_LINE_ITEM_ID as NUMBER(38,0)) as CSO_LINE_ITEM_ID,
        cast(RMA_ID as NUMBER(38,0)) as RMA_ID,
        cast(QTY_RETURNED as NUMBER(38,0)) as QTY_RETURNED,
        cast(IS_UNUSED_PART_RETURN as NUMBER(38,0)) as IS_UNUSED_PART_RETURN,
        cast(RETURN_CMTS as VARCHAR(16777216)) as RETURN_CMTS,
        cast(IS_PACKAGE_OPEN as NUMBER(38,0)) as IS_PACKAGE_OPEN,
        cast(IS_EXPOSED_TO_COPPER as NUMBER(38,0)) as IS_EXPOSED_TO_COPPER,
        cast(RETURN_REASON_TYPE_ID as NUMBER(38,0)) as RETURN_REASON_TYPE_ID,
        cast(DECONTAMINATION_ID as NUMBER(38,0)) as DECONTAMINATION_ID,
        cast(IS_RMA_GENERATED as NUMBER(38,0)) as IS_RMA_GENERATED,
        cast(RMA_GEN_DT as TIMESTAMP_NTZ(9)) as RMA_GEN_DT,
        cast(RMA_GEN_USER_ID as VARCHAR(16777216)) as RMA_GEN_USER_ID,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(CREATED_USER_ID as VARCHAR(16777216)) as CREATED_USER_ID,
        cast(LAST_UPDATED_DT as TIMESTAMP_NTZ(9)) as LAST_UPDATED_DT,
        cast(LAST_UPDATED_USER_ID as VARCHAR(16777216)) as LAST_UPDATED_USER_ID,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(INACTIVE_USER_ID as VARCHAR(16777216)) as INACTIVE_USER_ID,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(SERIAL_NUMBER as VARCHAR(16777216)) as SERIAL_NUMBER,
        cast(SERIAL_NUMBER_CORE as VARCHAR(16777216)) as SERIAL_NUMBER_CORE,
        cast(QVICS_RTISS_TKMS_NUM as VARCHAR(16777216)) as QVICS_RTISS_TKMS_NUM
    from transform_data
    )
select * from type_data