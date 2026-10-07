{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_G_L_ACCOUNT_MASTER_CHART_OF_ACCOUNTS',
    unique_key = ['MANDT','KTOPL','SAKNR'],
    transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        MANDT,
        KTOPL,
        SAKNR,
        XBILK,
        SAKAN,
        BILKT,
        ERDAT,
        ERNAM,
        GVTYP,
        KTOKS,
        MUSTR,
        VBUND,
        XLOEV,
        XSPEA,
        XSPEB,
        XSPEP,
        MCOD1,
        FUNC_AREA
    FROM {{ source('SAP_ORACLE_LIVE', 'SKA1') }}
),

transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _CAPTUREDATETIME,
        MANDT AS MANDT,
        KTOPL AS KTOPL,
        SAKNR AS SAKNR,
        XBILK AS XBILK,
        SAKAN AS SAKAN,
        BILKT AS BILKT,
        ERDAT AS ERDAT,
        ERNAM AS ERNAM,
        GVTYP AS GVTYP,
        KTOKS AS KTOKS,
        MUSTR AS MUSTR,
        VBUND AS VBUND,
        XLOEV AS XLOEV,
        XSPEA AS XSPEA,
        XSPEB AS XSPEB,
        XSPEP AS XSPEP,
        MCOD1 AS MCOD1,
        FUNC_AREA AS FUNC_AREA
    FROM source_data
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        MANDT,
        KTOPL,
        SAKNR,
        XBILK,
        SAKAN,
        BILKT,
        ERDAT,
        ERNAM,
        GVTYP,
        KTOKS,
        MUSTR,
        VBUND,
        XLOEV,
        XSPEA,
        XSPEB,
        XSPEP,
        MCOD1,
        FUNC_AREA
    FROM transform_data
)

SELECT * FROM type_data
