{{ config(
      materialized='view',
      alias='CUSTOMER_GROUP',
      transient=false
) }}



with source_data as
(
    SELECT
        CUSTCODE,
        FINANCE,
        PARTS,
        SERVICE,
        SALES,
        CREATEDATE,
        CUSTNAME
    FROM {{ ref('ODS__LEGACY93__CUSTOMER_GROUP') }}
)

,transform_data AS
(
    select * from source_data
)

    select * from transform_data