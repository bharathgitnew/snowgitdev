/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.43"
*************/

{{ config(
      materialized='view',
      alias='USER_RELATED_VALUES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        OTYPE,
        ONAME,
        UNAME,
        XUVAL,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__USER_RELATED_VALUES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data