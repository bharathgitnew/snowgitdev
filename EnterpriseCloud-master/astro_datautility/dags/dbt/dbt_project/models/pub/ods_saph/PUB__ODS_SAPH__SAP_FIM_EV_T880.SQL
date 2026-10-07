/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.51"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_T880',
      transient=false
) }}

with source_data as (
    SELECT
        RCOMP,
        NAME1,
        CNTRY,
        NAME2,
        LANGU,
        STRET,
        POBOX,
        PSTLC,
        CITY,
        CURR,
        MODCP,
        GLSIP,
        RESTA,
        RFORM,
        ZWEIG,
        MCOMP,
        MCLNT,
        LCCOMP,
        STRT2,
        INDPO,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_T880') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data