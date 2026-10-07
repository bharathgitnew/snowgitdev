{{ config(
        alias='SAPAPI_MATERIAL_MASTER_3PL',
        materialized='tel_incremental',
        incremental_strategy = 'merge',
        unique_key = ['MATERIAL_NUMBER'],
        transient = false
) }}

with material_data as (
    SELECT       
        _FILENAME AS MARA_FILENAME,
        _FILEDATE AS MARA_FILEDATE,
        get_ignore_case(to_object(JSONFIELD),'MATNR')::STRING AS MARA_MATERIAL_NUMBER,
        get_ignore_case(to_object(JSONFIELD),'MAKTX')::STRING AS MARA_MATERIAL_DESCRIPTION,
        get_ignore_case(to_object(JSONFIELD),'MEINS')::STRING AS MARA_UOM,
        TRY_TO_DATE((TRY_TO_DATE((get_ignore_case(to_object(JSONFIELD),'UPDATE_DATE')::STRING),'YYYYMMDD'))) AS MARA_UPDATE_DATE
    FROM 
        {{ source('SAPAPI', 'ZCDV_T_CMTU017_MARA') }}
    {% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(MARA_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'MATNR')::STRING,
                                get_ignore_case(to_object(JSONFIELD),'MAKTX')::STRING
                                ,get_ignore_case(to_object(JSONFIELD),'MEINS')::STRING
                                ORDER BY get_ignore_case(to_object(JSONFIELD),'UPDATE_DATE')::STRING  ASC )) = 1
)
,cost_data AS
( 
    SELECT   
        _FILENAME AS COST_FILENAME,
        _FILEDATE AS COST_FILEDATE, 
        JSONFIELD:MATNR::STRING AS COST_MATERIAL_NUMBER, 
 	 	JSONFIELD:BWKEY::STRING AS STANDARD_PRICE,    
        to_date(_FILEDATE)  AS COST_UPDATE_DATE
    FROM 
        {{ source('SAPH', 'SAP_US_MMT_EV_MBEW') }}
    {% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(COST_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:MATNR::STRING
                                ,JSONFIELD:BWKEY::STRING
                                ORDER BY _FILEDATE  ASC )) = 1)
,gtm_data AS
( 
    SELECT 
        _FILENAME AS GTM_FILENAME,
        _FILEDATE AS GTM_FILEDATE,       
        get_ignore_case(to_object(JSONFIELD),'PRODUCTNUM')::STRING  AS GTM_MATERIAL_NUMBER,
        get_ignore_case(to_object(JSONFIELD),'UNNUM1')::STRING  AS UNNUM1,
        get_ignore_case(to_object(JSONFIELD),'UploadDate')::STRING as GTM_UPDATE_DATE
    FROM 
        {{ source('SAPH', 'PARTS_EXPORTIMPORT_CONTROL') }}
    {% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(GTM_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'PRODUCTNUM')::STRING
                                ,get_ignore_case(to_object(JSONFIELD),'UNNUM1')::STRING
                                ORDER BY get_ignore_case(to_object(JSONFIELD),'UploadDate')::STRING  ASC )) = 1),
final_data as (
    SELECT
        MARA_FILENAME,
        COST_FILENAME,
        GTM_FILENAME,
        MARA_FILEDATE,
        COST_FILEDATE,
        GTM_FILEDATE,
        MARA_MATERIAL_NUMBER,
        MARA_MATERIAL_DESCRIPTION,
        MARA_UOM,
        MARA_UPDATE_DATE,
        COST_MATERIAL_NUMBER,
        STANDARD_PRICE,
        COST_UPDATE_DATE,
        GTM_MATERIAL_NUMBER,
        UNNUM1,
        GTM_UPDATE_DATE,
        GREATEST(COALESCE(MARA_UPDATE_DATE,'1900-01-01'),COALESCE(COST_UPDATE_DATE,'1900-01-01'),COALESCE(GTM_UPDATE_DATE,'1900-01-01')) AS FINAL_UPDATE_DATE,
        CASE WHEN MARA_MATERIAL_NUMBER is not null then MARA_MATERIAL_NUMBER
             WHEN MARA_MATERIAL_NUMBER is null and COST_MATERIAL_NUMBER is not null then COST_MATERIAL_NUMBER
             WHEN MARA_MATERIAL_NUMBER is null and GTM_MATERIAL_NUMBER is not null then GTM_MATERIAL_NUMBER
        END MATERIAL_NUMBER,
        CURRENT_DATE() AS SNAPSHOT_DATE
    FROM material_data
        FULL OUTER JOIN cost_data
            ON MARA_MATERIAL_NUMBER=COST_MATERIAL_NUMBER
        FULL OUTER JOIN gtm_data
            ON MARA_MATERIAL_NUMBER=GTM_MATERIAL_NUMBER
    WHERE MARA_MATERIAL_NUMBER IS NOT NULL 
            OR COST_MATERIAL_NUMBER IS NOT NULL
            OR GTM_MATERIAL_NUMBER IS NOT NULL
),
transform_data as (
    SELECT
        MARA_FILENAME,
        COST_FILENAME,
        GTM_FILENAME,
        MARA_FILEDATE,
        COST_FILEDATE,
        GTM_FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        MARA_MATERIAL_NUMBER,
        MARA_MATERIAL_DESCRIPTION,
        MARA_UOM,
        MARA_UPDATE_DATE,
        COST_MATERIAL_NUMBER,
        STANDARD_PRICE,
        COST_UPDATE_DATE,
        GTM_MATERIAL_NUMBER,
        UNNUM1,
        GTM_UPDATE_DATE,
        FINAL_UPDATE_DATE AS FINAL_UPDATE_DATE ,
        MATERIAL_NUMBER,
        SNAPSHOT_DATE
    FROM final_data
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY MARA_MATERIAL_NUMBER ORDER BY FINAL_UPDATE_DATE  DESC) = 1)
),
type_data as (
select
	CAST(MARA_FILENAME as varchar(128)) as MARA_FILENAME,
	CAST(COST_FILENAME as varchar(128)) as COST_FILENAME,
	CAST(GTM_FILENAME as varchar(128)) as GTM_FILENAME,
    CAST(MARA_FILEDATE AS VARCHAR(16777216)) AS MARA_FILEDATE,
    CAST(COST_FILEDATE AS VARCHAR(16777216)) AS COST_FILEDATE,
    CAST(GTM_FILEDATE AS VARCHAR(16777216)) AS GTM_FILEDATE,
    _AUDIT_LOG_ID,
    _ROW_HASH,
    MATERIAL_NUMBER,
    MARA_MATERIAL_DESCRIPTION,
    MARA_UOM,
    STANDARD_PRICE,
    UNNUM1,
    CAST(FINAL_UPDATE_DATE AS VARCHAR(16777216)) AS FINAL_UPDATE_DATE,
    CAST(SNAPSHOT_DATE AS DATE) AS SNAPSHOT_DATE
from transform_data
)

select * from type_data