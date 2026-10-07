/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.07"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_TSKM_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        TATYP,
        TAXKM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_TSKM_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data