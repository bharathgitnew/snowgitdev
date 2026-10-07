/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.51"
*************/

{{ config(
      materialized='view',
      alias='QUALITY_MESSAGE_MAINTENANCE_DATA_EXCERPT',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        QMNUM,
        IWERK,
        ILOAN,
        ILOAI,
        EQUNR,
        BAUTL,
        EBORT,
        MSAUS,
        AUSVN,
        AUSBS,
        AUZTV,
        AUZTB,
        AUSZT,
        MAUEH,
        BTPLN,
        BEQUI,
        AUSWK,
        VERFV,
        VERFN,
        VERFM,
        ANLZV,
        ANLZN,
        ANLZE,
        INSPK,
        DATAN,
        INGRP,
        WARPL,
        ABNUM,
        WAPOS,
        KDAUF,
        KDPOS,
        SCREENTY,
        PLNTY,
        PLNNR,
        PLNAL,
        REVNR,
        ILART,
        ZAEHL,
        PAMS_PTSTF,
        PAMS_PTSTT,
        PAMS_ATSTF,
        PAMS_ATSTT,
        PAMS_POOL,
        PAMS_KOSTL,
        PAMS_AUFNR,
        PAMS_PROID,
        PAMS_KOKRS,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__QUALITY_MESSAGE_MAINTENANCE_DATA_EXCERPT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data