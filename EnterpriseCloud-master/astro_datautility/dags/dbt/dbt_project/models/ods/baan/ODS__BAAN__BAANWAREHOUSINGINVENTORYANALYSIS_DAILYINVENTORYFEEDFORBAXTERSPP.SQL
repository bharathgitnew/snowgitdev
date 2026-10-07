/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGINVENTORYANALYSIS_DAILYINVENTORYFEEDFORBAXTERSPP',
    unique_key = ['ITEM',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,CAST(T$STOC AS NUMERIC(15,2))               AS INVENTORYONHAND 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'') AS ITEM 
            ,CAST(T$QINT AS NUMERIC(15,2))               AS QUANTITYINTRANSIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'') AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINA990201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.INVENTORYONHAND AS INVENTORYONHAND, 
        source_data.ITEM AS ITEM, 
        source_data.QUANTITYINTRANSIT AS QUANTITYINTRANSIT, 
        source_data.WAREHOUSE AS WAREHOUSE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(INVENTORYONHAND as NUMBER(15,2)) as INVENTORYONHAND,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(QUANTITYINTRANSIT as NUMBER(15,2)) as QUANTITYINTRANSIT,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data