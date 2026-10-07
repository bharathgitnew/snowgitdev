/************
Model file generated from dbtGeneratePubViews: 01.09.2023.04.53.55"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU080_T001L',
      transient=false
) }}

with source_data as (
    SELECT
        WERKS,
        LGORT,
        LGOBE,
        SPART,
        XLONG,
        XBUFX,
        DISKZ,
        XBLGO,
        XRESS,
        XHUPF,
        PARLG,
        VKORG,
        VTWEG,
        VSTEL,
        LIFNR,
        KUNNR,
        MESBS,
        MESST,
        OIHLICNO,
        OIGITRFL,
        OIBTNKASSIGN,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU080_T001L') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data