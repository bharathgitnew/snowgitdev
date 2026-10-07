/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.49"
*************/

{{ config(
      materialized='view',
      alias='MATERIAL_MASTER_STORAGE_LOCATION_SEGMENT_HISTORY',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        MATNR,
        WERKS,
        LGORT,
        LFGJA,
        LFMON,
        LABST,
        UMLME,
        INSME,
        EINME,
        SPEME,
        RETME,
        VKLAB,
        VKUML,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MATERIAL_MASTER_STORAGE_LOCATION_SEGMENT_HISTORY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data