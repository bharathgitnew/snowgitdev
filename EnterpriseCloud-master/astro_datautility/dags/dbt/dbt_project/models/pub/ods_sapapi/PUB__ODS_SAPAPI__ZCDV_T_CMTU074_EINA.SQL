/************
Model file generated from dbtGeneratePubViews: 12.22.2022.10.53.33"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU074_EINA',
      transient=false
) }}

with source_data as (
    SELECT
        INFNR,
        MATNR,
        MATKL,
        LIFNR,
        LOEKZ,
        ERDAT,
        ERNAM,
        TXZ01,
        SORTL,
        MEINS,
        UMREZ,
        UMREN,
        IDNLF,
        VERKF,
        TELF1,
        MAHN1,
        MAHN2,
        MAHN3,
        URZNR,
        URZDT,
        URZLA,
        URZTP,
        URZZT,
        LMEIN,
        REGIO,
        VABME,
        LTSNR,
        LTSSF,
        WGLIF,
        RUECK,
        LIFAB,
        LIFBI,
        KOLIF,
        ANZPU,
        PUNEI,
        RELIF,
        MFRNR,
        DUMMYEINAINCLEEWPS,
        LASTCHANGEDATETIME,
        ISEOPBLOCKED,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU074_EINA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data