/************
Model file generated from dbtGeneratePubViews: 03.21.2023.07.27.26"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_T059ZT_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        LAND1,
        WITHT,
        WT_WITHCD,
        TEXT40,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_T059ZT_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data