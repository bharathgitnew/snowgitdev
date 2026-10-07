/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\DISPOSITIONTYPE__CARMA_DISPOSITIONTYPE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\DISPOSITION_TYPE.SQL 
-materialized incremental
-alias DISPOSITION_TYPE 
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
    alias='DISPOSITION_TYPE',
    unique_key = ['DISP_TYPE_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"disp_type_id"::NUMBER AS disp_type_id, 
         JSONFIELD:"acronym"::STRING  AS acronym, 
         JSONFIELD:"name"::STRING  AS name, 
         JSONFIELD:"description"::STRING  AS description, 
         JSONFIELD:"is_preliminary_disposition"::NUMBER AS is_preliminary_disposition, 
         JSONFIELD:"is_final_disposition"::NUMBER AS is_final_disposition, 
         JSONFIELD:"sort_order"::NUMBER AS sort_order, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "DISPOSITION_TYPE") }}   as s
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "DISPOSITION_TYPE") }} as c
                                                where s.JSONFIELD:"disp_type_id"::NUMBER = c.JSONFIELD:"disp_type_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.DISP_TYPE_ID AS DISP_TYPE_ID, 
        source_data.ACRONYM AS ACRONYM, 
        source_data.NAME AS NAME, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.IS_PRELIMINARY_DISPOSITION AS IS_PRELIMINARY_DISPOSITION, 
        source_data.IS_FINAL_DISPOSITION AS IS_FINAL_DISPOSITION, 
        source_data.SORT_ORDER AS SORT_ORDER, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.ACTIVE AS ACTIVE, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(DISP_TYPE_ID as NUMBER(38,0)) as DISP_TYPE_ID,
        cast(ACRONYM as VARCHAR(16777216)) as ACRONYM,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(IS_PRELIMINARY_DISPOSITION as NUMBER(38,0)) as IS_PRELIMINARY_DISPOSITION,
        cast(IS_FINAL_DISPOSITION as NUMBER(38,0)) as IS_FINAL_DISPOSITION,
        cast(SORT_ORDER as NUMBER(38,0)) as SORT_ORDER,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data