/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.56.05"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_TCURC',
      transient=false
) }}

with source_data as (
    SELECT
        WAERS,
        ISOCD,
        ALTWR,
        GDATU,
        XPRIMARY,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_TCURC') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data