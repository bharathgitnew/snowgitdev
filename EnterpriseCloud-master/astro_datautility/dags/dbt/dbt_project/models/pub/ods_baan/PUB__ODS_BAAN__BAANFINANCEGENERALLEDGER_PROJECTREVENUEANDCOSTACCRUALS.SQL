/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.16"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNT,
        COSTCOMPONENT,
        CREATIONDATE,
        DEBITCREDITDESCRIPTION,
        DEBITCREDITID,
        DIMENSION1,
        DIMENSION2,
        DIMENSION3,
        DIMENSION4,
        DIMENSION5,
        DOCUMENT,
        FINANCIALTRANSACTIONDESCRIPTION,
        FINANCIALTRANSACTIONID,
        LEDGERACCOUNT,
        LINENUMBER_LINO,
        LINENUMBER_RLIN,
        POSITION,
        PROJECT,
        RECONCILIATIONDATE,
        RECONCILIATIONDOCUMENT,
        RECONCILIATIONTRANSACTIONTYPE,
        SALESORDER,
        SEQUENCENUMBER,
        TRANSACTIONORIGINDESCRIPTION,
        TRANSACTIONORIGINID,
        TRANSACTIONTYPE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_PROJECTREVENUEANDCOSTACCRUALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data