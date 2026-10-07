/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.58"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MSPR',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        CHARG,
        SOBKZ,
        PSPNR,
        LFGJA,
        LFMON,
        PRLAB,
        MEINS,
        PRINS,
        MEINS001,
        PRSPE,
        MEINS002,
        PREIN,
        MEINS003,
        MEINS004,
        BUKRS,
        WAERS,
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MSPR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data