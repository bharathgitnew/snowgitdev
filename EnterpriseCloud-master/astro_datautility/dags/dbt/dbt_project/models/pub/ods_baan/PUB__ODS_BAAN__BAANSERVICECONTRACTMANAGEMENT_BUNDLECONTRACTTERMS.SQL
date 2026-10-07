/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.19"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        AMOUNT1,
        AMOUNT10,
        AMOUNT2,
        AMOUNT3,
        AMOUNT4,
        AMOUNT5,
        AMOUNT6,
        AMOUNT7,
        AMOUNT8,
        AMOUNT9,
        CONTRACTEFFECTIVEDATE,
        CONTRACTEXPIRYDATE,
        CONTRACTTERM1,
        CONTRACTTERM10,
        CONTRACTTERM2,
        CONTRACTTERM3,
        CONTRACTTERM4,
        CONTRACTTERM5,
        CONTRACTTERM6,
        CONTRACTTERM7,
        CONTRACTTERM8,
        CONTRACTTERM9,
        FLEXSUPPORTHOURS,
        INSTALLMENT_PERCENT_1,
        INSTALLMENT_PERCENT_10,
        INSTALLMENT_PERCENT_2,
        INSTALLMENT_PERCENT_3,
        INSTALLMENT_PERCENT_4,
        INSTALLMENT_PERCENT_5,
        INSTALLMENT_PERCENT_6,
        INSTALLMENT_PERCENT_7,
        INSTALLMENT_PERCENT_8,
        INSTALLMENT_PERCENT_9,
        NOOFFES,
        PRODUCTTYPE1,
        PRODUCTTYPE10,
        PRODUCTTYPE2,
        PRODUCTTYPE3,
        PRODUCTTYPE4,
        PRODUCTTYPE5,
        PRODUCTTYPE6,
        PRODUCTTYPE7,
        PRODUCTTYPE8,
        PRODUCTTYPE9,
        SEQUENCENUMBER,
        SERVICECONTRACT,
        STATUSDESCRIPTION,
        STATUSID
    from {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data