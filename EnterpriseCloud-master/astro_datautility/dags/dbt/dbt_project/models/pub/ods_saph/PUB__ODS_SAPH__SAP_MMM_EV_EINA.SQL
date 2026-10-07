/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.12"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_EINA',
      transient=false,
	  enabled=false
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
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_EINA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data