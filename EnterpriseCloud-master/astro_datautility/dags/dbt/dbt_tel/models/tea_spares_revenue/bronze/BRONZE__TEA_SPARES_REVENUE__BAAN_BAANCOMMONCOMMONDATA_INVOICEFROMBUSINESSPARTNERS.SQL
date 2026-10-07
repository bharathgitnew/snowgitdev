/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS',
    unique_key = ['DEPARTMENT',
    'INVOICEFROMBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT 
             SourceTable._capturedatetime                                                                                                        AS _CaptureDatetime 
            ,200                                                                                                                                   AS _CompanyId 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cadr)),'')                                                                                         AS AddressCode 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$bloc)),'')                                                                                         AS BlockingCodeForPurchaseInvoices 
          --  ,NULLIF(RTRIM(LTRIM(SourceTable.t$bpgr$u)),'')    
        ,''                                                                                    AS BPReportGroup 
        ---- 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cbps)),'')                                                                                         AS BusinessPartnerSignal 
            ,t$bpst.ConstantDescription                                                                                                          AS BusinessPartnerStatusDescription 
            ,CAST(t$bpst AS INT)                                                                                                                 AS BusinessPartnerStatusId 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cbtp)),'')                                                                                         AS BusinessPartnerType 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ccal)),'')                                                                                         AS CalendarCode 
        ---- 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ccnt)),'')                                                                                         AS ContactCode 
            ,CAST(t$crlr AS NUMERIC(15,2))                                                                                                       AS CreditLimit 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ccur)),'')                                                                                         AS Currency 
            ,CAST(CASE WHEN t$dlcr<= '1/1/1970' THEN NULL ELSE t$dlcr  END AS DATETIME) AS DateLastCreditReview 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cofc)),'')                                                                                         AS Department 
            ,CAST(CASE WHEN t$endt<= '1/1/1970' THEN NULL ELSE t$endt END AS DATETIME) AS EndDate 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$rtyp)),'')                                                                                         AS ExchangeRateType 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cfsg)),'')                                                                                         AS FinancialSupplierGroup 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ifbp)),'')                                                                                         AS InvoiceFromBusinessPartner 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$clan)),'')                                                                                         AS Language 
        ---- 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ccrs)),'')                                                                                         AS LatePaymentSurcharge 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$paym)),'')                                                                                         AS PaymentMethod 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$ptbp)),'')                                                                                         AS PayToBusinessPartner 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$rcrs)),'')                                                                                         AS ReturnLatePaymentSurcharge 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$rpym)),'')                                                                                         AS ReturnPaymentMethod 
        ---- 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$rpay)),'')                                                                                         AS ReturnTermsOfPayment 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$seak)),'')                                                                                         AS SearchKey 
            ,CAST(CASE WHEN t$stdt<= '1/1/1970' THEN NULL ELSE t$stdt  END AS DATETIME) AS StartDate 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$mstm)),'')                                                                                         AS StatementMethod 
            ,t$subc.ConstantDescription                                                                                                          AS SubcontractingDescription 
        ---- 
            ,CAST(t$subc AS INT)                                                                                                                 AS SubcontractingId 
            ,t$cvyn.ConstantDescription                                                                                                          AS TaxDescription 
            ,CAST(t$cvyn AS INT)                                                                                                                 AS TaxId 
            ,NULLIF(RTRIM(LTRIM(SourceTable.t$cpay)),'')                                                                                         AS TermsOfPayment 
            ,SourceTable.t$txta   /* Text */                                                                                                     AS Text 
        ---- 
            ,t$vryn.ConstantDescription                                                                                                          AS VendorRatingDescription 
            ,CAST(t$vryn AS INT)                                                                                                                 AS VendorRatingId 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM122200") }} AS SOURCETABLE  
            /*BusinessPartnerStatus*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$bpst 
             ON   t$bpst.TableName  = 'tccom122' 
              AND t$bpst.ColumnName = 't$bpst' 
              AND t$bpst.Constant   = SourceTable.t$bpst 
            /*Subcontracting*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$subc 
             ON   t$subc.TableName  = 'tccom122' 
              AND t$subc.ColumnName = 't$subc' 
              AND t$subc.Constant   = SourceTable.t$subc 
            /*Tax*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$cvyn 
             ON   t$cvyn.TableName  = 'tccom122' 
              AND t$cvyn.ColumnName = 't$cvyn' 
              AND t$cvyn.Constant   = SourceTable.t$cvyn 
            /*VendorRating*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS t$vryn 
             ON   t$vryn.TableName  = 'tccom122' 
              AND t$vryn.ColumnName = 't$vryn' 
              AND t$vryn.Constant   = SourceTable.t$vryn 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}  
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.BLOCKINGCODEFORPURCHASEINVOICES AS BLOCKINGCODEFORPURCHASEINVOICES, 
        source_data.BPREPORTGROUP AS BPREPORTGROUP, 
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CREDITLIMIT AS CREDITLIMIT, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DATELASTCREDITREVIEW AS DATELASTCREDITREVIEW, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINANCIALSUPPLIERGROUP AS FINANCIALSUPPLIERGROUP, 
        source_data.INVOICEFROMBUSINESSPARTNER AS INVOICEFROMBUSINESSPARTNER, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.PAYMENTMETHOD AS PAYMENTMETHOD, 
        source_data.PAYTOBUSINESSPARTNER AS PAYTOBUSINESSPARTNER, 
        source_data.RETURNLATEPAYMENTSURCHARGE AS RETURNLATEPAYMENTSURCHARGE, 
        source_data.RETURNPAYMENTMETHOD AS RETURNPAYMENTMETHOD, 
        source_data.RETURNTERMSOFPAYMENT AS RETURNTERMSOFPAYMENT, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.STATEMENTMETHOD AS STATEMENTMETHOD, 
        source_data.SUBCONTRACTINGDESCRIPTION AS SUBCONTRACTINGDESCRIPTION, 
        source_data.SUBCONTRACTINGID AS SUBCONTRACTINGID, 
        source_data.TAXDESCRIPTION AS TAXDESCRIPTION, 
        source_data.TAXID AS TAXID, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TEXT AS TEXT, 
        source_data.VENDORRATINGDESCRIPTION AS VENDORRATINGDESCRIPTION, 
        source_data.VENDORRATINGID AS VENDORRATINGID
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
        ADDRESSCODE,
        BLOCKINGCODEFORPURCHASEINVOICES,
        BPREPORTGROUP,
        BUSINESSPARTNERSIGNAL,
        BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        BUSINESSPARTNERTYPE,
        CALENDARCODE,
        CONTACTCODE,
        cast(CREDITLIMIT as NUMBER(15,2)) as CREDITLIMIT,
        CURRENCY,
        cast(DATELASTCREDITREVIEW as TIMESTAMP_NTZ(9)) as DATELASTCREDITREVIEW,
        DEPARTMENT,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        EXCHANGERATETYPE,
        FINANCIALSUPPLIERGROUP,
        INVOICEFROMBUSINESSPARTNER,
        LANGUAGE,
        LATEPAYMENTSURCHARGE,
        PAYMENTMETHOD,
        PAYTOBUSINESSPARTNER,
        RETURNLATEPAYMENTSURCHARGE,
        RETURNPAYMENTMETHOD,
        RETURNTERMSOFPAYMENT,
        SEARCHKEY,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        STATEMENTMETHOD,
        SUBCONTRACTINGDESCRIPTION,
        cast(SUBCONTRACTINGID as NUMBER(38,0)) as SUBCONTRACTINGID,
        TAXDESCRIPTION,
        cast(TAXID as NUMBER(38,0)) as TAXID,
        TERMSOFPAYMENT,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        VENDORRATINGDESCRIPTION,
        cast(VENDORRATINGID as NUMBER(38,0)) as VENDORRATINGID
    from transform_data
    )
select * from type_data