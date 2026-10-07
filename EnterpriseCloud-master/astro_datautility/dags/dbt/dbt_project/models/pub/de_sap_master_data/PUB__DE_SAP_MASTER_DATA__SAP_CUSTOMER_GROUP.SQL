{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_CUSTOMER_GROUP',
      transient=false
) }}

with source_data as (
    SELECT
		  CUSTOMER_CODE,
		  CUSTOMER_GROUP,
		  CUSTOMER_NAME,
		  CORPORATION_CODE,
		  SEARCH_TERM1,
		  SEARCH_TERM2,
		  NAME_1,
		  NAME_2,
		  STREET_AND_HOUSE_NUMBER,
		  REGION,
		  CITY,
		  POSTAL_CODE,
		  COUNTRY,
		  CUSTOMER_FLAG,
		  VENDOR_FLAG,
		  SORT_FIELD,
		  CUSTOMER_CODE_TYPE_NAME,
		  CUSTOMER_CODE_TYPE,
		  BUSINESS_PARTNER_CATEGORY,
		  PORT
    from {{ ref('COMMON__SAPH__SAP_CUSTOMER_GROUP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data