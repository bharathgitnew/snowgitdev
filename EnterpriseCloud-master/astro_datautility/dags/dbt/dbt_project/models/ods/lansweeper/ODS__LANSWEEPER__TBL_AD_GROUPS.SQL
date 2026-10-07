/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_AD_GROUPS__Lansweeper_tblADGroups.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_AD_GROUPS.SQL 
-materialized incremental
-alias TBL_AD_GROUPS 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TBL_AD_GROUPS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"ADGroupID"::NUMBER AS AD_Group_ID 
        ,JSONFIELD:"ADObjectID"::NUMBER AS AD_Object_ID 
        ,JSONFIELD:"ManagerADObjectId"::NUMBER AS Manager_AD_Object_Id 
        ,JSONFIELD:"GroupType"::NUMBER AS Group_Type 
        ,REGEXP_REPLACE(JSONFIELD:"LastChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Changed 
        ,JSONFIELD:"Description"::STRING AS Description 
        ,JSONFIELD:"Name"::STRING AS Name 
        FROM {{ source("LANSWEEPER", "TBLADGROUPS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLADGROUPS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.AD_GROUP_ID, 
        source_data.AD_OBJECT_ID, 
        source_data.MANAGER_AD_OBJECT_ID,         
        source_data.GROUP_TYPE, 
        source_data.LAST_CHANGED, 
        source_data.DESCRIPTION,         
        source_data.NAME, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(AD_GROUP_ID as NUMBER(38,0)) as AD_GROUP_ID,
        cast(AD_OBJECT_ID as NUMBER(38,0)) as AD_OBJECT_ID,
        cast(MANAGER_AD_OBJECT_ID as NUMBER(38,0)) as MANAGER_AD_OBJECT_ID,
        cast(GROUP_TYPE as NUMBER(38,0)) as GROUP_TYPE,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data