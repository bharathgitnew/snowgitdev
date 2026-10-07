/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.38"
*************/

{{ config(
      materialized='view',
      alias='INDEX_OF_THE_RESB_FOR_THE_DIRECT_PROCUREMENT_ELEMENT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        RSNUM,
        RSPOS,
        RSART,
        RSINZ,
        PLNUM,
        BANFN,
        BNFPO,
        EBELN,
        EBELP,
        AUFNR,
        AUFPO,
        AOBAR,
        ZEINH,
        DAUER,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INDEX_OF_THE_RESB_FOR_THE_DIRECT_PROCUREMENT_ELEMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data