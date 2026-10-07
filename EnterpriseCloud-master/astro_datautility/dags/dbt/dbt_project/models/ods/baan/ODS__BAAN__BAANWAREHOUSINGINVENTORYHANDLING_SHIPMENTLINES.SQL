/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_SHIPMENTLINES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_SHIPMENTLINES.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_SHIPMENTLINES 
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
    alias='BAANWAREHOUSINGINVENTORYHANDLING_SHIPMENTLINES',
    unique_key = ['POSITIONNUMBER_PONO',
    'SHIPMENTIDENTIFICATION']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                         AS ACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RECD)),'')                                                                                         AS ADJUSTMENTREASON 
            ,T$ADJS.CONSTANTDESCRIPTION                                                                                                          AS AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDDESCRIPTION 
            ,CAST(T$ADJS AS INT)                                                                                                                 AS AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDID 
            ,CAST(T$BOML AS INT)                                                                                                                 AS BOMLINE 
            ,CAST(T$BOLP AS INT)                                                                                                                 AS CLUSTERINGPOSITION 
            ,T$CONF.CONSTANTDESCRIPTION                                                                                                          AS CONFIRMEDDESCRIPTION 
            ,CAST(T$CONF AS INT)                                                                                                                 AS CONFIRMEDID 
            ,CAST(T$QRCP AS NUMERIC(15,2))                                                                                                       AS CONFIRMEDRECEIVEDQUANTITY 
            ,T$CONS.CONSTANTDESCRIPTION                                                                                                          AS CONSIGNMENTDESCRIPTION 
            ,CAST(T$CONS AS INT)                                                                                                                 AS CONSIGNMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSSH)),'')                                                                                         AS DESTINATIONSHIPMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS FINTRANSACTIONTYPE 
            ,CAST(T$GRWT AS NUMERIC(15,2))                                                                                                       AS GROSSWEIGHT 
            ,CAST(CASE WHEN T$IADT<= '1/1/1970' THEN NULL ELSE T$IADT  END AS DATETIME) AS INVENTORYADJUSTMENTDATE 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVENTORYDATE 
            ,T$IADJ.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYUPDATEDDESCRIPTION 
            ,CAST(T$IADJ AS INT)                                                                                                                 AS INVENTORYUPDATEDID 
            ,CAST(CASE WHEN T$INVD<= '1/1/1970' THEN NULL ELSE T$INVD  END AS DATETIME) AS INVOICEDATE 
            ,CAST(T$CINV AS BIGINT)                                                                                                              AS INVOICENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,CAST(T$NTWT AS NUMERIC(15,2))                                                                                                       AS NETWEIGHT 
            ,CAST(T$NOSH AS TINYINT)                                                                                                             AS NUMBEROFSHIPMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$WORN)),'')                                                                                         AS ORDER_ 
            ,T$WORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$WORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PSNR)),'')                                                                                         AS PACKINGSTRUCTURENUMBER 
            ,CAST(T$QPIC AS NUMERIC(15,2))                                                                                                       AS PICKEDQUANTITY 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER_PONO 
            ,CAST(T$WPON AS INT)                                                                                                                 AS POSITIONNUMBER_WPON 
            ,T$PBOL.CONSTANTDESCRIPTION                                                                                                          AS PRINTBILLOFLADINGDESCRIPTION 
            ,CAST(T$PBOL AS INT)                                                                                                                 AS PRINTBILLOFLADINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                         AS PROCEDUREMASK 
            ,CAST(T$QNSH AS NUMERIC(15,2))                                                                                                       AS QUANTITYNOTSHIPPED 
            ,CAST(T$QUSP AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOSPLIT 
            ,CAST(T$RSEQ AS INT)                                                                                                                 AS SALESSEQUENCENUMBER 
            ,CAST(T$WSEQ AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$WSET AS INT)                                                                                                                 AS _SET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                         AS SHIPMENTIDENTIFICATION 
            ,CAST(T$QSHP AS NUMERIC(15,2))                                                                                                       AS SHIPPEDQUANTITYININVENTORYUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCA)),'')                                                                                         AS STAGINGLOCATION 
            ,SOURCETABLE.T$TEXT   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNITOFMEASURE_CUNI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWUN)),'')                                                                                         AS UNITOFMEASURE_CWUN 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH431201") }} AS SOURCETABLE  
            /*AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ADJS 
             ON   T$ADJS.TABLENAME  = 'WHINH431' 
              AND T$ADJS.COLUMNNAME = 'T$ADJS' 
              AND T$ADJS.CONSTANT   = SOURCETABLE.T$ADJS 
            /*CONFIRMED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONF 
             ON   T$CONF.TABLENAME  = 'WHINH431' 
              AND T$CONF.COLUMNNAME = 'T$CONF' 
              AND T$CONF.CONSTANT   = SOURCETABLE.T$CONF 
            /*CONSIGNMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONS 
             ON   T$CONS.TABLENAME  = 'WHINH431' 
              AND T$CONS.COLUMNNAME = 'T$CONS' 
              AND T$CONS.CONSTANT   = SOURCETABLE.T$CONS 
            /*INVENTORYUPDATED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$IADJ 
             ON   T$IADJ.TABLENAME  = 'WHINH431' 
              AND T$IADJ.COLUMNNAME = 'T$IADJ' 
              AND T$IADJ.CONSTANT   = SOURCETABLE.T$IADJ 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$WORG 
             ON   T$WORG.TABLENAME  = 'WHINH431' 
              AND T$WORG.COLUMNNAME = 'T$WORG' 
              AND T$WORG.CONSTANT   = SOURCETABLE.T$WORG 
            /*PRINTBILLOFLADING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PBOL 
             ON   T$PBOL.TABLENAME  = 'WHINH431' 
              AND T$PBOL.COLUMNNAME = 'T$PBOL' 
              AND T$PBOL.CONSTANT   = SOURCETABLE.T$PBOL 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ADJUSTMENTREASON AS ADJUSTMENTREASON, 
        source_data.AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDDESCRIPTION AS AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDDESCRIPTION, 
        source_data.AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDID AS AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDID, 
        source_data.BOMLINE AS BOMLINE, 
        source_data.CLUSTERINGPOSITION AS CLUSTERINGPOSITION, 
        source_data.CONFIRMEDDESCRIPTION AS CONFIRMEDDESCRIPTION, 
        source_data.CONFIRMEDID AS CONFIRMEDID, 
        source_data.CONFIRMEDRECEIVEDQUANTITY AS CONFIRMEDRECEIVEDQUANTITY, 
        source_data.CONSIGNMENTDESCRIPTION AS CONSIGNMENTDESCRIPTION, 
        source_data.CONSIGNMENTID AS CONSIGNMENTID, 
        source_data.DESTINATIONSHIPMENT AS DESTINATIONSHIPMENT, 
        source_data.FINTRANSACTIONTYPE AS FINTRANSACTIONTYPE, 
        source_data.GROSSWEIGHT AS GROSSWEIGHT, 
        source_data.INVENTORYADJUSTMENTDATE AS INVENTORYADJUSTMENTDATE, 
        source_data.INVENTORYDATE AS INVENTORYDATE, 
        source_data.INVENTORYUPDATEDDESCRIPTION AS INVENTORYUPDATEDDESCRIPTION, 
        source_data.INVENTORYUPDATEDID AS INVENTORYUPDATEDID, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICENUMBER AS INVOICENUMBER, 
        source_data.ITEM AS ITEM, 
        source_data.LOT AS LOT, 
        source_data.NETWEIGHT AS NETWEIGHT, 
        source_data.NUMBEROFSHIPMENTS AS NUMBEROFSHIPMENTS, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.PACKINGSTRUCTURENUMBER AS PACKINGSTRUCTURENUMBER, 
        source_data.PICKEDQUANTITY AS PICKEDQUANTITY, 
        source_data.POSITIONNUMBER_PONO AS POSITIONNUMBER_PONO, 
        source_data.POSITIONNUMBER_WPON AS POSITIONNUMBER_WPON, 
        source_data.PRINTBILLOFLADINGDESCRIPTION AS PRINTBILLOFLADINGDESCRIPTION, 
        source_data.PRINTBILLOFLADINGID AS PRINTBILLOFLADINGID, 
        source_data.PROCEDUREMASK AS PROCEDUREMASK, 
        source_data.QUANTITYNOTSHIPPED AS QUANTITYNOTSHIPPED, 
        source_data.QUANTITYTOSPLIT AS QUANTITYTOSPLIT, 
        source_data.SALESSEQUENCENUMBER AS SALESSEQUENCENUMBER, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data._SET AS _SET, 
        source_data.SHIPMENTIDENTIFICATION AS SHIPMENTIDENTIFICATION, 
        source_data.SHIPPEDQUANTITYININVENTORYUNIT AS SHIPPEDQUANTITYININVENTORYUNIT, 
        source_data.STAGINGLOCATION AS STAGINGLOCATION, 
        source_data.TEXT AS TEXT, 
        source_data.UNITOFMEASURE_CUNI AS UNITOFMEASURE_CUNI, 
        source_data.UNITOFMEASURE_CWUN AS UNITOFMEASURE_CWUN, 
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
        cast(ACTIVITY as VARCHAR(20)) as ACTIVITY,
        cast(ADJUSTMENTREASON as VARCHAR(6)) as ADJUSTMENTREASON,
        cast(AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDDESCRIPTION as VARCHAR(16777216)) as AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDDESCRIPTION,
        cast(AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDID as NUMBER(38,0)) as AUTOMATICADJUSTMENTOFQUANTITYNOTSHIPPEDID,
        cast(BOMLINE as NUMBER(38,0)) as BOMLINE,
        cast(CLUSTERINGPOSITION as NUMBER(38,0)) as CLUSTERINGPOSITION,
        cast(CONFIRMEDDESCRIPTION as VARCHAR(16777216)) as CONFIRMEDDESCRIPTION,
        cast(CONFIRMEDID as NUMBER(38,0)) as CONFIRMEDID,
        cast(CONFIRMEDRECEIVEDQUANTITY as NUMBER(15,2)) as CONFIRMEDRECEIVEDQUANTITY,
        cast(CONSIGNMENTDESCRIPTION as VARCHAR(16777216)) as CONSIGNMENTDESCRIPTION,
        cast(CONSIGNMENTID as NUMBER(38,0)) as CONSIGNMENTID,
        cast(DESTINATIONSHIPMENT as VARCHAR(9)) as DESTINATIONSHIPMENT,
        cast(FINTRANSACTIONTYPE as VARCHAR(3)) as FINTRANSACTIONTYPE,
        cast(GROSSWEIGHT as NUMBER(15,2)) as GROSSWEIGHT,
        cast(INVENTORYADJUSTMENTDATE as TIMESTAMP_NTZ(9)) as INVENTORYADJUSTMENTDATE,
        cast(INVENTORYDATE as TIMESTAMP_NTZ(9)) as INVENTORYDATE,
        cast(INVENTORYUPDATEDDESCRIPTION as VARCHAR(16777216)) as INVENTORYUPDATEDDESCRIPTION,
        cast(INVENTORYUPDATEDID as NUMBER(38,0)) as INVENTORYUPDATEDID,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICENUMBER as NUMBER(38,0)) as INVOICENUMBER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(NETWEIGHT as NUMBER(15,2)) as NETWEIGHT,
        cast(NUMBEROFSHIPMENTS as NUMBER(38,0)) as NUMBEROFSHIPMENTS,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(PACKINGSTRUCTURENUMBER as VARCHAR(15)) as PACKINGSTRUCTURENUMBER,
        cast(PICKEDQUANTITY as NUMBER(15,2)) as PICKEDQUANTITY,
        cast(POSITIONNUMBER_PONO as NUMBER(38,0)) as POSITIONNUMBER_PONO,
        cast(POSITIONNUMBER_WPON as NUMBER(38,0)) as POSITIONNUMBER_WPON,
        cast(PRINTBILLOFLADINGDESCRIPTION as VARCHAR(16777216)) as PRINTBILLOFLADINGDESCRIPTION,
        cast(PRINTBILLOFLADINGID as NUMBER(38,0)) as PRINTBILLOFLADINGID,
        cast(PROCEDUREMASK as VARCHAR(20)) as PROCEDUREMASK,
        cast(QUANTITYNOTSHIPPED as NUMBER(15,2)) as QUANTITYNOTSHIPPED,
        cast(QUANTITYTOSPLIT as NUMBER(15,2)) as QUANTITYTOSPLIT,
        cast(SALESSEQUENCENUMBER as NUMBER(38,0)) as SALESSEQUENCENUMBER,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(_SET as NUMBER(38,0)) as _SET,
        cast(SHIPMENTIDENTIFICATION as VARCHAR(9)) as SHIPMENTIDENTIFICATION,
        cast(SHIPPEDQUANTITYININVENTORYUNIT as NUMBER(15,2)) as SHIPPEDQUANTITYININVENTORYUNIT,
        cast(STAGINGLOCATION as VARCHAR(10)) as STAGINGLOCATION,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(UNITOFMEASURE_CUNI as VARCHAR(3)) as UNITOFMEASURE_CUNI,
        cast(UNITOFMEASURE_CWUN as VARCHAR(3)) as UNITOFMEASURE_CWUN,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data