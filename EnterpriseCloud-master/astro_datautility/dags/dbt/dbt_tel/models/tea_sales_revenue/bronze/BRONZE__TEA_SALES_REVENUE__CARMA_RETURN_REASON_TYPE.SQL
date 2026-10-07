/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\RETURNREASONTYPE__CARMA_RETURNREASONTYPE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\RETURN_REASON_TYPE.SQL 
-materialized incremental
-alias RETURN_REASON_TYPE 
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
    alias='CARMA_RETURN_REASON_TYPE',
    unique_key = ['RETURN_REASON_TYPE_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"return_reason_type_id"::NUMBER AS return_reason_type_id, 
         JSONFIELD:"name"::STRING  AS name, 
         JSONFIELD:"description"::STRING  AS description, 
         JSONFIELD:"sort_order"::NUMBER AS sort_order, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "RETURN_REASON_TYPE") }}  as s 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "RETURN_REASON_TYPE") }} as c 
                                                where s.JSONFIELD:"return_reason_type_id"::NUMBER = c.JSONFIELD:"return_reason_type_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.RETURN_REASON_TYPE_ID AS RETURN_REASON_TYPE_ID, 
        source_data.NAME AS NAME, 
        source_data.DESCRIPTION AS DESCRIPTION, 
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
        cast(RETURN_REASON_TYPE_ID as NUMBER(38,0)) as RETURN_REASON_TYPE_ID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SORT_ORDER as NUMBER(38,0)) as SORT_ORDER,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data