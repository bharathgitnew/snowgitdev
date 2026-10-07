{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_PURCHASING_SOURCE_LIST',
    unique_key = ['MANDT',
     'MATNR',
     'WERKS',
     'ZEORD']
) }}

with source_data as
(
    SELECT
        MANDT	,
        MATNR	,
        WERKS	,
        ZEORD	,
        ERDAT	,
        ERNAM	,
        VDATU	,
        BDATU	,
        LIFNR	,
        FLIFN	,
        EBELN	,
        EBELP	,
        FEBEL	,
        RESWK	,
        FRESW	,
        EMATN	,
        NOTKZ	,
        EKORG	,
        VRTYP	,
        EORTP	,
        AUTET	,
        MEINS	,
        LOGSY	,
        SOBKZ	,
        SRM_CONTRACT_ID	,
        SRM_CONTRACT_ITM	,
        _CAPTUREDATETIME
        FROM {{ source("SAP_ORACLE_LIVE", "EORD") }}
)

,transform_Is_Deleted as (
    select
        ods.MANDT,
        ods.MATNR,
        ods.WERKS,
        ods.ZEORD,
        ods.ERDAT,
        ods.ERNAM,
        ods.VDATU,
        ods.BDATU,
        ods.LIFNR,
        ods.FLIFN,
        ods.EBELN,
        ods.EBELP,
        ods.FEBEL,
        ods.RESWK,
        ods.FRESW,
        ods.EMATN,
        ods.NOTKZ,
        ods.EKORG,
        ods.VRTYP,
        ods.EORTP,
        ods.AUTET,
        ods.MEINS,
        ods.LOGSY,
        ods.SOBKZ,
        ods.SRM_CONTRACT_ID,
        ods.SRM_CONTRACT_ITM,
        ods._CAPTUREDATETIME,
        ods._AUDIT_LOG_ID,
        ods._ROW_HASH
    from {{this}} ods
    left join source_data lz
    on ods.mandt = lz.mandt
    and ods.matnr = lz.matnr
    and ods.werks = lz.werks
    and ods.zeord = lz.zeord
    where lz.mandt is  null
    and lz.matnr is  null
    and lz.werks is  null
    and lz.zeord is  null
)

,transform_data as
(
    SELECT
        MANDT,
        MATNR,
        WERKS,
        ZEORD,
        ERDAT,
        ERNAM,
        VDATU,
        BDATU,
        LIFNR,
        FLIFN,
        EBELN,
        EBELP,
        FEBEL,
        RESWK,
        FRESW,
        EMATN,
        NOTKZ,
        EKORG,
        VRTYP,
        EORTP,
        AUTET,
        MEINS,
        LOGSY,
        SOBKZ,
        SRM_CONTRACT_ID,
        SRM_CONTRACT_ITM,
        _CAPTUREDATETIME,
        'No' AS IS_DELETED,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH
    FROM source_data
    UNION
    SELECT
        MANDT,
        MATNR,
        WERKS,
        ZEORD,
        ERDAT,
        ERNAM,
        VDATU,
        BDATU,
        LIFNR,
        FLIFN,
        EBELN,
        EBELP,
        FEBEL,
        RESWK,
        FRESW,
        EMATN,
        NOTKZ,
        EKORG,
        VRTYP,
        EORTP,
        AUTET,
        MEINS,
        LOGSY,
        SOBKZ,
        SRM_CONTRACT_ID,
        SRM_CONTRACT_ITM,
        _CAPTUREDATETIME,
        'Yes' AS IS_DELETED,
        _AUDIT_LOG_ID,
        _ROW_HASH
    FROM transform_Is_Deleted 
)

,type_data as
(
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(MANDT AS VARCHAR(16777216)) AS MANDT,
        cast(MATNR AS VARCHAR(16777216)) AS MATNR,
        cast(WERKS AS VARCHAR(16777216)) AS WERKS,
        cast(ZEORD AS VARCHAR(16777216)) AS ZEORD,
        cast(ERDAT AS VARCHAR(16777216)) AS ERDAT,
        cast(ERNAM AS VARCHAR(16777216)) AS ERNAM,
        cast(VDATU AS VARCHAR(16777216)) AS VDATU,
        cast(BDATU AS VARCHAR(16777216)) AS BDATU,
        cast(LIFNR AS VARCHAR(16777216)) AS LIFNR,
        cast(FLIFN AS VARCHAR(16777216)) AS FLIFN,
        cast(EBELN AS VARCHAR(16777216)) AS EBELN,
        cast(EBELP AS VARCHAR(16777216)) AS EBELP,
        cast(FEBEL AS VARCHAR(16777216)) AS FEBEL,
        cast(RESWK AS VARCHAR(16777216)) AS RESWK,
        cast(FRESW AS VARCHAR(16777216)) AS FRESW,
        cast(EMATN AS VARCHAR(16777216)) AS EMATN,
        cast(NOTKZ AS VARCHAR(16777216)) AS NOTKZ,
        cast(EKORG AS VARCHAR(16777216)) AS EKORG,
        cast(VRTYP AS VARCHAR(16777216)) AS VRTYP,
        cast(EORTP AS VARCHAR(16777216)) AS EORTP,
        cast(AUTET AS VARCHAR(16777216)) AS AUTET,
        cast(MEINS AS VARCHAR(16777216)) AS MEINS,
        cast(LOGSY AS VARCHAR(16777216)) AS LOGSY,
        cast(SOBKZ AS VARCHAR(16777216)) AS SOBKZ,
        cast(SRM_CONTRACT_ID AS VARCHAR(16777216)) AS SRM_CONTRACT_ID,
        cast(SRM_CONTRACT_ITM AS VARCHAR(16777216)) AS SRM_CONTRACT_ITM,
        cast(IS_DELETED AS	VARCHAR(16777216))	AS	IS_DELETED	

    from transform_data
    )
select * from type_data