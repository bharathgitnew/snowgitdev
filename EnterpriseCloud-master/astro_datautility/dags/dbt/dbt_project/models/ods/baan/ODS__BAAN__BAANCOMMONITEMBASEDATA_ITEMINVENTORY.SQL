/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONITEMBASEDATA_ITEMINVENTORY.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONITEMBASEDATA_ITEMINVENTORY.SQL 
-materialized incremental
-alias BAANCOMMONITEMBASEDATA_ITEMINVENTORY 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONITEMBASEDATA_ITEMINVENTORY',
    unique_key = ['ITEM']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ALLO AS NUMERIC(15,2))                                                                                                       AS ALLOCATEDINVENTORY 
            ,CAST(T$AVPR AS NUMERIC(15,2))                                                                                                       AS AVERAGEPURCHASEPRICE 
            ,CAST("T$APMC$1" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC1 
            ,CAST("T$APMC$2" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC2 
            ,CAST("T$APMC$3" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC3 
            ,CAST(T$HALL AS NUMERIC(15,2))                                                                                                       AS COMMITTEDINVENTORY 
            ,CAST(T$CALL AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYALLOCATED 
            ,CAST(T$CSTO AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONHAND 
            ,CAST(T$CORD AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONORDER 
            ,CAST(T$USCU AS NUMERIC(15,2))                                                                                                       AS CUMULATIVEISSUE 
            ,CAST(T$PURC AS NUMERIC(15,2))                                                                                                       AS CUMULATIVEPURCHASERECEIPTS 
            ,CAST(T$QINT AS NUMERIC(15,2))                                                                                                       AS INVENTORYINTRANSIT 
            ,CAST(T$STOC AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHAND 
            ,CAST(T$BLCK AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHOLD 
            ,CAST(T$BEPL AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHOLDFORPLANNING 
            ,CAST(T$ORDR AS NUMERIC(15,2))                                                                                                       AS INVENTORYONORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LTDT<= '1/1/1970' THEN NULL ELSE T$LTDT  END AS DATETIME) AS LASTINVENTORYTRANSACTIONDATE 
            ,CAST(CASE WHEN T$LTPP<= '1/1/1970' THEN NULL ELSE T$LTPP  END AS DATETIME) AS LASTPURCHASEPRICETRANSACTIONDATE 
            ,CAST(T$LTPR AS NUMERIC(15,2))                                                                                                       AS LATESTPURCHASEPRICE 
            ,CAST("T$LPMC$1" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC1 
            ,CAST("T$LPMC$2" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC2 
            ,CAST("T$LPMC$3" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC3 
            ,T$NCST.CONSTANTDESCRIPTION                                                                                                          AS NETCHANGEDESCRIPTION 
            ,T$NDRP.CONSTANTDESCRIPTION                                                                                                          AS NETCHANGEDRPSTATUSDESCRIPTION 
            ,CAST(T$NDRP AS INT)                                                                                                                 AS NETCHANGEDRPSTATUSID 
            ,CAST(T$NCST AS INT)                                                                                                                 AS NETCHANGEID 
            ,CAST(CASE WHEN T$NCDT<= '1/1/1970' THEN NULL ELSE T$NCDT  END AS DATETIME) AS NETTCHANGEDATE 
            ,CAST(T$QBSI AS NUMERIC(15,2))                                                                                                       AS QUANTITYBLOCKEDFORSTORAGEINSPECTION 
            ,CAST(T$QUOT AS NUMERIC(15,2))                                                                                                       AS QUOTATIONALLOCATIONS 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD100200") }} AS SOURCETABLE  
            /*NETCHANGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NCST 
             ON   T$NCST.TABLENAME  = 'TCIBD100' 
              AND T$NCST.COLUMNNAME = 'T$NCST' 
              AND T$NCST.CONSTANT   = SOURCETABLE.T$NCST 
            /*NETCHANGEDRPSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NDRP 
             ON   T$NDRP.TABLENAME  = 'TCIBD100' 
              AND T$NDRP.COLUMNNAME = 'T$NDRP' 
              AND T$NDRP.CONSTANT   = SOURCETABLE.T$NDRP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ALLO AS NUMERIC(15,2))                                                                                                       AS ALLOCATEDINVENTORY 
            ,CAST(T$AVPR AS NUMERIC(15,2))                                                                                                       AS AVERAGEPURCHASEPRICE 
            ,CAST("T$APMC$1" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC1 
            ,CAST("T$APMC$2" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC2 
            ,CAST("T$APMC$3" AS NUMERIC(15,2))                                                                                                     AS AVERAGEPURCHASEPRICEMC3 
            ,CAST(T$HALL AS NUMERIC(15,2))                                                                                                       AS COMMITTEDINVENTORY 
            ,CAST(T$CALL AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYALLOCATED 
            ,CAST(T$CSTO AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONHAND 
            ,CAST(T$CORD AS NUMERIC(15,2))                                                                                                       AS CONSIGNMENTINVENTORYONORDER 
            ,CAST(T$USCU AS NUMERIC(15,2))                                                                                                       AS CUMULATIVEISSUE 
            ,CAST(T$PURC AS NUMERIC(15,2))                                                                                                       AS CUMULATIVEPURCHASERECEIPTS 
            ,CAST(T$QINT AS NUMERIC(15,2))                                                                                                       AS INVENTORYINTRANSIT 
            ,CAST(T$STOC AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHAND 
            ,CAST(T$BLCK AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHOLD 
            ,CAST(T$BEPL AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHOLDFORPLANNING 
            ,CAST(T$ORDR AS NUMERIC(15,2))                                                                                                       AS INVENTORYONORDER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LTDT<= '1/1/1970' THEN NULL ELSE T$LTDT  END AS DATETIME) AS LASTINVENTORYTRANSACTIONDATE 
            ,CAST(CASE WHEN T$LTPP<= '1/1/1970' THEN NULL ELSE T$LTPP  END AS DATETIME) AS LASTPURCHASEPRICETRANSACTIONDATE 
            ,CAST(T$LTPR AS NUMERIC(15,2))                                                                                                       AS LATESTPURCHASEPRICE 
            ,CAST("T$LPMC$1" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC1 
            ,CAST("T$LPMC$2" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC2 
            ,CAST("T$LPMC$3" AS NUMERIC(15,2))                                                                                                     AS LATESTPURCHASEPRICEMC3 
            ,T$NCST.CONSTANTDESCRIPTION                                                                                                          AS NETCHANGEDESCRIPTION 
            ,T$NDRP.CONSTANTDESCRIPTION                                                                                                          AS NETCHANGEDRPSTATUSDESCRIPTION 
            ,CAST(T$NDRP AS INT)                                                                                                                 AS NETCHANGEDRPSTATUSID 
            ,CAST(T$NCST AS INT)                                                                                                                 AS NETCHANGEID 
            ,CAST(CASE WHEN T$NCDT<= '1/1/1970' THEN NULL ELSE T$NCDT  END AS DATETIME) AS NETTCHANGEDATE 
            ,CAST(T$QBSI AS NUMERIC(15,2))                                                                                                       AS QUANTITYBLOCKEDFORSTORAGEINSPECTION 
            ,CAST(T$QUOT AS NUMERIC(15,2))                                                                                                       AS QUOTATIONALLOCATIONS 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD100201") }} AS SOURCETABLE  
            /*NETCHANGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NCST 
             ON   T$NCST.TABLENAME  = 'TCIBD100' 
              AND T$NCST.COLUMNNAME = 'T$NCST' 
              AND T$NCST.CONSTANT   = SOURCETABLE.T$NCST 
            /*NETCHANGEDRPSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NDRP 
             ON   T$NDRP.TABLENAME  = 'TCIBD100' 
              AND T$NDRP.COLUMNNAME = 'T$NDRP' 
              AND T$NDRP.CONSTANT   = SOURCETABLE.T$NDRP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ALLOCATEDINVENTORY AS ALLOCATEDINVENTORY, 
        source_data.AVERAGEPURCHASEPRICE AS AVERAGEPURCHASEPRICE, 
        source_data.AVERAGEPURCHASEPRICEMC1 AS AVERAGEPURCHASEPRICEMC1, 
        source_data.AVERAGEPURCHASEPRICEMC2 AS AVERAGEPURCHASEPRICEMC2, 
        source_data.AVERAGEPURCHASEPRICEMC3 AS AVERAGEPURCHASEPRICEMC3, 
        source_data.COMMITTEDINVENTORY AS COMMITTEDINVENTORY, 
        source_data.CONSIGNMENTINVENTORYALLOCATED AS CONSIGNMENTINVENTORYALLOCATED, 
        source_data.CONSIGNMENTINVENTORYONHAND AS CONSIGNMENTINVENTORYONHAND, 
        source_data.CONSIGNMENTINVENTORYONORDER AS CONSIGNMENTINVENTORYONORDER, 
        source_data.CUMULATIVEISSUE AS CUMULATIVEISSUE, 
        source_data.CUMULATIVEPURCHASERECEIPTS AS CUMULATIVEPURCHASERECEIPTS, 
        source_data.INVENTORYINTRANSIT AS INVENTORYINTRANSIT, 
        source_data.INVENTORYONHAND AS INVENTORYONHAND, 
        source_data.INVENTORYONHOLD AS INVENTORYONHOLD, 
        source_data.INVENTORYONHOLDFORPLANNING AS INVENTORYONHOLDFORPLANNING, 
        source_data.INVENTORYONORDER AS INVENTORYONORDER, 
        source_data.ITEM AS ITEM, 
        source_data.LASTINVENTORYTRANSACTIONDATE AS LASTINVENTORYTRANSACTIONDATE, 
        source_data.LASTPURCHASEPRICETRANSACTIONDATE AS LASTPURCHASEPRICETRANSACTIONDATE, 
        source_data.LATESTPURCHASEPRICE AS LATESTPURCHASEPRICE, 
        source_data.LATESTPURCHASEPRICEMC1 AS LATESTPURCHASEPRICEMC1, 
        source_data.LATESTPURCHASEPRICEMC2 AS LATESTPURCHASEPRICEMC2, 
        source_data.LATESTPURCHASEPRICEMC3 AS LATESTPURCHASEPRICEMC3, 
        source_data.NETCHANGEDESCRIPTION AS NETCHANGEDESCRIPTION, 
        source_data.NETCHANGEDRPSTATUSDESCRIPTION AS NETCHANGEDRPSTATUSDESCRIPTION, 
        source_data.NETCHANGEDRPSTATUSID AS NETCHANGEDRPSTATUSID, 
        source_data.NETCHANGEID AS NETCHANGEID, 
        source_data.NETTCHANGEDATE AS NETTCHANGEDATE, 
        source_data.QUANTITYBLOCKEDFORSTORAGEINSPECTION AS QUANTITYBLOCKEDFORSTORAGEINSPECTION, 
        source_data.QUOTATIONALLOCATIONS AS QUOTATIONALLOCATIONS
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
        cast(AVERAGEPURCHASEPRICE as NUMBER(15,2)) as AVERAGEPURCHASEPRICE,
        cast(AVERAGEPURCHASEPRICEMC1 as NUMBER(15,2)) as AVERAGEPURCHASEPRICEMC1,
        cast(AVERAGEPURCHASEPRICEMC2 as NUMBER(15,2)) as AVERAGEPURCHASEPRICEMC2,
        cast(AVERAGEPURCHASEPRICEMC3 as NUMBER(15,2)) as AVERAGEPURCHASEPRICEMC3,
        cast(COMMITTEDINVENTORY as NUMBER(15,2)) as COMMITTEDINVENTORY,
        cast(CONSIGNMENTINVENTORYALLOCATED as NUMBER(15,2)) as CONSIGNMENTINVENTORYALLOCATED,
        cast(CONSIGNMENTINVENTORYONHAND as NUMBER(15,2)) as CONSIGNMENTINVENTORYONHAND,
        cast(CONSIGNMENTINVENTORYONORDER as NUMBER(15,2)) as CONSIGNMENTINVENTORYONORDER,
        cast(CUMULATIVEISSUE as NUMBER(15,2)) as CUMULATIVEISSUE,
        cast(CUMULATIVEPURCHASERECEIPTS as NUMBER(15,2)) as CUMULATIVEPURCHASERECEIPTS,
        cast(INVENTORYINTRANSIT as NUMBER(15,2)) as INVENTORYINTRANSIT,
        cast(INVENTORYONHAND as NUMBER(15,2)) as INVENTORYONHAND,
        cast(INVENTORYONHOLD as NUMBER(15,2)) as INVENTORYONHOLD,
        cast(INVENTORYONHOLDFORPLANNING as NUMBER(15,2)) as INVENTORYONHOLDFORPLANNING,
        cast(INVENTORYONORDER as NUMBER(15,2)) as INVENTORYONORDER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTINVENTORYTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as LASTINVENTORYTRANSACTIONDATE,
        cast(LASTPURCHASEPRICETRANSACTIONDATE as TIMESTAMP_NTZ(9)) as LASTPURCHASEPRICETRANSACTIONDATE,
        cast(LATESTPURCHASEPRICE as NUMBER(15,2)) as LATESTPURCHASEPRICE,
        cast(LATESTPURCHASEPRICEMC1 as NUMBER(15,2)) as LATESTPURCHASEPRICEMC1,
        cast(LATESTPURCHASEPRICEMC2 as NUMBER(15,2)) as LATESTPURCHASEPRICEMC2,
        cast(LATESTPURCHASEPRICEMC3 as NUMBER(15,2)) as LATESTPURCHASEPRICEMC3,
        cast(NETCHANGEDESCRIPTION as VARCHAR(16777216)) as NETCHANGEDESCRIPTION,
        cast(NETCHANGEDRPSTATUSDESCRIPTION as VARCHAR(16777216)) as NETCHANGEDRPSTATUSDESCRIPTION,
        cast(NETCHANGEDRPSTATUSID as NUMBER(38,0)) as NETCHANGEDRPSTATUSID,
        cast(NETCHANGEID as NUMBER(38,0)) as NETCHANGEID,
        cast(NETTCHANGEDATE as TIMESTAMP_NTZ(9)) as NETTCHANGEDATE,
        cast(QUANTITYBLOCKEDFORSTORAGEINSPECTION as NUMBER(15,2)) as QUANTITYBLOCKEDFORSTORAGEINSPECTION,
        cast(QUOTATIONALLOCATIONS as NUMBER(15,2)) as QUOTATIONALLOCATIONS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data