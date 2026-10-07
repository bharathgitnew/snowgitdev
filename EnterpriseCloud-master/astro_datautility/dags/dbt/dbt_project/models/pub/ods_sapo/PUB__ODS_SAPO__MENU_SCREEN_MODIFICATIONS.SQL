/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.39"
*************/

{{ config(
      materialized='view',
      alias='MENU_SCREEN_MODIFICATIONS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        DYMOD,
        SEQNR,
        DYFLD,
        REQUI,
        NOINP,
        INVSB,
        INTEN,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MENU_SCREEN_MODIFICATIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data