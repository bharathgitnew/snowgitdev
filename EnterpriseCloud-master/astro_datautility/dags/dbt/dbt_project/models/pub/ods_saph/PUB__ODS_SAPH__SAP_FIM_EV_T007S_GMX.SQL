/************
Model file generated from dbtGeneratePubViews: 03.21.2023.07.27.21"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_T007S_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KALSM,
        MWSKZ,
        TEXT1,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_T007S_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data