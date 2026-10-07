/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_DEPT_MGMT_HIERARCHY',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        DEPARTMENT, 
 	 	SAP_DEPT, 
 	 	COST_CENTER, 
 	 	SVP_LEVEL, 
 	 	DIRECTOR_VP_LEVEL, 
 	 	MANAGER_LEVEL, 
 	 	BUDGET_PLANNER,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('FILE', 'ORACLE_DEPT_MGMT_HIERARCHY') }} AS ORACLE_DEPT_MGMT_HIERARCHY
        WHERE _UPLOADDATE = (SELECT MAX(_UPLOADDATE) FROM {{ source('FILE', 'ORACLE_DEPT_MGMT_HIERARCHY') }})
    ),
    transform_data as (
        SELECT
        DEPARTMENT, 
 	 	SAP_DEPT, 
 	 	COST_CENTER, 
 	 	SVP_LEVEL, 
 	 	DIRECTOR_VP_LEVEL, 
 	 	MANAGER_LEVEL, 
 	 	BUDGET_PLANNER,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(DEPARTMENT AS VARCHAR(16777216)) AS DEPARTMENT, 
 	 	CAST(SAP_DEPT AS VARCHAR(16777216)) AS SAP_DEPT, 
 	 	CAST(COST_CENTER AS VARCHAR(16777216)) AS COST_CENTER, 
 	 	CAST(SVP_LEVEL AS VARCHAR(16777216)) AS SVP_LEVEL, 
 	 	CAST(DIRECTOR_VP_LEVEL AS VARCHAR(16777216)) AS DIRECTOR_VP_LEVEL, 
 	 	CAST(MANAGER_LEVEL AS VARCHAR(16777216)) AS MANAGER_LEVEL, 
 	 	CAST(BUDGET_PLANNER AS VARCHAR(16777216)) AS BUDGET_PLANNER,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		CAST(_FILENAME AS VARCHAR(128)) AS _FILENAME,
        CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data