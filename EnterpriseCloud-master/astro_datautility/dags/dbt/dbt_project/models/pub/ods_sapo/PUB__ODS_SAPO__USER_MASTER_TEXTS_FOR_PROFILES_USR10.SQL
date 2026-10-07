/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.50"
*************/

{{ config(
      materialized='view',
      alias='USER_MASTER_TEXTS_FOR_PROFILES_USR10',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        LANGU,
        PROFN,
        AKTPS,
        PTEXT,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__USER_MASTER_TEXTS_FOR_PROFILES_USR10') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data