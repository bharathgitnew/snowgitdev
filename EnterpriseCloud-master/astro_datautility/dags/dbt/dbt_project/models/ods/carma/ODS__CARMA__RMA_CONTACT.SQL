/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\RMACONTACT__CARMA_RMACONTACT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\RMA_CONTACT.SQL 
-materialized incremental
-alias RMA_CONTACT 
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
    alias='RMA_CONTACT',
    unique_key = ['RMA_CONTACT_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"rma_contact_id"::NUMBER AS rma_contact_id, 
         JSONFIELD:"request_sales_id"::NUMBER AS request_sales_id, 
         JSONFIELD:"rma_contact_type_id"::NUMBER AS rma_contact_type_id, 
         JSONFIELD:"employee_id"::STRING  AS employee_id, 
         JSONFIELD:"first_name"::STRING  AS first_name, 
         JSONFIELD:"last_name"::STRING  AS last_name, 
         JSONFIELD:"phone"::STRING  AS phone, 
         JSONFIELD:"email"::STRING  AS email, 
         JSONFIELD:"comments"::STRING  AS comments, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "RMA_CONTACT") }}   as s
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "RMA_CONTACT") }} as c 
                                                where s.JSONFIELD:"rma_contact_id"::NUMBER = c.JSONFIELD:"rma_contact_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.RMA_CONTACT_ID AS RMA_CONTACT_ID, 
        source_data.REQUEST_SALES_ID AS REQUEST_SALES_ID, 
        source_data.RMA_CONTACT_TYPE_ID AS RMA_CONTACT_TYPE_ID, 
        source_data.EMPLOYEE_ID AS EMPLOYEE_ID, 
        source_data.FIRST_NAME AS FIRST_NAME, 
        source_data.LAST_NAME AS LAST_NAME, 
        source_data.PHONE AS PHONE, 
        source_data.EMAIL AS EMAIL, 
        source_data.COMMENTS AS COMMENTS, 
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
        cast(RMA_CONTACT_ID as NUMBER(38,0)) as RMA_CONTACT_ID,
        cast(REQUEST_SALES_ID as NUMBER(38,0)) as REQUEST_SALES_ID,
        cast(RMA_CONTACT_TYPE_ID as NUMBER(38,0)) as RMA_CONTACT_TYPE_ID,
        cast(EMPLOYEE_ID as VARCHAR(16777216)) as EMPLOYEE_ID,
        cast(FIRST_NAME as VARCHAR(16777216)) as FIRST_NAME,
        cast(LAST_NAME as VARCHAR(16777216)) as LAST_NAME,
        cast(PHONE as VARCHAR(16777216)) as PHONE,
        cast(EMAIL as VARCHAR(16777216)) as EMAIL,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data