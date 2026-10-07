/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.36"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_SKAT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KTOPL,
        SAKNR,
        TXT20,
        TXT50,
        MCOD1,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_SKAT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data