/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.07.06"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_TVFKT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        FKART,
        VTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_TVFKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data