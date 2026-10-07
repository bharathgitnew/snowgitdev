/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.48"
*************/

{{ config(
      materialized='view',
      alias='INFOTYPE_1001_DB_TABLE',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        OTYPE,
        OBJID,
        PLVAR,
        RSIGN,
        RELAT,
        ISTAT,
        PRIOX,
        BEGDA,
        ENDDA,
        VARYF,
        SEQNR,
        INFTY,
        OTJID,
        SUBTY,
        AEDTM,
        UNAME,
        REASN,
        HISTO,
        ITXNR,
        SCLAS,
        SOBID,
        PROZT,
        ADATANR,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INFOTYPE_1001_DB_TABLE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data