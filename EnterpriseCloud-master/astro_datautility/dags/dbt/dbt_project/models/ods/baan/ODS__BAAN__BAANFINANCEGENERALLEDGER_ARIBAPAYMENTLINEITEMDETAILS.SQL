/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTLINEITEMDETAILS',
    unique_key = ['PAYMENTID',
    'POSITION',
    'SEQ']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$IAMT AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDCOSTITEM 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,CAST(T$CFAC AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,T$ISCO.CONSTANTDESCRIPTION                                                                                                          AS ISCOMPOSITEDESCRIPTION 
            ,CAST(T$ISCO AS INT)                                                                                                                 AS ISCOMPOSITEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,CAST(T$LCAT AS INT)                                                                                                                 AS LINETYPECATERY_LCAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPECATERY_LTYP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MAST)),'')                                                                                         AS MASTERAGREEMENTNAME 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,CAST(T$OLIN AS INT)                                                                                                                 AS ORDER_LINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$POLN AS INT)                                                                                                                 AS POLINENUMBER 
            ,CAST(T$PNUM AS INT)                                                                                                                 AS PONUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS PORECEIVINGTYPE 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PBQN AS NUMERIC(15,2))                                                                                                       AS PRICEBASISQUANTITY 
            ,CAST(T$PQAN AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITY 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(T$POSI AS BIGINT)                                                                                                              AS PURCHASEORDERPOS 
            ,CAST(T$QUAN AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,CAST(T$REDO AS INT)                                                                                                                 AS REFERENCEINVDOCUMENT 
            ,CAST(T$SAPI AS INT)                                                                                                                 AS SAPPARENTPOITEM 
            ,CAST(T$SACI AS INT)                                                                                                                 AS SAPPOITEM 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQ 
            ,CAST(T$LINE AS INT)                                                                                                                 AS SERVICELINENUMBER 
            ,CAST(T$SHID AS BIGINT)                                                                                                              AS SERVICESHEETID 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNITOFMEASURE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD717200") }} AS SOURCETABLE  
            /*ISCOMPOSITE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISCO 
             ON   T$ISCO.TABLENAME  = 'TFGLD717' 
              AND T$ISCO.COLUMNNAME = 'T$ISCO' 
              AND T$ISCO.CONSTANT   = SOURCETABLE.T$ISCO 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD717' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$IAMT AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDCOSTITEM 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,CAST(T$CFAC AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,T$ISCO.CONSTANTDESCRIPTION                                                                                                          AS ISCOMPOSITEDESCRIPTION 
            ,CAST(T$ISCO AS INT)                                                                                                                 AS ISCOMPOSITEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,CAST(T$LCAT AS INT)                                                                                                                 AS LINETYPECATERY_LCAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPECATERY_LTYP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MAST)),'')                                                                                         AS MASTERAGREEMENTNAME 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,CAST(T$OLIN AS INT)                                                                                                                 AS ORDER_LINES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$POLN AS INT)                                                                                                                 AS POLINENUMBER 
            ,CAST(T$PNUM AS INT)                                                                                                                 AS PONUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS PORECEIVINGTYPE 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PBQN AS NUMERIC(15,2))                                                                                                       AS PRICEBASISQUANTITY 
            ,CAST(T$PQAN AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITY 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(T$POSI AS BIGINT)                                                                                                              AS PURCHASEORDERPOS 
            ,CAST(T$QUAN AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,CAST(T$REDO AS INT)                                                                                                                 AS REFERENCEINVDOCUMENT 
            ,CAST(T$SAPI AS INT)                                                                                                                 AS SAPPARENTPOITEM 
            ,CAST(T$SACI AS INT)                                                                                                                 AS SAPPOITEM 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQ 
            ,CAST(T$LINE AS INT)                                                                                                                 AS SERVICELINENUMBER 
            ,CAST(T$SHID AS BIGINT)                                                                                                              AS SERVICESHEETID 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNITOFMEASURE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD717201") }} AS SOURCETABLE  
            /*ISCOMPOSITE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISCO 
             ON   T$ISCO.TABLENAME  = 'TFGLD717' 
              AND T$ISCO.COLUMNNAME = 'T$ISCO' 
              AND T$ISCO.CONSTANT   = SOURCETABLE.T$ISCO 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD717' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADJUSTEDCOSTITEM AS ADJUSTEDCOSTITEM, 
        source_data.AMOUNT AS AMOUNT, 
        source_data.CONVERSIONFACTOR AS CONVERSIONFACTOR, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.ISCOMPOSITEDESCRIPTION AS ISCOMPOSITEDESCRIPTION, 
        source_data.ISCOMPOSITEID AS ISCOMPOSITEID, 
        source_data.ITEMTEXT AS ITEMTEXT, 
        source_data.LINETYPECATERY_LCAT AS LINETYPECATERY_LCAT, 
        source_data.LINETYPECATERY_LTYP AS LINETYPECATERY_LTYP, 
        source_data.MASTERAGREEMENTNAME AS MASTERAGREEMENTNAME, 
        source_data.NUMBERINCOLLECTION AS NUMBERINCOLLECTION, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_LINES AS ORDER_LINES, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.POLINENUMBER AS POLINENUMBER, 
        source_data.PONUMBER AS PONUMBER, 
        source_data.PORECEIVINGTYPE AS PORECEIVINGTYPE, 
        source_data.POSITION AS POSITION, 
        source_data.PRICEBASISQUANTITY AS PRICEBASISQUANTITY, 
        source_data.PRICEQUANTITY AS PRICEQUANTITY, 
        source_data.PRICEQUANTITYUOM AS PRICEQUANTITYUOM, 
        source_data.PROCESSDATE AS PROCESSDATE, 
        source_data.PURCHASEORDERPOS AS PURCHASEORDERPOS, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.REFERENCEINVDOCUMENT AS REFERENCEINVDOCUMENT, 
        source_data.SAPPARENTPOITEM AS SAPPARENTPOITEM, 
        source_data.SAPPOITEM AS SAPPOITEM, 
        source_data.SEQ AS SEQ, 
        source_data.SERVICELINENUMBER AS SERVICELINENUMBER, 
        source_data.SERVICESHEETID AS SERVICESHEETID, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.UNITOFMEASURE AS UNITOFMEASURE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADJUSTEDCOSTITEM as NUMBER(15,2)) as ADJUSTEDCOSTITEM,
        cast(AMOUNT as NUMBER(15,2)) as AMOUNT,
        cast(CONVERSIONFACTOR as NUMBER(15,2)) as CONVERSIONFACTOR,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(ISCOMPOSITEDESCRIPTION as VARCHAR(16777216)) as ISCOMPOSITEDESCRIPTION,
        cast(ISCOMPOSITEID as NUMBER(38,0)) as ISCOMPOSITEID,
        cast(ITEMTEXT as VARCHAR(999)) as ITEMTEXT,
        cast(LINETYPECATERY_LCAT as NUMBER(38,0)) as LINETYPECATERY_LCAT,
        cast(LINETYPECATERY_LTYP as VARCHAR(50)) as LINETYPECATERY_LTYP,
        cast(MASTERAGREEMENTNAME as VARCHAR(10)) as MASTERAGREEMENTNAME,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(ORDER_ as VARCHAR(50)) as ORDER_,
        cast(ORDER_LINES as NUMBER(38,0)) as ORDER_LINES,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(POLINENUMBER as NUMBER(38,0)) as POLINENUMBER,
        cast(PONUMBER as NUMBER(38,0)) as PONUMBER,
        cast(PORECEIVINGTYPE as VARCHAR(50)) as PORECEIVINGTYPE,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PRICEBASISQUANTITY as NUMBER(15,2)) as PRICEBASISQUANTITY,
        cast(PRICEQUANTITY as NUMBER(15,2)) as PRICEQUANTITY,
        cast(PRICEQUANTITYUOM as NUMBER(15,2)) as PRICEQUANTITYUOM,
        cast(PROCESSDATE as TIMESTAMP_NTZ(9)) as PROCESSDATE,
        cast(PURCHASEORDERPOS as NUMBER(38,0)) as PURCHASEORDERPOS,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(REFERENCEINVDOCUMENT as NUMBER(38,0)) as REFERENCEINVDOCUMENT,
        cast(SAPPARENTPOITEM as NUMBER(38,0)) as SAPPARENTPOITEM,
        cast(SAPPOITEM as NUMBER(38,0)) as SAPPOITEM,
        cast(SEQ as NUMBER(38,0)) as SEQ,
        cast(SERVICELINENUMBER as NUMBER(38,0)) as SERVICELINENUMBER,
        cast(SERVICESHEETID as NUMBER(38,0)) as SERVICESHEETID,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(UNITOFMEASURE as VARCHAR(3)) as UNITOFMEASURE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data