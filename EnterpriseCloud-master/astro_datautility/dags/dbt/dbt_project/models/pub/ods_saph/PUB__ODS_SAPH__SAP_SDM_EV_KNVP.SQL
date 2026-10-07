/************
Model file generated from dbtGeneratePubViews: 10.20.2022.09.44.57"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_KNVP',
      transient=false
) }}

with source_data as (
    SELECT
        KUNNR,
        VKORG,
        VTWEG,
        SPART,
        PARVW,
        PARZA,
        KUNN2,
        LIFNR,
        PERNR,
        PARNR,
        KNREF,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_KNVP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data