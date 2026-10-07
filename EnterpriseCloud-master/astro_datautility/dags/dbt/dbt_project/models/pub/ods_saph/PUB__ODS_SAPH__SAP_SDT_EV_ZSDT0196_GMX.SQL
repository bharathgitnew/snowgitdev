/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.56"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_ZSDT0196_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SEQNO,
        PRC_STS,
        ZZVKORG,
        ZZVBELN_C,
        ZZPOSNR_C,
        ZZIHREZ_C,
        ZZCNZZ_C,
        ZZVBELN_M,
        ZZAUART_M,
        ZZPOSNR_M,
        ZZVBELN_S,
        ZZAUART_S,
        ZZPOSNR_S,
        ZZSLSB_S,
        DEL_FLG,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_ZSDT0196_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data