/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTACCOUNTDETAILS',
    unique_key = ['PAYMENTID',
    'POSITION',
    'SEQUENCE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$IAMT AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDCOSTITEM 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ASST)),'')                                                                                         AS ASSET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUBN)),'')                                                                                         AS ASSETSUBNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCEN)),'')                                                                                         AS COSTCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IORD)),'')                                                                                         AS INTERNALORDER 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT END AS DATE)                                                             AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LCAT AS INT)                                                                                                                 AS LINETYPECATERY_LCAT 
            ,CAST(T$LTYP AS INT)                                                                                                                 AS LINETYPECATERY_LTYP 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OEXP)),'')                                                                                         AS OFFICEEXPORT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PNUM)),'')                                                                                         AS PONUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS PORECEIVINGTYPE 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PEXP)),'')                                                                                         AS PROJECTEXPORT 
            ,CAST(T$QUAN AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SDET)),'')                                                                                         AS SEGMENTEXPORT 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SERI)),'')                                                                                         AS SERIALNUMBER 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$COMP AS INT)                                                                                                                 AS TARGETCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNITOFMEASURE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ELEM)),'')                                                                                         AS WBSELEMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD719200") }} AS SOURCETABLE  
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD719' 
              AND T$STUS.COLUMNNAME = 'T$STUS' 
              AND T$STUS.CONSTANT   = SOURCETABLE.T$STUS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$IAMT AS NUMERIC(15,2))                                                                                                       AS ADJUSTEDCOSTITEM 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS AMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ASST)),'')                                                                                         AS ASSET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUBN)),'')                                                                                         AS ASSETSUBNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCEN)),'')                                                                                         AS COSTCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IORD)),'')                                                                                         AS INTERNALORDER 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT END AS DATE)                                                             AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$LCAT AS INT)                                                                                                                 AS LINETYPECATERY_LCAT 
            ,CAST(T$LTYP AS INT)                                                                                                                 AS LINETYPECATERY_LTYP 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OEXP)),'')                                                                                         AS OFFICEEXPORT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PNUM)),'')                                                                                         AS PONUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS PORECEIVINGTYPE 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PEXP)),'')                                                                                         AS PROJECTEXPORT 
            ,CAST(T$QUAN AS NUMERIC(15,2))                                                                                                       AS QUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SDET)),'')                                                                                         AS SEGMENTEXPORT 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SERI)),'')                                                                                         AS SERIALNUMBER 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$COMP AS INT)                                                                                                                 AS TARGETCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUNI)),'')                                                                                         AS UNITOFMEASURE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ELEM)),'')                                                                                         AS WBSELEMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD719201") }} AS SOURCETABLE  
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD719' 
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
        source_data.ASSET AS ASSET, 
        source_data.ASSETSUBNUMBER AS ASSETSUBNUMBER, 
        source_data.COSTCENTER AS COSTCENTER, 
        source_data.INTERNALORDER AS INTERNALORDER, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LINETYPECATERY_LCAT AS LINETYPECATERY_LCAT, 
        source_data.LINETYPECATERY_LTYP AS LINETYPECATERY_LTYP, 
        source_data.NUMBERINCOLLECTION AS NUMBERINCOLLECTION, 
        source_data.OFFICEEXPORT AS OFFICEEXPORT, 
        source_data.ORDER_ AS ORDER_, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.PONUMBER AS PONUMBER, 
        source_data.PORECEIVINGTYPE AS PORECEIVINGTYPE, 
        source_data.POSITION AS POSITION, 
        source_data.PRICEQUANTITYUOM AS PRICEQUANTITYUOM, 
        source_data.PROCESSDATE AS PROCESSDATE, 
        source_data.PROJECTEXPORT AS PROJECTEXPORT, 
        source_data.QUANTITY AS QUANTITY, 
        source_data.SEGMENTEXPORT AS SEGMENTEXPORT, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.SERIALNUMBER AS SERIALNUMBER, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.TARGETCOMPANY AS TARGETCOMPANY, 
        source_data.TAXCODE AS TAXCODE, 
        source_data.UNITOFMEASURE AS UNITOFMEASURE, 
        source_data.WBSELEMENT AS WBSELEMENT
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
        cast(ASSET as VARCHAR(50)) as ASSET,
        cast(ASSETSUBNUMBER as VARCHAR(4)) as ASSETSUBNUMBER,
        cast(COSTCENTER as VARCHAR(50)) as COSTCENTER,
        cast(INTERNALORDER as VARCHAR(9)) as INTERNALORDER,
        cast(INVOICEDATE as DATE) as INVOICEDATE,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LINETYPECATERY_LCAT as NUMBER(38,0)) as LINETYPECATERY_LCAT,
        cast(LINETYPECATERY_LTYP as NUMBER(38,0)) as LINETYPECATERY_LTYP,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(OFFICEEXPORT as VARCHAR(6)) as OFFICEEXPORT,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(PONUMBER as VARCHAR(9)) as PONUMBER,
        cast(PORECEIVINGTYPE as VARCHAR(50)) as PORECEIVINGTYPE,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PRICEQUANTITYUOM as NUMBER(15,2)) as PRICEQUANTITYUOM,
        cast(PROCESSDATE as TIMESTAMP_NTZ(9)) as PROCESSDATE,
        cast(PROJECTEXPORT as VARCHAR(6)) as PROJECTEXPORT,
        cast(QUANTITY as NUMBER(15,2)) as QUANTITY,
        cast(SEGMENTEXPORT as VARCHAR(6)) as SEGMENTEXPORT,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SERIALNUMBER as VARCHAR(8)) as SERIALNUMBER,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(TARGETCOMPANY as NUMBER(38,0)) as TARGETCOMPANY,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(UNITOFMEASURE as VARCHAR(3)) as UNITOFMEASURE,
        cast(WBSELEMENT as VARCHAR(50)) as WBSELEMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data