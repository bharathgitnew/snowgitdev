/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.56.02"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_T161',
      transient=false
) }}

with source_data as (
    SELECT
        BSTYP,
        BSART,
        BSAKZ,
        PINCR,
        NUMKI,
        NUMKE,
        BREFN,
        REFBA,
        ABVOR,
        STAFO,
        UPINC,
        STAKO,
        PARGR,
        NUMKA,
        HITYP,
        LPHIS,
        GSFRG,
        VARIANTE,
        SHENQ,
        KZALE,
        ABGEBOT,
        KORNR,
        UMLIF,
        KOETT,
        AR_OBJECT,
        KOAKO,
        TOLSL,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_T161') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data