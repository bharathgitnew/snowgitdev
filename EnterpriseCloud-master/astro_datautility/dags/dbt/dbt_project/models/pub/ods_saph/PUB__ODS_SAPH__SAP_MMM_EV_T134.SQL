/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.34"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T134',
      transient=false
) }}

with source_data as (
    SELECT
        MTART,
        BSEXT,
        BSINT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T134') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data