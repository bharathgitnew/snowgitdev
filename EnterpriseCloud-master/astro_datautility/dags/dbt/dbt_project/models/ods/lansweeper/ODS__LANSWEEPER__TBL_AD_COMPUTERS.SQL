/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TBL_AD_COMPUTERS__Lansweeper_tblADComputers.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TBL_AD_COMPUTERS.SQL 
-materialized incremental
-alias TBL_AD_COMPUTERS 
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
    alias='TBL_AD_COMPUTERS',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"AdcomputerID"::NUMBER AS Ad_computer_ID 
        ,JSONFIELD:"AssetID"::NUMBER AS Asset_ID 
        ,JSONFIELD:"Comment"::STRING AS Comment 
        ,JSONFIELD:"Company"::STRING AS Company 
        ,JSONFIELD:"Description"::STRING AS Description 
        ,JSONFIELD:"Location"::STRING AS Location 
        ,JSONFIELD:"OU"::STRING AS OU 
        ,REGEXP_REPLACE(JSONFIELD:"Lastchanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_changed 
        ,JSONFIELD:"ADObjectID"::NUMBER AS AD_Object_ID 
        ,JSONFIELD:"ManagerADObjectId"::NUMBER AS Manager_AD_Object_Id 
        ,JSONFIELD:"IsEnabled"::NUMBER AS Is_Enabled 
        FROM {{ source("LANSWEEPER", "TBLADCOMPUTERS") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TBLADCOMPUTERS") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.AD_COMPUTER_ID, 
        source_data.ASSET_ID, 
        source_data.COMMENT, 
        source_data.COMPANY,  
        source_data.DESCRIPTION, 
        source_data.LOCATION, 
        source_data.OU,
        source_data.LAST_CHANGED,         
        source_data.AD_OBJECT_ID, 
        source_data.MANAGER_AD_OBJECT_ID, 
        source_data.IS_ENABLED, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(AD_COMPUTER_ID as NUMBER(38,0)) as AD_COMPUTER_ID,
        cast(ASSET_ID as NUMBER(38,0)) as ASSET_ID,
        cast(COMMENT as VARCHAR(16777216)) as COMMENT,
        cast(COMPANY as VARCHAR(16777216)) as COMPANY,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(LOCATION as VARCHAR(16777216)) as LOCATION,
        cast(OU as VARCHAR(16777216)) as OU,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(AD_OBJECT_ID as NUMBER(38,0)) as AD_OBJECT_ID,
        cast(MANAGER_AD_OBJECT_ID as NUMBER(38,0)) as MANAGER_AD_OBJECT_ID,
        cast(IS_ENABLED as NUMBER(38,0)) as IS_ENABLED,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data