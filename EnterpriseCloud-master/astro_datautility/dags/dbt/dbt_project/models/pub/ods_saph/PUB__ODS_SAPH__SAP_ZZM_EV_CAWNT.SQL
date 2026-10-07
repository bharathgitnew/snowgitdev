/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.32"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_CAWNT',
      transient=false
) }}

with source_data as (
    SELECT
        ATINN,
        ADZHL,
        ATZHL,
        SPRAS,
        ATINN_INNER,
        ADZHL001,
        ATWTB,
        DATUV,
        TECHV,
        AENNR,
        LKENZ,
        ADATU,
        VDATU,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_CAWNT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data