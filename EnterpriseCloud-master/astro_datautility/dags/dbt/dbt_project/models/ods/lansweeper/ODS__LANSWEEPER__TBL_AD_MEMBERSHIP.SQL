/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_AD_MEMBERSHIP__Lansweeper_tblADMembership.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_AD_MEMBERSHIP.SQL 
-materialized incremental
-alias TBL_AD_MEMBERSHIP 
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
    alias='TBL_AD_MEMBERSHIP',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"ChildAdObjectID"::NUMBER AS Child_Ad_Object_ID 
        ,JSONFIELD:"ParentAdObjectID"::NUMBER AS Parent_Ad_Object_ID 
        ,REGEXP_REPLACE(JSONFIELD:"lastChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS last_Changed 
        FROM {{ source("LANSWEEPER", "TBLADMEMBERSHIP") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLADMEMBERSHIP") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.CHILD_AD_OBJECT_ID, 
        source_data.LAST_CHANGED, 
        source_data.PARENT_AD_OBJECT_ID, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(CHILD_AD_OBJECT_ID as NUMBER(38,0)) as CHILD_AD_OBJECT_ID,
        cast(PARENT_AD_OBJECT_ID as NUMBER(38,0)) as PARENT_AD_OBJECT_ID,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data