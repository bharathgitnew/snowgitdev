/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.52"
*************/

{{ config(
      materialized='view',
      alias='STXD_SAPSCRIPT_TEXT_FILE_LINES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        RELID,
        TDOBJECT,
        TDNAME,
        TDID,
        TDSPRAS,
        SRTF2,
        CLUSTR,
        CLUSTD,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__STXD_SAPSCRIPT_TEXT_FILE_LINES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data