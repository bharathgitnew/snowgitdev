/************
Model file generated from dbtGeneratePubViews: 02.27.2023.06.15.21"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_TKA01',
      transient=false
) }}

with source_data as (
    SELECT
        KOKRS,
        BEZEI,
        WAERS,
        KTOPL,
        LMONA,
        DPRCT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_TKA01') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data