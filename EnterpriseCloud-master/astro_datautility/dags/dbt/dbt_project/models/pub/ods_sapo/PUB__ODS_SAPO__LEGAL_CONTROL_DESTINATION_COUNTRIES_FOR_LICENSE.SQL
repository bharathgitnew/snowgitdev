/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.41"
*************/

{{ config(
      materialized='view',
      alias='LEGAL_CONTROL_DESTINATION_COUNTRIES_FOR_LICENSE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        GEGRU,
        GEART,
        GENLA,
        GENNR,
		IS_DELETED
    from {{ ref('ODS__SAPO__LEGAL_CONTROL_DESTINATION_COUNTRIES_FOR_LICENSE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data