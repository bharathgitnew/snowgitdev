/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_TSKMT_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        TATYP,
        TAXKM,
        VTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_TSKMT_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data