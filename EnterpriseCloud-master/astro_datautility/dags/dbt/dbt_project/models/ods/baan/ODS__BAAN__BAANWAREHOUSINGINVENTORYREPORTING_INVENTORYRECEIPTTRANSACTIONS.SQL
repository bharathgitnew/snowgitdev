/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS 
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
    alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONS',
    unique_key = ['ITEM',
    'SEQUENCENUMBER_SEQN',
    'TRANSACTIONDATE',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$CONS.CONSTANTDESCRIPTION                                                                                                          AS CONSIGNMENTDESCRIPTION 
            ,CAST(T$CONS AS INT)                                                                                                                 AS CONSIGNMENTID 
            ,T$VACO.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYVARIANCEASSIGNEDDESCRIPTION 
            ,CAST(T$VACO AS INT)                                                                                                                 AS INVENTORYVARIANCEASSIGNEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$QSKT AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOBECONSUMED 
            ,CAST(T$QSTK AS NUMERIC(15,2))                                                                                                       AS RECEIVEDQUANTITY 
            ,T$RVLD.CONSTANTDESCRIPTION                                                                                                          AS REVALUEDDESCRIPTION 
            ,CAST(T$RVLD AS INT)                                                                                                                 AS REVALUEDID 
            ,CAST(CASE WHEN T$RDAT<= '1/1/1970' THEN NULL ELSE T$RDAT  END AS DATETIME) AS REVALUEDON 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER_SEQN 
            ,CAST(T$SRNB AS BIGINT)                                                                                                              AS SEQUENCENUMBER_SRNB 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,T$TRNS.CONSTANTDESCRIPTION                                                                                                          AS TRANSITIONEDDESCRIPTION 
            ,CAST(T$TRNS AS INT)                                                                                                                 AS TRANSITIONEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINR112201") }} AS SOURCETABLE  
            /*CONSIGNMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONS 
             ON   T$CONS.TABLENAME  = 'WHINR112' 
              AND T$CONS.COLUMNNAME = 'T$CONS' 
              AND T$CONS.CONSTANT   = SOURCETABLE.T$CONS 
            /*INVENTORYVARIANCEASSIGNED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VACO 
             ON   T$VACO.TABLENAME  = 'WHINR112' 
              AND T$VACO.COLUMNNAME = 'T$VACO' 
              AND T$VACO.CONSTANT   = SOURCETABLE.T$VACO 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINR112' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
            /*REVALUED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RVLD 
             ON   T$RVLD.TABLENAME  = 'WHINR112' 
              AND T$RVLD.COLUMNNAME = 'T$RVLD' 
              AND T$RVLD.CONSTANT   = SOURCETABLE.T$RVLD 
            /*TRANSITIONED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TRNS 
             ON   T$TRNS.TABLENAME  = 'WHINR112' 
              AND T$TRNS.COLUMNNAME = 'T$TRNS' 
              AND T$TRNS.CONSTANT   = SOURCETABLE.T$TRNS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CONSIGNMENTDESCRIPTION AS CONSIGNMENTDESCRIPTION, 
        source_data.CONSIGNMENTID AS CONSIGNMENTID, 
        source_data.INVENTORYVARIANCEASSIGNEDDESCRIPTION AS INVENTORYVARIANCEASSIGNEDDESCRIPTION, 
        source_data.INVENTORYVARIANCEASSIGNEDID AS INVENTORYVARIANCEASSIGNEDID, 
        source_data.ITEM AS ITEM, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.QUANTITYTOBECONSUMED AS QUANTITYTOBECONSUMED, 
        source_data.RECEIVEDQUANTITY AS RECEIVEDQUANTITY, 
        source_data.REVALUEDDESCRIPTION AS REVALUEDDESCRIPTION, 
        source_data.REVALUEDID AS REVALUEDID, 
        source_data.REVALUEDON AS REVALUEDON, 
        source_data.SEQUENCENUMBER_SEQN AS SEQUENCENUMBER_SEQN, 
        source_data.SEQUENCENUMBER_SRNB AS SEQUENCENUMBER_SRNB, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSITIONEDDESCRIPTION AS TRANSITIONEDDESCRIPTION, 
        source_data.TRANSITIONEDID AS TRANSITIONEDID, 
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
        cast(CONSIGNMENTDESCRIPTION as VARCHAR(16777216)) as CONSIGNMENTDESCRIPTION,
        cast(CONSIGNMENTID as NUMBER(38,0)) as CONSIGNMENTID,
        cast(INVENTORYVARIANCEASSIGNEDDESCRIPTION as VARCHAR(16777216)) as INVENTORYVARIANCEASSIGNEDDESCRIPTION,
        cast(INVENTORYVARIANCEASSIGNEDID as NUMBER(38,0)) as INVENTORYVARIANCEASSIGNEDID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(QUANTITYTOBECONSUMED as NUMBER(15,2)) as QUANTITYTOBECONSUMED,
        cast(RECEIVEDQUANTITY as NUMBER(15,2)) as RECEIVEDQUANTITY,
        cast(REVALUEDDESCRIPTION as VARCHAR(16777216)) as REVALUEDDESCRIPTION,
        cast(REVALUEDID as NUMBER(38,0)) as REVALUEDID,
        cast(REVALUEDON as TIMESTAMP_NTZ(9)) as REVALUEDON,
        cast(SEQUENCENUMBER_SEQN as NUMBER(38,0)) as SEQUENCENUMBER_SEQN,
        cast(SEQUENCENUMBER_SRNB as NUMBER(38,0)) as SEQUENCENUMBER_SRNB,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSITIONEDDESCRIPTION as VARCHAR(16777216)) as TRANSITIONEDDESCRIPTION,
        cast(TRANSITIONEDID as NUMBER(38,0)) as TRANSITIONEDID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data