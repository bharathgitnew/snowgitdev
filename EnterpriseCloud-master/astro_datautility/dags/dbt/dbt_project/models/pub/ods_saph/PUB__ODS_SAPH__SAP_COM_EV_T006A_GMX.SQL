/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.47"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_T006A_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        MSEHI,
        MSEH3,
        MSEH6,
        MSEHT,
        MSEHL,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_T006A_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data