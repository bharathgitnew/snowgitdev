/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\ManagerServiceGroup__MDM_ManagerServiceGroup.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\ManagerServiceGroup.SQL 
-materialized incremental
-alias ManagerServiceGroup 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ManagerServiceGroup',
    unique_key = ['Manager']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"Manager"::VARCHAR AS Manager,  
        	jsonfield:"Emp ID"::VARCHAR AS EmpID, 
        	jsonfield:"Emp Group"::VARCHAR AS EmpGroup, 
        	jsonfield:"Job Title Group"::VARCHAR AS JobTitleGroup, 
        	jsonfield:"Job Category"::VARCHAR AS JobCategory, 
        	jsonfield:"Office Name"::VARCHAR AS OfficeName, 
        	jsonfield:"Last Audit Date"::VARCHAR AS LastAuditDate, 
        	jsonfield:"Regional Service Manager"::VARCHAR AS RegionalServiceManager, 
        	jsonfield:"Service Manager ID"::VARCHAR AS ServiceManagerID, 
        	jsonfield:"Active"::VARCHAR AS Active 
        FROM {{ source("MDM", "MANAGERSERVICEGROUP") }} 
        )
,transform_data as
(
    SELECT 
        source_data.MANAGER AS Manager, 
        source_data.EMPID AS EmpID, 
        source_data.EMPGROUP AS EmpGroup, 
        source_data.JOBTITLEGROUP AS JobTitleGroup, 
        source_data.JOBCATEGORY AS JobCategory, 
        source_data.OFFICENAME AS OfficeName, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.LASTAUDITDATE , '/Date(' , '' ) , ')/' , '' ) ) AS LastAuditDate, 
        source_data.REGIONALSERVICEMANAGER AS RegionalServiceManager, 
        source_data.SERVICEMANAGERID AS ServiceManagerID, 
        source_data.ACTIVE AS Active, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(MANAGER as VARCHAR(16777216)) as MANAGER,
        cast(EMPID as VARCHAR(16777216)) as EMPID,
        cast(EMPGROUP as VARCHAR(16777216)) as EMPGROUP,
        cast(JOBTITLEGROUP as VARCHAR(16777216)) as JOBTITLEGROUP,
        cast(JOBCATEGORY as VARCHAR(16777216)) as JOBCATEGORY,
        cast(OFFICENAME as VARCHAR(16777216)) as OFFICENAME,
        cast(LASTAUDITDATE as TIMESTAMP_NTZ(9)) as LASTAUDITDATE,
        cast(REGIONALSERVICEMANAGER as VARCHAR(16777216)) as REGIONALSERVICEMANAGER,
        cast(SERVICEMANAGERID as VARCHAR(16777216)) as SERVICEMANAGERID,
        cast(ACTIVE as VARCHAR(16777216)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data