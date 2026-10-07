/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\REQUESTSERVICE__CARMA_REQUESTSERVICE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\REQUEST_SERVICE.SQL 
-materialized incremental
-alias REQUEST_SERVICE 
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
    alias='CARMA_REQUEST_SERVICE',
    unique_key = ['REQ_SERVICE_ID']
) }}


with source_data as 
(
    SELECT 
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"req_service_id"::NUMBER AS req_service_id, 
         JSONFIELD:"rma_id"::NUMBER AS rma_id, 
         JSONFIELD:"receiving_expired"::NUMBER AS receiving_expired, 
         JSONFIELD:"baan_fab_id"::STRING  AS baan_fab_id, 
         JSONFIELD:"cust_descr"::STRING  AS cust_descr, 
         JSONFIELD:"scrap_keep_or_reclean_part"::NUMBER AS scrap_keep_or_reclean_part, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"part_recleaned_dt" ,'/Date()/')) AS part_recleaned_dt, 
         JSONFIELD:"part_recleaned_user_id"::STRING  AS part_recleaned_user_id, 
         JSONFIELD:"from_consignment_program"::NUMBER AS from_consignment_program, 
         JSONFIELD:"part_needed_by_tea"::NUMBER AS part_needed_by_tea, 
         JSONFIELD:"in_transit_shipstamp_id"::NUMBER AS in_transit_shipstamp_id, 
         JSONFIELD:"credit_consignment_whse_id"::NUMBER AS credit_consignment_whse_id, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "REQUEST_SERVICE") }}   as s
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source("CARMA", "REQUEST_SERVICE") }} as c 
                                                where s.JSONFIELD:"req_service_id"::NUMBER = c.JSONFIELD:"req_service_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.REQ_SERVICE_ID AS REQ_SERVICE_ID, 
        source_data.RMA_ID AS RMA_ID, 
        source_data.RECEIVING_EXPIRED AS RECEIVING_EXPIRED, 
        source_data.BAAN_FAB_ID AS BAAN_FAB_ID, 
        source_data.CUST_DESCR AS CUST_DESCR, 
        source_data.SCRAP_KEEP_OR_RECLEAN_PART AS SCRAP_KEEP_OR_RECLEAN_PART, 
        source_data.PART_RECLEANED_DT AS PART_RECLEANED_DT, 
        source_data.PART_RECLEANED_USER_ID AS PART_RECLEANED_USER_ID, 
        source_data.FROM_CONSIGNMENT_PROGRAM AS FROM_CONSIGNMENT_PROGRAM, 
        source_data.PART_NEEDED_BY_TEA AS PART_NEEDED_BY_TEA, 
        source_data.IN_TRANSIT_SHIPSTAMP_ID AS IN_TRANSIT_SHIPSTAMP_ID, 
        source_data.CREDIT_CONSIGNMENT_WHSE_ID AS CREDIT_CONSIGNMENT_WHSE_ID, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.ACTIVE AS ACTIVE
        FROM source_data
        )
,type_data as 
(
    select
        CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(REQ_SERVICE_ID as NUMBER(38,0)) as REQ_SERVICE_ID,
        cast(RMA_ID as NUMBER(38,0)) as RMA_ID,
        cast(RECEIVING_EXPIRED as NUMBER(38,0)) as RECEIVING_EXPIRED,
        cast(BAAN_FAB_ID as VARCHAR(16777216)) as BAAN_FAB_ID,
        cast(CUST_DESCR as VARCHAR(16777216)) as CUST_DESCR,
        cast(SCRAP_KEEP_OR_RECLEAN_PART as NUMBER(38,0)) as SCRAP_KEEP_OR_RECLEAN_PART,
        cast(PART_RECLEANED_DT as TIMESTAMP_NTZ(9)) as PART_RECLEANED_DT,
        cast(PART_RECLEANED_USER_ID as VARCHAR(16777216)) as PART_RECLEANED_USER_ID,
        cast(FROM_CONSIGNMENT_PROGRAM as NUMBER(38,0)) as FROM_CONSIGNMENT_PROGRAM,
        cast(PART_NEEDED_BY_TEA as NUMBER(38,0)) as PART_NEEDED_BY_TEA,
        cast(IN_TRANSIT_SHIPSTAMP_ID as NUMBER(38,0)) as IN_TRANSIT_SHIPSTAMP_ID,
        cast(CREDIT_CONSIGNMENT_WHSE_ID as NUMBER(38,0)) as CREDIT_CONSIGNMENT_WHSE_ID,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE
    from transform_data
    )
select * from type_data