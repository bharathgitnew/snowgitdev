/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.48"
*************/

{{ config(
      materialized='view',
      alias='MRP_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        DISMM,
        DISVF,
        PROKZ,
        PROVB,
        PROOS,
        KZSIB,
        KZMEB,
        PRRED,
        FXART,
        RESPL,
        KZREG,
        ICBED,
        RYBED,
        DYFOL,
        CBPPT,
        BBBED,
        U1BED,
        U2BED,
        U4BED,
        A1BED,
        A2BED,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MRP_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data