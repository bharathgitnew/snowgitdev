/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.59"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T023T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        MATKL,
        WGBEZ,
        WGBEZ60,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T023T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data