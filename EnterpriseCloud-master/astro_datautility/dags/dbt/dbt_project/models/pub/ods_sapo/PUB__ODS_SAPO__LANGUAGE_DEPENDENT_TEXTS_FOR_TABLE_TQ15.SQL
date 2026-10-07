/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.41"
*************/

{{ config(
      materialized='view',
      alias='LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRACHE,
        KATALOGART,
        KATALOGTXT,
        SCHLAGWORT,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__LANGUAGE_DEPENDENT_TEXTS_FOR_TABLE_TQ15') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data