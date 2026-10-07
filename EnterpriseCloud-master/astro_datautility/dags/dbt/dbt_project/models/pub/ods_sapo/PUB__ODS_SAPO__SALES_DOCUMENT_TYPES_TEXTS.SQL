/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.48"
*************/

{{ config(
      materialized='view',
      alias='SALES_DOCUMENT_TYPES_TEXTS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        AUART,
        BEZEI,
        TXT_BUTTON,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SALES_DOCUMENT_TYPES_TEXTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data