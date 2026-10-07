/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.06"
*************/

{{ config(
      materialized='view',
      alias='BAANDISTRIBUTIONPURCHASECONTROL_LINKEDORDERLINEDATA',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ALTERNATIVE,
        CONFIGURATION,
        CONTRACT,
        OPERATION,
        ORIGINALDOCUMENTTYPEDESCRIPTION,
        ORIGINALDOCUMENTTYPEID,
        ORIGINALORDER,
        POSITIONNUMBER_PONO,
        POSITIONNUMBER_POSI,
        POSITIONNUMBER_QPON,
        POSITIONNUMBER_RETP,
        POSITIONNUMBER_RQPO,
        POSITIONNUMBER_SPON,
        PRODUCTIONORDER,
        PURCHASEOFFICE,
        PURCHASEORDER,
        REQUESTFORQUOTATION,
        REQUISITIONNUMBER,
        RETURNORDER,
        SALESORDER,
        SCHEDULENUMBER,
        SCHEDULEPOSITIONNUMBER,
        SCHEDULEREVISIONNUMBER,
        SEQUENCENUMBER_RETS,
        SEQUENCENUMBER_SQNB,
        SEQUENCENUMBER_SSEQ,
        SERVICE_LINENUMBER,
        SERVICEORDER
    from {{ ref('ODS__BAAN__BAANDISTRIBUTIONPURCHASECONTROL_LINKEDORDERLINEDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data