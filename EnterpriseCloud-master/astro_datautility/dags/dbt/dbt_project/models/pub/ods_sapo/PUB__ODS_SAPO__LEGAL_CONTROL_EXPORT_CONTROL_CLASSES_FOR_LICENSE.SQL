{{ config(
      materialized='view',
      alias='LEGAL_CONTROL_EXPORT_CONTROL_CLASSES_FOR_LICENSE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        GEGRU,
        GEART,
        ALNUM,
        GENNR,
        SECGK,
		IS_DELETED
    from {{ ref('ODS__SAPO__LEGAL_CONTROL_EXPORT_CONTROL_CLASSES_FOR_LICENSE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data