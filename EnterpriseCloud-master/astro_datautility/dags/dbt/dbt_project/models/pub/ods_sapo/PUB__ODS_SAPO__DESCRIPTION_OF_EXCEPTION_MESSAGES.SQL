/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.36"
*************/

{{ config(
      materialized='view',
      alias='DESCRIPTION_OF_EXCEPTION_MESSAGES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SPRAS,
        AUSSL,
        AUSLT,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__DESCRIPTION_OF_EXCEPTION_MESSAGES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data