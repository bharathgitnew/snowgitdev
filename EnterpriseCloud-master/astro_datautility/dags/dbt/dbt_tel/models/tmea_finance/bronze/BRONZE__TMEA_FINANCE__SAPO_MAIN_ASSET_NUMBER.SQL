{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_MAIN_ASSET_NUMBER',
        unique_key = ['MANDT',
    'BUKRS',
    'ANLN1'],
        transient=false
) }}

with source_data as (
SELECT 
	_CAPTUREDATETIME,
    MANDT,
    BUKRS,
    ANLN1,
    LUNTN,
    LANEP,
    ANUPD,
    FUNTN,
    ANLHTXT
FROM {{source('SAP_ORACLE_LIVE', 'ANLH')}}
),

TRANSFORM_DATA as 
(
SELECT
    _CAPTUREDATETIME,
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    MANDT,
    BUKRS,
    ANLN1,
    LUNTN,
    LANEP,
    ANUPD,
    FUNTN,
    ANLHTXT
FROM SOURCE_DATA
), 

TYPE_DATA as 
(
SELECT 
	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    MANDT,
    BUKRS,
    ANLN1,
    LUNTN,
    LANEP,
    ANUPD,
    FUNTN,
    ANLHTXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA