/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\CSO__CARMA_CSO.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\CSO.SQL 
-materialized incremental
-alias CSO 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/10/2022 2:23:23 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='CSO',
    unique_key = ['CSO_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"cso_id"::NUMBER AS cso_id, 
         JSONFIELD:"orig_service_order_nbr"::STRING  AS orig_service_order_nbr, 
         JSONFIELD:"orig_ncdr_nbr"::STRING  AS orig_ncdr_nbr, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"final_allowed_consumption_dt" ,'/Date()/')) AS final_allowed_consumption_dt, 
         JSONFIELD:"all_cso_lines_complete"::NUMBER AS all_cso_lines_complete, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"completed_in_baan_dt" ,'/Date()/')) AS completed_in_baan_dt, 
         JSONFIELD:"completed_in_baan_user_id"::STRING  AS completed_in_baan_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"assist_request_dt" ,'/Date()/')) AS assist_request_dt, 
         JSONFIELD:"assist_request_by_user_id"::STRING  AS assist_request_by_user_id, 
         JSONFIELD:"assist_request_cmts"::STRING  AS assist_request_cmts, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"created_user_id"::STRING  AS created_user_id, 
         JSONFIELD:"created_role_id"::STRING  AS created_role_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"first_rma_gen_dt" ,'/Date()/')) AS first_rma_gen_dt, 
         JSONFIELD:"first_rma_gen_user_id"::STRING  AS first_rma_gen_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"last_updated_dt" ,'/Date()/')) AS last_updated_dt, 
         JSONFIELD:"last_updated_user_id"::STRING  AS last_updated_user_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
         JSONFIELD:"inactive_user_id"::STRING  AS inactive_user_id, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "CSO") }} as s  
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "CSO") }} as c 
                                                where s.JSONFIELD:"cso_id"::NUMBER = c.JSONFIELD:"cso_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.CSO_ID AS CSO_ID, 
        source_data.ORIG_SERVICE_ORDER_NBR AS ORIG_SERVICE_ORDER_NBR, 
        source_data.ORIG_NCDR_NBR AS ORIG_NCDR_NBR, 
        source_data.FINAL_ALLOWED_CONSUMPTION_DT AS FINAL_ALLOWED_CONSUMPTION_DT, 
        source_data.ALL_CSO_LINES_COMPLETE AS ALL_CSO_LINES_COMPLETE, 
        source_data.COMPLETED_IN_BAAN_DT AS COMPLETED_IN_BAAN_DT, 
        source_data.COMPLETED_IN_BAAN_USER_ID AS COMPLETED_IN_BAAN_USER_ID, 
        source_data.ASSIST_REQUEST_DT AS ASSIST_REQUEST_DT, 
        source_data.ASSIST_REQUEST_BY_USER_ID AS ASSIST_REQUEST_BY_USER_ID, 
        source_data.ASSIST_REQUEST_CMTS AS ASSIST_REQUEST_CMTS, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.CREATED_USER_ID AS CREATED_USER_ID, 
        source_data.CREATED_ROLE_ID AS CREATED_ROLE_ID, 
        source_data.FIRST_RMA_GEN_DT AS FIRST_RMA_GEN_DT, 
        source_data.FIRST_RMA_GEN_USER_ID AS FIRST_RMA_GEN_USER_ID, 
        source_data.LAST_UPDATED_DT AS LAST_UPDATED_DT, 
        source_data.LAST_UPDATED_USER_ID AS LAST_UPDATED_USER_ID, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.INACTIVE_USER_ID AS INACTIVE_USER_ID, 
        source_data.ACTIVE AS ACTIVE, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(CSO_ID as NUMBER(38,0)) as CSO_ID,
        cast(ORIG_SERVICE_ORDER_NBR as VARCHAR(16777216)) as ORIG_SERVICE_ORDER_NBR,
        cast(ORIG_NCDR_NBR as VARCHAR(16777216)) as ORIG_NCDR_NBR,
        cast(FINAL_ALLOWED_CONSUMPTION_DT as TIMESTAMP_NTZ(9)) as FINAL_ALLOWED_CONSUMPTION_DT,
        cast(ALL_CSO_LINES_COMPLETE as NUMBER(38,0)) as ALL_CSO_LINES_COMPLETE,
        cast(COMPLETED_IN_BAAN_DT as TIMESTAMP_NTZ(9)) as COMPLETED_IN_BAAN_DT,
        cast(COMPLETED_IN_BAAN_USER_ID as VARCHAR(16777216)) as COMPLETED_IN_BAAN_USER_ID,
        cast(ASSIST_REQUEST_DT as TIMESTAMP_NTZ(9)) as ASSIST_REQUEST_DT,
        cast(ASSIST_REQUEST_BY_USER_ID as VARCHAR(16777216)) as ASSIST_REQUEST_BY_USER_ID,
        cast(ASSIST_REQUEST_CMTS as VARCHAR(16777216)) as ASSIST_REQUEST_CMTS,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(CREATED_USER_ID as VARCHAR(16777216)) as CREATED_USER_ID,
        cast(CREATED_ROLE_ID as VARCHAR(16777216)) as CREATED_ROLE_ID,
        cast(FIRST_RMA_GEN_DT as TIMESTAMP_NTZ(9)) as FIRST_RMA_GEN_DT,
        cast(FIRST_RMA_GEN_USER_ID as VARCHAR(16777216)) as FIRST_RMA_GEN_USER_ID,
        cast(LAST_UPDATED_DT as TIMESTAMP_NTZ(9)) as LAST_UPDATED_DT,
        cast(LAST_UPDATED_USER_ID as VARCHAR(16777216)) as LAST_UPDATED_USER_ID,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(INACTIVE_USER_ID as VARCHAR(16777216)) as INACTIVE_USER_ID,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data