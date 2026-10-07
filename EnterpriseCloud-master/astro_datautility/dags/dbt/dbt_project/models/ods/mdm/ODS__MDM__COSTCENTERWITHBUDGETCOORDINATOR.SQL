/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\CostCenterwithBudgetCoordinator.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\CostCenterwithBudgetCoordinator.SQL 
-materialized incremental
-alias CostCenterwithBudgetCoordinator 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:24:59 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='CostCenterwithBudgetCoordinator',
    unique_key = ['NAME']
) }}


with source_data as 
(
    SELECT 
        dataset.jsonfield:Name::STRING AS Name, 
        dataset.jsonfield:DivisionName::STRING AS DivisionName, 
        dataset.jsonfield:DivisionOwner_Code::STRING AS DivisionOwnerID, 
        dataset.jsonfield:DivisionOwner_Name::STRING AS DivisionOwnerName, 
        dataset.jsonfield:SubDivisionName::STRING AS SubDivisionName, 
        dataset.jsonfield:SubDivisionOwner_Code::STRING AS SubDivisionOwnerID, 
        dataset.jsonfield:SubDivisionOwner_Name::STRING AS SubDivisionOwnerName, 
        dataset.jsonfield:GroupName::STRING AS GroupName, 
        dataset.jsonfield:GroupOwner_Code::STRING AS GroupOwnerID, 
        dataset.jsonfield:GroupOwner_Name::STRING AS GroupOwnerName, 
        dataset.jsonfield:Status::STRING AS Status, 
        TO_TIMESTAMP_NTZ(TRIM(dataset.jsonfield:EffectiveDate::STRING,'/Date()/')) as EffectiveDate, 
        TO_TIMESTAMP_NTZ(TRIM(dataset.jsonfield:ExpirationDate::STRING,'/Date()/')) as ExpirationDate, 
        dataset.jsonfield:BudgetCoordinator_Code::STRING AS BudgetCoordinatorID, 
        dataset.jsonfield:BudgetCoordinator_Name::STRING AS BudgetCoordinatorName, 
        dataset.jsonfield:CostCenterGroup::STRING AS CostCenterGroup 
        FROM  {{ source("MDM", "COSTCENTERWITHBUDGETCOORDINATOR") }} dataset 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "COSTCENTERWITHBUDGETCOORDINATOR") }}  as c where c.jsonfield:Name::STRING = dataset.jsonfield:Name::STRING) 
        --AND METADATA$ACTION = 'INSERT 
        )
,transform_data as
(
    SELECT 
        source_data.NAME AS NAME, 
        source_data.DIVISIONNAME AS DIVISIONNAME, 
        source_data.DIVISIONOWNERID AS DIVISIONOWNERID, 
        source_data.DIVISIONOWNERNAME AS DIVISIONOWNERNAME, 
        source_data.SUBDIVISIONNAME AS SUBDIVISIONNAME, 
        source_data.SUBDIVISIONOWNERID AS SUBDIVISIONOWNERID, 
        source_data.SUBDIVISIONOWNERNAME AS SUBDIVISIONOWNERNAME, 
        source_data.GROUPNAME AS GROUPNAME, 
        source_data.GROUPOWNERID AS GROUPOWNERID, 
        source_data.GROUPOWNERNAME AS GROUPOWNERNAME, 
        source_data.STATUS AS STATUS, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.EXPIRATIONDATE AS EXPIRATIONDATE, 
        source_data.BUDGETCOORDINATORID AS BUDGETCOORDINATORID, 
        source_data.BUDGETCOORDINATORNAME AS BUDGETCOORDINATORNAME, 
        source_data.COSTCENTERGROUP AS COSTCENTERGROUP, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(DIVISIONNAME as VARCHAR(16777216)) as DIVISIONNAME,
        cast(DIVISIONOWNERID as VARCHAR(16777216)) as DIVISIONOWNERID,
        cast(DIVISIONOWNERNAME as VARCHAR(16777216)) as DIVISIONOWNERNAME,
        cast(SUBDIVISIONNAME as VARCHAR(16777216)) as SUBDIVISIONNAME,
        cast(SUBDIVISIONOWNERID as VARCHAR(16777216)) as SUBDIVISIONOWNERID,
        cast(SUBDIVISIONOWNERNAME as VARCHAR(16777216)) as SUBDIVISIONOWNERNAME,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(GROUPOWNERID as VARCHAR(16777216)) as GROUPOWNERID,
        cast(GROUPOWNERNAME as VARCHAR(16777216)) as GROUPOWNERNAME,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(BUDGETCOORDINATORID as VARCHAR(16777216)) as BUDGETCOORDINATORID,
        cast(BUDGETCOORDINATORNAME as VARCHAR(16777216)) as BUDGETCOORDINATORNAME,
        cast(COSTCENTERGROUP as VARCHAR(16777216)) as COSTCENTERGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data