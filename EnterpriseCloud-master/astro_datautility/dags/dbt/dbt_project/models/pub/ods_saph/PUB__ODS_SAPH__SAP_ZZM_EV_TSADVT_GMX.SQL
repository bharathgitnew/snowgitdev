/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.05"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_TSADVT_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        LANGU,
        NATION,
        NATION_TEX,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_TSADVT_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data