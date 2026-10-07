/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\PARTSCRAPDISPTYPE__CARMA_PARTSCRAPDISPTYPE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\PART_SCRAP_DISP_TYPE.SQL 
-materialized incremental
-alias PART_SCRAP_DISP_TYPE 
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
    alias='CARMA_PART_SCRAP_DISP_TYPE',
    unique_key = ['PART_SCRAP_DISP_TYPE_ID']
) }}


with source_data as 
(
    SELECT 
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"part_scrap_disp_type_id"::NUMBER AS part_scrap_disp_type_id, 
         JSONFIELD:"name"::STRING  AS name, 
         JSONFIELD:"description"::STRING  AS description, 
         JSONFIELD:"sort_order"::NUMBER AS sort_order, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "PART_SCRAP_DISP_TYPE") }} as s   
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source("CARMA", "PART_SCRAP_DISP_TYPE") }} as c
                                                where s.JSONFIELD:"part_scrap_disp_type_id"::NUMBER = c.JSONFIELD:"part_scrap_disp_type_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.PART_SCRAP_DISP_TYPE_ID AS PART_SCRAP_DISP_TYPE_ID, 
        source_data.NAME AS NAME, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.SORT_ORDER AS SORT_ORDER, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
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
        cast(PART_SCRAP_DISP_TYPE_ID as NUMBER(38,0)) as PART_SCRAP_DISP_TYPE_ID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SORT_ORDER as NUMBER(38,0)) as SORT_ORDER,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE
    from transform_data
    )
select * from type_data