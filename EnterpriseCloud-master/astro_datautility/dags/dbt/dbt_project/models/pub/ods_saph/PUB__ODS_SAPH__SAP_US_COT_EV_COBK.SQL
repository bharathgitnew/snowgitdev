/************
Model file generated from dbtGeneratePubViews: 10.11.2022.09.06.57"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_COT_EV_COBK',
      transient=false
) }}

with source_data as (
    SELECT
        KOKRS,
        BELNR,
        GJAHR,
        VERSN,
        VRGNG,
        TIMESTMP,
        PERAB,
        PERBI,
        BLDAT,
        BUDAT,
        CPUDT,
        USNAM,
        BLTXT,
        STFLG,
        STOKZ,
        REFBT,
        REFBN,
        REFBK,
        REFGJ,
        BLART,
        ORGVG,
        SUMBZ,
        DELBZ,
        WSDAT,
        KURST,
        KWAER,
        AWTYP,
        AWORG,
        LOGSYSTEM,
        CPUTM,
        ALEBZ,
        ALEBN,
        AWSYS,
        AWREF_REV,
        AWORG_REV,
        ZBELNR_FI,
        ZBUKRS_FI,
        ZGJAHR_FI,
        BUKRS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_COT_EV_COBK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data