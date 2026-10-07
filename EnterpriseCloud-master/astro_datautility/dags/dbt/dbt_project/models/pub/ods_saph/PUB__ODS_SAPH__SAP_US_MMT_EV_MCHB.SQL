/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.48"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMT_EV_MCHB',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        CHARG,
        LVORM,
        ERSDA,
        ERNAM,
        LAEDA,
        AENAM,
        LFGJA,
        LFMON,
        SPERC,
        CLABS,
        MEINS,
        CUMLM,
        MEINS001,
        CINSM,
        MEINS002,
        CEINM,
        MEINS003,
        CSPEM,
        MEINS004,
        CRETM,
        MEINS005,
        CVMLA,
        MEINS006,
        CVMUM,
        MEINS007,
        CVMIN,
        MEINS008,
        CVMEI,
        MEINS009,
        CVMSP,
        MEINS010,
        CVMRE,
        MEINS011,
        KZICL,
        KZICQ,
        KZICE,
        KZICS,
        KZVCL,
        KZVCQ,
        KZVCE,
        KZVCS,
        HERKL,
        CHDLL,
        CHJIN,
        CHRUE,
        ZFPDT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMT_EV_MCHB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data