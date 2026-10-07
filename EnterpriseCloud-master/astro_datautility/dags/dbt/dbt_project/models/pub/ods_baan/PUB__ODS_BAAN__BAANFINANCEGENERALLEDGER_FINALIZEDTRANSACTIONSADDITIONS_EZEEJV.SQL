/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.13"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BACKGROUNDSEQUENCENO,
        DATEMODIFIED,
        DOCUMENT,
        INVOICETOBUSINESSPARTNER,
        LINENUMBER,
        MACHINESRNO,
        SEQUENCENUMBER,
        SERVICECONTRACT,
        SERVICEORDER,
        SOLDTOBUSINESSPARTNER,
        TRANSACTIONTYPE
    from {{ ref('ODS__BAAN__BAANFINANCEGENERALLEDGER_FINALIZEDTRANSACTIONSADDITIONS_EZEEJV') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data