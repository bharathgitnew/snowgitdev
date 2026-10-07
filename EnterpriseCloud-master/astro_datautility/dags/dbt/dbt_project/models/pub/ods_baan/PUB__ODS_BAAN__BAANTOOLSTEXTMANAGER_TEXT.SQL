/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.25"
*************/

{{ config(
      materialized='view',
      alias='BAANTOOLSTEXTMANAGER_TEXT',
      transient=false
) }}

with source_data as (
    SELECT
        TEXTNUMBER,
        LANGUAGE,
        NUMBEROFLINES,
        TEXTLINE
    from {{ ref('ODS__BAAN__BAANTOOLSTEXTMANAGER_TEXT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data