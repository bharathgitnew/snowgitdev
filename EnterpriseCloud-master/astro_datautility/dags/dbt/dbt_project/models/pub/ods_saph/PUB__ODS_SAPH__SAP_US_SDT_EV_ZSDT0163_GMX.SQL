/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.56.04"
*************/

{{ config(
    materialized='view',
    alias='SAP_US_SDT_EV_ZSDT0163_GMX',
    transient=false,
    enabled=false
) }}

with source_data as (
    SELECT
        VBELN,
        POSNR,
        ZRSCZ,
        ZRFZZ,
        ZRNZZ,
        ZRANZ,
        ZRRNZ,
        ZRRAN,
        ZMCNNM,
        ZMCNNO,
        ZDRZZ,
        ZRSZZ,
        ZRQSN,
        ZRPSN,
        ZZRMTZ,
        DEL_FLG,
        C_DATE,
        C_TIME,
        C_USER,
        C_PGM,
        U_DATE,
        U_TIME,
        U_USER,
        U_PGM,
        VKORG,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_SDT_EV_ZSDT0163_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data