{{ config(
      materialized='view',
      alias='SALES_DISTRIBUTION_DOCUMENT_EXPORT_CONTROL_ITEM_DATA',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        VBELN,
        POSNR,
        GEGRU,
        ALNUM,
        EMBGR,
        GEART,
        GENNR,
        EXKUA,
        EXWAE,
        MODCO,
        AHBAS,
        SECGK,
        _DATAAGING,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SALES_DISTRIBUTION_DOCUMENT_EXPORT_CONTROL_ITEM_DATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data