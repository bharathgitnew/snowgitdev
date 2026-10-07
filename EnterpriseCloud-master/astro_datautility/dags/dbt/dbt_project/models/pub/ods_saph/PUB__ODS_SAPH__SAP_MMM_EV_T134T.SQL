/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.34"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T134T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        MTART,
        MTBEZ,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T134T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data