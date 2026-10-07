/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES.SQL 
-materialized incremental
-alias BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES 
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
    alias='BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES',
    unique_key = ['MATRIXDEFINITION',
    'MATRIXLEVELID',
    'MATRIXTYPEID',
    'SEQUENCE']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AREA)),'')                                                                                         AS AREA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BFBP)),'')                                                                                         AS BUYFROMPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BFTY)),'')                                                                                         AS BUYFROMTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,T$DTRM.CONSTANTDESCRIPTION                                                                                                          AS DETERMININGDESCRIPTION 
            ,CAST(T$DTRM AS INT)                                                                                                                 AS DETERMININGID 
            ,CAST(T$DSAM AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCO)),'')                                                                                         AS DISCOUNTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSDL)),'')                                                                                         AS DISCOUNTDEAL 
            ,T$DSMT.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTMETHODDESCRIPTION 
            ,CAST(T$DSMT AS INT)                                                                                                                 AS DISCOUNTMETHODID 
            ,CAST(T$DSPR AS NUMERIC(15,2))                                                                                                       AS DISCOUNTPERCENTAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSSC)),'')                                                                                         AS DISCOUNTSCHEDULE 
            ,T$DSOR.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTSCHEDULEORIGINDESCRIPTION 
            ,CAST(T$DSOR AS INT)                                                                                                                 AS DISCOUNTSCHEDULEORIGINID 
            ,T$DSTY.CONSTANTDESCRIPTION                                                                                                          AS DISCOUNTTYPEDESCRIPTION 
            ,CAST(T$DSTY AS INT)                                                                                                                 AS DISCOUNTTYPEID 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,T$ELGB.CONSTANTDESCRIPTION                                                                                                          AS ELIGIBLEDESCRIPTION 
            ,CAST(T$ELGB AS INT)                                                                                                                 AS ELIGIBLEID 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT  END AS DATETIME) AS EXPIRATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$GNKY)),'')                                                                                         AS GENERICKEY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IFBP)),'')                                                                                         AS INVOICEFROMPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITGR)),'')                                                                                         AS ITEMGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MANU)),'')                                                                                         AS MANUFACTURER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MADE)),'')                                                                                         AS MATRIXDEFINITION 
            ,T$MALV.CONSTANTDESCRIPTION                                                                                                          AS MATRIXLEVELDESCRIPTION 
            ,CAST(T$MALV AS INT)                                                                                                                 AS MATRIXLEVELID 
            ,T$MATY.CONSTANTDESCRIPTION                                                                                                          AS MATRIXTYPEDESCRIPTION 
            ,CAST(T$MATY AS INT)                                                                                                                 AS MATRIXTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAME)),'')                                                                                         AS PAYMENTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPPO)),'')                                                                                         AS POBUSINESSPARTNERFORPRICING 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRBK)),'')                                                                                         AS PRICEBOOK 
            ,T$PBOR.CONSTANTDESCRIPTION                                                                                                          AS PRICEBOOKORIGINDESCRIPTION 
            ,CAST(T$PBOR AS INT)                                                                                                                 AS PRICEBOOKORIGINID 
            ,T$PCOR.CONSTANTDESCRIPTION                                                                                                          AS PRICECALCULATIONORIGINDESCRIPTION 
            ,CAST(T$PCOR AS INT)                                                                                                                 AS PRICECALCULATIONORIGINID 
            ,CAST(T$PRFC AS NUMERIC(15,2))                                                                                                       AS PRICEFACTOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRGR)),'')                                                                                         AS PRICEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRLS)),'')                                                                                         AS PRICELIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRCL)),'')                                                                                         AS PRODUCTCLASS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRLI)),'')                                                                                         AS PRODUCTLINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRTY)),'')                                                                                         AS PRODUCTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POOF)),'')                                                                                         AS PURCHASEOFFICE 
            ,T$POOR.CONSTANTDESCRIPTION                                                                                                          AS PURCHASEORDERORIGINDESCRIPTION 
            ,CAST(T$POOR AS INT)                                                                                                                 AS PURCHASEORDERORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$POTY)),'')                                                                                         AS PURCHASEORDERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RACO)),'')                                                                                         AS RATECODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SOOF)),'')                                                                                         AS SALESOFFICE 
            ,T$SOOR.CONSTANTDESCRIPTION                                                                                                          AS SALESORDERORIGINDESCRIPTION 
            ,CAST(T$SOOR AS INT)                                                                                                                 AS SALESORDERORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SOTY)),'')                                                                                         AS SALESORDERTYPE 
            ,CAST(T$PRSE AS BIGINT)                                                                                                              AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPSO)),'')                                                                                         AS SOBUSINESSPARTNERFORPRICING 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SOLDTOPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STTY)),'')                                                                                         AS SOLDTOTYPE 
            ,T$STDS.CONSTANTDESCRIPTION                                                                                                          AS STOPDISCOUNTINGDESCRIPTION 
            ,CAST(T$STDS AS INT)                                                                                                                 AS STOPDISCOUNTINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TRDE)),'')                                                                                         AS TERMSOFDELIVERY 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTDPCG030201") }} AS SOURCETABLE  
            /*DETERMINING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DTRM 
             ON   T$DTRM.TABLENAME  = 'TDPCG030' 
              AND T$DTRM.COLUMNNAME = 'T$DTRM' 
              AND T$DTRM.CONSTANT   = SOURCETABLE.T$DTRM 
            /*DISCOUNTMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DSMT 
             ON   T$DSMT.TABLENAME  = 'TDPCG030' 
              AND T$DSMT.COLUMNNAME = 'T$DSMT' 
              AND T$DSMT.CONSTANT   = SOURCETABLE.T$DSMT 
            /*DISCOUNTSCHEDULEORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DSOR 
             ON   T$DSOR.TABLENAME  = 'TDPCG030' 
              AND T$DSOR.COLUMNNAME = 'T$DSOR' 
              AND T$DSOR.CONSTANT   = SOURCETABLE.T$DSOR 
            /*DISCOUNTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DSTY 
             ON   T$DSTY.TABLENAME  = 'TDPCG030' 
              AND T$DSTY.COLUMNNAME = 'T$DSTY' 
              AND T$DSTY.CONSTANT   = SOURCETABLE.T$DSTY 
            /*ELIGIBLE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ELGB 
             ON   T$ELGB.TABLENAME  = 'TDPCG030' 
              AND T$ELGB.COLUMNNAME = 'T$ELGB' 
              AND T$ELGB.CONSTANT   = SOURCETABLE.T$ELGB 
            /*MATRIXLEVEL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MALV 
             ON   T$MALV.TABLENAME  = 'TDPCG030' 
              AND T$MALV.COLUMNNAME = 'T$MALV' 
              AND T$MALV.CONSTANT   = SOURCETABLE.T$MALV 
            /*MATRIXTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MATY 
             ON   T$MATY.TABLENAME  = 'TDPCG030' 
              AND T$MATY.COLUMNNAME = 'T$MATY' 
              AND T$MATY.CONSTANT   = SOURCETABLE.T$MATY 
            /*PRICEBOOKORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PBOR 
             ON   T$PBOR.TABLENAME  = 'TDPCG030' 
              AND T$PBOR.COLUMNNAME = 'T$PBOR' 
              AND T$PBOR.CONSTANT   = SOURCETABLE.T$PBOR 
            /*PRICECALCULATIONORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PCOR 
             ON   T$PCOR.TABLENAME  = 'TDPCG030' 
              AND T$PCOR.COLUMNNAME = 'T$PCOR' 
              AND T$PCOR.CONSTANT   = SOURCETABLE.T$PCOR 
            /*PURCHASEORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$POOR 
             ON   T$POOR.TABLENAME  = 'TDPCG030' 
              AND T$POOR.COLUMNNAME = 'T$POOR' 
              AND T$POOR.CONSTANT   = SOURCETABLE.T$POOR 
            /*SALESORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SOOR 
             ON   T$SOOR.TABLENAME  = 'TDPCG030' 
              AND T$SOOR.COLUMNNAME = 'T$SOOR' 
              AND T$SOOR.CONSTANT   = SOURCETABLE.T$SOOR 
            /*STOPDISCOUNTING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STDS 
             ON   T$STDS.TABLENAME  = 'TDPCG030' 
              AND T$STDS.COLUMNNAME = 'T$STDS' 
              AND T$STDS.CONSTANT   = SOURCETABLE.T$STDS 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AREA AS AREA, 
        source_data.BUYFROMPARTNER AS BUYFROMPARTNER, 
        source_data.BUYFROMTYPE AS BUYFROMTYPE, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DETERMININGDESCRIPTION AS DETERMININGDESCRIPTION, 
        source_data.DETERMININGID AS DETERMININGID, 
        source_data.DISCOUNTAMOUNT AS DISCOUNTAMOUNT, 
        source_data.DISCOUNTCODE AS DISCOUNTCODE, 
        source_data.DISCOUNTDEAL AS DISCOUNTDEAL, 
        source_data.DISCOUNTMETHODDESCRIPTION AS DISCOUNTMETHODDESCRIPTION, 
        source_data.DISCOUNTMETHODID AS DISCOUNTMETHODID, 
        source_data.DISCOUNTPERCENTAGE AS DISCOUNTPERCENTAGE, 
        source_data.DISCOUNTSCHEDULE AS DISCOUNTSCHEDULE, 
        source_data.DISCOUNTSCHEDULEORIGINDESCRIPTION AS DISCOUNTSCHEDULEORIGINDESCRIPTION, 
        source_data.DISCOUNTSCHEDULEORIGINID AS DISCOUNTSCHEDULEORIGINID, 
        source_data.DISCOUNTTYPEDESCRIPTION AS DISCOUNTTYPEDESCRIPTION, 
        source_data.DISCOUNTTYPEID AS DISCOUNTTYPEID, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.ELIGIBLEDESCRIPTION AS ELIGIBLEDESCRIPTION, 
        source_data.ELIGIBLEID AS ELIGIBLEID, 
        source_data.EXPIRATIONDATE AS EXPIRATIONDATE, 
        source_data.GENERICKEY AS GENERICKEY, 
        source_data.INVOICEFROMPARTNER AS INVOICEFROMPARTNER, 
        source_data.INVOICETOPARTNER AS INVOICETOPARTNER, 
        source_data.ITEM AS ITEM, 
        source_data.ITEMGROUP AS ITEMGROUP, 
        source_data.MANUFACTURER AS MANUFACTURER, 
        source_data.MATRIXDEFINITION AS MATRIXDEFINITION, 
        source_data.MATRIXLEVELDESCRIPTION AS MATRIXLEVELDESCRIPTION, 
        source_data.MATRIXLEVELID AS MATRIXLEVELID, 
        source_data.MATRIXTYPEDESCRIPTION AS MATRIXTYPEDESCRIPTION, 
        source_data.MATRIXTYPEID AS MATRIXTYPEID, 
        source_data.PAYMENTMETHOD AS PAYMENTMETHOD, 
        source_data.POBUSINESSPARTNERFORPRICING AS POBUSINESSPARTNERFORPRICING, 
        source_data.PRICEBOOK AS PRICEBOOK, 
        source_data.PRICEBOOKORIGINDESCRIPTION AS PRICEBOOKORIGINDESCRIPTION, 
        source_data.PRICEBOOKORIGINID AS PRICEBOOKORIGINID, 
        source_data.PRICECALCULATIONORIGINDESCRIPTION AS PRICECALCULATIONORIGINDESCRIPTION, 
        source_data.PRICECALCULATIONORIGINID AS PRICECALCULATIONORIGINID, 
        source_data.PRICEFACTOR AS PRICEFACTOR, 
        source_data.PRICEGROUP AS PRICEGROUP, 
        source_data.PRICELIST AS PRICELIST, 
        source_data.PRODUCTCLASS AS PRODUCTCLASS, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.PRODUCTTYPE AS PRODUCTTYPE, 
        source_data.PURCHASEOFFICE AS PURCHASEOFFICE, 
        source_data.PURCHASEORDERORIGINDESCRIPTION AS PURCHASEORDERORIGINDESCRIPTION, 
        source_data.PURCHASEORDERORIGINID AS PURCHASEORDERORIGINID, 
        source_data.PURCHASEORDERTYPE AS PURCHASEORDERTYPE, 
        source_data.RATECODE AS RATECODE, 
        source_data.SALESOFFICE AS SALESOFFICE, 
        source_data.SALESORDERORIGINDESCRIPTION AS SALESORDERORIGINDESCRIPTION, 
        source_data.SALESORDERORIGINID AS SALESORDERORIGINID, 
        source_data.SALESORDERTYPE AS SALESORDERTYPE, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.SOBUSINESSPARTNERFORPRICING AS SOBUSINESSPARTNERFORPRICING, 
        source_data.SOLDTOPARTNER AS SOLDTOPARTNER, 
        source_data.SOLDTOTYPE AS SOLDTOTYPE, 
        source_data.STOPDISCOUNTINGDESCRIPTION AS STOPDISCOUNTINGDESCRIPTION, 
        source_data.STOPDISCOUNTINGID AS STOPDISCOUNTINGID, 
        source_data.TERMSOFDELIVERY AS TERMSOFDELIVERY
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AREA as VARCHAR(3)) as AREA,
        cast(BUYFROMPARTNER as VARCHAR(9)) as BUYFROMPARTNER,
        cast(BUYFROMTYPE as VARCHAR(3)) as BUYFROMTYPE,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DETERMININGDESCRIPTION as VARCHAR(16777216)) as DETERMININGDESCRIPTION,
        cast(DETERMININGID as NUMBER(38,0)) as DETERMININGID,
        cast(DISCOUNTAMOUNT as NUMBER(15,2)) as DISCOUNTAMOUNT,
        cast(DISCOUNTCODE as VARCHAR(3)) as DISCOUNTCODE,
        cast(DISCOUNTDEAL as VARCHAR(6)) as DISCOUNTDEAL,
        cast(DISCOUNTMETHODDESCRIPTION as VARCHAR(16777216)) as DISCOUNTMETHODDESCRIPTION,
        cast(DISCOUNTMETHODID as NUMBER(38,0)) as DISCOUNTMETHODID,
        cast(DISCOUNTPERCENTAGE as NUMBER(15,2)) as DISCOUNTPERCENTAGE,
        cast(DISCOUNTSCHEDULE as VARCHAR(6)) as DISCOUNTSCHEDULE,
        cast(DISCOUNTSCHEDULEORIGINDESCRIPTION as VARCHAR(16777216)) as DISCOUNTSCHEDULEORIGINDESCRIPTION,
        cast(DISCOUNTSCHEDULEORIGINID as NUMBER(38,0)) as DISCOUNTSCHEDULEORIGINID,
        cast(DISCOUNTTYPEDESCRIPTION as VARCHAR(16777216)) as DISCOUNTTYPEDESCRIPTION,
        cast(DISCOUNTTYPEID as NUMBER(38,0)) as DISCOUNTTYPEID,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(ELIGIBLEDESCRIPTION as VARCHAR(16777216)) as ELIGIBLEDESCRIPTION,
        cast(ELIGIBLEID as NUMBER(38,0)) as ELIGIBLEID,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(GENERICKEY as VARCHAR(90)) as GENERICKEY,
        cast(INVOICEFROMPARTNER as VARCHAR(9)) as INVOICEFROMPARTNER,
        cast(INVOICETOPARTNER as VARCHAR(9)) as INVOICETOPARTNER,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(MANUFACTURER as VARCHAR(6)) as MANUFACTURER,
        cast(MATRIXDEFINITION as VARCHAR(6)) as MATRIXDEFINITION,
        cast(MATRIXLEVELDESCRIPTION as VARCHAR(16777216)) as MATRIXLEVELDESCRIPTION,
        cast(MATRIXLEVELID as NUMBER(38,0)) as MATRIXLEVELID,
        cast(MATRIXTYPEDESCRIPTION as VARCHAR(16777216)) as MATRIXTYPEDESCRIPTION,
        cast(MATRIXTYPEID as NUMBER(38,0)) as MATRIXTYPEID,
        cast(PAYMENTMETHOD as VARCHAR(3)) as PAYMENTMETHOD,
        cast(POBUSINESSPARTNERFORPRICING as VARCHAR(9)) as POBUSINESSPARTNERFORPRICING,
        cast(PRICEBOOK as VARCHAR(6)) as PRICEBOOK,
        cast(PRICEBOOKORIGINDESCRIPTION as VARCHAR(16777216)) as PRICEBOOKORIGINDESCRIPTION,
        cast(PRICEBOOKORIGINID as NUMBER(38,0)) as PRICEBOOKORIGINID,
        cast(PRICECALCULATIONORIGINDESCRIPTION as VARCHAR(16777216)) as PRICECALCULATIONORIGINDESCRIPTION,
        cast(PRICECALCULATIONORIGINID as NUMBER(38,0)) as PRICECALCULATIONORIGINID,
        cast(PRICEFACTOR as NUMBER(15,2)) as PRICEFACTOR,
        cast(PRICEGROUP as VARCHAR(6)) as PRICEGROUP,
        cast(PRICELIST as VARCHAR(3)) as PRICELIST,
        cast(PRODUCTCLASS as VARCHAR(6)) as PRODUCTCLASS,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(PRODUCTTYPE as VARCHAR(3)) as PRODUCTTYPE,
        cast(PURCHASEOFFICE as VARCHAR(6)) as PURCHASEOFFICE,
        cast(PURCHASEORDERORIGINDESCRIPTION as VARCHAR(16777216)) as PURCHASEORDERORIGINDESCRIPTION,
        cast(PURCHASEORDERORIGINID as NUMBER(38,0)) as PURCHASEORDERORIGINID,
        cast(PURCHASEORDERTYPE as VARCHAR(3)) as PURCHASEORDERTYPE,
        cast(RATECODE as VARCHAR(3)) as RATECODE,
        cast(SALESOFFICE as VARCHAR(6)) as SALESOFFICE,
        cast(SALESORDERORIGINDESCRIPTION as VARCHAR(16777216)) as SALESORDERORIGINDESCRIPTION,
        cast(SALESORDERORIGINID as NUMBER(38,0)) as SALESORDERORIGINID,
        cast(SALESORDERTYPE as VARCHAR(3)) as SALESORDERTYPE,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(SOBUSINESSPARTNERFORPRICING as VARCHAR(9)) as SOBUSINESSPARTNERFORPRICING,
        cast(SOLDTOPARTNER as VARCHAR(9)) as SOLDTOPARTNER,
        cast(SOLDTOTYPE as VARCHAR(3)) as SOLDTOTYPE,
        cast(STOPDISCOUNTINGDESCRIPTION as VARCHAR(16777216)) as STOPDISCOUNTINGDESCRIPTION,
        cast(STOPDISCOUNTINGID as NUMBER(38,0)) as STOPDISCOUNTINGID,
        cast(TERMSOFDELIVERY as VARCHAR(3)) as TERMSOFDELIVERY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data