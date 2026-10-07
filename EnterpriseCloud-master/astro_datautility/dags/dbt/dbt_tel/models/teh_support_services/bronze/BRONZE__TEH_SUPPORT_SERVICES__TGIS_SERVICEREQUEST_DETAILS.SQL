{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TGIS_SERVICEREQUEST_DETAILS'
) }}


with source_data as
(
    SELECT
        JSONFIELD:id::STRING AS ID,
        JSONFIELD:svc_mng_nm::STRING AS SVC_MNG_NM,
        JSONFIELD:step_number::STRING AS STEP_NUMBER,
        JSONFIELD:step_name_ja::STRING AS STEP_NAME_JA,
        JSONFIELD:step_name_en::STRING AS STEP_NAME_EN,
        JSONFIELD:progress_category::STRING AS PROGRESS_CATEGORY,
        JSONFIELD:progress_category_ja::STRING AS PROGRESS_CATEGORY_JA,
        JSONFIELD:progress_category_en::STRING AS PROGRESS_CATEGORY_EN,
        JSONFIELD:work_number::STRING AS WORK_NUMBER,
        JSONFIELD:work_name_ja::STRING AS WORK_NAME_JA,
        JSONFIELD:work_name_en::STRING AS WORK_NAME_EN,
        JSONFIELD:work_category_id::STRING AS WORK_CATEGORY_ID,
        JSONFIELD:work_category_ja::STRING AS WORK_CATEGORY_JA,
        JSONFIELD:work_category_en::STRING AS WORK_CATEGORY_EN,
        JSONFIELD:itgc_flag::STRING AS ITGC_FLAG,
        JSONFIELD:incharge_group_id::STRING AS INCHARGE_GROUP_ID,
        JSONFIELD:incharge_group_ja::STRING AS INCHARGE_GROUP_JA,
        JSONFIELD:incharge_group_en::STRING AS INCHARGE_GROUP_EN,
        JSONFIELD:assignment_category_id::STRING AS ASSIGNMENT_CATEGORY_ID,
        JSONFIELD:assignment_category_ja::STRING AS ASSIGNMENT_CATEGORY_JA,
        JSONFIELD:assignment_category_en::STRING AS ASSIGNMENT_CATEGORY_EN,
        JSONFIELD:work_complete_flag::STRING AS WORK_COMPLETE_FLAG,
        JSONFIELD:work_incharge_telnm::STRING AS WORK_INCHARGE_TELNM,
        JSONFIELD:work_incharge_telname::STRING AS WORK_INCHARGE_TELNAME,
        CONVERT_TIMEZONE('UTC', 'US/Central',LEFT(((REGEXP_REPLACE(JSONFIELD:work_exec_date, '\/Date\\(|\\)\/', '')::TIMESTAMP)::TIMESTAMP_LTZ),POSITION(' -',(REGEXP_REPLACE(JSONFIELD:work_exec_date, '\/Date\\(|\\)\/', '')::TIMESTAMP)::TIMESTAMP_LTZ)-1)::TIMESTAMP_LTZ)::TIMESTAMP_NTZ AS WORK_EXEC_DATE,
        JSONFIELD:work_result_id::STRING AS WORK_RESULT_ID,
        JSONFIELD:work_result_ja::STRING AS WORK_RESULT_JA,
        JSONFIELD:work_result_en::STRING AS WORK_RESULT_EN,
        JSONFIELD:progress_step_number::STRING AS PROGRESS_STEP_NUMBER,
        JSONFIELD:proxy_telname::STRING AS PROXY_TELNAME,
        JSONFIELD:comment_ja::STRING AS COMMENT_JA,
        JSONFIELD:comment_en::STRING AS COMMENT_EN,
        _FILEDATE,
        _FILENAME
    FROM {{ source("TGIS", "SERVICEREQUEST_DETAILS") }}
    WHERE _FILEDATE = (
        SELECT MAX(RUN_TIME)
        FROM {{ source('TGIS', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'dwh_servicerequest_details'
        ) 
)

,transform_data as (
    SELECT
        ID,
        SVC_MNG_NM,
        STEP_NUMBER,
        STEP_NAME_JA,
        STEP_NAME_EN,
        PROGRESS_CATEGORY,
        PROGRESS_CATEGORY_JA,
        PROGRESS_CATEGORY_EN,
        WORK_NUMBER,
        WORK_NAME_JA,
        WORK_NAME_EN,
        WORK_CATEGORY_ID,
        WORK_CATEGORY_JA,
        WORK_CATEGORY_EN,
        ITGC_FLAG,
        INCHARGE_GROUP_ID,
        INCHARGE_GROUP_JA,
        INCHARGE_GROUP_EN,
        ASSIGNMENT_CATEGORY_ID,
        ASSIGNMENT_CATEGORY_JA,
        ASSIGNMENT_CATEGORY_EN,
        WORK_COMPLETE_FLAG,
        WORK_INCHARGE_TELNM,
        WORK_INCHARGE_TELNAME,
        WORK_EXEC_DATE,
        WORK_RESULT_ID,
        WORK_RESULT_JA,
        WORK_RESULT_EN,
        PROGRESS_STEP_NUMBER,
        PROXY_TELNAME,
        COMMENT_JA,
        COMMENT_EN,
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
)

,type_data as (
    SELECT
		CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        ID,
        SVC_MNG_NM,
        STEP_NUMBER,
        STEP_NAME_JA,
        STEP_NAME_EN,
        PROGRESS_CATEGORY,
        PROGRESS_CATEGORY_JA,
        PROGRESS_CATEGORY_EN,
        WORK_NUMBER,
        WORK_NAME_JA,
        WORK_NAME_EN,
        WORK_CATEGORY_ID,
        WORK_CATEGORY_JA,
        WORK_CATEGORY_EN,
        ITGC_FLAG,
        INCHARGE_GROUP_ID,
        INCHARGE_GROUP_JA,
        INCHARGE_GROUP_EN,
        ASSIGNMENT_CATEGORY_ID,
        ASSIGNMENT_CATEGORY_JA,
        ASSIGNMENT_CATEGORY_EN,
        WORK_COMPLETE_FLAG,
        WORK_INCHARGE_TELNM,
        WORK_INCHARGE_TELNAME,
        WORK_EXEC_DATE,
        WORK_RESULT_ID,
        WORK_RESULT_JA,
        WORK_RESULT_EN,
        PROGRESS_STEP_NUMBER,
        PROXY_TELNAME,
        COMMENT_JA,
        COMMENT_EN
	FROM transform_data
)

SELECT * FROM type_data