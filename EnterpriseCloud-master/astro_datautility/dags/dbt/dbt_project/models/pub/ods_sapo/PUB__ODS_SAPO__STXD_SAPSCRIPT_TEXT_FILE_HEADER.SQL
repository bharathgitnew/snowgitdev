/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.51"
*************/

{{ config(
      materialized='view',
      alias='STXD_SAPSCRIPT_TEXT_FILE_HEADER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        TDOBJECT,
        TDNAME,
        TDID,
        TDSPRAS,
        TDTITLE,
        TDFRELES,
        TDFUSER,
        TDFDATE,
        TDFTIME,
        TDLRELES,
        TDLUSER,
        TDLDATE,
        TDLTIME,
        TDVERSION,
        TDSTYLE,
        TDFORM,
        TDHYPHENAT,
        TDTRANSTAT,
        TDOSPRAS,
        TDMACODE1,
        TDMACODE2,
        TDTXTLINES,
        TDREF,
        TDREFOBJ,
        TDREFNAME,
        TDREFID,
        TDTEXTTYPE,
        TDCOMPRESS,
        TDOCLASS,
        LOGSYS,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__STXD_SAPSCRIPT_TEXT_FILE_HEADER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data