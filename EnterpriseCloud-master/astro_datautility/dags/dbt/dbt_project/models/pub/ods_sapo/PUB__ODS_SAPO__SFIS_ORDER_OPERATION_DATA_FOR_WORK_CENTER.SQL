/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.49"
*************/

{{ config(
      materialized='view',
      alias='SFIS_ORDER_OPERATION_DATA_FOR_WORK_CENTER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        SSOUR,
        VRSIO,
        SPMON,
        SPTAG,
        SPWOC,
        SPBUP,
        WERKS,
        ARBPL,
        KAPAR,
        MATNR,
        AUFNR,
        PLNUM,
        POSNR,
        PLNFL,
        VORNR,
        PERIV,
        VWDAT,
        MEINH,
        DFZEH,
        LIGZE,
        WRTZE,
        RSTZE,
        BEAZE,
        ARUZE,
        TRAZE,
        KEINH,
        KAPID,
        KALID,
        OBJNR,
        VERTL,
        ERDAT,
        FTRMP,
        FTRMS,
        FTRMI,
        GSTRP,
        GSTRS,
        GSTRI,
        SSADD,
        IADD,
        FSAVD,
        SSAVD,
        ISDD,
        ISAVD,
        FSEDD,
        SSEDD,
        IEDD,
        IEAVD,
        GLTRP,
        GLTRS,
        GLTRI,
        GMNGA,
        MGVRG,
        LMNGA,
        ASVRG,
        XMNGA,
        S_DFZ,
        I_DFZ,
        LIEGZ,
        WARTZ,
        RUEST,
        BEARZ,
        ABRUE,
        TRANZ,
        KRUES,
        KBEAS,
        KABRS,
        LIEGV,
        KAPKZ,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__SFIS_ORDER_OPERATION_DATA_FOR_WORK_CENTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data