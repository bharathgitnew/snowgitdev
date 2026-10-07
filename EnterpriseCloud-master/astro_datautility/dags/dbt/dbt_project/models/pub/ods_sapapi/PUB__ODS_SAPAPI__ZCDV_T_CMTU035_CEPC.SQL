/************
Model file generated from dbtGeneratePubViews: 10.18.2022.06.21.58"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU035_CEPC',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        PRCTR,
        DATBI,
        KOKRS,
        DATAB,
        ERSDA,
        USNAM,
        MERKMAL,
        ABTEI,
        VERAK,
        VERAK_USER,
        WAERS,
        NPRCTR,
        LAND1,
        ANRED,
        NAME1,
        NAME2,
        NAME3,
        NAME4,
        ORT01,
        ORT02,
        STRAS,
        PFACH,
        PSTLZ,
        PSTL2,
        SPRAS,
        TELBX,
        TELF1,
        TELF2,
        TELFX,
        TELTX,
        TELX1,
        DATLT,
        DRNAM,
        KHINR,
        BUKRS,
        VNAME,
        RECID,
        ETYPE,
        TXJCD,
        REGIO,
        KVEWE,
        KAPPL,
        KALSM,
        LOGSYSTEM,
        LOCK_IND,
        PCA_TEMPLATE,
        SEGMENT,
        EEW_CEPC_PS_DUMMY,
        UPDATE_DATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU035_CEPC') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data