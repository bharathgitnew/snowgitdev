/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS.SQL 
-materialized incremental
-alias BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS 
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
    alias='BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS',
    unique_key = ['FINANCIALCOMPANY',
    'SALESINVOICEDOCUMENTNUMBER',
    'SALESINVOICETRANSACTIONTYPE']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AAAI AS NUMERIC(15,2))                                                                                                       AS ADVANCEAMOUNTALREADYINVOICED 
            ,CAST(T$ATBI AS NUMERIC(15,2))                                                                                                       AS ADVANCEAMOUNTTOBEINVOICED 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVOICECURRENCY 
            ,CAST(T$BRID AS BIGINT)                                                                                                              AS BILLINGREQUEST 
            ,CAST(T$BAMT AS NUMERIC(15,2))                                                                                                       AS BLOCKEDAMOUNT 
            ,CAST(T$CSAI AS NUMERIC(15,2))                                                                                                       AS COSTAMOUNTINVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS DEPARTMENT 
            ,CAST(T$DCAI AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNTINVOICECURRENCY 
            ,T$DOCT.CONSTANTDESCRIPTION                                                                                                          AS DOCUMENTTYPEDESCRIPTION 
            ,CAST(T$DOCT AS INT)                                                                                                                 AS DOCUMENTTYPEID 
            ,T$EDPR.CONSTANTDESCRIPTION                                                                                                          AS EDIORPRINTINVOICEDESCRIPTION 
            ,CAST(T$EDPR AS INT)                                                                                                                 AS EDIORPRINTINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$SFCP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST(T$GDAI AS NUMERIC(15,2))                                                                                                       AS ODSAMOUNTINVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS INVOICECURRENCY 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CIDM)),'')                                                                                         AS INVOICEDELIVERYMETHOD 
            ,CAST(T$INII AS NUMERIC(15,2))                                                                                                       AS INVOICEDINSTALLMENTSINV_CURR 
            ,CAST(CASE WHEN T$D1DT<= '1/1/1970' THEN NULL ELSE T$D1DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D1DT 
            ,CAST(CASE WHEN T$D2DT<= '1/1/1970' THEN NULL ELSE T$D2DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D2DT 
            ,CAST(CASE WHEN T$D3DT<= '1/1/1970' THEN NULL ELSE T$D3DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D3DT 
            ,CAST("T$D1AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY1 
            ,CAST("T$D1AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY2 
            ,CAST("T$D1AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY3 
            ,CAST("T$D2AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_1 
            ,CAST("T$D2AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_2 
            ,CAST("T$D2AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_3 
            ,CAST("T$D3AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_1 
            ,CAST("T$D3AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_2 
            ,CAST("T$D3AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_3 
            ,CAST(T$D1AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D1AI 
            ,CAST(T$D2AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D2AI 
            ,CAST(T$D3AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D3AI 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS INVOICESTATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS INVOICESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITOA)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(T$SCAI AS NUMERIC(15,2))                                                                                                       AS LATEPAYMENTSURCHARGEAMOUNT 
            ,CAST(CASE WHEN T$SCDT<= '1/1/1970' THEN NULL ELSE T$SCDT  END AS DATETIME) AS LATEPAYMENTSURCHARGEDATE 
            ,CAST("T$SCAH$1" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR1 
            ,CAST("T$SCAH$2" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR2 
            ,CAST("T$SCAH$3" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR3 
            ,CAST(T$NMSI AS BIGINT)                                                                                                              AS NOMANUALSALESINVOICELINES 
            ,CAST(T$NIIV AS BIGINT)                                                                                                              AS NOOFINTERESTINVOICELINES 
            ,CAST(T$NPRJ AS BIGINT)                                                                                                              AS NOOFPROJECTINVOICELINES 
            ,CAST(T$NSLO AS BIGINT)                                                                                                              AS NOSALESORDERINVOICELINES 
            ,CAST(T$NSCO AS BIGINT)                                                                                                              AS NOSERVICECONTRACTINVOICELINES 
            ,CAST(T$NSVO AS BIGINT)                                                                                                              AS NOSERVICEORDERINVOICELINES 
            ,CAST(T$NWHO AS BIGINT)                                                                                                              AS NOWAREHOUSEORDERINVOICELINES 
            ,CAST(T$OPAI AS NUMERIC(15,2))                                                                                                       AS OVERPAIDININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATORDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS RATEDETERMINATORID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,CAST(T$RMAI AS NUMERIC(15,2))                                                                                                       AS REMAININGAMOUNT 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS SALESINVOICECOMPANY 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS SALESINVOICEDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS SALESINVOICETRANSACTIONTYPE 
            ,CAST("T$STAH$1" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1 
            ,CAST("T$STAH$2" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2 
            ,CAST("T$STAH$3" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3 
            ,CAST(T$STAI AS NUMERIC(15,2))                                                                                                       AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STOA)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,CAST("T$TXAH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$TXAH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$TXAH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTININVOICECURRENCY 
            ,CAST(T$TBAI AS NUMERIC(15,2))                                                                                                       AS TAXBASEAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCT)),'')                                                                                         AS TAXCOUNTRY 
            ,CAST(CASE WHEN T$TXDT<= '1/1/1970' THEN NULL ELSE T$TXDT  END AS DATETIME) AS TAXDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,CAST(T$TBII AS NUMERIC(15,2))                                                                                                       AS TOBEINVOICEDINSTALLMENTSINV_CURR 
            ,CAST(T$PCBA AS NUMERIC(15,2))                                                                                                       AS WAGEB_ACCOUNT 
            ,CAST(T$WAMT AS NUMERIC(15,2))                                                                                                       AS WAGEPARTAMOUNT 
            ,CAST(T$PCWA AS NUMERIC(15,2))                                                                                                       AS WAGEPARTOFCONTRACTACCOUNT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI205200") }} AS SOURCETABLE  
            /*DOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DOCT 
             ON   T$DOCT.TABLENAME  = 'CISLI205' 
              AND T$DOCT.COLUMNNAME = 'T$DOCT' 
              AND T$DOCT.CONSTANT   = SOURCETABLE.T$DOCT 
            /*EDIORPRINTINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EDPR 
             ON   T$EDPR.TABLENAME  = 'CISLI205' 
              AND T$EDPR.COLUMNNAME = 'T$EDPR' 
              AND T$EDPR.CONSTANT   = SOURCETABLE.T$EDPR 
            /*INVOICESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI205' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*RATEDETERMINATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'CISLI205' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$AAAI AS NUMERIC(15,2))                                                                                                       AS ADVANCEAMOUNTALREADYINVOICED 
            ,CAST(T$ATBI AS NUMERIC(15,2))                                                                                                       AS ADVANCEAMOUNTTOBEINVOICED 
            ,CAST("T$AMTH$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY1 
            ,CAST("T$AMTH$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY2 
            ,CAST("T$AMTH$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNTINHOMECURRENCY3 
            ,CAST(T$AMTI AS NUMERIC(15,2))                                                                                                       AS AMOUNTININVOICECURRENCY 
            ,CAST(T$BRID AS BIGINT)                                                                                                              AS BILLINGREQUEST 
            ,CAST(T$BAMT AS NUMERIC(15,2))                                                                                                       AS BLOCKEDAMOUNT 
            ,CAST(T$CSAI AS NUMERIC(15,2))                                                                                                       AS COSTAMOUNTINVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'')                                                                                         AS DEPARTMENT 
            ,CAST(T$DCAI AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNTINVOICECURRENCY 
            ,T$DOCT.CONSTANTDESCRIPTION                                                                                                          AS DOCUMENTTYPEDESCRIPTION 
            ,CAST(T$DOCT AS INT)                                                                                                                 AS DOCUMENTTYPEID 
            ,T$EDPR.CONSTANTDESCRIPTION                                                                                                          AS EDIORPRINTINVOICEDESCRIPTION 
            ,CAST(T$EDPR AS INT)                                                                                                                 AS EDIORPRINTINVOICEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RTYP)),'')                                                                                         AS EXCHANGERATETYPE 
            ,CAST(T$SFCP AS INT)                                                                                                                 AS FINANCIALCOMPANY 
            ,CAST(T$GDAI AS NUMERIC(15,2))                                                                                                       AS ODSAMOUNTINVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS INVOICECURRENCY 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVOICEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CIDM)),'')                                                                                         AS INVOICEDELIVERYMETHOD 
            ,CAST(T$INII AS NUMERIC(15,2))                                                                                                       AS INVOICEDINSTALLMENTSINV_CURR 
            ,CAST(CASE WHEN T$D1DT<= '1/1/1970' THEN NULL ELSE T$D1DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D1DT 
            ,CAST(CASE WHEN T$D2DT<= '1/1/1970' THEN NULL ELSE T$D2DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D2DT 
            ,CAST(CASE WHEN T$D3DT<= '1/1/1970' THEN NULL ELSE T$D3DT  END AS DATETIME) AS INVOICEDISCOUNTDATE_D3DT 
            ,CAST("T$D1AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY1 
            ,CAST("T$D1AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY2 
            ,CAST("T$D1AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY3 
            ,CAST("T$D2AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_1 
            ,CAST("T$D2AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_2 
            ,CAST("T$D2AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D2AH_3 
            ,CAST("T$D3AH$1" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_1 
            ,CAST("T$D3AH$2" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_2 
            ,CAST("T$D3AH$3" AS NUMERIC(15,2))                                                                                                     AS INVOICEDISCOUNTHOMECURRENCY_D3AH_3 
            ,CAST(T$D1AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D1AI 
            ,CAST(T$D2AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D2AI 
            ,CAST(T$D3AI AS NUMERIC(15,2))                                                                                                       AS INVOICEDISCOUNTINVOICECURRENCY_D3AI 
            ,T$STAT.CONSTANTDESCRIPTION                                                                                                          AS INVOICESTATUSDESCRIPTION 
            ,CAST(T$STAT AS INT)                                                                                                                 AS INVOICESTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITOA)),'')                                                                                         AS INVOICETOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'')                                                                                         AS INVOICETOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCRS)),'')                                                                                         AS LATEPAYMENTSURCHARGE 
            ,CAST(T$SCAI AS NUMERIC(15,2))                                                                                                       AS LATEPAYMENTSURCHARGEAMOUNT 
            ,CAST(CASE WHEN T$SCDT<= '1/1/1970' THEN NULL ELSE T$SCDT  END AS DATETIME) AS LATEPAYMENTSURCHARGEDATE 
            ,CAST("T$SCAH$1" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR1 
            ,CAST("T$SCAH$2" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR2 
            ,CAST("T$SCAH$3" AS NUMERIC(15,2))                                                                                                     AS LATEPAYMENTSURCHARGEHOMECURR3 
            ,CAST(T$NMSI AS BIGINT)                                                                                                              AS NOMANUALSALESINVOICELINES 
            ,CAST(T$NIIV AS BIGINT)                                                                                                              AS NOOFINTERESTINVOICELINES 
            ,CAST(T$NPRJ AS BIGINT)                                                                                                              AS NOOFPROJECTINVOICELINES 
            ,CAST(T$NSLO AS BIGINT)                                                                                                              AS NOSALESORDERINVOICELINES 
            ,CAST(T$NSCO AS BIGINT)                                                                                                              AS NOSERVICECONTRACTINVOICELINES 
            ,CAST(T$NSVO AS BIGINT)                                                                                                              AS NOSERVICEORDERINVOICELINES 
            ,CAST(T$NWHO AS BIGINT)                                                                                                              AS NOWAREHOUSEORDERINVOICELINES 
            ,CAST(T$OPAI AS NUMERIC(15,2))                                                                                                       AS OVERPAIDININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFAD)),'')                                                                                         AS PAYFROMADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PFBP)),'')                                                                                         AS PAYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PAYM)),'')                                                                                         AS PAYMENTMETHOD 
            ,CAST("T$RATE$1" AS NUMERIC(15,2))                                                                                                     AS RATE1 
            ,CAST("T$RATE$2" AS NUMERIC(15,2))                                                                                                     AS RATE2 
            ,CAST("T$RATE$3" AS NUMERIC(15,2))                                                                                                     AS RATE3 
            ,CAST(CASE WHEN T$RATD<= '1/1/1970' THEN NULL ELSE T$RATD  END AS DATETIME) AS RATEDATE 
            ,T$FCRT.CONSTANTDESCRIPTION                                                                                                          AS RATEDETERMINATORDESCRIPTION 
            ,CAST(T$FCRT AS INT)                                                                                                                 AS RATEDETERMINATORID 
            ,CAST("T$RATF$1" AS BIGINT)                                                                                                            AS RATEFACTOR1 
            ,CAST("T$RATF$2" AS BIGINT)                                                                                                            AS RATEFACTOR2 
            ,CAST("T$RATF$3" AS BIGINT)                                                                                                            AS RATEFACTOR3 
            ,CAST(T$RMAI AS NUMERIC(15,2))                                                                                                       AS REMAININGAMOUNT 
            ,CAST(T$SCMP AS INT)                                                                                                                 AS SALESINVOICECOMPANY 
            ,CAST(T$IDOC AS BIGINT)                                                                                                              AS SALESINVOICEDOCUMENTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITYP)),'')                                                                                         AS SALESINVOICETRANSACTIONTYPE 
            ,CAST("T$STAH$1" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1 
            ,CAST("T$STAH$2" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2 
            ,CAST("T$STAH$3" AS NUMERIC(15,2))                                                                                                     AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3 
            ,CAST(T$STAI AS NUMERIC(15,2))                                                                                                       AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STOA)),'')                                                                                         AS SHIPTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'')                                                                                         AS SHIPTOBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFAD)),'')                                                                                         AS SOLDTOADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OFBP)),'')                                                                                         AS SOLDTOBUSINESSPARTNER 
            ,CAST("T$TXAH$1" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY1 
            ,CAST("T$TXAH$2" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY2 
            ,CAST("T$TXAH$3" AS NUMERIC(15,2))                                                                                                     AS TAXAMOUNTINHOMECURRENCY3 
            ,CAST(T$TXAI AS NUMERIC(15,2))                                                                                                       AS TAXAMOUNTININVOICECURRENCY 
            ,CAST(T$TBAI AS NUMERIC(15,2))                                                                                                       AS TAXBASEAMOUNTININVOICECURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TXCT)),'')                                                                                         AS TAXCOUNTRY 
            ,CAST(CASE WHEN T$TXDT<= '1/1/1970' THEN NULL ELSE T$TXDT  END AS DATETIME) AS TAXDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPAY)),'')                                                                                         AS TERMSOFPAYMENT 
            ,CAST(T$TBII AS NUMERIC(15,2))                                                                                                       AS TOBEINVOICEDINSTALLMENTSINV_CURR 
            ,CAST(T$PCBA AS NUMERIC(15,2))                                                                                                       AS WAGEB_ACCOUNT 
            ,CAST(T$WAMT AS NUMERIC(15,2))                                                                                                       AS WAGEPARTAMOUNT 
            ,CAST(T$PCWA AS NUMERIC(15,2))                                                                                                       AS WAGEPARTOFCONTRACTACCOUNT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI205201") }} AS SOURCETABLE  
            /*DOCUMENTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DOCT 
             ON   T$DOCT.TABLENAME  = 'CISLI205' 
              AND T$DOCT.COLUMNNAME = 'T$DOCT' 
              AND T$DOCT.CONSTANT   = SOURCETABLE.T$DOCT 
            /*EDIORPRINTINVOICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EDPR 
             ON   T$EDPR.TABLENAME  = 'CISLI205' 
              AND T$EDPR.COLUMNNAME = 'T$EDPR' 
              AND T$EDPR.CONSTANT   = SOURCETABLE.T$EDPR 
            /*INVOICESTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$STAT 
             ON   T$STAT.TABLENAME  = 'CISLI205' 
              AND T$STAT.COLUMNNAME = 'T$STAT' 
              AND T$STAT.CONSTANT   = SOURCETABLE.T$STAT 
            /*RATEDETERMINATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FCRT 
             ON   T$FCRT.TABLENAME  = 'CISLI205' 
              AND T$FCRT.COLUMNNAME = 'T$FCRT' 
              AND T$FCRT.CONSTANT   = SOURCETABLE.T$FCRT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADVANCEAMOUNTALREADYINVOICED AS ADVANCEAMOUNTALREADYINVOICED, 
        source_data.ADVANCEAMOUNTTOBEINVOICED AS ADVANCEAMOUNTTOBEINVOICED, 
        source_data.AMOUNTINHOMECURRENCY1 AS AMOUNTINHOMECURRENCY1, 
        source_data.AMOUNTINHOMECURRENCY2 AS AMOUNTINHOMECURRENCY2, 
        source_data.AMOUNTINHOMECURRENCY3 AS AMOUNTINHOMECURRENCY3, 
        source_data.AMOUNTININVOICECURRENCY AS AMOUNTININVOICECURRENCY, 
        source_data.BILLINGREQUEST AS BILLINGREQUEST, 
        source_data.BLOCKEDAMOUNT AS BLOCKEDAMOUNT, 
        source_data.COSTAMOUNTINVOICECURRENCY AS COSTAMOUNTINVOICECURRENCY, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.DISCOUNTAMOUNTINVOICECURRENCY AS DISCOUNTAMOUNTINVOICECURRENCY, 
        source_data.DOCUMENTTYPEDESCRIPTION AS DOCUMENTTYPEDESCRIPTION, 
        source_data.DOCUMENTTYPEID AS DOCUMENTTYPEID, 
        source_data.EDIORPRINTINVOICEDESCRIPTION AS EDIORPRINTINVOICEDESCRIPTION, 
        source_data.EDIORPRINTINVOICEID AS EDIORPRINTINVOICEID, 
        source_data.EXCHANGERATETYPE AS EXCHANGERATETYPE, 
        source_data.FINANCIALCOMPANY AS FINANCIALCOMPANY, 
        source_data.ODSAMOUNTINVOICECURRENCY AS ODSAMOUNTINVOICECURRENCY, 
        source_data.INVOICECURRENCY AS INVOICECURRENCY, 
        source_data.INVOICEDATE AS INVOICEDATE, 
        source_data.INVOICEDELIVERYMETHOD AS INVOICEDELIVERYMETHOD, 
        source_data.INVOICEDINSTALLMENTSINV_CURR AS INVOICEDINSTALLMENTSINV_CURR, 
        source_data.INVOICEDISCOUNTDATE_D1DT AS INVOICEDISCOUNTDATE_D1DT, 
        source_data.INVOICEDISCOUNTDATE_D2DT AS INVOICEDISCOUNTDATE_D2DT, 
        source_data.INVOICEDISCOUNTDATE_D3DT AS INVOICEDISCOUNTDATE_D3DT, 
        source_data.INVOICEDISCOUNTHOMECURRENCY1 AS INVOICEDISCOUNTHOMECURRENCY1, 
        source_data.INVOICEDISCOUNTHOMECURRENCY2 AS INVOICEDISCOUNTHOMECURRENCY2, 
        source_data.INVOICEDISCOUNTHOMECURRENCY3 AS INVOICEDISCOUNTHOMECURRENCY3, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D2AH_1 AS INVOICEDISCOUNTHOMECURRENCY_D2AH_1, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D2AH_2 AS INVOICEDISCOUNTHOMECURRENCY_D2AH_2, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D2AH_3 AS INVOICEDISCOUNTHOMECURRENCY_D2AH_3, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D3AH_1 AS INVOICEDISCOUNTHOMECURRENCY_D3AH_1, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D3AH_2 AS INVOICEDISCOUNTHOMECURRENCY_D3AH_2, 
        source_data.INVOICEDISCOUNTHOMECURRENCY_D3AH_3 AS INVOICEDISCOUNTHOMECURRENCY_D3AH_3, 
        source_data.INVOICEDISCOUNTINVOICECURRENCY_D1AI AS INVOICEDISCOUNTINVOICECURRENCY_D1AI, 
        source_data.INVOICEDISCOUNTINVOICECURRENCY_D2AI AS INVOICEDISCOUNTINVOICECURRENCY_D2AI, 
        source_data.INVOICEDISCOUNTINVOICECURRENCY_D3AI AS INVOICEDISCOUNTINVOICECURRENCY_D3AI, 
        source_data.INVOICESTATUSDESCRIPTION AS INVOICESTATUSDESCRIPTION, 
        source_data.INVOICESTATUSID AS INVOICESTATUSID, 
        source_data.INVOICETOADDRESS AS INVOICETOADDRESS, 
        source_data.INVOICETOBUSINESSPARTNER AS INVOICETOBUSINESSPARTNER, 
        source_data.LATEPAYMENTSURCHARGE AS LATEPAYMENTSURCHARGE, 
        source_data.LATEPAYMENTSURCHARGEAMOUNT AS LATEPAYMENTSURCHARGEAMOUNT, 
        source_data.LATEPAYMENTSURCHARGEDATE AS LATEPAYMENTSURCHARGEDATE, 
        source_data.LATEPAYMENTSURCHARGEHOMECURR1 AS LATEPAYMENTSURCHARGEHOMECURR1, 
        source_data.LATEPAYMENTSURCHARGEHOMECURR2 AS LATEPAYMENTSURCHARGEHOMECURR2, 
        source_data.LATEPAYMENTSURCHARGEHOMECURR3 AS LATEPAYMENTSURCHARGEHOMECURR3, 
        source_data.NOMANUALSALESINVOICELINES AS NOMANUALSALESINVOICELINES, 
        source_data.NOOFINTERESTINVOICELINES AS NOOFINTERESTINVOICELINES, 
        source_data.NOOFPROJECTINVOICELINES AS NOOFPROJECTINVOICELINES, 
        source_data.NOSALESORDERINVOICELINES AS NOSALESORDERINVOICELINES, 
        source_data.NOSERVICECONTRACTINVOICELINES AS NOSERVICECONTRACTINVOICELINES, 
        source_data.NOSERVICEORDERINVOICELINES AS NOSERVICEORDERINVOICELINES, 
        source_data.NOWAREHOUSEORDERINVOICELINES AS NOWAREHOUSEORDERINVOICELINES, 
        source_data.OVERPAIDININVOICECURRENCY AS OVERPAIDININVOICECURRENCY, 
        source_data.PAYFROMADDRESS AS PAYFROMADDRESS, 
        source_data.PAYFROMBUSINESSPARTNER AS PAYFROMBUSINESSPARTNER, 
        source_data.PAYMENTMETHOD AS PAYMENTMETHOD, 
        source_data.RATE1 AS RATE1, 
        source_data.RATE2 AS RATE2, 
        source_data.RATE3 AS RATE3, 
        source_data.RATEDATE AS RATEDATE, 
        source_data.RATEDETERMINATORDESCRIPTION AS RATEDETERMINATORDESCRIPTION, 
        source_data.RATEDETERMINATORID AS RATEDETERMINATORID, 
        source_data.RATEFACTOR1 AS RATEFACTOR1, 
        source_data.RATEFACTOR2 AS RATEFACTOR2, 
        source_data.RATEFACTOR3 AS RATEFACTOR3, 
        source_data.REMAININGAMOUNT AS REMAININGAMOUNT, 
        source_data.SALESINVOICECOMPANY AS SALESINVOICECOMPANY, 
        source_data.SALESINVOICEDOCUMENTNUMBER AS SALESINVOICEDOCUMENTNUMBER, 
        source_data.SALESINVOICETRANSACTIONTYPE AS SALESINVOICETRANSACTIONTYPE, 
        source_data.SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1 AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1, 
        source_data.SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2 AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2, 
        source_data.SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3 AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3, 
        source_data.SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI AS SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI, 
        source_data.SHIPTOADDRESS AS SHIPTOADDRESS, 
        source_data.SHIPTOBUSINESSPARTNER AS SHIPTOBUSINESSPARTNER, 
        source_data.SOLDTOADDRESS AS SOLDTOADDRESS, 
        source_data.SOLDTOBUSINESSPARTNER AS SOLDTOBUSINESSPARTNER, 
        source_data.TAXAMOUNTINHOMECURRENCY1 AS TAXAMOUNTINHOMECURRENCY1, 
        source_data.TAXAMOUNTINHOMECURRENCY2 AS TAXAMOUNTINHOMECURRENCY2, 
        source_data.TAXAMOUNTINHOMECURRENCY3 AS TAXAMOUNTINHOMECURRENCY3, 
        source_data.TAXAMOUNTININVOICECURRENCY AS TAXAMOUNTININVOICECURRENCY, 
        source_data.TAXBASEAMOUNTININVOICECURRENCY AS TAXBASEAMOUNTININVOICECURRENCY, 
        source_data.TAXCOUNTRY AS TAXCOUNTRY, 
        source_data.TAXDATE AS TAXDATE, 
        source_data.TERMSOFPAYMENT AS TERMSOFPAYMENT, 
        source_data.TOBEINVOICEDINSTALLMENTSINV_CURR AS TOBEINVOICEDINSTALLMENTSINV_CURR, 
        source_data.WAGEB_ACCOUNT AS WAGEB_ACCOUNT, 
        source_data.WAGEPARTAMOUNT AS WAGEPARTAMOUNT, 
        source_data.WAGEPARTOFCONTRACTACCOUNT AS WAGEPARTOFCONTRACTACCOUNT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADVANCEAMOUNTALREADYINVOICED as NUMBER(15,2)) as ADVANCEAMOUNTALREADYINVOICED,
        cast(ADVANCEAMOUNTTOBEINVOICED as NUMBER(15,2)) as ADVANCEAMOUNTTOBEINVOICED,
        cast(AMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY1,
        cast(AMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY2,
        cast(AMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as AMOUNTINHOMECURRENCY3,
        cast(AMOUNTININVOICECURRENCY as NUMBER(15,2)) as AMOUNTININVOICECURRENCY,
        cast(BILLINGREQUEST as NUMBER(38,0)) as BILLINGREQUEST,
        cast(BLOCKEDAMOUNT as NUMBER(15,2)) as BLOCKEDAMOUNT,
        cast(COSTAMOUNTINVOICECURRENCY as NUMBER(15,2)) as COSTAMOUNTINVOICECURRENCY,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(DISCOUNTAMOUNTINVOICECURRENCY as NUMBER(15,2)) as DISCOUNTAMOUNTINVOICECURRENCY,
        cast(DOCUMENTTYPEDESCRIPTION as VARCHAR(16777216)) as DOCUMENTTYPEDESCRIPTION,
        cast(DOCUMENTTYPEID as NUMBER(38,0)) as DOCUMENTTYPEID,
        cast(EDIORPRINTINVOICEDESCRIPTION as VARCHAR(16777216)) as EDIORPRINTINVOICEDESCRIPTION,
        cast(EDIORPRINTINVOICEID as NUMBER(38,0)) as EDIORPRINTINVOICEID,
        cast(EXCHANGERATETYPE as VARCHAR(3)) as EXCHANGERATETYPE,
        cast(FINANCIALCOMPANY as NUMBER(38,0)) as FINANCIALCOMPANY,
        cast(ODSAMOUNTINVOICECURRENCY as NUMBER(15,2)) as ODSAMOUNTINVOICECURRENCY,
        cast(INVOICECURRENCY as VARCHAR(3)) as INVOICECURRENCY,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICEDELIVERYMETHOD as VARCHAR(3)) as INVOICEDELIVERYMETHOD,
        cast(INVOICEDINSTALLMENTSINV_CURR as NUMBER(15,2)) as INVOICEDINSTALLMENTSINV_CURR,
        cast(INVOICEDISCOUNTDATE_D1DT as TIMESTAMP_NTZ(9)) as INVOICEDISCOUNTDATE_D1DT,
        cast(INVOICEDISCOUNTDATE_D2DT as TIMESTAMP_NTZ(9)) as INVOICEDISCOUNTDATE_D2DT,
        cast(INVOICEDISCOUNTDATE_D3DT as TIMESTAMP_NTZ(9)) as INVOICEDISCOUNTDATE_D3DT,
        cast(INVOICEDISCOUNTHOMECURRENCY1 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY1,
        cast(INVOICEDISCOUNTHOMECURRENCY2 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY2,
        cast(INVOICEDISCOUNTHOMECURRENCY3 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY3,
        cast(INVOICEDISCOUNTHOMECURRENCY_D2AH_1 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D2AH_1,
        cast(INVOICEDISCOUNTHOMECURRENCY_D2AH_2 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D2AH_2,
        cast(INVOICEDISCOUNTHOMECURRENCY_D2AH_3 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D2AH_3,
        cast(INVOICEDISCOUNTHOMECURRENCY_D3AH_1 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D3AH_1,
        cast(INVOICEDISCOUNTHOMECURRENCY_D3AH_2 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D3AH_2,
        cast(INVOICEDISCOUNTHOMECURRENCY_D3AH_3 as NUMBER(15,2)) as INVOICEDISCOUNTHOMECURRENCY_D3AH_3,
        cast(INVOICEDISCOUNTINVOICECURRENCY_D1AI as NUMBER(15,2)) as INVOICEDISCOUNTINVOICECURRENCY_D1AI,
        cast(INVOICEDISCOUNTINVOICECURRENCY_D2AI as NUMBER(15,2)) as INVOICEDISCOUNTINVOICECURRENCY_D2AI,
        cast(INVOICEDISCOUNTINVOICECURRENCY_D3AI as NUMBER(15,2)) as INVOICEDISCOUNTINVOICECURRENCY_D3AI,
        cast(INVOICESTATUSDESCRIPTION as VARCHAR(16777216)) as INVOICESTATUSDESCRIPTION,
        cast(INVOICESTATUSID as NUMBER(38,0)) as INVOICESTATUSID,
        cast(INVOICETOADDRESS as VARCHAR(9)) as INVOICETOADDRESS,
        cast(INVOICETOBUSINESSPARTNER as VARCHAR(9)) as INVOICETOBUSINESSPARTNER,
        cast(LATEPAYMENTSURCHARGE as VARCHAR(3)) as LATEPAYMENTSURCHARGE,
        cast(LATEPAYMENTSURCHARGEAMOUNT as NUMBER(15,2)) as LATEPAYMENTSURCHARGEAMOUNT,
        cast(LATEPAYMENTSURCHARGEDATE as TIMESTAMP_NTZ(9)) as LATEPAYMENTSURCHARGEDATE,
        cast(LATEPAYMENTSURCHARGEHOMECURR1 as NUMBER(15,2)) as LATEPAYMENTSURCHARGEHOMECURR1,
        cast(LATEPAYMENTSURCHARGEHOMECURR2 as NUMBER(15,2)) as LATEPAYMENTSURCHARGEHOMECURR2,
        cast(LATEPAYMENTSURCHARGEHOMECURR3 as NUMBER(15,2)) as LATEPAYMENTSURCHARGEHOMECURR3,
        cast(NOMANUALSALESINVOICELINES as NUMBER(38,0)) as NOMANUALSALESINVOICELINES,
        cast(NOOFINTERESTINVOICELINES as NUMBER(38,0)) as NOOFINTERESTINVOICELINES,
        cast(NOOFPROJECTINVOICELINES as NUMBER(38,0)) as NOOFPROJECTINVOICELINES,
        cast(NOSALESORDERINVOICELINES as NUMBER(38,0)) as NOSALESORDERINVOICELINES,
        cast(NOSERVICECONTRACTINVOICELINES as NUMBER(38,0)) as NOSERVICECONTRACTINVOICELINES,
        cast(NOSERVICEORDERINVOICELINES as NUMBER(38,0)) as NOSERVICEORDERINVOICELINES,
        cast(NOWAREHOUSEORDERINVOICELINES as NUMBER(38,0)) as NOWAREHOUSEORDERINVOICELINES,
        cast(OVERPAIDININVOICECURRENCY as NUMBER(15,2)) as OVERPAIDININVOICECURRENCY,
        cast(PAYFROMADDRESS as VARCHAR(9)) as PAYFROMADDRESS,
        cast(PAYFROMBUSINESSPARTNER as VARCHAR(9)) as PAYFROMBUSINESSPARTNER,
        cast(PAYMENTMETHOD as VARCHAR(3)) as PAYMENTMETHOD,
        cast(RATE1 as NUMBER(15,2)) as RATE1,
        cast(RATE2 as NUMBER(15,2)) as RATE2,
        cast(RATE3 as NUMBER(15,2)) as RATE3,
        cast(RATEDATE as TIMESTAMP_NTZ(9)) as RATEDATE,
        cast(RATEDETERMINATORDESCRIPTION as VARCHAR(16777216)) as RATEDETERMINATORDESCRIPTION,
        cast(RATEDETERMINATORID as NUMBER(38,0)) as RATEDETERMINATORID,
        cast(RATEFACTOR1 as NUMBER(38,0)) as RATEFACTOR1,
        cast(RATEFACTOR2 as NUMBER(38,0)) as RATEFACTOR2,
        cast(RATEFACTOR3 as NUMBER(38,0)) as RATEFACTOR3,
        cast(REMAININGAMOUNT as NUMBER(15,2)) as REMAININGAMOUNT,
        cast(SALESINVOICECOMPANY as NUMBER(38,0)) as SALESINVOICECOMPANY,
        cast(SALESINVOICEDOCUMENTNUMBER as NUMBER(38,0)) as SALESINVOICEDOCUMENTNUMBER,
        cast(SALESINVOICETRANSACTIONTYPE as VARCHAR(3)) as SALESINVOICETRANSACTIONTYPE,
        cast(SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1 as NUMBER(15,2)) as SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_1,
        cast(SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2 as NUMBER(15,2)) as SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_2,
        cast(SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3 as NUMBER(15,2)) as SHIFTEDTAXAMOUNTINHOMECURRENCY_STAH_3,
        cast(SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI as NUMBER(15,2)) as SHIFTEDTAXAMOUNTINHOMECURRENCY_STAI,
        cast(SHIPTOADDRESS as VARCHAR(9)) as SHIPTOADDRESS,
        cast(SHIPTOBUSINESSPARTNER as VARCHAR(9)) as SHIPTOBUSINESSPARTNER,
        cast(SOLDTOADDRESS as VARCHAR(9)) as SOLDTOADDRESS,
        cast(SOLDTOBUSINESSPARTNER as VARCHAR(9)) as SOLDTOBUSINESSPARTNER,
        cast(TAXAMOUNTINHOMECURRENCY1 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY1,
        cast(TAXAMOUNTINHOMECURRENCY2 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY2,
        cast(TAXAMOUNTINHOMECURRENCY3 as NUMBER(15,2)) as TAXAMOUNTINHOMECURRENCY3,
        cast(TAXAMOUNTININVOICECURRENCY as NUMBER(15,2)) as TAXAMOUNTININVOICECURRENCY,
        cast(TAXBASEAMOUNTININVOICECURRENCY as NUMBER(15,2)) as TAXBASEAMOUNTININVOICECURRENCY,
        cast(TAXCOUNTRY as VARCHAR(3)) as TAXCOUNTRY,
        cast(TAXDATE as TIMESTAMP_NTZ(9)) as TAXDATE,
        cast(TERMSOFPAYMENT as VARCHAR(3)) as TERMSOFPAYMENT,
        cast(TOBEINVOICEDINSTALLMENTSINV_CURR as NUMBER(15,2)) as TOBEINVOICEDINSTALLMENTSINV_CURR,
        cast(WAGEB_ACCOUNT as NUMBER(15,2)) as WAGEB_ACCOUNT,
        cast(WAGEPARTAMOUNT as NUMBER(15,2)) as WAGEPARTAMOUNT,
        cast(WAGEPARTOFCONTRACTACCOUNT as NUMBER(15,2)) as WAGEPARTOFCONTRACTACCOUNT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data