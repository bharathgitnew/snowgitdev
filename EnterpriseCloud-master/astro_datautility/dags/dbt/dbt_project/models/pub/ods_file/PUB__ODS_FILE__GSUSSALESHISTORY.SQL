/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.19"
*************/

{{ config(
      materialized='view',
      alias='GSUSSALESHISTORY',
      transient=false
) }}

with source_data as (
    SELECT
        FISCALYEAR,
        QUARTER,
        SALESMONTH,
        BUSINESSUNITCODE,
        KA,
        BUSINESSUNITNAME,
        SUBBUSINESSUNITNAME,
        SALESORDERNUMBER,
        ACCOUNTCODE,
        ACCOUNTNAME,
        CUSTOMERCODE,
        CUSTOMERNAME,
        ENDUSERCODE,
        ENDUSERNAME,
        OPPORTUNITY,
        PRODUCTNAME,
        LEVEL,
        LEVEL2,
        SALESAMOUNT,
        DIRECTMARGIN,
        SALESAMOUNT100M,
        DIRECTMARGIN100M,
        QUANTITY,
        EUROPEREQUESTDATE,
        DELIVERYDATE,
        CUSTOMCLEARENCEDATE,
        ONDOCKDATE,
        SALESDATE,
        MACHINESERIALNUMBER,
        SALESCATEGORYCODE,
        SALESCATEGORYNAME,
        AREA,
        AREANAME,
        DISTRIBUTIONFLAG,
        LOANFLAG,
        CSTFLAG,
        INVESTMENTCODE,
        PROCESSOFRECORD,
        BACKUP,
        DEGREEOFSALESUNCERTAINTY,
        INVESTMENTSUBCODE,
        DEVICE1CODE,
        DEVICE1NAME,
        DEVICE2CODE,
        DEVICE2NAME,
        ISINTEL,
        SOURCETYPE,
        FILEDATE
    from {{ ref('ODS__FILE__GSUSSALESHISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data