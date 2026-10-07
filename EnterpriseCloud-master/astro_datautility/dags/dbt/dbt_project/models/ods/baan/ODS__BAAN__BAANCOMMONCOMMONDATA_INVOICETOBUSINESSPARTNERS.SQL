/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS 
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
    alias='BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS',
    unique_key = ['DEPARTMENT',
    'INVOICETOBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,200                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                             AS ADDRESSCODE 
            ,T$RETR.CONSTANTDESCRIPTION                                                                                                              AS ALLOWRETRO_BILLINGDESCRIPTION 
            ,CAST(T$RETR AS INT)                                                                                                                     AS ALLOWRETRO_BILLINGID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BPGR$U")),'')                                                                                           AS BPREPORTGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBPS)),'')                                                                                             AS BUSINESSPARTNERSIGNAL 
            ,T$ITST.CONSTANTDESCRIPTION                                                                                                              AS BUSINESSPARTNERSTATUSDESCRIPTION 
            ,CAST(T$ITST AS INT)                                                                                                                     AS BUSINESSPARTNERSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'')                                                                                             AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                             AS CALENDARCODE 
            ,T$CHIN.CONSTANTDESCRIPTION                                                                                                              AS CHARGEINTERESTDESCRIPTION 
            ,CAST(T$CHIN AS INT)                                                                                                                     AS CHARGEINTERESTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                             AS CONTACTCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRA)),'')                                                                                             AS CREDITANALYST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRBU)),'')                                                                                             AS CREDITBUREAUREFERENCENUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCIC)),'')                                                                                             AS CREDITINSURANCECOMPANY 
            ,CAST(T$CRLR AS NUMERIC(15,2))                                                                                                           AS CREDITLIMIT 
            ,CAST(CASE WHEN "T$CXDT$U"<= '1/1/1970' THEN NULL ELSE "T$CXDT$U"  END AS DATETIME) AS CREDITLIMITEXPIRESON 
            ,CAST(T$CLIN AS NUMERIC(15,2))                                                                                                           AS CREDITLIMITINSURED 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRAT)),'')                                                                                             AS CREDITRATING 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                             AS CURRENCY 
            ,CAST(CASE WHEN T$LIDT<= '1/1/1970' THEN NULL ELSE T$LIDT  END AS DATETIME)     AS DATEINVOICED 
            ,CAST(CASE WHEN T$DLCR<= '1/1/1970' THEN NULL ELSE T$DLCR  END AS DATETIME)     AS DATELASTCREDITREVIEW 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                             AS DEPARTMENT 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME)     AS ENDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                             AS EXCHANGERATETYPE 
            ,CAST(CASE WHEN T$EDCI<= '1/1/1970' THEN NULL ELSE T$EDCI  END AS DATETIME)     AS EXPIRYDATEOFINSUREDCREDITLIMIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFCG)),'')                                                                                             AS FINANCIALCUSTOMERGROUP 
            ,CAST(T$HCRU AS NUMERIC(15,2))                                                                                                           AS HIGHESTCREDITUSEDSINCEDATELASTCREDITREVIEW 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CIDM)),'')                                                                                             AS INVOICEDELIVERYMETHOD 
            ,CAST(T$INFQ AS INT)                                                                                                                     AS INVOICEINTERVAL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                             AS INVOICETOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CINM)),'')                                                                                             AS INVOICINGMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                             AS LANGUAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                             AS LATEPAYMENTSURCHARGE 
            ,CAST(T$NCIN AS TINYINT)                                                                                                                 AS NUMBEROFEXTRAINVOICECOPIES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                             AS PAYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                             AS PAYMENTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RFCI)),'')                                                                                             AS REFERENCECREDITINSURANCECOMPANY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RCRS)),'')                                                                                             AS RETURNLATEPAYMENTSURCHARGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RPYM)),'')                                                                                             AS RETURNPAYMENTMETHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RPAY)),'')                                                                                             AS RETURNTERMSOFPAYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                             AS SEARCHKEY 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME)     AS STARTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MSTM)),'')                                                                                             AS STATEMENTMETHOD 
            ,T$CVYN.CONSTANTDESCRIPTION                                                                                                              AS TAXDESCRIPTION 
            ,CAST(T$CVYN AS INT)                                                                                                                     AS TAXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                             AS TERMSOFPAYMENT 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                         AS TEXT 
            ,CAST(T$TAMD AS NUMERIC(15,2))                                                                                                           AS TOLERANCEAMOUNTFORDUEINVOICES 
            ,CAST(T$TPCD AS NUMERIC(15,2))                                                                                                           AS TOLERANCEPERCENTAGEFORDUEINVOICES 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM112200") }} AS SOURCETABLE  
            /*ALLOWRETRO_BILLING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RETR 
             ON   T$RETR.TABLENAME  = 'TCCOM112' 
              AND T$RETR.COLUMNNAME = 'T$RETR' 
              AND T$RETR.CONSTANT   = SOURCETABLE.T$RETR 
            /*BUSINESSPARTNERSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ITST 
             ON   T$ITST.TABLENAME  = 'TCCOM112' 
              AND T$ITST.COLUMNNAME = 'T$ITST' 
              AND T$ITST.CONSTANT   = SOURCETABLE.T$ITST 
            /*CHARGEINTEREST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHIN 
             ON   T$CHIN.TABLENAME  = 'TCCOM112' 
              AND T$CHIN.COLUMNNAME = 'T$CHIN' 
              AND T$CHIN.CONSTANT   = SOURCETABLE.T$CHIN 
            /*TAX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CVYN 
             ON   T$CVYN.TABLENAME  = 'TCCOM112' 
              AND T$CVYN.COLUMNNAME = 'T$CVYN' 
              AND T$CVYN.CONSTANT   = SOURCETABLE.T$CVYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDRESSCODE AS ADDRESSCODE, 
        source_data.ALLOWRETRO_BILLINGDESCRIPTION AS ALLOWRETRO_BILLINGDESCRIPTION, 
        source_data.ALLOWRETRO_BILLINGID AS ALLOWRETRO_BILLINGID, 
        source_data.BPREPORTGROUP AS BPREPORTGROUP, 
        source_data.BUSINESSPARTNERSIGNAL AS BUSINESSPARTNERSIGNAL, 
        source_data.BUSINESSPARTNERSTATUSDESCRIPTION AS BUSINESSPARTNERSTATUSDESCRIPTION, 
        source_data.BUSINESSPARTNERSTATUSID AS BUSINESSPARTNERSTATUSID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
        source_data.CALENDARCODE AS CALENDARCODE, 
        source_data.CHARGEINTERESTDESCRIPTION AS CHARGEINTERESTDESCRIPTION, 
        source_data.CHARGEINTERESTID AS CHARGEINTERESTID, 
        source_data.CONTACTCODE AS CONTACTCODE, 
        source_data.CREDITANALYST AS CREDITANALYST, 
        source_data.CREDITBUREAUREFERENCENUMBER AS CREDITBUREAUREFERENCENUMBER, 
        source_data.CREDITINSURANCECOMPANY AS CREDITINSURANCECOMPANY, 
        source_data.CREDITLIMIT AS CREDITLIMIT, 
        source_data.CREDITLIMITEXPIRESON AS CREDITLIMITEXPIRESON, 
        source_data.CREDITLIMITINSURED AS CREDITLIMITINSURED, 
        source_data.CREDITRATING AS CREDITRATING, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DATEINVOICED AS DATEINVOICED, 
        source_data.DATELASTCREDITREVIEW AS DATELASTCREDITREVIEW, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.ENDDATE AS ENDDATE, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.EXPIRYDATEOFINSUREDCREDITLIMIT AS EXPIRYDATEOFINSUREDCREDITLIMIT, 
        source_data.FINANCIALCUSTOMERGROUP AS FINANCIALCUSTOMERGROUP, 
        source_data.HIGHESTCREDITUSEDSINCEDATELASTCREDITREVIEW AS HIGHESTCREDITUSEDSINCEDATELASTCREDITREVIEW, 
        source_data.INVOICEDELIVERYMETHOD AS INVOICEDELIVERYMETHOD, 
        source_data.INVOICEINTERVAL AS INVOICEINTERVAL, 
        source_data.INVOICETOBUSINESSPARTNER AS INVOICETOBUSINESSPARTNER, 
        source_data.INVOICINGMETHOD AS INVOICINGMETHOD, 
        source_data.LANGUAGE AS LANGUAGE, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.NUMBEROFEXTRAINVOICECOPIES AS NUMBEROFEXTRAINVOICECOPIES, 
        source_data.PAYFROMBUSINESSPARTNER AS PAYFROMBUSINESSPARTNER, 
        source_data.PAYMENTMETHOD AS PAYMENTMETHOD, 
        source_data.REFERENCECREDITINSURANCECOMPANY AS REFERENCECREDITINSURANCECOMPANY, 
        source_data.RETURNLATEPAYMENTSURCHARGE AS RETURNLATEPAYMENTSURCHARGE, 
        source_data.RETURNPAYMENTMETHOD AS RETURNPAYMENTMETHOD, 
        source_data.RETURNTERMSOFPAYMENT AS RETURNTERMSOFPAYMENT, 
        source_data.SEARCHKEY AS SEARCHKEY, 
        source_data.STARTDATE AS STARTDATE, 
        source_data.STATEMENTMETHOD AS STATEMENTMETHOD, 
        source_data.TAXDESCRIPTION AS TAXDESCRIPTION, 
        source_data.TAXID AS TAXID, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TEXT AS TEXT, 
        source_data.TOLERANCEAMOUNTFORDUEINVOICES AS TOLERANCEAMOUNTFORDUEINVOICES, 
        source_data.TOLERANCEPERCENTAGEFORDUEINVOICES AS TOLERANCEPERCENTAGEFORDUEINVOICES
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
        cast(ALLOWRETRO_BILLINGDESCRIPTION as VARCHAR(16777216)) as ALLOWRETRO_BILLINGDESCRIPTION,
        cast(ALLOWRETRO_BILLINGID as NUMBER(38,0)) as ALLOWRETRO_BILLINGID,
        cast(BPREPORTGROUP as VARCHAR(15)) as BPREPORTGROUP,
        cast(BUSINESSPARTNERSIGNAL as VARCHAR(3)) as BUSINESSPARTNERSIGNAL,
        cast(BUSINESSPARTNERSTATUSDESCRIPTION as VARCHAR(16777216)) as BUSINESSPARTNERSTATUSDESCRIPTION,
        cast(BUSINESSPARTNERSTATUSID as NUMBER(38,0)) as BUSINESSPARTNERSTATUSID,
        cast(BUSINESSPARTNERTYPE as VARCHAR(3)) as BUSINESSPARTNERTYPE,
        cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
        cast(CHARGEINTERESTDESCRIPTION as VARCHAR(16777216)) as CHARGEINTERESTDESCRIPTION,
        cast(CHARGEINTERESTID as NUMBER(38,0)) as CHARGEINTERESTID,
        cast(CONTACTCODE as VARCHAR(9)) as CONTACTCODE,
        cast(CREDITANALYST as VARCHAR(6)) as CREDITANALYST,
        cast(CREDITBUREAUREFERENCENUMBER as VARCHAR(30)) as CREDITBUREAUREFERENCENUMBER,
        cast(CREDITINSURANCECOMPANY as VARCHAR(3)) as CREDITINSURANCECOMPANY,
        cast(CREDITLIMIT as NUMBER(15,2)) as CREDITLIMIT,
        cast(CREDITLIMITEXPIRESON as TIMESTAMP_NTZ(9)) as CREDITLIMITEXPIRESON,
        cast(CREDITLIMITINSURED as NUMBER(15,2)) as CREDITLIMITINSURED,
        cast(CREDITRATING as VARCHAR(3)) as CREDITRATING,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DATEINVOICED as TIMESTAMP_NTZ(9)) as DATEINVOICED,
        cast(DATELASTCREDITREVIEW as TIMESTAMP_NTZ(9)) as DATELASTCREDITREVIEW,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(EXPIRYDATEOFINSUREDCREDITLIMIT as TIMESTAMP_NTZ(9)) as EXPIRYDATEOFINSUREDCREDITLIMIT,
        cast(FINANCIALCUSTOMERGROUP as VARCHAR(3)) as FINANCIALCUSTOMERGROUP,
        cast(HIGHESTCREDITUSEDSINCEDATELASTCREDITREVIEW as NUMBER(15,2)) as HIGHESTCREDITUSEDSINCEDATELASTCREDITREVIEW,
        cast(INVOICEDELIVERYMETHOD as VARCHAR(3)) as INVOICEDELIVERYMETHOD,
        cast(INVOICEINTERVAL as NUMBER(38,0)) as INVOICEINTERVAL,
        cast(INVOICETOBUSINESSPARTNER as VARCHAR(9)) as INVOICETOBUSINESSPARTNER,
        cast(INVOICINGMETHOD as VARCHAR(3)) as INVOICINGMETHOD,
        cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
        cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
        cast(NUMBEROFEXTRAINVOICECOPIES as NUMBER(38,0)) as NUMBEROFEXTRAINVOICECOPIES,
        cast(PAYFROMBUSINESSPARTNER as VARCHAR(9)) as PAYFROMBUSINESSPARTNER,
        cast(PAYMENTMETHOD as VARCHAR(3)) as PAYMENTMETHOD,
        cast(REFERENCECREDITINSURANCECOMPANY as VARCHAR(15)) as REFERENCECREDITINSURANCECOMPANY,
        cast(RETURNLATEPAYMENTSURCHARGE as VARCHAR(3)) as RETURNLATEPAYMENTSURCHARGE,
        cast(RETURNPAYMENTMETHOD as VARCHAR(3)) as RETURNPAYMENTMETHOD,
        cast(RETURNTERMSOFPAYMENT as VARCHAR(3)) as RETURNTERMSOFPAYMENT,
        cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(STATEMENTMETHOD as VARCHAR(3)) as STATEMENTMETHOD,
        cast(TAXDESCRIPTION as VARCHAR(16777216)) as TAXDESCRIPTION,
        cast(TAXID as NUMBER(38,0)) as TAXID,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(TOLERANCEAMOUNTFORDUEINVOICES as NUMBER(15,2)) as TOLERANCEAMOUNTFORDUEINVOICES,
        cast(TOLERANCEPERCENTAGEFORDUEINVOICES as NUMBER(15,2)) as TOLERANCEPERCENTAGEFORDUEINVOICES,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data