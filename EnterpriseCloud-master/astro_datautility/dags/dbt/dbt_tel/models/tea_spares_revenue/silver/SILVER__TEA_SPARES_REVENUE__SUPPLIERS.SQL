{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SUPPLIERS'
) }}

with source_data as
(       
    SELECT DISTINCT
           a.InvoiceFromBusinessPartner
               AS Supplier_Code,
           d.NAME
               AS Supplier,
           c.NAME
               AS Address_Name,
           c.ADDRESS
               AS Address,
           c.CITY
               AS City,
           c.STATEPROVINCE
               AS State_Province,
           c.ZIPCODEPOSTALCODE
               AS Postal_Code,
           c.COUNTRY
               AS Country,
           c.TELEPHONE
               AS Telephone,
           c.FAX
               AS Fax,
           c.TAXNUMBER
               AS Tax_Number,
            c.VERIFICATIONDATE
               AS Verification_Date,
           a.Currency
               AS Currency,
           a.TermsOfPayment
               AS Terms_of_Payment,
           a.FinancialSupplierGroup
               AS Financial_Supplier_Group,
           a.BusinessPartnerStatusDescription
               AS Supplier_Status,
           e.WAREHOUSE
               AS Ship_From_Data,
           b.LINEOFBUSINESS
               AS Line_of_Business,
           b.PURCHASEPRICELIST
               AS Purchase_Price_List,
           f.PRICEBOOK
               AS Price_Book,
           g._1099NAME
               AS Supplier_Name_1099,
           g.ADDRESSCODE
               AS Supplier_Address_Code_1099,
           h.ADDRESS
               AS Supplier_Address_1099,
           h.CITY
               AS Supplier_City_1099,
           h.ZIPCODEPOSTALCODE
               AS Supplier_Postal_Code_1099,
           g.PAYEENAMECONTROL
               AS Payee_Name_Control,
           g.FOREIGNNON_USENTITYDESCRIPTION
               AS Foreign_Entity,
           g.INCOMETAXTYPE
               AS Income_Tax_Type,
           g.ACCOUNTNUMBER1099
               AS Account_No_1099,
           g._1NDTINDESCRIPTION
               AS Tin_2nd,
           g.REASONFORPAYMENTS
               AS Reason_for_Payment,
           i.DESCRIPTION
               AS Business_Partner_Type,
           b.COMMODITYCODE
               AS Commodity_Code,
           b.SUBCOMMODITYCODE
               AS Sub_Commodity_Code,
           d.BUSINESSPARTNERSTATUSDESCRIPTION
               AS General_BP_Status                              
      FROM {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS') }}  a                    -- Invoice-From Business Partner
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS') }} b     -- Buy-From Business Partner
                                          ON a.InvoiceFromBusinessPartner = b.BUYFROMBUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_ADDRESSES') }} c                         -- Addresses
                                          ON a.ADDRESSCODE = c.ADDRESSCODE
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}  d         -- Generic Business Partners
                                          ON a.InvoiceFromBusinessPartner = d.BUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS') }}  e                      -- Ship From BP
                                          ON a.InvoiceFromBusinessPartner = e.SHIPFROMBUSINESSPARTNER
           LEFT OUTER JOIN
           (SELECT DISTINCT b.PRICEBOOK, a.BUYFROMPARTNER
              FROM {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES') }}  a
                   /* Price Matrices */
                   JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS') }} b
                       /* Price Books */
                       ON     a.PRICEBOOKORIGINID = b.PRICEBOOKORIGINID
                          AND a.PRICEBOOK = b.PRICEBOOK
                          AND a.EXPIRATIONDATE = TO_DATE ('01/01/1970', 'MM/DD/YYYY'))
           f
               ON a.InvoiceFromBusinessPartner = f.BUYFROMPARTNER
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNER1099DETAILS') }}  g         /* Pay-to BP 1099 Details */
                                          ON a.InvoiceFromBusinessPartner = g.PAYTOBUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_ADDRESSES') }}  h                         -- Addresses
                                          ON g.ADDRESSCODE = h.ADDRESSCODE
           LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES') }}  i            -- Business Partner Types
                                          ON b.BUSINESSPARTNERTYPE = i.BUSINESSPARTNERTYPE


    )

,transform_data as(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        SUPPLIER_CODE,
        SUPPLIER,
        ADDRESS_NAME,
        ADDRESS,
        CITY,
        STATE_PROVINCE,
        POSTAL_CODE,
        COUNTRY,
        TELEPHONE,
        FAX,
        TAX_NUMBER,
        VERIFICATION_DATE,
        CURRENCY,
        TERMS_OF_PAYMENT,
        FINANCIAL_SUPPLIER_GROUP,
        SUPPLIER_STATUS,
        SHIP_FROM_DATA,
        LINE_OF_BUSINESS,
        PURCHASE_PRICE_LIST,
        PRICE_BOOK,
        SUPPLIER_NAME_1099,
        SUPPLIER_ADDRESS_CODE_1099,
        SUPPLIER_ADDRESS_1099,
        SUPPLIER_CITY_1099,
        SUPPLIER_POSTAL_CODE_1099,
        PAYEE_NAME_CONTROL,
        FOREIGN_ENTITY,
        INCOME_TAX_TYPE,
        ACCOUNT_NO_1099,
        TIN_2ND,
        REASON_FOR_PAYMENT,
        BUSINESS_PARTNER_TYPE,
        COMMODITY_CODE,
        SUB_COMMODITY_CODE,
        GENERAL_BP_STATUS
    FROM source_data
)
,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SUPPLIER_CODE,
        SUPPLIER,
        ADDRESS_NAME,
        ADDRESS,
        CITY,
        STATE_PROVINCE,
        POSTAL_CODE,
        COUNTRY,
        TELEPHONE,
        FAX,
        TAX_NUMBER,
        cast(VERIFICATION_DATE as TIMESTAMP_NTZ(9)) as VERIFICATION_DATE,
        CURRENCY,
        TERMS_OF_PAYMENT,
        FINANCIAL_SUPPLIER_GROUP,
        SUPPLIER_STATUS,
        SHIP_FROM_DATA,
        LINE_OF_BUSINESS,
        PURCHASE_PRICE_LIST,
        PRICE_BOOK,
        SUPPLIER_NAME_1099,
        SUPPLIER_ADDRESS_CODE_1099,
        SUPPLIER_ADDRESS_1099,
        SUPPLIER_CITY_1099,
        SUPPLIER_POSTAL_CODE_1099,
        PAYEE_NAME_CONTROL,
        FOREIGN_ENTITY,
        INCOME_TAX_TYPE,
        ACCOUNT_NO_1099,
        TIN_2ND,
        REASON_FOR_PAYMENT,
        BUSINESS_PARTNER_TYPE,
        COMMODITY_CODE,
        SUB_COMMODITY_CODE,
        GENERAL_BP_STATUS
    from transform_data
    )
select * from type_data