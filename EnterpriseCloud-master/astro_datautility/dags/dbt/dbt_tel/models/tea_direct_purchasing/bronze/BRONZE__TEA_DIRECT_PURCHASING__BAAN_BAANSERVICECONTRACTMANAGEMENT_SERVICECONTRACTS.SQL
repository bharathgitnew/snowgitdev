/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS',
    unique_key = ['SERVICECONTRACT']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS ADDRESSCODE 
            ,T$BFIL.CONSTANTDESCRIPTION                                                                                                          AS BACKFILLDESCRIPTION 
            ,CAST(T$BFIL AS INT)                                                                                                                 AS BACKFILLID 
            ,CAST(CASE WHEN T$BSDT<= '1/1/1970' THEN NULL ELSE T$BSDT END AS DATE)                                                             AS BILLINGSTARTDATE 
            ,T$BKYN.CONSTANTDESCRIPTION                                                                                                          AS BLOCKEDDESCRIPTION 
            ,CAST(T$BKYN AS INT)                                                                                                                 AS BLOCKEDID 
            ,CAST(T$CBLC AS TINYINT)                                                                                                             AS BLOCKINGCODE 
            ,CAST(CASE WHEN T$CADT<= '1/1/1970' THEN NULL ELSE T$CADT END AS DATE)                                                             AS CANCELDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDIS)),'')                                                                                         AS CANCELREASON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFCN)),'')                                                                                         AS CONTACTPERSON 
            ,CAST(CASE WHEN T$EFDT<= '1/1/1970' THEN NULL ELSE T$EFDT END AS DATE)                                                             AS CONTRACTEFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXDT<= '1/1/1970' THEN NULL ELSE T$EXDT END AS DATE)                                                             AS CONTRACTEXPIRYDATE 
            ,T$CRYN.CONSTANTDESCRIPTION                                                                                                          AS CONTRACTRENEWALDESCRIPTION 
            ,CAST(T$CRYN AS INT)                                                                                                                 AS CONTRACTRENEWALID 
            ,T$SCON.CONSTANTDESCRIPTION                                                                                                          AS CONTRACTSTATUSDESCRIPTION 
            ,CAST(T$SCON AS INT)                                                                                                                 AS CONTRACTSTATUSID 
            ,CAST(T$TERM AS BIGINT)                                                                                                              AS CONTRACTTERMS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTPC)),'')                                                                                         AS CONTRACTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTY)),'')                                                                                         AS COUNTRY 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT END AS DATE)                                                             AS CREATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTIK)),'')                                                                                         AS CTIKEYFORCONTRACTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$RATC$1" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE1 
            ,CAST("T$RATC$2" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE2 
            ,CAST("T$RATC$3" AS NUMERIC(15,2))                                                                                                     AS CURRENCYRATE3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCQU)),'')                                                                                         AS DERIVEDFROMQUOTATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTE)),'')                                                                                         AS DERIVEDFROMTEMPLATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS FOOTERTEXT 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS HEADERTEXT 
            ,"T$IHLD$U".CONSTANTDESCRIPTION                                                                                                        AS HOLDINVOICEDESCRIPTION 
            ,CAST("T$IHLD$U" AS INT)                                                                                                               AS HOLDINVOICEID 
            ,T$INCH.CONSTANTDESCRIPTION                                                                                                          AS INCIDENTALCHANGESDESCRIPTION 
            ,CAST(T$INCH AS INT)                                                                                                                 AS INCIDENTALCHANGESID 
            ,CAST(T$INNP AS BIGINT)                                                                                                              AS INDEXATIONPERIOD 
            ,T$INPR.CONSTANTDESCRIPTION                                                                                                          AS INDEXATIONPROCEDUREDESCRIPTION 
            ,CAST(T$INPR AS INT)                                                                                                                 AS INDEXATIONPROCEDUREID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CIND)),'')                                                                                         AS INDEXATIONTEMPLATE 
            ,SOURCETABLE.T$TXTD   /* TEXT */                                                                                                     AS INSTALLMENTTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICE_TOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTIN)),'')                                                                                         AS INVOICETEMPLATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITAD)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITCN)),'')                                                                                         AS INVOICETOCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBRN)),'')                                                                                         AS LINEOFBUSINESS 
            ,CAST(T$NRPE AS BIGINT)                                                                                                              AS NUMBEROFPERIODSOFCONTRACTDURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORSC)),'')                                                                                         AS ORIGINALSERVICECONTRACT 
            ,T$OVYN.CONSTANTDESCRIPTION                                                                                                          AS OVERTIMEALLOWEDDESCRIPTION 
            ,CAST(T$OVYN AS INT)                                                                                                                 AS OVERTIMEALLOWEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYBYADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFCN)),'')                                                                                         AS PAYBYCONTACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYFROMBUSINESSPARTNER 
            ,CAST(T$ICPN AS NUMERIC(15,2))                                                                                                       AS PENALTY 
            ,CAST(T$PERC AS NUMERIC(15,2))                                                                                                       AS PERCENTAGEOFSALESVALUE 
            ,T$CRPU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNIT_CRPUDESCRIPTION 
            ,CAST(T$CRPU AS INT)                                                                                                                 AS PERIODUNIT_CRPUID 
            ,T$INPU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNIT_INPUDESCRIPTION 
            ,CAST(T$INPU AS INT)                                                                                                                 AS PERIODUNIT_INPUID 
            ,T$PERU.CONSTANTDESCRIPTION                                                                                                          AS PERIODUNITOFCONTRACTDURATIONDESCRIPTION 
            ,CAST(T$PERU AS INT)                                                                                                                 AS PERIODUNITOFCONTRACTDURATIONID 
            ,T$INDX.CONSTANTDESCRIPTION                                                                                                          AS PRICEINDEXATIONDESCRIPTION 
            ,CAST(T$INDX AS INT)                                                                                                                 AS PRICEINDEXATIONID 
            ,T$PRMT.CONSTANTDESCRIPTION                                                                                                          AS PRICINGMETHODDESCRIPTION 
            ,CAST(T$PRMT AS INT)                                                                                                                 AS PRICINGMETHODID 
            ,T$CRPR.CONSTANTDESCRIPTION                                                                                                          AS PROCEDUREFORCONTRACTRENEWALDESCRIPTION 
            ,CAST(T$CRPR AS INT)                                                                                                                 AS PROCEDUREFORCONTRACTRENEWALID 
            ,T$ICPR.CONSTANTDESCRIPTION                                                                                                          AS PROCEDUREFORINCIDENTALCHANGESDESCRIPTION 
            ,CAST(T$ICPR AS INT)                                                                                                                 AS PROCEDUREFORINCIDENTALCHANGESID 
            ,CAST(T$PROV AS NUMERIC(15,2))                                                                                                       AS PROVISION 
            ,CAST(CASE WHEN T$RTDT<= '1/1/1970' THEN NULL ELSE T$RTDT  END AS DATETIME) AS RATEDATE 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINERDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS RATEDETERMINERID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS RATETYPE 
            ,T$RCCG.CONSTANTDESCRIPTION                                                                                                          AS RECOGNIZEREVENUEPERCONFIGURATIONDESCRIPTION 
            ,CAST(T$RCCG AS INT)                                                                                                                 AS RECOGNIZEREVENUEPERCONFIGURATIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFA)),'')                                                                                         AS REFERENCEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REFB)),'')                                                                                         AS REFERENCEB 
            ,CAST(T$CRNP AS BIGINT)                                                                                                              AS RENEWALPERIOD 
            ,T$RVMD.CONSTANTDESCRIPTION                                                                                                          AS REVENUERECOGNITIONBASEDONDESCRIPTION 
            ,CAST(T$RVMD AS INT)                                                                                                                 AS REVENUERECOGNITIONBASEDONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLT)),'')                                                                                         AS SALESPRICELIST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS SALESREP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SERI)),'')                                                                                         AS SERIES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS SERVICECONTRACTTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICEOFFICE 
            ,SOURCETABLE.T$TXTE   /* TEXT */                                                                                                     AS SERVICEORDERTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CVAT)),'')                                                                                         AS TAXCODE 
            ,T$TXYN.CONSTANTDESCRIPTION                                                                                                          AS TAXDESCRIPTION 
            ,CAST(T$TXYN AS INT)                                                                                                                 AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM300201") }} AS SOURCETABLE  
            /*BACKFILL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BFIL 
             ON   T$BFIL.TABLENAME  = 'TSCTM300' 
              AND T$BFIL.COLUMNNAME = 'T$BFIL' 
              AND T$BFIL.CONSTANT   = SOURCETABLE.T$BFIL 
            /*BLOCKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$BKYN 
             ON   T$BKYN.TABLENAME  = 'TSCTM300' 
              AND T$BKYN.COLUMNNAME = 'T$BKYN' 
              AND T$BKYN.CONSTANT   = SOURCETABLE.T$BKYN 
            /*CONTRACTRENEWAL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRYN 
             ON   T$CRYN.TABLENAME  = 'TSCTM300' 
              AND T$CRYN.COLUMNNAME = 'T$CRYN' 
              AND T$CRYN.CONSTANT   = SOURCETABLE.T$CRYN 
            /*CONTRACTSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SCON 
             ON   T$SCON.TABLENAME  = 'TSCTM300' 
              AND T$SCON.COLUMNNAME = 'T$SCON' 
              AND T$SCON.CONSTANT   = SOURCETABLE.T$SCON 
            /*HOLDINVOICEU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$IHLD$U" 
             ON   "T$IHLD$U".TABLENAME  = 'TSCTM300' 
              AND "T$IHLD$U".COLUMNNAME = 'T$IHLD.U' 
              AND "T$IHLD$U".CONSTANT   = SOURCETABLE."T$IHLD$U" 
            /*INCIDENTALCHANGES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INCH 
             ON   T$INCH.TABLENAME  = 'TSCTM300' 
              AND T$INCH.COLUMNNAME = 'T$INCH' 
              AND T$INCH.CONSTANT   = SOURCETABLE.T$INCH 
            /*INDEXATIONPROCEDURE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INPR 
             ON   T$INPR.TABLENAME  = 'TSCTM300' 
              AND T$INPR.COLUMNNAME = 'T$INPR' 
              AND T$INPR.CONSTANT   = SOURCETABLE.T$INPR 
            /*OVERTIMEALLOWED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OVYN 
             ON   T$OVYN.TABLENAME  = 'TSCTM300' 
              AND T$OVYN.COLUMNNAME = 'T$OVYN' 
              AND T$OVYN.CONSTANT   = SOURCETABLE.T$OVYN 
            /*PERIODUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRPU 
             ON   T$CRPU.TABLENAME  = 'TSCTM300' 
              AND T$CRPU.COLUMNNAME = 'T$CRPU' 
              AND T$CRPU.CONSTANT   = SOURCETABLE.T$CRPU 
            /*PERIODUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INPU 
             ON   T$INPU.TABLENAME  = 'TSCTM300' 
              AND T$INPU.COLUMNNAME = 'T$INPU' 
              AND T$INPU.CONSTANT   = SOURCETABLE.T$INPU 
            /*PERIODUNITOFCONTRACTDURATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PERU 
             ON   T$PERU.TABLENAME  = 'TSCTM300' 
              AND T$PERU.COLUMNNAME = 'T$PERU' 
              AND T$PERU.CONSTANT   = SOURCETABLE.T$PERU 
            /*PRICEINDEXATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INDX 
             ON   T$INDX.TABLENAME  = 'TSCTM300' 
              AND T$INDX.COLUMNNAME = 'T$INDX' 
              AND T$INDX.CONSTANT   = SOURCETABLE.T$INDX 
            /*PRICINGMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRMT 
             ON   T$PRMT.TABLENAME  = 'TSCTM300' 
              AND T$PRMT.COLUMNNAME = 'T$PRMT' 
              AND T$PRMT.CONSTANT   = SOURCETABLE.T$PRMT 
            /*PROCEDUREFORCONTRACTRENEWAL*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRPR 
             ON   T$CRPR.TABLENAME  = 'TSCTM300' 
              AND T$CRPR.COLUMNNAME = 'T$CRPR' 
              AND T$CRPR.CONSTANT   = SOURCETABLE.T$CRPR 
            /*PROCEDUREFORINCIDENTALCHANGES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ICPR 
             ON   T$ICPR.TABLENAME  = 'TSCTM300' 
              AND T$ICPR.COLUMNNAME = 'T$ICPR' 
              AND T$ICPR.CONSTANT   = SOURCETABLE.T$ICPR 
            /*RATEDETERMINER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'TSCTM300' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
            /*RECOGNIZEREVENUEPERCONFIGURATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RCCG 
             ON   T$RCCG.TABLENAME  = 'TSCTM300' 
              AND T$RCCG.COLUMNNAME = 'T$RCCG' 
              AND T$RCCG.CONSTANT   = SOURCETABLE.T$RCCG 
            /*REVENUERECOGNITIONBASEDON*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RVMD 
             ON   T$RVMD.TABLENAME  = 'TSCTM300' 
              AND T$RVMD.COLUMNNAME = 'T$RVMD' 
              AND T$RVMD.CONSTANT   = SOURCETABLE.T$RVMD 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TXYN 
             ON   T$TXYN.TABLENAME  = 'TSCTM300' 
              AND T$TXYN.COLUMNNAME = 'T$TXYN' 
              AND T$TXYN.CONSTANT   = SOURCETABLE.T$TXYN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,	transform_data as
(
    SELECT 
		source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.SERVICECONTRACT AS SERVICECONTRACT,
		source_data._COMPANYID AS _COMPANYID,
		source_data.ADDRESSCODE AS ADDRESSCODE,
		source_data.BACKFILLDESCRIPTION AS BACKFILLDESCRIPTION,
		source_data.BACKFILLID AS BACKFILLID,
		source_data.BILLINGSTARTDATE AS BILLINGSTARTDATE,
		source_data.BLOCKEDDESCRIPTION AS BLOCKEDDESCRIPTION,
		source_data.BLOCKEDID AS BLOCKEDID,
		source_data.BLOCKINGCODE AS BLOCKINGCODE,
		source_data.CANCELDATE AS CANCELDATE,
		source_data.CANCELREASON AS CANCELREASON,
		source_data.CONTACTPERSON AS CONTACTPERSON,
		source_data.CONTRACTEFFECTIVEDATE AS CONTRACTEFFECTIVEDATE,
		source_data.CONTRACTEXPIRYDATE AS CONTRACTEXPIRYDATE,
		source_data.CONTRACTRENEWALDESCRIPTION AS CONTRACTRENEWALDESCRIPTION,
		source_data.CONTRACTRENEWALID AS CONTRACTRENEWALID,
		source_data.CONTRACTSTATUSDESCRIPTION AS CONTRACTSTATUSDESCRIPTION,
		source_data.CONTRACTSTATUSID AS CONTRACTSTATUSID,
		source_data.CONTRACTTERMS AS CONTRACTTERMS,
		source_data.CONTRACTTYPE AS CONTRACTTYPE,
		source_data.COUNTRY AS COUNTRY,
		source_data.CREATIONDATE AS CREATIONDATE,
		source_data.CTIKEYFORCONTRACTS AS CTIKEYFORCONTRACTS,
		source_data.CURRENCY AS CURRENCY,
		source_data.CURRENCYRATE1 AS CURRENCYRATE1,
		source_data.CURRENCYRATE2 AS CURRENCYRATE2,
		source_data.CURRENCYRATE3 AS CURRENCYRATE3,
		source_data.DERIVEDFROMQUOTATION AS DERIVEDFROMQUOTATION,
		source_data.DERIVEDFROMTEMPLATE AS DERIVEDFROMTEMPLATE,
		source_data.DESCRIPTION AS DESCRIPTION,
		source_data.FOOTERTEXT AS FOOTERTEXT,
		source_data.HEADERTEXT AS HEADERTEXT,
		source_data.HOLDINVOICEDESCRIPTION AS HOLDINVOICEDESCRIPTION,
		source_data.HOLDINVOICEID AS HOLDINVOICEID,
		source_data.INCIDENTALCHANGESDESCRIPTION AS INCIDENTALCHANGESDESCRIPTION,
		source_data.INCIDENTALCHANGESID AS INCIDENTALCHANGESID,
		source_data.INDEXATIONPERIOD AS INDEXATIONPERIOD,
		source_data.INDEXATIONPROCEDUREDESCRIPTION AS INDEXATIONPROCEDUREDESCRIPTION,
		source_data.INDEXATIONPROCEDUREID AS INDEXATIONPROCEDUREID,
		source_data.INDEXATIONTEMPLATE AS INDEXATIONTEMPLATE,
		source_data.INSTALLMENTTEXT AS INSTALLMENTTEXT,
		source_data.INVOICE_TOBUSINESSPARTNER AS INVOICE_TOBUSINESSPARTNER,
		source_data.INVOICETEMPLATE AS INVOICETEMPLATE,
		source_data.INVOICETOADDRESS AS INVOICETOADDRESS,
		source_data.INVOICETOCONTACT AS INVOICETOCONTACT,
		source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE,
		source_data.LINEOFBUSINESS AS LINEOFBUSINESS,
		source_data.NUMBEROFPERIODSOFCONTRACTDURATION AS NUMBEROFPERIODSOFCONTRACTDURATION,
		source_data.ORIGINALSERVICECONTRACT AS ORIGINALSERVICECONTRACT,
		source_data.OVERTIMEALLOWEDDESCRIPTION AS OVERTIMEALLOWEDDESCRIPTION,
		source_data.OVERTIMEALLOWEDID AS OVERTIMEALLOWEDID,
		source_data.PAYBYADDRESS AS PAYBYADDRESS,
		source_data.PAYBYCONTACT AS PAYBYCONTACT,
		source_data.PAYFROMBUSINESSPARTNER AS PAYFROMBUSINESSPARTNER,
		source_data.PENALTY AS PENALTY,
		source_data.PERCENTAGEOFSALESVALUE AS PERCENTAGEOFSALESVALUE,
		source_data.PERIODUNIT_CRPUDESCRIPTION AS PERIODUNIT_CRPUDESCRIPTION,
		source_data.PERIODUNIT_CRPUID AS PERIODUNIT_CRPUID,
		source_data.PERIODUNIT_INPUDESCRIPTION AS PERIODUNIT_INPUDESCRIPTION,
		source_data.PERIODUNIT_INPUID AS PERIODUNIT_INPUID,
		source_data.PERIODUNITOFCONTRACTDURATIONDESCRIPTION AS PERIODUNITOFCONTRACTDURATIONDESCRIPTION,
		source_data.PERIODUNITOFCONTRACTDURATIONID AS PERIODUNITOFCONTRACTDURATIONID,
		source_data.PRICEINDEXATIONDESCRIPTION AS PRICEINDEXATIONDESCRIPTION,
		source_data.PRICEINDEXATIONID AS PRICEINDEXATIONID,
		source_data.PRICINGMETHODDESCRIPTION AS PRICINGMETHODDESCRIPTION,
		source_data.PRICINGMETHODID AS PRICINGMETHODID,
		source_data.PROCEDUREFORCONTRACTRENEWALDESCRIPTION AS PROCEDUREFORCONTRACTRENEWALDESCRIPTION,
		source_data.PROCEDUREFORCONTRACTRENEWALID AS PROCEDUREFORCONTRACTRENEWALID,
		source_data.PROCEDUREFORINCIDENTALCHANGESDESCRIPTION AS PROCEDUREFORINCIDENTALCHANGESDESCRIPTION,
		source_data.PROCEDUREFORINCIDENTALCHANGESID AS PROCEDUREFORINCIDENTALCHANGESID,
		source_data.PROVISION AS PROVISION,
		source_data.RATEDATE AS RATEDATE,
		source_data.RATEDETERMINERDESCRIPTION AS RATEDETERMINERDESCRIPTION,
		source_data.RATEDETERMINERID AS RATEDETERMINERID,
		source_data.RATEFACTOR1 AS RATEFACTOR1,
		source_data.RATEFACTOR2 AS RATEFACTOR2,
		source_data.RATEFACTOR3 AS RATEFACTOR3,
		source_data.RATETYPE AS RATETYPE,
		source_data.RECOGNIZEREVENUEPERCONFIGURATIONDESCRIPTION AS RECOGNIZEREVENUEPERCONFIGURATIONDESCRIPTION,
		source_data.RECOGNIZEREVENUEPERCONFIGURATIONID AS RECOGNIZEREVENUEPERCONFIGURATIONID,
		source_data.REFERENCEA AS REFERENCEA,
		source_data.REFERENCEB AS REFERENCEB,
		source_data.RENEWALPERIOD AS RENEWALPERIOD,
		source_data.REVENUERECOGNITIONBASEDONDESCRIPTION AS REVENUERECOGNITIONBASEDONDESCRIPTION,
		source_data.REVENUERECOGNITIONBASEDONID AS REVENUERECOGNITIONBASEDONID,
		source_data.SALESPRICELIST AS SALESPRICELIST,
		source_data.SALESREP AS SALESREP,
		source_data.SEARCHARGUMENT AS SEARCHARGUMENT,
		source_data.SERIES AS SERIES,
		source_data.SERVICECONTRACTTEXT AS SERVICECONTRACTTEXT,
		source_data.SERVICEOFFICE AS SERVICEOFFICE,
		source_data.SERVICEORDERTEXT AS SERVICEORDERTEXT,
		source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER,
		source_data.TAXCODE AS TAXCODE,
		source_data.TAXDESCRIPTION AS TAXDESCRIPTION,
		source_data.TAXID AS TAXID,
		source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT   
        FROM source_data
        )
,	type_data as 
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
		cast(BACKFILLDESCRIPTION as VARCHAR(16777216)) as BACKFILLDESCRIPTION,
		cast(BACKFILLID as NUMBER(38,0)) as BACKFILLID,
		cast(BILLINGSTARTDATE as DATE) as BILLINGSTARTDATE,
		cast(BLOCKEDDESCRIPTION as VARCHAR(16777216)) as BLOCKEDDESCRIPTION,
		cast(BLOCKEDID as NUMBER(38,0)) as BLOCKEDID,
		cast(BLOCKINGCODE as NUMBER(38,0)) as BLOCKINGCODE,
		cast(CANCELDATE as DATE) as CANCELDATE,
		cast(CANCELREASON as VARCHAR(6)) as CANCELREASON,
		cast(CONTACTPERSON as VARCHAR(9)) as CONTACTPERSON,
		cast(CONTRACTEFFECTIVEDATE as DATE) as CONTRACTEFFECTIVEDATE,
		cast(CONTRACTEXPIRYDATE as DATE) as CONTRACTEXPIRYDATE,
		cast(CONTRACTRENEWALDESCRIPTION as VARCHAR(16777216)) as CONTRACTRENEWALDESCRIPTION,
		cast(CONTRACTRENEWALID as NUMBER(38,0)) as CONTRACTRENEWALID,
		cast(CONTRACTSTATUSDESCRIPTION as VARCHAR(16777216)) as CONTRACTSTATUSDESCRIPTION,
		cast(CONTRACTSTATUSID as NUMBER(38,0)) as CONTRACTSTATUSID,
		cast(CONTRACTTERMS as NUMBER(38,0)) as CONTRACTTERMS,
		cast(CONTRACTTYPE as VARCHAR(3)) as CONTRACTTYPE,
		cast(COUNTRY as VARCHAR(3)) as COUNTRY,
		cast(CREATIONDATE as DATE) as CREATIONDATE,
		cast(CTIKEYFORCONTRACTS as VARCHAR(9)) as CTIKEYFORCONTRACTS,
		cast(CURRENCY as VARCHAR(3)) as CURRENCY,
		cast(CURRENCYRATE1 as NUMBER(15,2)) as CURRENCYRATE1,
		cast(CURRENCYRATE2 as NUMBER(15,2)) as CURRENCYRATE2,
		cast(CURRENCYRATE3 as NUMBER(15,2)) as CURRENCYRATE3,
		cast(DERIVEDFROMQUOTATION as VARCHAR(9)) as DERIVEDFROMQUOTATION,
		cast(DERIVEDFROMTEMPLATE as VARCHAR(16)) as DERIVEDFROMTEMPLATE,
		cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
		cast(FOOTERTEXT as NUMBER(38,10)) as FOOTERTEXT,
		cast(HEADERTEXT as NUMBER(38,10)) as HEADERTEXT,
		cast(HOLDINVOICEDESCRIPTION as VARCHAR(16777216)) as HOLDINVOICEDESCRIPTION,
		cast(HOLDINVOICEID as NUMBER(38,0)) as HOLDINVOICEID,
		cast(INCIDENTALCHANGESDESCRIPTION as VARCHAR(16777216)) as INCIDENTALCHANGESDESCRIPTION,
		cast(INCIDENTALCHANGESID as NUMBER(38,0)) as INCIDENTALCHANGESID,
		cast(INDEXATIONPERIOD as NUMBER(38,0)) as INDEXATIONPERIOD,
		cast(INDEXATIONPROCEDUREDESCRIPTION as VARCHAR(16777216)) as INDEXATIONPROCEDUREDESCRIPTION,
		cast(INDEXATIONPROCEDUREID as NUMBER(38,0)) as INDEXATIONPROCEDUREID,
		cast(INDEXATIONTEMPLATE as VARCHAR(3)) as INDEXATIONTEMPLATE,
		cast(INSTALLMENTTEXT as NUMBER(38,10)) as INSTALLMENTTEXT,
		cast(INVOICE_TOBUSINESSPARTNER as VARCHAR(9)) as INVOICE_TOBUSINESSPARTNER,
		cast(INVOICETEMPLATE as VARCHAR(3)) as INVOICETEMPLATE,
		cast(INVOICETOADDRESS as VARCHAR(9)) as INVOICETOADDRESS,
		cast(INVOICETOCONTACT as VARCHAR(9)) as INVOICETOCONTACT,
		cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
		cast(LINEOFBUSINESS as VARCHAR(6)) as LINEOFBUSINESS,
		cast(NUMBEROFPERIODSOFCONTRACTDURATION as NUMBER(38,0)) as NUMBEROFPERIODSOFCONTRACTDURATION,
		cast(ORIGINALSERVICECONTRACT as VARCHAR(9)) as ORIGINALSERVICECONTRACT,
		cast(OVERTIMEALLOWEDDESCRIPTION as VARCHAR(16777216)) as OVERTIMEALLOWEDDESCRIPTION,
		cast(OVERTIMEALLOWEDID as NUMBER(38,0)) as OVERTIMEALLOWEDID,
		cast(PAYBYADDRESS as VARCHAR(9)) as PAYBYADDRESS,
		cast(PAYBYCONTACT as VARCHAR(9)) as PAYBYCONTACT,
		cast(PAYFROMBUSINESSPARTNER as VARCHAR(9)) as PAYFROMBUSINESSPARTNER,
		cast(PENALTY as NUMBER(15,2)) as PENALTY,
		cast(PERCENTAGEOFSALESVALUE as NUMBER(15,2)) as PERCENTAGEOFSALESVALUE,
		cast(PERIODUNIT_CRPUDESCRIPTION as VARCHAR(16777216)) as PERIODUNIT_CRPUDESCRIPTION,
		cast(PERIODUNIT_CRPUID as NUMBER(38,0)) as PERIODUNIT_CRPUID,
		cast(PERIODUNIT_INPUDESCRIPTION as VARCHAR(16777216)) as PERIODUNIT_INPUDESCRIPTION,
		cast(PERIODUNIT_INPUID as NUMBER(38,0)) as PERIODUNIT_INPUID,
		cast(PERIODUNITOFCONTRACTDURATIONDESCRIPTION as VARCHAR(16777216)) as PERIODUNITOFCONTRACTDURATIONDESCRIPTION,
		cast(PERIODUNITOFCONTRACTDURATIONID as NUMBER(38,0)) as PERIODUNITOFCONTRACTDURATIONID,
		cast(PRICEINDEXATIONDESCRIPTION as VARCHAR(16777216)) as PRICEINDEXATIONDESCRIPTION,
		cast(PRICEINDEXATIONID as NUMBER(38,0)) as PRICEINDEXATIONID,
		cast(PRICINGMETHODDESCRIPTION as VARCHAR(16777216)) as PRICINGMETHODDESCRIPTION,
		cast(PRICINGMETHODID as NUMBER(38,0)) as PRICINGMETHODID,
		cast(PROCEDUREFORCONTRACTRENEWALDESCRIPTION as VARCHAR(16777216)) as PROCEDUREFORCONTRACTRENEWALDESCRIPTION,
		cast(PROCEDUREFORCONTRACTRENEWALID as NUMBER(38,0)) as PROCEDUREFORCONTRACTRENEWALID,
		cast(PROCEDUREFORINCIDENTALCHANGESDESCRIPTION as VARCHAR(16777216)) as PROCEDUREFORINCIDENTALCHANGESDESCRIPTION,
		cast(PROCEDUREFORINCIDENTALCHANGESID as NUMBER(38,0)) as PROCEDUREFORINCIDENTALCHANGESID,
		cast(PROVISION as NUMBER(15,2)) as PROVISION,
		cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
		cast(RATEDETERMINERDESCRIPTION as VARCHAR(16777216)) as RATEDETERMINERDESCRIPTION,
		cast(RATEDETERMINERID as NUMBER(38,0)) as RATEDETERMINERID,
		cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
		cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
		cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
		cast(RATETYPE as VARCHAR(3)) as RATETYPE,
		cast(RECOGNIZEREVENUEPERCONFIGURATIONDESCRIPTION as VARCHAR(16777216)) as RECOGNIZEREVENUEPERCONFIGURATIONDESCRIPTION,
		cast(RECOGNIZEREVENUEPERCONFIGURATIONID as NUMBER(38,0)) as RECOGNIZEREVENUEPERCONFIGURATIONID,
		cast(REFERENCEA as VARCHAR(30)) as REFERENCEA,
		cast(REFERENCEB as VARCHAR(30)) as REFERENCEB,
		cast(RENEWALPERIOD as NUMBER(38,0)) as RENEWALPERIOD,
		cast(REVENUERECOGNITIONBASEDONDESCRIPTION as VARCHAR(16777216)) as REVENUERECOGNITIONBASEDONDESCRIPTION,
		cast(REVENUERECOGNITIONBASEDONID as NUMBER(38,0)) as REVENUERECOGNITIONBASEDONID,
		cast(SALESPRICELIST as VARCHAR(3)) as SALESPRICELIST,
		cast(SALESREP as VARCHAR(6)) as SALESREP,
		cast(SEARCHARGUMENT as VARCHAR(16)) as SEARCHARGUMENT,
		cast(SERIES as VARCHAR(8)) as SERIES,
		cast(SERVICECONTRACTTEXT as NUMBER(38,10)) as SERVICECONTRACTTEXT,
		cast(SERVICEOFFICE as VARCHAR(6)) as SERVICEOFFICE,
		cast(SERVICEORDERTEXT as NUMBER(38,10)) as SERVICEORDERTEXT,
		cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
		cast(TAXCODE as VARCHAR(9)) as TAXCODE,
		cast(TAXDESCRIPTION as VARCHAR(16777216)) as TAXDESCRIPTION,
		cast(TAXID as NUMBER(38,0)) as TAXID,
		cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT
    from transform_data
    )
select * from type_data