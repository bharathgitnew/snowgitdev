/************
Model file generated from dbtGeneratePubViews: 08.23.2022.10.40.07"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_A901_GMX',
      transient=false,
       enabled=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        VKORG,
        KUNNR,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_A901_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data