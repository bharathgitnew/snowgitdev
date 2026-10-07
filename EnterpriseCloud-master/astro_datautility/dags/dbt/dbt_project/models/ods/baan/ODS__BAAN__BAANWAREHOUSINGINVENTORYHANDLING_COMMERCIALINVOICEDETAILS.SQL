/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS 
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
    alias='BAANWAREHOUSINGINVENTORYHANDLING_COMMERCIALINVOICEDETAILS',
    unique_key = ['COMMERCIALINVOICE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$APPR)),'')                                                                                             AS AESAPPROVEDBY 
            ,CAST(CASE WHEN T$APDT<= '1/1/1970' THEN NULL ELSE T$APDT  END AS DATETIME)     AS AESAPPROVEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AESC)),'')                                                                                             AS AESCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AESP)),'')                                                                                             AS AESPARAMETER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AEST)),'')                                                                                             AS AESSTATEMENT 
            ,T$ATCI.CONSTANTDESCRIPTION                                                                                                              AS ATCIDESCRIPTION 
            ,CAST(T$ATCI AS INT)                                                                                                                     AS ATCIID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REF4)),'')                                                                                             AS CIREFERENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COIN)),'')                                                                                             AS COMMERCIALINVOICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CNTT)),'')                                                                                             AS CONTACTINFO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTDT)),'')                                                                                             AS COUNTRYOFDESTINATION 
            ,CAST(CASE WHEN T$CDAT<= '1/1/1970' THEN NULL ELSE T$CDAT END AS DATE)                                                                 AS CREATEDATE 
            ,CAST(CASE WHEN T$CDTE<= '1/1/1970' THEN NULL ELSE T$CDTE  END AS DATETIME)     AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAC)),'')                                                                                             AS CUSTOMERCARRIERACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CORN)),'')                                                                                             AS CUSTOMERORDERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                             AS CUSTOMERORDERPO 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DEPT)),'')                                                                                             AS DEPARTMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DCST)),'')                                                                                             AS DESTCONTROLSTATEMENTCODE 
            ,CAST(CASE WHEN T$ETAD<= '1/1/1970' THEN NULL ELSE T$ETAD END AS DATE)                                                                 AS ETA 
            ,CAST(CASE WHEN T$ETDD<= '1/1/1970' THEN NULL ELSE T$ETDD END AS DATE)                                                                 AS ETD 
            ,"T$EXPT$U".CONSTANTDESCRIPTION                                                                                                            AS EXPORTDESCRIPTION 
            ,CAST("T$EXPT$U" AS INT)                                                                                                                   AS EXPORTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ELCT)),'')                                                                                             AS EXPORTLICENSECATERY 
            ,CAST(CASE WHEN T$FIDT<= '1/1/1970' THEN NULL ELSE T$FIDT END AS DATE)                                                                 AS FINALIZATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FLNO)),'')                                                                                             AS FLIGHTNO 
            ,T$FRTM.CONSTANTDESCRIPTION                                                                                                              AS FREIGHTTERMSDESCRIPTION 
            ,CAST(T$FRTM AS INT)                                                                                                                     AS FREIGHTTERMSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HAWB)),'')                                                                                             AS HOUSEAIRWAYBILL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LICN)),'')                                                                                             AS LICENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MAWB)),'')                                                                                             AS MASTERAIRWAYBILL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MESS)),'')                                                                                             AS MESSAGE 
            ,T$MODE.CONSTANTDESCRIPTION                                                                                                              AS MODEDESCRIPTION 
            ,CAST(T$MODE AS INT)                                                                                                                     AS MODEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                             AS ORDER_ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PDEL)),'')                                                                                             AS PORTOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PEXP)),'')                                                                                             AS PORTOFEXPORT 
            ,CAST(CASE WHEN "T$PRDT$U"<= '1/1/1970' THEN NULL ELSE "T$PRDT$U"  END AS DATETIME) AS PRDTU 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REMK)),'')                                                                                             AS REMARKS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RECC)),'')                                                                                             AS REVISEDECCN 
            ,CAST(T$RQTY AS NUMERIC(15,2))                                                                                                           AS REVISEDQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SHPM)),'')                                                                                             AS SHIPMENTIDENTIFICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                             AS SHIPTOBP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'')                                                                                             AS SHIPVIACARRIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                             AS SOLDTOBP 
            ,"T$STAT$U".CONSTANTDESCRIPTION                                                                                                            AS STATUSDESCRIPTION 
            ,CAST("T$STAT$U" AS INT)                                                                                                                   AS STATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELP)),'')                                                                                             AS TELP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                             AS TERMSOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                             AS TERMSOFPAYMENT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$UNIQ)),'')                                                                                             AS UNIQUEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACCT)),'')                                                                                             AS UPSACCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SWAR)),'')                                                                                             AS UPSWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH914201") }} AS SOURCETABLE  
            /*ATCI*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ATCI 
             ON   T$ATCI.TABLENAME  = 'WHINH914' 
              AND T$ATCI.COLUMNNAME = 'T$ATCI' 
              AND T$ATCI.CONSTANT   = SOURCETABLE.T$ATCI 
            /*EXPORTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EXPT$U" 
             ON   "T$EXPT$U".TABLENAME  = 'WHINH914' 
              AND "T$EXPT$U".COLUMNNAME = 'T$EXPT.U' 
              AND "T$EXPT$U".CONSTANT   = SOURCETABLE."T$EXPT$U" 
            /*FREIGHTTERMS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FRTM 
             ON   T$FRTM.TABLENAME  = 'WHINH914' 
              AND T$FRTM.COLUMNNAME = 'T$FRTM' 
              AND T$FRTM.CONSTANT   = SOURCETABLE.T$FRTM 
            /*MODE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MODE 
             ON   T$MODE.TABLENAME  = 'WHINH914' 
              AND T$MODE.COLUMNNAME = 'T$MODE' 
              AND T$MODE.CONSTANT   = SOURCETABLE.T$MODE 
            /*STATUSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$STAT$U" 
             ON   "T$STAT$U".TABLENAME  = 'WHINH914' 
              AND "T$STAT$U".COLUMNNAME = 'T$STAT.U' 
              AND "T$STAT$U".CONSTANT   = SOURCETABLE."T$STAT$U" 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AESAPPROVEDBY AS AESAPPROVEDBY, 
        source_data.AESAPPROVEDDATE AS AESAPPROVEDDATE, 
        source_data.AESCODE AS AESCODE, 
        source_data.AESPARAMETER AS AESPARAMETER, 
        source_data.AESSTATEMENT AS AESSTATEMENT, 
        source_data.ATCIDESCRIPTION AS ATCIDESCRIPTION, 
        source_data.ATCIID AS ATCIID, 
        source_data.CIREFERENCE AS CIREFERENCE, 
        source_data.COMMERCIALINVOICE AS COMMERCIALINVOICE, 
        source_data.CONTACTINFO AS CONTACTINFO, 
        source_data.COUNTRYOFDESTINATION AS COUNTRYOFDESTINATION, 
        source_data.CREATEDATE AS CREATEDATE, 
        source_data.CREATIONDATE AS CREATIONDATE, 
        source_data.CUSTOMERCARRIERACCOUNT AS CUSTOMERCARRIERACCOUNT, 
        source_data.CUSTOMERORDERNUMBER AS CUSTOMERORDERNUMBER, 
        source_data.CUSTOMERORDERPO AS CUSTOMERORDERPO, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.DESTCONTROLSTATEMENTCODE AS DESTCONTROLSTATEMENTCODE, 
        source_data.ETA AS ETA, 
        source_data.ETD AS ETD, 
        source_data.EXPORTDESCRIPTION AS EXPORTDESCRIPTION, 
        source_data.EXPORTID AS EXPORTID, 
        source_data.EXPORTLICENSECATERY AS EXPORTLICENSECATERY, 
        source_data.FINALIZATIONDATE AS FINALIZATIONDATE, 
        source_data.FLIGHTNO AS FLIGHTNO, 
        source_data.FREIGHTTERMSDESCRIPTION AS FREIGHTTERMSDESCRIPTION, 
        source_data.FREIGHTTERMSID AS FREIGHTTERMSID, 
        source_data.HOUSEAIRWAYBILL AS HOUSEAIRWAYBILL, 
        source_data.LICENCE AS LICENCE, 
        source_data.MASTERAIRWAYBILL AS MASTERAIRWAYBILL, 
        source_data.MESSAGE AS MESSAGE, 
        source_data.MODEDESCRIPTION AS MODEDESCRIPTION, 
        source_data.MODEID AS MODEID, 
        source_data.ORDER_ AS ORDER_, 
        source_data.PORTOFDELIVERY AS PORTOFDELIVERY, 
        source_data.PORTOFEXPORT AS PORTOFEXPORT, 
        source_data.PRDTU AS PRDTU, 
        source_data.REMARKS AS REMARKS, 
        source_data.REVISEDECCN AS REVISEDECCN, 
        source_data.REVISEDQUANTITY AS REVISEDQUANTITY, 
        source_data.SHIPMENTIDENTIFICATION AS SHIPMENTIDENTIFICATION, 
        source_data.SHIPTOBP AS SHIPTOBP, 
        source_data.SHIPVIACARRIER AS SHIPVIACARRIER, 
        source_data.SOLDTOBP AS SOLDTOBP, 
        source_data.STATUSDESCRIPTION AS STATUSDESCRIPTION, 
        source_data.STATUSID AS STATUSID, 
        source_data.TELP AS TELP, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TEXT AS TEXT, 
        source_data.UNIQUEID AS UNIQUEID, 
        source_data.UPSACCOUNT AS UPSACCOUNT, 
        source_data.UPSWAREHOUSE AS UPSWAREHOUSE, 
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
        cast(AESAPPROVEDBY as VARCHAR(16)) as AESAPPROVEDBY,
        cast(AESAPPROVEDDATE as TIMESTAMP_NTZ(9)) as AESAPPROVEDDATE,
        cast(AESCODE as VARCHAR(3)) as AESCODE,
        cast(AESPARAMETER as VARCHAR(20)) as AESPARAMETER,
        cast(AESSTATEMENT as VARCHAR(50)) as AESSTATEMENT,
        cast(ATCIDESCRIPTION as VARCHAR(16777216)) as ATCIDESCRIPTION,
        cast(ATCIID as NUMBER(38,0)) as ATCIID,
        cast(CIREFERENCE as VARCHAR(80)) as CIREFERENCE,
        cast(COMMERCIALINVOICE as VARCHAR(10)) as COMMERCIALINVOICE,
        cast(CONTACTINFO as VARCHAR(15)) as CONTACTINFO,
        cast(COUNTRYOFDESTINATION as VARCHAR(2)) as COUNTRYOFDESTINATION,
        cast(CREATEDATE as DATE) as CREATEDATE,
        cast(CREATIONDATE as TIMESTAMP_NTZ(9)) as CREATIONDATE,
        cast(CUSTOMERCARRIERACCOUNT as VARCHAR(15)) as CUSTOMERCARRIERACCOUNT,
        cast(CUSTOMERORDERNUMBER as VARCHAR(30)) as CUSTOMERORDERNUMBER,
        cast(CUSTOMERORDERPO as VARCHAR(30)) as CUSTOMERORDERPO,
        cast(DEPARTMENT as VARCHAR(15)) as DEPARTMENT,
        cast(DESTCONTROLSTATEMENTCODE as VARCHAR(3)) as DESTCONTROLSTATEMENTCODE,
        cast(ETA as DATE) as ETA,
        cast(ETD as DATE) as ETD,
        cast(EXPORTDESCRIPTION as VARCHAR(16777216)) as EXPORTDESCRIPTION,
        cast(EXPORTID as NUMBER(38,0)) as EXPORTID,
        cast(EXPORTLICENSECATERY as VARCHAR(15)) as EXPORTLICENSECATERY,
        cast(FINALIZATIONDATE as DATE) as FINALIZATIONDATE,
        cast(FLIGHTNO as VARCHAR(10)) as FLIGHTNO,
        cast(FREIGHTTERMSDESCRIPTION as VARCHAR(16777216)) as FREIGHTTERMSDESCRIPTION,
        cast(FREIGHTTERMSID as NUMBER(38,0)) as FREIGHTTERMSID,
        cast(HOUSEAIRWAYBILL as VARCHAR(15)) as HOUSEAIRWAYBILL,
        cast(LICENCE as VARCHAR(15)) as LICENCE,
        cast(MASTERAIRWAYBILL as VARCHAR(15)) as MASTERAIRWAYBILL,
        cast(MESSAGE as VARCHAR(215)) as MESSAGE,
        cast(MODEDESCRIPTION as VARCHAR(16777216)) as MODEDESCRIPTION,
        cast(MODEID as NUMBER(38,0)) as MODEID,
        cast(ORDER_ as VARCHAR(9)) as ORDER_,
        cast(PORTOFDELIVERY as VARCHAR(15)) as PORTOFDELIVERY,
        cast(PORTOFEXPORT as VARCHAR(15)) as PORTOFEXPORT,
        cast(PRDTU as TIMESTAMP_NTZ(9)) as PRDTU,
        cast(REMARKS as VARCHAR(150)) as REMARKS,
        cast(REVISEDECCN as VARCHAR(10)) as REVISEDECCN,
        cast(REVISEDQUANTITY as NUMBER(15,2)) as REVISEDQUANTITY,
        cast(SHIPMENTIDENTIFICATION as VARCHAR(9)) as SHIPMENTIDENTIFICATION,
        cast(SHIPTOBP as VARCHAR(9)) as SHIPTOBP,
        cast(SHIPVIACARRIER as VARCHAR(3)) as SHIPVIACARRIER,
        cast(SOLDTOBP as VARCHAR(9)) as SOLDTOBP,
        cast(STATUSDESCRIPTION as VARCHAR(16777216)) as STATUSDESCRIPTION,
        cast(STATUSID as NUMBER(38,0)) as STATUSID,
        cast(TELP as VARCHAR(15)) as TELP,
        cast(TERMSOFDELIVERY as VARCHAR(3)) as TERMSOFDELIVERY,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(UNIQUEID as VARCHAR(40)) as UNIQUEID,
        cast(UPSACCOUNT as VARCHAR(10)) as UPSACCOUNT,
        cast(UPSWAREHOUSE as VARCHAR(6)) as UPSWAREHOUSE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data