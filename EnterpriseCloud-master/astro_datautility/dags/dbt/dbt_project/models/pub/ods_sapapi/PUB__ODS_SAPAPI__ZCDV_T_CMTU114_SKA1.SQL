/************
Model file generated from dbtGeneratePubViews: 01.12.2023.09.12.13"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU114_SKA1',
      transient=false
) }}

with source_data as (
    SELECT
        KTOPL,
        SAKNR,
        XBILK,
        SAKAN,
        BILKT,
        ERDAT,
        ERNAM,
        GVTYP,
        KTOKS,
        MUSTR,
        VBUND,
        XLOEV,
        XSPEA,
        XSPEB,
        XSPEP,
        MCOD1,
        FUNCAREA,
        GLACCOUNTTYPE,
        LASTCHANGEDTS,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU114_SKA1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data