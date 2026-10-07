/************
Model file generated from dbtGeneratePubViews: 03.21.2023.07.27.23"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T156T',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        BWART,
        SOBKZ,
        KZBEW,
        KZZUG,
        KZVBR,
        BTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T156T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data