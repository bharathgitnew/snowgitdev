/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.51"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_KNVI_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        KUNNR,
        ALAND,
        TATYP,
        TAXKD,
        DELFLAG,
        CDCHANGENR,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_KNVI_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data