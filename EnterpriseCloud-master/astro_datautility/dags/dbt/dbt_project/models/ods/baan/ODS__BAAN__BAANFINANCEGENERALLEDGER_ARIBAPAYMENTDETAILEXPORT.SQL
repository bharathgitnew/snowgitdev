/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT 
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
    alias='BAANFINANCEGENERALLEDGER_ARIBAPAYMENTDETAILEXPORT',
    unique_key = ['PAYMENTID',
    'POSITION',
    'SEQUENCENUMBER']
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
            ,CAST(T$COMP AS INT)                                                                                                                 AS COMPANY 
            ,CAST(T$CFAC AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCEN)),'')                                                                                         AS COSTCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DBCR)),'')                                                                                         AS DRCR 
            ,T$LEVL.CONSTANTDESCRIPTION                                                                                                          AS HEADERLINELEVELDESCRIPTION 
            ,CAST(T$LEVL AS INT)                                                                                                                 AS HEADERLINELEVELID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS INTERNALORDER 
            ,T$ISCO.CONSTANTDESCRIPTION                                                                                                          AS ISCOMPOSITEDESCRIPTION 
            ,CAST(T$ISCO AS INT)                                                                                                                 AS ISCOMPOSITEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$CATE AS INT)                                                                                                                 AS LINETYPECATERY_CATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPECATERY_LTYP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MAST)),'')                                                                                         AS MASTERAGREEMENTNAME 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION_COLL 
            ,CAST(T$FLAG AS INT)                                                                                                                 AS NUMBERINCOLLECTION_FLAG 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PNUM)),'')                                                                                         AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORUN)),'')                                                                                         AS ORDER_UNIQUENAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PBAN AS NUMERIC(15,2))                                                                                                       AS PRICEBASISQUANTITY 
            ,CAST(T$PQAN AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITY 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(T$POSI AS BIGINT)                                                                                                              AS PURCHASEORDERPOS 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTO 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$TCOM AS INT)                                                                                                                 AS TARGETCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXE)),'')                                                                                         AS TAXACCCOUNTKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ELEM)),'')                                                                                         AS WBSELEMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD716200") }} AS SOURCETABLE  
            /*HEADERLINELEVEL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LEVL 
             ON   T$LEVL.TABLENAME  = 'TFGLD716' 
              AND T$LEVL.COLUMNNAME = 'T$LEVL' 
              AND T$LEVL.CONSTANT   = SOURCETABLE.T$LEVL 
            /*ISCOMPOSITE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISCO 
             ON   T$ISCO.TABLENAME  = 'TFGLD716' 
              AND T$ISCO.COLUMNNAME = 'T$ISCO' 
              AND T$ISCO.CONSTANT   = SOURCETABLE.T$ISCO 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD716' 
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
            ,CAST(T$COMP AS INT)                                                                                                                 AS COMPANY 
            ,CAST(T$CFAC AS NUMERIC(15,2))                                                                                                       AS CONVERSIONFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCEN)),'')                                                                                         AS COSTCENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM2)),'')                                                                                         AS DIMENSION2 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM3)),'')                                                                                         AS DIMENSION3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM4)),'')                                                                                         AS DIMENSION4 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIM5)),'')                                                                                         AS DIMENSION5 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DBCR)),'')                                                                                         AS DRCR 
            ,T$LEVL.CONSTANTDESCRIPTION                                                                                                          AS HEADERLINELEVELDESCRIPTION 
            ,CAST(T$LEVL AS INT)                                                                                                                 AS HEADERLINELEVELID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS INTERNALORDER 
            ,T$ISCO.CONSTANTDESCRIPTION                                                                                                          AS ISCOMPOSITEDESCRIPTION 
            ,CAST(T$ISCO AS INT)                                                                                                                 AS ISCOMPOSITEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITXT)),'')                                                                                         AS ITEMTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LEAC)),'')                                                                                         AS LEDGERACCOUNT 
            ,CAST(T$CATE AS INT)                                                                                                                 AS LINETYPECATERY_CATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LTYP)),'')                                                                                         AS LINETYPECATERY_LTYP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MAST)),'')                                                                                         AS MASTERAGREEMENTNAME 
            ,CAST(T$COLL AS INT)                                                                                                                 AS NUMBERINCOLLECTION_COLL 
            ,CAST(T$FLAG AS INT)                                                                                                                 AS NUMBERINCOLLECTION_FLAG 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PNUM)),'')                                                                                         AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORUN)),'')                                                                                         AS ORDER_UNIQUENAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMID)),'')                                                                                         AS PAYMENTID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$PBAN AS NUMERIC(15,2))                                                                                                       AS PRICEBASISQUANTITY 
            ,CAST(T$PQAN AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITY 
            ,CAST(T$PQUM AS NUMERIC(15,2))                                                                                                       AS PRICEQUANTITYUOM 
            ,CAST(CASE WHEN T$PDAT<= '1/1/1970' THEN NULL ELSE T$PDAT  END AS DATETIME) AS PROCESSDATE 
            ,CAST(T$POSI AS BIGINT)                                                                                                              AS PURCHASEORDERPOS 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTO 
            ,T$STUS.CONSTANTDESCRIPTION                                                                                                          AS STATUSDESCRIPTION 
            ,CAST(T$STUS AS INT)                                                                                                                 AS STATUSID 
            ,CAST(T$TCOM AS INT)                                                                                                                 AS TARGETCOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TAXE)),'')                                                                                         AS TAXACCCOUNTKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ELEM)),'')                                                                                         AS WBSELEMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD716201") }} AS SOURCETABLE  
            /*HEADERLINELEVEL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LEVL 
             ON   T$LEVL.TABLENAME  = 'TFGLD716' 
              AND T$LEVL.COLUMNNAME = 'T$LEVL' 
              AND T$LEVL.CONSTANT   = SOURCETABLE.T$LEVL 
            /*ISCOMPOSITE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ISCO 
             ON   T$ISCO.TABLENAME  = 'TFGLD716' 
              AND T$ISCO.COLUMNNAME = 'T$ISCO' 
              AND T$ISCO.CONSTANT   = SOURCETABLE.T$ISCO 
            /*STATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STUS 
             ON   T$STUS.TABLENAME  = 'TFGLD716' 
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
        source_data.COMPANY AS COMPANY, 
        source_data.CONVERSIONFACTOR AS CONVERSIONFACTOR, 
        source_data.COSTCENTER AS COSTCENTER, 
        source_data.DIMENSION2 AS DIMENSION2, 
        source_data.DIMENSION3 AS DIMENSION3, 
        source_data.DIMENSION4 AS DIMENSION4, 
        source_data.DIMENSION5 AS DIMENSION5, 
        source_data.DRCR AS DRCR, 
        source_data.HEADERLINELEVELDESCRIPTION AS HEADERLINELEVELDESCRIPTION, 
        source_data.HEADERLINELEVELID AS HEADERLINELEVELID, 
        source_data.INTERNALORDER AS INTERNALORDER, 
        source_data.ISCOMPOSITEDESCRIPTION AS ISCOMPOSITEDESCRIPTION, 
        source_data.ISCOMPOSITEID AS ISCOMPOSITEID, 
        source_data.ITEMTEXT AS ITEMTEXT, 
        source_data.LEDGERACCOUNT AS LEDGERACCOUNT, 
        source_data.LINETYPECATERY_CATE AS LINETYPECATERY_CATE, 
        source_data.LINETYPECATERY_LTYP AS LINETYPECATERY_LTYP, 
        source_data.MASTERAGREEMENTNAME AS MASTERAGREEMENTNAME, 
        source_data.NUMBERINCOLLECTION_COLL AS NUMBERINCOLLECTION_COLL, 
        source_data.NUMBERINCOLLECTION_FLAG AS NUMBERINCOLLECTION_FLAG, 
        source_data.ORDER_ AS ORDER_, 
        source_data.ORDER_UNIQUENAME AS ORDER_UNIQUENAME, 
        source_data.PAYMENTID AS PAYMENTID, 
        source_data.POSITION AS POSITION, 
        source_data.PRICEBASISQUANTITY AS PRICEBASISQUANTITY, 
        source_data.PRICEQUANTITY AS PRICEQUANTITY, 
        source_data.PRICEQUANTITYUOM AS PRICEQUANTITYUOM, 
        source_data.PROCESSDATE AS PROCESSDATE, 
        source_data.PURCHASEORDERPOS AS PURCHASEORDERPOS, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.SHIPTO AS SHIPTO, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.TARGETCOMPANY AS TARGETCOMPANY, 
        source_data.TAXACCCOUNTKEY AS TAXACCCOUNTKEY, 
        source_data.TAXCODE AS TAXCODE, 
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
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(CONVERSIONFACTOR as NUMBER(15,2)) as CONVERSIONFACTOR,
        cast(COSTCENTER as VARCHAR(50)) as COSTCENTER,
        cast(DIMENSION2 as VARCHAR(6)) as DIMENSION2,
        cast(DIMENSION3 as VARCHAR(6)) as DIMENSION3,
        cast(DIMENSION4 as VARCHAR(6)) as DIMENSION4,
        cast(DIMENSION5 as VARCHAR(6)) as DIMENSION5,
        cast(DRCR as VARCHAR(10)) as DRCR,
        cast(HEADERLINELEVELDESCRIPTION as VARCHAR(16777216)) as HEADERLINELEVELDESCRIPTION,
        cast(HEADERLINELEVELID as NUMBER(38,0)) as HEADERLINELEVELID,
        cast(INTERNALORDER as VARCHAR(9)) as INTERNALORDER,
        cast(ISCOMPOSITEDESCRIPTION as VARCHAR(16777216)) as ISCOMPOSITEDESCRIPTION,
        cast(ISCOMPOSITEID as NUMBER(38,0)) as ISCOMPOSITEID,
        cast(ITEMTEXT as VARCHAR(999)) as ITEMTEXT,
        cast(LEDGERACCOUNT as VARCHAR(12)) as LEDGERACCOUNT,
        cast(LINETYPECATERY_CATE as NUMBER(38,0)) as LINETYPECATERY_CATE,
        cast(LINETYPECATERY_LTYP as VARCHAR(50)) as LINETYPECATERY_LTYP,
        cast(MASTERAGREEMENTNAME as VARCHAR(10)) as MASTERAGREEMENTNAME,
        cast(NUMBERINCOLLECTION_COLL as NUMBER(38,0)) as NUMBERINCOLLECTION_COLL,
        cast(NUMBERINCOLLECTION_FLAG as NUMBER(38,0)) as NUMBERINCOLLECTION_FLAG,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(ORDER_UNIQUENAME as VARCHAR(50)) as ORDER_UNIQUENAME,
        cast(PAYMENTID as VARCHAR(50)) as PAYMENTID,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(PRICEBASISQUANTITY as NUMBER(15,2)) as PRICEBASISQUANTITY,
        cast(PRICEQUANTITY as NUMBER(15,2)) as PRICEQUANTITY,
        cast(PRICEQUANTITYUOM as NUMBER(15,2)) as PRICEQUANTITYUOM,
        cast(PROCESSDATE as TIMESTAMP_NTZ(9)) as PROCESSDATE,
        cast(PURCHASEORDERPOS as NUMBER(38,0)) as PURCHASEORDERPOS,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(SHIPTO as VARCHAR(50)) as SHIPTO,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(TARGETCOMPANY as NUMBER(38,0)) as TARGETCOMPANY,
        cast(TAXACCCOUNTKEY as VARCHAR(50)) as TAXACCCOUNTKEY,
        cast(TAXCODE as VARCHAR(9)) as TAXCODE,
        cast(WBSELEMENT as VARCHAR(50)) as WBSELEMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data