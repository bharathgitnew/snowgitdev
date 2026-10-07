/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.46"
*************/

{{ config(
      materialized='view',
      alias='PLANNING_AND_ORGANIZATION_FILE',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        PLVAR,
        OTYPE,
        OBJID,
        INFTY,
        SUBTY,
        ISTAT,
        PRIOX,
        BEGDA,
        ENDDA,
        VARYF,
        SEQNR,
        AEDTM,
        UNAME,
        REASN,
        HISTO,
        ITXNR,
        VDATA,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__PLANNING_AND_ORGANIZATION_FILE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data