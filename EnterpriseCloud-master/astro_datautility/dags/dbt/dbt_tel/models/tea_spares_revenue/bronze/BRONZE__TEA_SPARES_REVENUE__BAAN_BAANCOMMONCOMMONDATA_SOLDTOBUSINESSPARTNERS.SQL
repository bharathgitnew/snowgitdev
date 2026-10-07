/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS',
    unique_key = ['SOLDTOBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,T$ACKX.CONSTANTDESCRIPTION                                                                                                          AS ACKNOWLEDGEBYEXCEPTIONDESCRIPTION 
            ,CAST(T$ACKX AS INT)                                                                                                                 AS ACKNOWLEDGEBYEXCEPTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREG)),'')                                                                                         AS AREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPR)),'')                                                                                         AS BUSINESSPARTNERFORPRICESDISCOUNTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPUS)),'')                                                                                         AS BUSINESSPARTNERFORSTATISTICSUPDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBPS)),'')                                                                                         AS BUSINESSPARTNERSIGNAL 
            ,T$BPST.CONSTANTDESCRIPTION                                                                                                          AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$BPST AS INT)                                                                                                                 AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'')                                                                                         AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHAN)),'')                                                                                         AS CHANNEL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACTCODE 
            ,CAST(T$PRIO AS TINYINT)                                                                                                             AS CUSTOMERPRIORITY 
            ,T$CHAK.CONSTANTDESCRIPTION                                                                                                          AS EDIORDERCHANGERESPONSEDESCRIPTION 
            ,CAST(T$CHAK AS INT)                                                                                                                 AS EDIORDERCHANGERESPONSEID 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSRP)),'')                                                                                         AS EXTERNALSALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CREP)),'')                                                                                         AS INTERNALSALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLGR)),'')                                                                                         AS LISTGROUP 
            ,CAST(T$LMSP AS NUMERIC(15,2))                                                                                                       AS LOWERMARGIN 
            ,CAST(T$ODIS AS NUMERIC(15,2))                                                                                                       AS ORDER_DISCOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OSNO)),'')                                                                                         AS OURSUPPLIERNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLDD)),'')                                                                                         AS PRICELISTFORDIRECTDELIVERY 
            ,CAST(T$CSPR AS TINYINT)                                                                                                             AS PRIORITY 
            ,T$MCFR.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATORDESCRIPTION 
            ,CAST(T$MCFR AS INT)                                                                                                                 AS RATEDETERMINATORID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTC)),'')                                                                                         AS RESPONSETIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RDEC)),'')                                                                                         AS RETURNTERMSOFDELIVERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS SALESOFFICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SOTP)),'')                                                                                         AS SALESORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLS)),'')                                                                                         AS SALESPRICELIST 
            ,T$SCQQ.CONSTANTDESCRIPTION                                                                                                          AS SCHEDULEQUANTITYQUALIFIERDESCRIPTION 
            ,CAST(T$SCQQ AS INT)                                                                                                                 AS SCHEDULEQUANTITYQUALIFIERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS SHIPPINGCONSTRAINTDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS SHIPPINGCONSTRAINTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEC)),'')                                                                                         AS TERMSOFDELIVERY 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,CAST(T$UMSP AS NUMERIC(15,2))                                                                                                       AS UPPERMARGIN 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM110200") }} AS SOURCETABLE  
            /*ACKNOWLEDGEBYEXCEPTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACKX 
             ON   T$ACKX.TABLENAME  = 'TCCOM110' 
              AND T$ACKX.COLUMNNAME = 'T$ACKX' 
              AND T$ACKX.CONSTANT   = SOURCETABLE.T$ACKX 
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BPST 
             ON   T$BPST.TABLENAME  = 'TCCOM110' 
              AND T$BPST.COLUMNNAME = 'T$BPST' 
              AND T$BPST.CONSTANT   = SOURCETABLE.T$BPST 
            /*EDIORDERCHANGERESPONSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHAK 
             ON   T$CHAK.TABLENAME  = 'TCCOM110' 
              AND T$CHAK.COLUMNNAME = 'T$CHAK' 
              AND T$CHAK.CONSTANT   = SOURCETABLE.T$CHAK 
            /*RATEDETERMINATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MCFR 
             ON   T$MCFR.TABLENAME  = 'TCCOM110' 
              AND T$MCFR.COLUMNNAME = 'T$MCFR' 
              AND T$MCFR.CONSTANT   = SOURCETABLE.T$MCFR 
            /*SCHEDULEQUANTITYQUALIFIER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCQQ 
             ON   T$SCQQ.TABLENAME  = 'TCCOM110' 
              AND T$SCQQ.COLUMNNAME = 'T$SCQQ' 
              AND T$SCQQ.CONSTANT   = SOURCETABLE.T$SCQQ 
            /*SHIPPINGCONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TCCOM110' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACKNOWLEDGEBYEXCEPTIONDESCRIPTION AS ACKNOWLEDGEBYEXCEPTIONDESCRIPTION, 
        source_data.ACKNOWLEDGEBYEXCEPTIONID AS ACKNOWLEDGEBYEXCEPTIONID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.AREA AS AREA, 
        source_data.BUSINESSPARTNERFORPRICESDISCOUNTS AS BUSINESSPARTNERFORPRICESDISCOUNTS, 
        source_data.BUSINESSPARTNERFORSTATISTICSUPDATE AS BUSINESSPARTNERFORSTATISTICSUPDATE, 
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.CALENDAR AS CALENDAR, 
        source_data.CHANNEL AS CHANNEL, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CUSTOMERPRIORITY AS CUSTOMERPRIORITY, 
        source_data.EDIORDERCHANGERESPONSEDESCRIPTION AS EDIORDERCHANGERESPONSEDESCRIPTION, 
        source_data.EDIORDERCHANGERESPONSEID AS EDIORDERCHANGERESPONSEID, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.EXTERNALSALESREP AS EXTERNALSALESREP, 
        source_data.INTERNALSALESREP AS INTERNALSALESREP, 
        source_data.INVOICETOBUSINESSPARTNER AS INVOICETOBUSINESSPARTNER, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.LINEOFBUSINESS AS LINEOFBUSINESS, 
        source_data.LISTGROUP AS LISTGROUP, 
        source_data.LOWERMARGIN AS LOWERMARGIN, 
        source_data.ORDER_DISCOUNT AS ORDER_DISCOUNT, 
        source_data.OURSUPPLIERNUMBER AS OURSUPPLIERNUMBER, 
        source_data.PRICELISTFORDIRECTDELIVERY AS PRICELISTFORDIRECTDELIVERY, 
        source_data.PRIORITY AS PRIORITY, 
        source_data.RATEDETERMINATORDESCRIPTION AS RATEDETERMINATORDESCRIPTION, 
        source_data.RATEDETERMINATORID AS RATEDETERMINATORID, 
        source_data.RESPONSETIME AS RESPONSETIME, 
        source_data.RETURNTERMSOFDELIVERY AS RETURNTERMSOFDELIVERY, 
        source_data.SALESOFFICE AS SALESOFFICE, 
        source_data.SALESORDERTYPE AS SALESORDERTYPE, 
        source_data.SALESPRICELIST AS SALESPRICELIST, 
        source_data.SCHEDULEQUANTITYQUALIFIERDESCRIPTION AS SCHEDULEQUANTITYQUALIFIERDESCRIPTION, 
        source_data.SCHEDULEQUANTITYQUALIFIERID AS SCHEDULEQUANTITYQUALIFIERID, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.SHIPPINGCONSTRAINTDESCRIPTION AS SHIPPINGCONSTRAINTDESCRIPTION, 
        source_data.SHIPPINGCONSTRAINTID AS SHIPPINGCONSTRAINTID, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY, 
        source_data.TEXT AS TEXT, 
        source_data.UPPERMARGIN AS UPPERMARGIN
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        ACKNOWLEDGEBYEXCEPTIONDESCRIPTION,
        cast(ACKNOWLEDGEBYEXCEPTIONID as NUMBER(38,0)) as ACKNOWLEDGEBYEXCEPTIONID,
        ADDRESSCODE,
        AREA,
        BUSINESSPARTNERFORPRICESDISCOUNTS,
        BUSINESSPARTNERFORSTATISTICSUPDATE,
        BUSINESSPARTNERSIGNAL,
        BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        BUSINESSPARTNERTYPE,
        CALENDAR,
        CHANNEL,
        CONTACTCODE,
        cast(CUSTOMERPRIORITY as NUMBER(38,0)) as CUSTOMERPRIORITY,
        EDIORDERCHANGERESPONSEDESCRIPTION,
        cast(EDIORDERCHANGERESPONSEID as NUMBER(38,0)) as EDIORDERCHANGERESPONSEID,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        EXTERNALSALESREP,
        INTERNALSALESREP,
        INVOICETOBUSINESSPARTNER,
        LANGUAGE,
        LINEOFBUSINESS,
        LISTGROUP,
        cast(LOWERMARGIN as NUMBER(15,2)) as LOWERMARGIN,
        cast(ORDER_DISCOUNT as NUMBER(15,2)) as ORDER_DISCOUNT,
        OURSUPPLIERNUMBER,
        PRICELISTFORDIRECTDELIVERY,
        cast(PRIORITY as NUMBER(38,0)) as PRIORITY,
        RATEDETERMINATORDESCRIPTION,
        cast(RATEDETERMINATORID as NUMBER(38,0)) as RATEDETERMINATORID,
        RESPONSETIME,
        RETURNTERMSOFDELIVERY,
        SALESOFFICE,
        SALESORDERTYPE,
        SALESPRICELIST,
        SCHEDULEQUANTITYQUALIFIERDESCRIPTION,
        cast(SCHEDULEQUANTITYQUALIFIERID as NUMBER(38,0)) as SCHEDULEQUANTITYQUALIFIERID,
        SEARCHKEY,
        SHIPPINGCONSTRAINTDESCRIPTION,
        cast(SHIPPINGCONSTRAINTID as NUMBER(38,0)) as SHIPPINGCONSTRAINTID,
        SHIPTOBUSINESSPARTNER,
        SOLDTOBUSINESSPARTNER,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        TERMSOFDELIVERY,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(UPPERMARGIN as NUMBER(15,2)) as UPPERMARGIN
    from transform_data
    )
select * from type_data