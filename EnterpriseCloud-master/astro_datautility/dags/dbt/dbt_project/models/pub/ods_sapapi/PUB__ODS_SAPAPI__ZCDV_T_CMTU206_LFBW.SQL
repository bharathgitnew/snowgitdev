/************
Model file generated from dbtGeneratePubViews: 04.21.2023.06.07.26"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU206_LFBW',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        LIFNR,
        BUKRS,
        WITHT,
        WTSUBJCT,
        QSREC,
        WTWTSTCD,
        WTWITHCD,
        WTEXNR,
        WTEXRT,
        WTEXDF,
        WTEXDT,
        WTWTEXRS,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU206_LFBW') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data