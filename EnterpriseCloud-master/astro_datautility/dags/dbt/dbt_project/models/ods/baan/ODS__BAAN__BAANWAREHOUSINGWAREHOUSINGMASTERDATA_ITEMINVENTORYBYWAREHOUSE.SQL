/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMINVENTORYBYWAREHOUSE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMINVENTORYBYWAREHOUSE.SQL 
-materialized incremental
-alias BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMINVENTORYBYWAREHOUSE 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:57 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMINVENTORYBYWAREHOUSE',
    unique_key = ['ITEM',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ALLO AS NUMERIC(15,2))                                                                                                       AS ALLOCATEDINVENTORY 
            ,CAST(T$HALL AS NUMERIC(15,2))                                                                                                       AS COMMITTEDINVENTORY 
            ,CAST(T$CALL AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYALLOCATED 
            ,CAST(T$CSTO AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONHAND 
            ,CAST(T$CORD AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONORDER 
            ,CAST(T$USCU AS NUMERIC(15,2))                                                                                                       AS CUMULATIVEISSUE 
            ,CAST(CASE WHEN T$HSTD<= '1/1/1970' THEN NULL ELSE T$HSTD  END AS DATETIME) AS DATEOFHISTORICALINVENTORYBALANCE 
            ,CAST(T$HSTB AS NUMERIC(15,2))                                                                                                       AS HISTORICALINVENTORYBALANCE 
            ,CAST(T$STOC AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHAND 
            ,CAST(T$BLCK AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHOLDINVENTORYUNIT 
            ,CAST(T$ORDR AS NUMERIC(15,2))                                                                                                       AS INVENTORYONORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LTDT<= '1/1/1970' THEN NULL ELSE T$LTDT  END AS DATETIME) AS LASTINVENTORYTRANSACTIONDATE 
            ,CAST(CASE WHEN T$LSID<= '1/1/1970' THEN NULL ELSE T$LSID  END AS DATETIME) AS LASTSTORAGEINSPECTIONDATE 
            ,CAST(T$ALPL AS NUMERIC(15,2))                                                                                                       AS LOCATIONALLOCATED 
            ,CAST(T$QTBO AS NUMERIC(15,2))                                                                                                       AS QUANTITYBACKORDERED 
            ,CAST(T$QBSI AS NUMERIC(15,2))                                                                                                       AS QUANTITYBLOCKEDFORSTORAGEINSPECTION 
            ,CAST(T$QINT AS NUMERIC(15,2))                                                                                                       AS QUANTITYINTRANSIT 
            ,CAST(T$BEPL AS NUMERIC(15,2))                                                                                                       AS QUANTITYONHOLDFORPLANNING 
            ,CAST(T$AREJ AS NUMERIC(15,2))                                                                                                       AS REJECTED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHWMD215201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ALLOCATEDINVENTORY AS ALLOCATEDINVENTORY, 
        source_data.COMMITTEDINVENTORY AS COMMITTEDINVENTORY, 
        source_data.CONSIGNMENTINVENTORYALLOCATED AS CONSIGNMENTINVENTORYALLOCATED, 
        source_data.CONSIGNMENTINVENTORYONHAND AS CONSIGNMENTINVENTORYONHAND, 
        source_data.CONSIGNMENTINVENTORYONORDER AS CONSIGNMENTINVENTORYONORDER, 
        source_data.CUMULATIVEISSUE AS CUMULATIVEISSUE, 
        source_data.DATEOFHISTORICALINVENTORYBALANCE AS DATEOFHISTORICALINVENTORYBALANCE, 
        source_data.HISTORICALINVENTORYBALANCE AS HISTORICALINVENTORYBALANCE, 
        source_data.INVENTORYONHAND AS INVENTORYONHAND, 
        source_data.INVENTORYONHOLDINVENTORYUNIT AS INVENTORYONHOLDINVENTORYUNIT, 
        source_data.INVENTORYONORDER AS INVENTORYONORDER, 
        source_data.ITEM AS ITEM, 
        source_data.LASTINVENTORYTRANSACTIONDATE AS LASTINVENTORYTRANSACTIONDATE, 
        source_data.LASTSTORAGEINSPECTIONDATE AS LASTSTORAGEINSPECTIONDATE, 
        source_data.LOCATIONALLOCATED AS LOCATIONALLOCATED, 
        source_data.QUANTITYBACKORDERED AS QUANTITYBACKORDERED, 
        source_data.QUANTITYBLOCKEDFORSTORAGEINSPECTION AS QUANTITYBLOCKEDFORSTORAGEINSPECTION, 
        source_data.QUANTITYINTRANSIT AS QUANTITYINTRANSIT, 
        source_data.QUANTITYONHOLDFORPLANNING AS QUANTITYONHOLDFORPLANNING, 
        source_data.REJECTED AS REJECTED, 
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
        cast(ALLOCATEDINVENTORY as NUMBER(15,2)) as ALLOCATEDINVENTORY,
        cast(COMMITTEDINVENTORY as NUMBER(15,2)) as COMMITTEDINVENTORY,
        cast(CONSIGNMENTINVENTORYALLOCATED as NUMBER(15,2)) as CONSIGNMENTINVENTORYALLOCATED,
        cast(CONSIGNMENTINVENTORYONHAND as NUMBER(15,2)) as CONSIGNMENTINVENTORYONHAND,
        cast(CONSIGNMENTINVENTORYONORDER as NUMBER(15,2)) as CONSIGNMENTINVENTORYONORDER,
        cast(CUMULATIVEISSUE as NUMBER(15,2)) as CUMULATIVEISSUE,
        cast(DATEOFHISTORICALINVENTORYBALANCE as TIMESTAMP_NTZ(9)) as DATEOFHISTORICALINVENTORYBALANCE,
        cast(HISTORICALINVENTORYBALANCE as NUMBER(15,2)) as HISTORICALINVENTORYBALANCE,
        cast(INVENTORYONHAND as NUMBER(15,2)) as INVENTORYONHAND,
        cast(INVENTORYONHOLDINVENTORYUNIT as NUMBER(15,2)) as INVENTORYONHOLDINVENTORYUNIT,
        cast(INVENTORYONORDER as NUMBER(15,2)) as INVENTORYONORDER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTINVENTORYTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as LASTINVENTORYTRANSACTIONDATE,
        cast(LASTSTORAGEINSPECTIONDATE as TIMESTAMP_NTZ(9)) as LASTSTORAGEINSPECTIONDATE,
        cast(LOCATIONALLOCATED as NUMBER(15,2)) as LOCATIONALLOCATED,
        cast(QUANTITYBACKORDERED as NUMBER(15,2)) as QUANTITYBACKORDERED,
        cast(QUANTITYBLOCKEDFORSTORAGEINSPECTION as NUMBER(15,2)) as QUANTITYBLOCKEDFORSTORAGEINSPECTION,
        cast(QUANTITYINTRANSIT as NUMBER(15,2)) as QUANTITYINTRANSIT,
        cast(QUANTITYONHOLDFORPLANNING as NUMBER(15,2)) as QUANTITYONHOLDFORPLANNING,
        cast(REJECTED as NUMBER(15,2)) as REJECTED,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data