/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS',
    unique_key = ['CURRENCY',
    'EFFECTIVEDATE',
    'ITEM',
    'MINIMUMQUANTITY',
    'PRICEBOOK',
    'PRICEBOOKORIGINID']
) }}


with source_data as 
(
    SELECT   
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,CAST(T$BAPR AS NUMERIC(15,2))                                                                                                           AS BASEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CURN)),'')                                                                                             AS CURRENCY 
            ,T$DFPB.CONSTANTDESCRIPTION                                                                                                              AS DEFAULTPRICEBOOKDESCRIPTION 
            ,CAST(T$DFPB AS INT)                                                                                                                     AS DEFAULTPRICEBOOKID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSSC)),'')                                                                                             AS DISCOUNTSCHEDULE 
            ,T$DSOR.CONSTANTDESCRIPTION                                                                                                              AS DISCOUNTSCHEDULEORIGINDESCRIPTION 
            ,CAST(T$DSOR AS INT)                                                                                                                     AS DISCOUNTSCHEDULEORIGINID 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT  END AS DATETIME)     AS EFFECTIVEDATE 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME)     AS ENTRYDATE_percent_TIME 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT  END AS DATETIME)     AS EXPIRATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,CAST(CASE WHEN "T$LUPD$U"<= '1/1/1970' THEN NULL ELSE "T$LUPD$U"  END AS DATETIME) AS LASTCHANGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LUSR$U")),'')                                                                                           AS LOGINCODE 
            ,CAST(T$MIQT AS NUMERIC(15,2))                                                                                                           AS MINIMUMQUANTITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRBK)),'')                                                                                             AS PRICEBOOK 
            ,T$PBOR.CONSTANTDESCRIPTION                                                                                                              AS PRICEBOOKORIGINDESCRIPTION 
            ,CAST(T$PBOR AS INT)                                                                                                                     AS PRICEBOOKORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRUN)),'')                                                                                             AS PRICEUNIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$QTUN)),'')                                                                                             AS QUANTITYUNITS 
            ,T$QUON.CONSTANTDESCRIPTION                                                                                                              AS QUOTATIONSONLYDESCRIPTION 
            ,CAST(T$QUON AS INT)                                                                                                                     AS QUOTATIONSONLYID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPCG031201") }} AS SOURCETABLE  
            /*DEFAULTPRICEBOOK*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DFPB 
             ON   T$DFPB.TABLENAME  = 'TDPCG031' 
              AND T$DFPB.COLUMNNAME = 'T$DFPB' 
              AND T$DFPB.CONSTANT   = SOURCETABLE.T$DFPB 
            /*DISCOUNTSCHEDULEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DSOR 
             ON   T$DSOR.TABLENAME  = 'TDPCG031' 
              AND T$DSOR.COLUMNNAME = 'T$DSOR' 
              AND T$DSOR.CONSTANT   = SOURCETABLE.T$DSOR 
            /*PRICEBOOKORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PBOR 
             ON   T$PBOR.TABLENAME  = 'TDPCG031' 
              AND T$PBOR.COLUMNNAME = 'T$PBOR' 
              AND T$PBOR.CONSTANT   = SOURCETABLE.T$PBOR 
            /*QUOTATIONSONLY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$QUON 
             ON   T$QUON.TABLENAME  = 'TDPCG031' 
              AND T$QUON.COLUMNNAME = 'T$QUON' 
              AND T$QUON.CONSTANT   = SOURCETABLE.T$QUON 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BASEPRICE AS BASEPRICE, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DEFAULTPRICEBOOKDESCRIPTION AS DEFAULTPRICEBOOKDESCRIPTION, 
        source_data.DEFAULTPRICEBOOKID AS DEFAULTPRICEBOOKID, 
        source_data.DISCOUNTSCHEDULE AS DISCOUNTSCHEDULE, 
        source_data.DISCOUNTSCHEDULEORIGINDESCRIPTION AS DISCOUNTSCHEDULEORIGINDESCRIPTION, 
        source_data.DISCOUNTSCHEDULEORIGINID AS DISCOUNTSCHEDULEORIGINID, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.ENTRYDATE_PERCENT_TIME AS ENTRYDATE_PERCENT_TIME, 
        source_data.EXPIRATIONDATE AS EXPIRATIONDATE, 
        source_data.ITEM AS ITEM, 
        source_data.LASTCHANGE AS LASTCHANGE, 
        source_data.LOGINCODE AS LOGINCODE, 
        source_data.MINIMUMQUANTITY AS MINIMUMQUANTITY, 
        source_data.PRICEBOOK AS PRICEBOOK, 
        source_data.PRICEBOOKORIGINDESCRIPTION AS PRICEBOOKORIGINDESCRIPTION, 
        source_data.PRICEBOOKORIGINID AS PRICEBOOKORIGINID, 
        source_data.PRICEUNIT AS PRICEUNIT, 
        source_data.QUANTITYUNITS AS QUANTITYUNITS, 
        source_data.QUOTATIONSONLYDESCRIPTION AS QUOTATIONSONLYDESCRIPTION, 
        source_data.QUOTATIONSONLYID AS QUOTATIONSONLYID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BASEPRICE as NUMBER(15,2)) as BASEPRICE,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DEFAULTPRICEBOOKDESCRIPTION as VARCHAR(16777216)) as DEFAULTPRICEBOOKDESCRIPTION,
        cast(DEFAULTPRICEBOOKID as NUMBER(38,0)) as DEFAULTPRICEBOOKID,
        cast(DISCOUNTSCHEDULE as VARCHAR(6)) as DISCOUNTSCHEDULE,
        cast(DISCOUNTSCHEDULEORIGINDESCRIPTION as VARCHAR(16777216)) as DISCOUNTSCHEDULEORIGINDESCRIPTION,
        cast(DISCOUNTSCHEDULEORIGINID as NUMBER(38,0)) as DISCOUNTSCHEDULEORIGINID,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(ENTRYDATE_PERCENT_TIME as TIMESTAMP_NTZ(9)) as ENTRYDATE_PERCENT_TIME,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTCHANGE as TIMESTAMP_NTZ(9)) as LASTCHANGE,
        cast(LOGINCODE as VARCHAR(16)) as LOGINCODE,
        cast(MINIMUMQUANTITY as NUMBER(15,2)) as MINIMUMQUANTITY,
        cast(PRICEBOOK as VARCHAR(6)) as PRICEBOOK,
        cast(PRICEBOOKORIGINDESCRIPTION as VARCHAR(16777216)) as PRICEBOOKORIGINDESCRIPTION,
        cast(PRICEBOOKORIGINID as NUMBER(38,0)) as PRICEBOOKORIGINID,
        cast(PRICEUNIT as VARCHAR(3)) as PRICEUNIT,
        cast(QUANTITYUNITS as VARCHAR(3)) as QUANTITYUNITS,
        cast(QUOTATIONSONLYDESCRIPTION as VARCHAR(16777216)) as QUOTATIONSONLYDESCRIPTION,
        cast(QUOTATIONSONLYID as NUMBER(38,0)) as QUOTATIONSONLYID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data