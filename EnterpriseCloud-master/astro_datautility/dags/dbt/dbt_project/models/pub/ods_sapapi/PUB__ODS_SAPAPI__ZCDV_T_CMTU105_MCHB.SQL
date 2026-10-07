/************
Model file generated from dbtGeneratePubViews: 03.03.2023.02.18.25"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU105_MCHB',
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
        CUMLM,
        CINSM,
        CEINM,
        CSPEM,
        CRETM,
        CVMLA,
        CVMUM,
        CVMIN,
        CVMEI,
        CVMSP,
        CVMRE,
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
        SGTSCAT,
        FSHSEASONYEAR,
        FSHSEASON,
        FSHCOLLECTION,
        FSHTHEME,
        FSHSALLOCQTY,
        CWM_CLABS,
        CWM_CINSM,
        CWM_CEINM,
        CWM_CSPEM,
        CWM_CRETM,
        CWM_CUMLM,
        CWM_CVMLA,
        CWM_CVMIN,
        CWM_CVMEI,
        CWM_CVMSP,
        CWM_CVMRE,
        CWM_CVMUM,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU105_MCHB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data