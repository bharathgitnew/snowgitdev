{{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_PC_MGMT_HIERARCHY',
            tags=["finance"],
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        PROFIT_CENTER,
        COST_CENTER,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        NULL AS LONG_DESCRIPTION,
        NULL AS SEGMENT_NAME,
        NULL AS DEPARTMENT_NAME,
        NULL AS OFFICE_NAME,
        NULL AS ACCT_CAT,
        NULL AS SHORT_DESCRIPTION,
        NULL AS SEG,
        NULL AS FUNCTION,
        NULL AS SAP_DEPT,
        NULL AS DEPARTMENT,
        NULL AS BU,
        NULL AS ORACLE_SEGMENT,
        _FILEDATE,
		_FILENAME
        FROM {{ ref('ODS__SHAREPOINT__ORACLE_PC_MGMT_HIERARCHY') }}
    ),

    transform_data as (
        SELECT
        _FILEDATE,
		_FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        PROFIT_CENTER,
        COST_CENTER,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        LONG_DESCRIPTION,
        SEGMENT_NAME,
        DEPARTMENT_NAME,
        OFFICE_NAME,
        ACCT_CAT,
        SHORT_DESCRIPTION,
        SEG,
        FUNCTION,
        SAP_DEPT,
        DEPARTMENT,
        BU,
        ORACLE_SEGMENT
        FROM source_data
    ),

    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        PROFIT_CENTER,
        COST_CENTER,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        LONG_DESCRIPTION,
        SEGMENT_NAME,
        DEPARTMENT_NAME,
        OFFICE_NAME,
        ACCT_CAT,
        SHORT_DESCRIPTION,
        SEG,
        FUNCTION,
        SAP_DEPT,
        DEPARTMENT,
        BU,
        ORACLE_SEGMENT
        FROM transform_data
    )
    SELECT * FROM type_data