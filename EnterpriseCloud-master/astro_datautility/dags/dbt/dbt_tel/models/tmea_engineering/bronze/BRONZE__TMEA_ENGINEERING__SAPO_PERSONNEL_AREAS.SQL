{{ config(
        materialized='tel_incremental',
        incremental_strategy='merge',
        alias='SAPO_PERSONNEL_AREAS',
        unique_key = ['MANDT',
    'PERSA'],
        transient=false
) }}


with source_data as (
SELECT 
    MANDT,
    PERSA,
	MOLGA,
    BUKRS,
    NAME1,
    NAME2,
    STRAS,
    PFACH,
    PSTLZ,
    ORT01,
    LAND1,
    REGIO,
    COUNC,
    CITYC,
    ADRNR,
    _CAPTUREDATETIME
FROM {{source('SAP_ORACLE_LIVE', 'T500P')}}
),
transform_data as 
(
SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
	MANDT as MANDT,
    PERSA as PERSA,
    MOLGA as MOLGA,
    BUKRS as BUKRS,
    NAME1 as NAME1,
    NAME2 as NAME2,
    STRAS as STRAS,
    PFACH as PFACH,
    PSTLZ as PSTLZ,
    ORT01 as ORT01,
    LAND1 as LAND1,
    REGIO as REGIO,
    COUNC as COUNC,
    CITYC as CITYC,
    ADRNR as ADRNR,
    _CAPTUREDATETIME
	FROM SOURCE_DATA
), 

type_data as 
(
SELECT 
	_AUDIT_LOG_ID,
	_ROW_HASH,
	MANDT,
    PERSA,
    MOLGA,
    BUKRS,
    NAME1,
    NAME2,
    STRAS,
    PFACH,
    PSTLZ,
    ORT01,
    LAND1,
    REGIO,
    COUNC,
    CITYC,
    ADRNR,
    CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME
FROM TRANSFORM_DATA
)
 
SELECT * FROM TYPE_DATA