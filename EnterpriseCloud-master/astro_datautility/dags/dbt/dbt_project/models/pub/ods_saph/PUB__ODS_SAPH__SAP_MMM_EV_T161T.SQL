/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.46"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T161T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        BSART,
        BSTYP,
        BATXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T161T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data