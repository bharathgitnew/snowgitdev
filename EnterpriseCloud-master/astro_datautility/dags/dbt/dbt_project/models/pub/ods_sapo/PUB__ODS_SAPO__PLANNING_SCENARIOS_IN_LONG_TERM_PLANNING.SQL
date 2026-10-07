/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.46"
*************/

{{ config(
      materialized='view',
      alias='PLANNING_SCENARIOS_IN_LONG_TERM_PLANNING',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        PLSCN,
        PSACT,
        PLSCT,
        PDAT1,
        PDAT2,
        MDATE,
        SBFLG,
        SSTCK,
        SSTFL,
        VERSA,
        FIXEL,
        VRSIO,
        EISDT,
        VSBCO,
        BCODT,
        FIXLO,
        EINPL,
        KDAKZ,
        FBAKZ,
        FPAKZ,
        DIRKZ,
        AVMKZ,
        LLSKZ,
        LTPLS,
        LTPID,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__PLANNING_SCENARIOS_IN_LONG_TERM_PLANNING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data