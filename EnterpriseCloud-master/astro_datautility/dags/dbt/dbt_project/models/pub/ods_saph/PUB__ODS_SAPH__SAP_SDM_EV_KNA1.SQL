/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.03"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_KNA1',
      transient=false
) }}

with source_data as (
    SELECT
        KUNNR,
        LAND1,
        NAME1,
        NAME2,
        NAME3,
        NAME4,
        ORT01,
        PSTLZ,
        REGIO,
        SORTL,
        STRAS,
        TELF1,
        TELFX,
        XCPDK,
        ADRNR,
        MCOD1,
        MCOD2,
        MCOD3,
        ANRED,
        AUFSD,
        BEGRU,
        BRSCH,
        ERDAT,
        ERNAM,
        KTOKD,
        LIFNR,
        LOEVM,
        SPRAS,
        KATR1,
        KATR2,
        KATR3,
        KATR4,
        KATR5,
        KATR6,
        KATR7,
        KATR8,
        KATR9,
        KATR10,
        KONZS,
        ZZPORT,
        STCEG,
        VBUND,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_KNA1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data