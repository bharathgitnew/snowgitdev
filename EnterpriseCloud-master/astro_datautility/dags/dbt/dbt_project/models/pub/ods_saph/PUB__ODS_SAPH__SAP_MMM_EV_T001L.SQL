/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.45"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T001L',
      transient=false
) }}

with source_data as (
    SELECT
        WERKS,
        LGORT,
        LGOBE,
        SPART,
        DISKZ,
        VKORG,
        VTWEG,
        VSTEL,
        LIFNR,
        KUNNR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T001L') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data