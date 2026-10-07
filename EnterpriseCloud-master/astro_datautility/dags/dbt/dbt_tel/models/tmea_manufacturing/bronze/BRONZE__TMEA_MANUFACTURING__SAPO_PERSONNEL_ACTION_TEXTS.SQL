{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_PERSONNEL_ACTION_TEXTS',
        unique_key = ['MANDT',
    'SPRSL',
    'MASSN'],
        transient=false
) }}


with source_data as (
SELECT 
    MANDT,
    SPRSL,
    MASSN,
    MNTXT,
    _CAPTUREDATETIME
FROM {{source('SAP_ORACLE_LIVE', 'T529T')}}
),
transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    _CAPTUREDATETIME,
	MANDT as MANDT,
    SPRSL as SPRSL,
    MASSN as MASSN,
    MNTXT as MNTXT
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
	MANDT,
    SPRSL,
    MASSN,
    MNTXT
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA