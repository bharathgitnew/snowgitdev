{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='SAPO_PLANT_MAINTENANCE_OBJECT_LIST',
    unique_key = ['MANDT',
    'OBKNR',
    'OBZAE']
) }}

with source_data as (
	SELECT 
	_CAPTUREDATETIME,
	MANDT,
	OBKNR,
	OBZAE,
	EQUNR,
	IHNUM,
	BAUTL,
	ILOAN,
	SORTF,
	BEARB,
	OBJVW,
	SERNR,
	MATNR,
	DATUM,
	EQSNR,
	TASER,
	UII,
	EAM_BADI_FLAG
	FROM {{ source("SAP_ORACLE_LIVE", "OBJK") }}
        
        )
,
    transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _CAPTUREDATETIME,
		MANDT as MANDT,
		OBKNR as OBKNR,
		OBZAE as OBZAE,
		EQUNR as EQUNR,
		IHNUM as IHNUM,
		BAUTL as BAUTL,
		ILOAN as ILOAN,
		SORTF as SORTF,
		BEARB as BEARB,
		OBJVW as OBJVW,
		SERNR as SERNR,
		MATNR as MATNR,
		DATUM as DATUM,
		EQSNR as EQSNR,
		TASER as TASER,
		UII as UII,
		EAM_BADI_FLAG as EAM_BADI_FLAG
	FROM SOURCE_DATA
    ), 

    type_data as 
    (
    SELECT 
    	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    	CAST(_CAPTUREDATETIME AS TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
		MANDT,
		CAST(OBKNR AS NUMBER(38,10)) AS OBKNR,
		CAST(OBZAE AS NUMBER(38,10)) AS OBZAE,
		EQUNR,
		IHNUM,
		BAUTL,
		ILOAN,
		SORTF,
		BEARB,
		OBJVW,
		SERNR,
		MATNR,
		DATUM,
		EQSNR,
		TASER,
		UII,
		EAM_BADI_FLAG
FROM TRANSFORM_DATA
    )
 
    SELECT * FROM TYPE_DATA