/************
Model file generated from dbtGeneratePubViews: 02.02.2023.03.56.37"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_A114_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        VKORG,
        KUNNR,
        DATBI,
        DATAB,
        KNUMH,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_A114_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data