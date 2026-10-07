/************
Model file generated from dbtGeneratePubViews: 02.21.2023.08.06.31"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_TVKGR',
      transient=false
) }}

with source_data as (
    SELECT
        VKGRP,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_TVKGR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data