/************
Model file generated from dbtGeneratePubViews: 02.10.2023.12.59.23"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_PRHI_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        POSNR,
        PSPHI,
        UP,
        DOWN,
        RIGHT,
        LEFT,
        PBUKR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_PRHI_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data