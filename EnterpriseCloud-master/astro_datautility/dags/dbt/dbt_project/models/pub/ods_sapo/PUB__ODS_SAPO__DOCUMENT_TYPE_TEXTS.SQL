/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.44"
*************/

{{ config(
      materialized='view',
      alias='DOCUMENT_TYPE_TEXTS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        BLART,
        LTEXT,
        _CAPTUREDATETIME,
        IS_DELETED
    from {{ ref('ODS__SAPO__DOCUMENT_TYPE_TEXTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data