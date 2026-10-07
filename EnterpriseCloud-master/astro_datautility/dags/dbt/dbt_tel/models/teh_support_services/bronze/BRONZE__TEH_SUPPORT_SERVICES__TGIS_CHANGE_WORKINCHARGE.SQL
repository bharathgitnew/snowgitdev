{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TGIS_CHANGE_WORKINCHARGE'
) }}

with source_data as
(
    SELECT
        JSONFIELD:id::STRING AS ID,
        JSONFIELD:chg_mng_nm::STRING AS CHG_MNG_NM,
        JSONFIELD:step_number::STRING AS STEP_NUMBER,
        JSONFIELD:work_number::STRING AS WORK_NUMBER,
        JSONFIELD:work_incharge_telnm::STRING AS WORK_INCHARGE_TELNM,
        JSONFIELD:work_incharge_telname::STRING AS WORK_INCHARGE_TELNAME,
        _FILEDATE,
        _FILENAME
    FROM {{ source("TGIS", "CHANGE_WORKINCHARGE") }}
    WHERE _FILEDATE = (
			SELECT MAX(RUN_TIME)
			FROM {{ source('TGIS', 'CONTROLTABLE') }}
			WHERE TABLE_NAME = 'dwh_change_workincharge'
        )
)

,transform_data as (
    SELECT
        ID,
        CHG_MNG_NM,
        STEP_NUMBER,
        WORK_NUMBER,
        WORK_INCHARGE_TELNM,
        WORK_INCHARGE_TELNAME,
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
)

,type_data as (
    SELECT
        CAST (ID AS VARCHAR(16777216)) AS ID,
        CAST (CHG_MNG_NM AS VARCHAR(16777216)) AS CHG_MNG_NM,
        CAST (STEP_NUMBER AS VARCHAR(16777216)) AS STEP_NUMBER,
        CAST (WORK_NUMBER AS VARCHAR(16777216)) AS WORK_NUMBER,
        CAST (WORK_INCHARGE_TELNM AS VARCHAR(16777216)) AS WORK_INCHARGE_TELNM,
        CAST (WORK_INCHARGE_TELNAME AS VARCHAR(16777216)) AS WORK_INCHARGE_TELNAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
		CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
	FROM transform_data
)

SELECT * FROM type_data