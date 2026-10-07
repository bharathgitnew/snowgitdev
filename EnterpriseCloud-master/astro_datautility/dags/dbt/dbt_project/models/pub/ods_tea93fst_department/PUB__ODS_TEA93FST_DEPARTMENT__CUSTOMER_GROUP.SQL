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
    FROM {{ ref('ODS__TEA93FST_DEPARTMENT__CUSTOMER_GROUP') }}
)

,transform_data AS
(
    select * from source_data
)

    select * from transform_data