/************
Model file generated from dbtGeneratePubViews: 02.10.2023.12.59.33"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_LFA1',
      transient=false
) }}

with source_data as (
    SELECT
        LIFNR,
        NAME1,
        NAME2,
        NAME3,
        NAME4,
        ADRNR,
        MCOD1,
        MCOD2,
        MCOD3,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_LFA1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data