{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='BAANV_TEA_CUSTOMERS'
) }} 


with source_data as
(
    SELECT 
            a.INVOICETOBUSINESSPARTNER AS Customer_Code,
            b.NAME AS Customer,
            c.NAME AS Address_Name,
            c.ADDRESS AS Address,
            c.CITY AS City,
            c.STATEPROVINCE AS State_Province,
            c.ZIPCODEPOSTALCODE AS Postal_Code,
            c.COUNTRY AS Country,
            c.TELEPHONE AS Telephone,
            c.FAX AS Fax,
            b.CURRENCY AS Currency,
            d.TERMSOFDELIVERY AS Terms_of_Delivery,
            d.ORDER_DISCOUNT AS Order_Discount,
            d.LINEOFBUSINESS AS Line_Of_Business,
            d.OURSUPPLIERNUMBER AS Our_Supplier_No,
            d.INTERNALSALESREP AS Sales_Representative,
            MAX(a.DATEINVOICED) AS Date_Invoiced,
            d.SALESPRICELIST AS Customer_Price_List,
            MAX(a.CREDITLIMIT) AS Credit_Limit,
            a.BUSINESSPARTNERSTATUSDESCRIPTION AS Inv_to_BP_Status,
            b.BUSINESSPARTNERSTATUSDESCRIPTION AS General_BP_Status 
       FROM {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS') }} a     
            INNER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}  b  
                                     ON a.INVOICETOBUSINESSPARTNER = b.BUSINESSPARTNER
            LEFT OUTER JOIN {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_ADDRESSES') }}  c ON a.ADDRESSCODE = c.ADDRESSCODE
            LEFT OUTER JOIN (  SELECT INVOICETOBUSINESSPARTNER,
                                      MAX (TERMSOFDELIVERY) TERMSOFDELIVERY,
                                      ORDER_DISCOUNT,
                                      LINEOFBUSINESS,
                                      OURSUPPLIERNUMBER,
                                      INTERNALSALESREP,
                                      MAX (SALESPRICELIST) SALESPRICELIST
                                 FROM {{ ref('BRONZE__TEA_SPARES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} 
                             GROUP BY INVOICETOBUSINESSPARTNER,
                                      ORDER_DISCOUNT,
                                      LINEOFBUSINESS,
                                      OURSUPPLIERNUMBER,
                                      INTERNALSALESREP) d
               ON a.INVOICETOBUSINESSPARTNER = d.INVOICETOBUSINESSPARTNER
        GROUP BY 
          a.INVOICETOBUSINESSPARTNER,
          b.NAME,
          c.NAME,
          c.ADDRESS,
          c.CITY,
          c.STATEPROVINCE,
          c.ZIPCODEPOSTALCODE,
          c.COUNTRY,
          c.TELEPHONE,
          c.FAX,
          b.CURRENCY,
          d.TERMSOFDELIVERY,
          d.ORDER_DISCOUNT,
          d.LINEOFBUSINESS,
          d.OURSUPPLIERNUMBER,
          d.INTERNALSALESREP,
          d.SALESPRICELIST,
          a.BUSINESSPARTNERSTATUSDESCRIPTION,
          b.BUSINESSPARTNERSTATUSDESCRIPTION

)

,transform_data as 
(
     SELECT 
          '{{ invocation_id }}' AS _AUDIT_LOG_ID,
          SHA2('hash_me') as _ROW_HASH,
          CUSTOMER_CODE,
          CUSTOMER,
          ADDRESS_NAME,
          ADDRESS,
          CITY,
          STATE_PROVINCE,
          POSTAL_CODE,
          COUNTRY,
          TELEPHONE,
          FAX,
          CURRENCY,
          TERMS_OF_DELIVERY,
          ORDER_DISCOUNT,
          LINE_OF_BUSINESS,
          OUR_SUPPLIER_NO,
          SALES_REPRESENTATIVE,
          DATE_INVOICED,
          CUSTOMER_PRICE_LIST,
          CREDIT_LIMIT,
          INV_TO_BP_STATUS,
          GENERAL_BP_STATUS
     FROM source_data
)

,type_data as 
(
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        CUSTOMER_CODE,
        CUSTOMER,
        ADDRESS_NAME,
        ADDRESS,
        CITY,
        STATE_PROVINCE,
        POSTAL_CODE,
        COUNTRY,
        TELEPHONE,
        FAX,
        CURRENCY,
        TERMS_OF_DELIVERY,
        ORDER_DISCOUNT,
        LINE_OF_BUSINESS,
        OUR_SUPPLIER_NO,
        SALES_REPRESENTATIVE,
        DATE_INVOICED,
        CUSTOMER_PRICE_LIST,
        CREDIT_LIMIT,
        INV_TO_BP_STATUS,
        GENERAL_BP_STATUS
    from transform_data
    )
select * from type_data