/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_PC_MGMT_HIERARCHY',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        PROFIT_CENTER,
        COST_CENTER,
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
        ORACLE_SEGMENT,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('FILE', 'ORACLE_PC_MGMT_HIERARCHY') }} AS ORACLE_PC_MGMT_HIERARCHY
        WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('FILE', 'ORACLE_PC_MGMT_HIERARCHY') }})
    ),
    transform_data as (
        SELECT
        PROFIT_CENTER,
        COST_CENTER,
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
        ORACLE_SEGMENT,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        PROFIT_CENTER,
        COST_CENTER,
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
        ORACLE_SEGMENT,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER
        FROM transform_data
    )
    SELECT * FROM type_data