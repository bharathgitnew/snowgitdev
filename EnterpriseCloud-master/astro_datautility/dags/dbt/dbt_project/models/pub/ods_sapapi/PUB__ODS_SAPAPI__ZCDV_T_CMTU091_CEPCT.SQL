/************
Model file generated from dbtGeneratePubViews: 01.02.2023.23.58.19"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU091_CEPCT',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        PRCTR,
        DATBI,
        KOKRS,
        KTEXT,
        LTEXT,
        MCTXT,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU091_CEPCT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data