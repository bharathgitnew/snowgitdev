/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.33"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_TKA02',
      transient=false
) }}

with source_data as (
    SELECT
        BUKRS,
        GSBER,
        KOKRS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_TKA02') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data