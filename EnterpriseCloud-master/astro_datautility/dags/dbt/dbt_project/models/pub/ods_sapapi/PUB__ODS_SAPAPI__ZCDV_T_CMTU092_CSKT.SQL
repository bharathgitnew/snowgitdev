/************
Model file generated from dbtGeneratePubViews: 03.09.2023.04.53.31"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU092_CSKT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KOKRS,
        KOSTL,
        DATBI,
        KTEXT,
        LTEXT,
        MCTXT,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU092_CSKT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data