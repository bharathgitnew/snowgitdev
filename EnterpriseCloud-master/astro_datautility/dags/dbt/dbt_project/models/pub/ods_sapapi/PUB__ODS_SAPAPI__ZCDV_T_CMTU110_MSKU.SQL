/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.26"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU110_MSKU',
      transient=false
) }}

with source_data as (
    SELECT
        MATNR,
        WERKS,
        CHARG,
        SOBKZ,
        KUNNR,
        LFGJA,
        LFMON,
        KUSPR,
        KULAB,
        KUINS,
        KUVLA,
        KUVIN,
        KUILL,
        KUILQ,
        KUVLL,
        KUVLQ,
        KUFLL,
        KUFLQ,
        KUDLL,
        KUEIN,
        KUVEI,
        ERSDA,
        KUJIN,
        KURUE,
        KUUML,
        SGTSCAT,
        FSHSEASONYEAR,
        FSHSEASON,
        FSHCOLLECTION,
        FSHTHEME,
        FSHSALLOCQTY,
        CWM_KULAB,
        CWM_KUINS,
        CWM_KUEIN,
        CWM_KUUML,
        CWM_KUVLA,
        CWM_KUVIN,
        CWM_KUVEI,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU110_MSKU') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data