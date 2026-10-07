/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.47"
*************/

{{ config(
      materialized='view',
      alias='QUOTA_FILE_HEADER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        WERKS,
        BDATU,
        VDATU,
        QUNUM,
        ERDAT,
        ERNAM,
        SCMNG,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__QUOTA_FILE_HEADER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data