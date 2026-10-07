/************
Model file generated from dbtGeneratePubViews: 03.21.2023.07.27.28"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T156',
      transient=false
) }}

with source_data as (
    SELECT
        BWART,
        SHKZG,
        KZBWA,
        XSTBW,
        KZMHD,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T156') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data