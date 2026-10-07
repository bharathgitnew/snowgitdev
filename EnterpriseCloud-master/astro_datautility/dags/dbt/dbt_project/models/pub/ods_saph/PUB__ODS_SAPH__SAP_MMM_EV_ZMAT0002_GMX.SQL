/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.55"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_ZMAT0002_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        ZZPROCO,
        ZZMODEL,
        ZZSYSN,
        ZZETEXT,
        ZZJTEXT,
        ZZWEFSZ,
        ZZCANCD,
        ZZSWLHV,
        ZZNMTF,
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
    from {{ ref('ODS__SAPH__SAP_MMM_EV_ZMAT0002_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data