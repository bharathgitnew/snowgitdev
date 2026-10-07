/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.17"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ERRORCODE1,
        ERRORCODE10,
        ERRORCODE11,
        ERRORCODE12,
        ERRORCODE13,
        ERRORCODE14,
        ERRORCODE15,
        ERRORCODE2,
        ERRORCODE3,
        ERRORCODE4,
        ERRORCODE5,
        ERRORCODE6,
        ERRORCODE7,
        ERRORCODE8,
        ERRORCODE9,
        ERRORMESSAGE1,
        ERRORMESSAGE10,
        ERRORMESSAGE11,
        ERRORMESSAGE12,
        ERRORMESSAGE13,
        ERRORMESSAGE14,
        ERRORMESSAGE15,
        ERRORMESSAGE2,
        ERRORMESSAGE3,
        ERRORMESSAGE4,
        ERRORMESSAGE5,
        ERRORMESSAGE6,
        ERRORMESSAGE7,
        ERRORMESSAGE8,
        ERRORMESSAGE9,
        TRANSACTIONID
    from {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_ERRORCODESDURINGPRE_PROCESSCHECKS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data