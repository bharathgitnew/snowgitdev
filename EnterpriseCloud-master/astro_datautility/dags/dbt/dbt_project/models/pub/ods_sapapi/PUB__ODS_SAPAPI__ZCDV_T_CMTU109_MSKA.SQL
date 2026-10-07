/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.24"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU109_MSKA',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        LGORT,
        CHARG,
        SOBKZ,
        VBELN,
        POSNR,
        LFGJA,
        LFMON,
        KASPR,
        KALAB,
        KAINS,
        KASPE,
        KAVLA,
        KAVIN,
        KAVSP,
        KAILL,
        KAILQ,
        KAILS,
        KAVLL,
        KAVLQ,
        KAVLS,
        KAFLL,
        KAFLQ,
        KAFLS,
        KADLL,
        KAEIN,
        KAVEI,
        ERSDA,
        KAJIN,
        KARUE,
        SGTSCAT,
        FSHSEASONYEAR,
        FSHSEASON,
        FSHCOLLECTION,
        FSHTHEME,
        FSHSALLOCQTY,
        CWM_KALAB,
        CWM_KAINS,
        CWM_KASPE,
        CWM_KAEIN,
        CWM_KAVLA,
        CWM_KAVIN,
        CWM_KAVSP,
        CWM_KAVEI,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU109_MSKA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data