/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.06"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_CSKT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KOKRS,
        KOSTL,
        DATBI,
        KTEXT,
        LTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_CSKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data