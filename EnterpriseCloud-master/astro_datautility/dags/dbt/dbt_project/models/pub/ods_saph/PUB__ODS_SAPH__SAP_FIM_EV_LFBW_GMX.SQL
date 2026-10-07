/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.45"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_LFBW_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        LIFNR,
        BUKRS,
        WITHT,
        WT_SUBJCT,
        QSREC,
        WT_WTSTCD,
        WT_WITHCD,
        WT_EXNR,
        WT_EXRT,
        WT_EXDF,
        WT_EXDT,
        WT_WTEXRS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_LFBW_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data