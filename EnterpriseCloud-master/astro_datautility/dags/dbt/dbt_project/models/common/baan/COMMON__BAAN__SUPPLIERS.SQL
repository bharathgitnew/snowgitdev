{{ config(
    materialized='incremental',
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
      FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_INVOICEFROMBUSINESSPARTNERS') }}  a                    -- Invoice-From Business Partner
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUYFROMBUSINESSPARTNERS') }} b     -- Buy-From Business Partner
                                          ON a.InvoiceFromBusinessPartner = b.BUYFROMBUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_ADDRESSES') }} c                         -- Addresses
                                          ON a.ADDRESSCODE = c.ADDRESSCODE
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}  d         -- Generic Business Partners
                                          ON a.InvoiceFromBusinessPartner = d.BUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SHIPFROMBUSINESSPARTNERS') }}  e                      -- Ship From BP
                                          ON a.InvoiceFromBusinessPartner = e.SHIPFROMBUSINESSPARTNER
           LEFT OUTER JOIN
           (SELECT DISTINCT b.PRICEBOOK, a.BUYFROMPARTNER
              FROM {{ ref('ODS__BAAN__BAANDISTRIBUTIONPRICINGCONTROL_PRICEMATRICES') }}  a
                   /* Price Matrices */
                   JOIN {{ ref('ODS__BAAN__BAANDISTRIBUTIONPRICINGCONTROL_PRICEBOOKS') }} b
                       /* Price Books */
                       ON     a.PRICEBOOKORIGINID = b.PRICEBOOKORIGINID
                          AND a.PRICEBOOK = b.PRICEBOOK
                          AND a.EXPIRATIONDATE = TO_DATE ('01/01/1970', 'MM/DD/YYYY'))
           f
               ON a.InvoiceFromBusinessPartner = f.BUYFROMPARTNER
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_PAYTOBUSINESSPARTNER1099DETAILS') }}  g         /* Pay-to BP 1099 Details */
                                          ON a.InvoiceFromBusinessPartner = g.PAYTOBUSINESSPARTNER
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_ADDRESSES') }}  h                         -- Addresses
                                          ON g.ADDRESSCODE = h.ADDRESSCODE
           LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES') }}  i            -- Business Partner Types
                                          ON b.BUSINESSPARTNERTYPE = i.BUSINESSPARTNERTYPE


    )

,transform_data as(
    SELECT
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
        GENERAL_BP_STATUS,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(SUPPLIER_CODE as VARCHAR(16777216)) as SUPPLIER_CODE,
        cast(SUPPLIER as VARCHAR(16777216)) as SUPPLIER,
        cast(ADDRESS_NAME as VARCHAR(16777216)) as ADDRESS_NAME,
        cast(ADDRESS as VARCHAR(16777216)) as ADDRESS,
        cast(CITY as VARCHAR(16777216)) as CITY,
        cast(STATE_PROVINCE as VARCHAR(16777216)) as STATE_PROVINCE,
        cast(POSTAL_CODE as VARCHAR(16777216)) as POSTAL_CODE,
        cast(COUNTRY as VARCHAR(16777216)) as COUNTRY,
        cast(TELEPHONE as VARCHAR(16777216)) as TELEPHONE,
        cast(FAX as VARCHAR(16777216)) as FAX,
        cast(TAX_NUMBER as VARCHAR(16777216)) as TAX_NUMBER,
        cast(VERIFICATION_DATE as TIMESTAMP_NTZ(9)) as VERIFICATION_DATE,
        cast(CURRENCY as VARCHAR(16777216)) as CURRENCY,
        cast(TERMS_OF_PAYMENT as VARCHAR(16777216)) as TERMS_OF_PAYMENT,
        cast(FINANCIAL_SUPPLIER_GROUP as VARCHAR(16777216)) as FINANCIAL_SUPPLIER_GROUP,
        cast(SUPPLIER_STATUS as VARCHAR(16777216)) as SUPPLIER_STATUS,
        cast(SHIP_FROM_DATA as VARCHAR(16777216)) as SHIP_FROM_DATA,
        cast(LINE_OF_BUSINESS as VARCHAR(16777216)) as LINE_OF_BUSINESS,
        cast(PURCHASE_PRICE_LIST as VARCHAR(16777216)) as PURCHASE_PRICE_LIST,
        cast(PRICE_BOOK as VARCHAR(16777216)) as PRICE_BOOK,
        cast(SUPPLIER_NAME_1099 as VARCHAR(16777216)) as SUPPLIER_NAME_1099,
        cast(SUPPLIER_ADDRESS_CODE_1099 as VARCHAR(16777216)) as SUPPLIER_ADDRESS_CODE_1099,
        cast(SUPPLIER_ADDRESS_1099 as VARCHAR(16777216)) as SUPPLIER_ADDRESS_1099,
        cast(SUPPLIER_CITY_1099 as VARCHAR(16777216)) as SUPPLIER_CITY_1099,
        cast(SUPPLIER_POSTAL_CODE_1099 as VARCHAR(16777216)) as SUPPLIER_POSTAL_CODE_1099,
        cast(PAYEE_NAME_CONTROL as VARCHAR(16777216)) as PAYEE_NAME_CONTROL,
        cast(FOREIGN_ENTITY as VARCHAR(16777216)) as FOREIGN_ENTITY,
        cast(INCOME_TAX_TYPE as VARCHAR(16777216)) as INCOME_TAX_TYPE,
        cast(ACCOUNT_NO_1099 as VARCHAR(16777216)) as ACCOUNT_NO_1099,
        cast(TIN_2ND as VARCHAR(16777216)) as TIN_2ND,
        cast(REASON_FOR_PAYMENT as VARCHAR(16777216)) as REASON_FOR_PAYMENT,
        cast(BUSINESS_PARTNER_TYPE as VARCHAR(16777216)) as BUSINESS_PARTNER_TYPE,
        cast(COMMODITY_CODE as VARCHAR(16777216)) as COMMODITY_CODE,
        cast(SUB_COMMODITY_CODE as VARCHAR(16777216)) as SUB_COMMODITY_CODE,
        cast(GENERAL_BP_STATUS as VARCHAR(16777216)) as GENERAL_BP_STATUS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data