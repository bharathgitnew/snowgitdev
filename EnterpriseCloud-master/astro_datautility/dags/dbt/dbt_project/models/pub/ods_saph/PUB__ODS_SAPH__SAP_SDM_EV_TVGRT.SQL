/************
Model file generated from dbtGeneratePubViews: 03.13.2023.10.56.45"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_TVGRT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        VKGRP,
        BEZEI,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_TVGRT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data