/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS',
    unique_key = ['BUYFROMBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                         AS AREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPR)),'')                                                                                         AS BUSINESSPARTNERFORPRICESDISCOUNTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPUS)),'')                                                                                         AS BUSINESSPARTNERFORSTATISTICSUPDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBPS)),'')                                                                                         AS BUSINESSPARTNERSIGNAL 
            ,T$BPST.CONSTANTDESCRIPTION                                                                                                          AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$BPST AS INT)                                                                                                                 AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'')                                                                                         AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COMC$U")),'')                                                                                       AS COMMODITYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCON)),'')                                                                                         AS CONTACTPURCHASE 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFBP)),'')                                                                                         AS INVOICEFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOBC$U")),'')                                                                                       AS LINEOFBUSINESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLGR)),'')                                                                                         AS LISTGROUP 
            ,CAST(T$ODIS AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OCUS)),'')                                                                                         AS OURCUSTOMERNUMBER 
            ,T$ACKX.CONSTANTDESCRIPTION                                                                                                          AS PRINTPURCHASEORDERBYEXCEPTIONDESCRIPTION 
            ,CAST(T$ACKX AS INT)                                                                                                                 AS PRINTPURCHASEORDERBYEXCEPTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS PURCHASEOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POTP)),'')                                                                                         AS PURCHASEORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLP)),'')                                                                                         AS PURCHASEPRICELIST 
            ,T$MCFR.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATORDESCRIPTION 
            ,CAST(T$MCFR AS INT)                                                                                                                 AS RATEDETERMINATORID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RDEC)),'')                                                                                         AS RETURNTERMSOFDELIVERY 
            ,T$SCQQ.CONSTANTDESCRIPTION                                                                                                          AS SCHEDULEQUANTITYQUALIFIERDESCRIPTION 
            ,CAST(T$SCQQ AS INT)                                                                                                                 AS SCHEDULEQUANTITYQUALIFIERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SFBP)),'')                                                                                         AS SHIPFROMBUSINESSPARTNER 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SUBC$U")),'')                                                                                       AS SUBCOMMODITYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                         AS TERMSOFDELIVERY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,T$VRYN.CONSTANTDESCRIPTION                                                                                                          AS VENDORRATINGDESCRIPTION 
            ,CAST(T$VRYN AS INT)                                                                                                                 AS VENDORRATINGID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM120200") }} AS SOURCETABLE  
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BPST 
             ON   T$BPST.TABLENAME  = 'TCCOM120' 
              AND T$BPST.COLUMNNAME = 'T$BPST' 
              AND T$BPST.CONSTANT   = SOURCETABLE.T$BPST 
            /*PRINTPURCHASEORDERBYEXCEPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACKX 
             ON   T$ACKX.TABLENAME  = 'TCCOM120' 
              AND T$ACKX.COLUMNNAME = 'T$ACKX' 
              AND T$ACKX.CONSTANT   = SOURCETABLE.T$ACKX 
            /*RATEDETERMINATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MCFR 
             ON   T$MCFR.TABLENAME  = 'TCCOM120' 
              AND T$MCFR.COLUMNNAME = 'T$MCFR' 
              AND T$MCFR.CONSTANT   = SOURCETABLE.T$MCFR 
            /*SCHEDULEQUANTITYQUALIFIER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCQQ 
             ON   T$SCQQ.TABLENAME  = 'TCCOM120' 
              AND T$SCQQ.COLUMNNAME = 'T$SCQQ' 
              AND T$SCQQ.CONSTANT   = SOURCETABLE.T$SCQQ 
            /*VENDORRATING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VRYN 
             ON   T$VRYN.TABLENAME  = 'TCCOM120' 
              AND T$VRYN.COLUMNNAME = 'T$VRYN' 
              AND T$VRYN.CONSTANT   = SOURCETABLE.T$VRYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.AREA AS AREA, 
        source_data.BUSINESSPARTNERFORPRICESDISCOUNTS AS BUSINESSPARTNERFORPRICESDISCOUNTS, 
        source_data.BUSINESSPARTNERFORSTATISTICSUPDATE AS BUSINESSPARTNERFORSTATISTICSUPDATE, 
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.COMMODITYCODE AS COMMODITYCODE, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CONTACTPURCHASE AS CONTACTPURCHASE, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.INVOICEFROMBUSINESSPARTNER AS INVOICEFROMBUSINESSPARTNER, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.LINEOFBUSINESS AS LINEOFBUSINESS, 
        source_data.LINEOFBUSINESSCODE AS LINEOFBUSINESSCODE, 
        source_data.LISTGROUP AS LISTGROUP, 
        source_data.ORDER_DISCOUNT AS ORDER_DISCOUNT, 
        source_data.OURCUSTOMERNUMBER AS OURCUSTOMERNUMBER, 
        source_data.PRINTPURCHASEORDERBYEXCEPTIONDESCRIPTION AS PRINTPURCHASEORDERBYEXCEPTIONDESCRIPTION, 
        source_data.PRINTPURCHASEORDERBYEXCEPTIONID AS PRINTPURCHASEORDERBYEXCEPTIONID, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.PURCHASEORDERTYPE AS PURCHASEORDERTYPE, 
        source_data.PURCHASEPRICELIST AS PURCHASEPRICELIST, 
        source_data.RATEDETERMINATORDESCRIPTION AS RATEDETERMINATORDESCRIPTION, 
        source_data.RATEDETERMINATORID AS RATEDETERMINATORID, 
        source_data.RETURNTERMSOFDELIVERY AS RETURNTERMSOFDELIVERY, 
        source_data.SCHEDULEQUANTITYQUALIFIERDESCRIPTION AS SCHEDULEQUANTITYQUALIFIERDESCRIPTION, 
        source_data.SCHEDULEQUANTITYQUALIFIERID AS SCHEDULEQUANTITYQUALIFIERID, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.SHIPFROMBUSINESSPARTNER AS SHIPFROMBUSINESSPARTNER, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.SUBCOMMODITYCODE AS SUBCOMMODITYCODE, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY, 
        source_data.TEXT AS TEXT, 
        source_data.VENDORRATINGDESCRIPTION AS VENDORRATINGDESCRIPTION, 
        source_data.VENDORRATINGID AS VENDORRATINGID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
        cast(AREA as VARCHAR(3)) as AREA,
        cast(BUSINESSPARTNERFORPRICESDISCOUNTS as VARCHAR(9)) as BUSINESSPARTNERFORPRICESDISCOUNTS,
        cast(BUSINESSPARTNERFORSTATISTICSUPDATE as VARCHAR(9)) as BUSINESSPARTNERFORSTATISTICSUPDATE,
        cast(BUSINESSPARTNERSIGNAL as VARCHAR(3)) as BUSINESSPARTNERSIGNAL,
        cast(BUSINESSPARTNERSTATUSDESCRIPTION as VARCHAR(16777216)) as BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        cast(BUSINESSPARTNERTYPE as VARCHAR(3)) as BUSINESSPARTNERTYPE,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(COMMODITYCODE as VARCHAR(3)) as COMMODITYCODE,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(CONTACTPURCHASE as VARCHAR(6)) as CONTACTPURCHASE,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(INVOICEFROMBUSINESSPARTNER as VARCHAR(9)) as INVOICEFROMBUSINESSPARTNER,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(LINEOFBUSINESS as VARCHAR(6)) as LINEOFBUSINESS,
        cast(LINEOFBUSINESSCODE as VARCHAR(3)) as LINEOFBUSINESSCODE,
        cast(LISTGROUP as VARCHAR(3)) as LISTGROUP,
        cast(ORDER_DISCOUNT as NUMBER(15,2)) as ORDER_DISCOUNT,
        cast(OURCUSTOMERNUMBER as VARCHAR(15)) as OURCUSTOMERNUMBER,
        cast(PRINTPURCHASEORDERBYEXCEPTIONDESCRIPTION as VARCHAR(16777216)) as PRINTPURCHASEORDERBYEXCEPTIONDESCRIPTION,
        cast(PRINTPURCHASEORDERBYEXCEPTIONID as NUMBER(38,0)) as PRINTPURCHASEORDERBYEXCEPTIONID,
        cast(PURCHASEOFFICE as VARCHAR(6)) as PURCHASEOFFICE,
        cast(PURCHASEORDERTYPE as VARCHAR(3)) as PURCHASEORDERTYPE,
        cast(PURCHASEPRICELIST as VARCHAR(3)) as PURCHASEPRICELIST,
        cast(RATEDETERMINATORDESCRIPTION as VARCHAR(16777216)) as RATEDETERMINATORDESCRIPTION,
        cast(RATEDETERMINATORID as NUMBER(38,0)) as RATEDETERMINATORID,
        cast(RETURNTERMSOFDELIVERY as VARCHAR(3)) as RETURNTERMSOFDELIVERY,
        cast(SCHEDULEQUANTITYQUALIFIERDESCRIPTION as VARCHAR(16777216)) as SCHEDULEQUANTITYQUALIFIERDESCRIPTION,
        cast(SCHEDULEQUANTITYQUALIFIERID as NUMBER(38,0)) as SCHEDULEQUANTITYQUALIFIERID,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(SHIPFROMBUSINESSPARTNER as VARCHAR(9)) as SHIPFROMBUSINESSPARTNER,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(SUBCOMMODITYCODE as VARCHAR(3)) as SUBCOMMODITYCODE,
        cast(TERMSOFDELIVERY as VARCHAR(3)) as TERMSOFDELIVERY,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(VENDORRATINGDESCRIPTION as VARCHAR(16777216)) as VENDORRATINGDESCRIPTION,
        cast(VENDORRATINGID as NUMBER(38,0)) as VENDORRATINGID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data