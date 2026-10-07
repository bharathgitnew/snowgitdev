/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.27"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU139_T685T',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        KVEWE,
        KAPPL,
        KSCHL,
        VTEXT,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU139_T685T') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data