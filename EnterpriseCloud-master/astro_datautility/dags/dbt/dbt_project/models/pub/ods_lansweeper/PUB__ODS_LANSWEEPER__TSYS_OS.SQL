/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.39"
*************/

{{ config(
      materialized='view',
      alias='TSYS_OS',
      transient=false
) }}

with source_data as (
    SELECT
        OS_CODE,
        OS_NAME,
        IMAGE,
        SORT_ORDER,
        OS_CODE_NUMERIC,
        _FILEDATE
    from {{ ref('ODS__LANSWEEPER__TSYS_OS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data