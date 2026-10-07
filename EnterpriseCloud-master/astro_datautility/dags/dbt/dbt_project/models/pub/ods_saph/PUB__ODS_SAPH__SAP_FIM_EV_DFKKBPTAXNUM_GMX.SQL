/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.50"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_DFKKBPTAXNUM_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        PARTNER,
        TAXTYPE,
        TAXNUM,
        TAXNUMXL,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_DFKKBPTAXNUM_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data