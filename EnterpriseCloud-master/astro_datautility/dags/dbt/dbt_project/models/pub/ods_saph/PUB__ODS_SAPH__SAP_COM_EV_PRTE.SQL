/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.23"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_PRTE',
      transient=false
) }}

with source_data as (
    SELECT
        POSNR,
        PSPHI,
        PSTRT,
        ESTRT,
        ISTRT,
        PENDE,
        EENDE,
        IENDE,
        PDAUR,
        PEINH,
        EDAUR,
        EEINH,
        IDAUR,
        IEINH,
        IEINH001,
        EEINH001,
        PEINH001,
        FLGVG,
        FLGEW,
        FLGEM,
        FLGVM,
        FLGIM,
        FLGVI,
        PSTRM,
        PETRM,
        ESTRM,
        EETRM,
        VIEND,
        VISTR,
        PSTRS,
        PETRF,
        ESTRS,
        EETRF,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_PRTE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data