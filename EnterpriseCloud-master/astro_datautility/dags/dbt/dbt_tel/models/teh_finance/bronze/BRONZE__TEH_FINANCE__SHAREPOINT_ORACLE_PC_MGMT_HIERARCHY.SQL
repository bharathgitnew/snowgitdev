{{ config(
materialized='tel_incremental'
,incremental_strategy='insert_overwrite'
,alias='SHAREPOINT_ORACLE_PC_MGMT_HIERARCHY'
,transient=false
) }}


with source_data AS 
(
    SELECT
    _FILENAME,
    _FILEDATE,
    jsonfield:fields.Title::STRING as PROFIT_CENTER,
    jsonfield:fields.COST_CENTER::STRING as COST_CENTER,
    jsonfield:fields.SVP_LEVEL::STRING as SVP_LEVEL,
    jsonfield:fields.DIRECTOR_VP_LEVEL::STRING as DIRECTOR_VP_LEVEL,
    jsonfield:fields.MANAGER_LEVEL::STRING as MANAGER_LEVEL,
    jsonfield:fields.BUDGET_PLANNER::STRING as BUDGET_PLANNER,
    jsonfield:fields.Created::STRING as CREATED,
    jsonfield:fields.Modified::STRING as MODIFIED,
    DataItems.value:email::STRING AS CREATEDBY,
    DataItems1.value:email::STRING AS MODIFIEDBY  
    FROM {{source('SHAREPOINT', 'ORACLE_PC_MGMT_HIERARCHY')}},
    LATERAL FLATTEN (input => JsonField:createdBy) DataItems,
    LATERAL FLATTEN (input => JsonField:lastModifiedBy) DataItems1 
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source('SHAREPOINT','ORACLE_PC_MGMT_HIERARCHY') }})
)

,transform_data AS
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        PROFIT_CENTER,
        COST_CENTER,
        LPAD(SVP_LEVEL,6,0) AS SVP_LEVEL,
        LPAD(DIRECTOR_VP_LEVEL,6,0) AS DIRECTOR_VP_LEVEL,
        LPAD(MANAGER_LEVEL,6,0) AS MANAGER_LEVEL,
        LPAD(BUDGET_PLANNER,6,0) AS BUDGET_PLANNER,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM source_data
)

,type_data AS 
(
    SELECT 
        _FILENAME,
        _FILEDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        PROFIT_CENTER,
        COST_CENTER,
        SVP_LEVEL,
        DIRECTOR_VP_LEVEL,
        MANAGER_LEVEL,
        BUDGET_PLANNER,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM transform_data
)

SELECT * FROM type_data

