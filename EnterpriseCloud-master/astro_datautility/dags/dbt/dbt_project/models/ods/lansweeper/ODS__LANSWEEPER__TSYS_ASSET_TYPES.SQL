/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Lansweeper\TSYS_ASSET_TYPES__Lansweeper_tsysAssetTypes.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\lansweeper\TSYS_ASSET_TYPES.SQL 
-materialized incremental
-alias TSYS_ASSET_TYPES 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema LANSWEEPER
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/12/2022 9:15:50 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TSYS_ASSET_TYPES',
    unique_key = []
) }}


with source_data as 
(
    SELECT 
        _FILENAME 
        ,_FILEDATE 
        ,JSONFIELD:"AssetType"::NUMBER AS Asset_Type 
        ,JSONFIELD:"AssetTypename"::STRING AS Asset_Type_name 
        ,JSONFIELD:"AssetTypeIcon10"::STRING AS Asset_Type_Icon_10 
        ,JSONFIELD:"AssetTypeIcon16"::STRING AS Asset_Type_Icon_16 
        ,JSONFIELD:"AssetTypeIcon48"::STRING AS Asset_Type_Icon_48 
        ,REGEXP_REPLACE(JSONFIELD:"LastChanged", '\/Date\\(|\\)\/', '')::TIMESTAMP AS Last_Changed 
        FROM {{ source("LANSWEEPER", "TSYSASSETTYPES") }} 
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("LANSWEEPER", "TSYSASSETTYPES") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.ASSET_TYPE, 
        source_data.ASSET_TYPE_ICON_10, 
        source_data.ASSET_TYPE_ICON_16, 
        source_data.ASSET_TYPE_ICON_48, 
        source_data.ASSET_TYPE_NAME, 
        source_data.LAST_CHANGED, 
        source_data._FILEDATE 
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID 
        FROM source_data
        )
,type_data as 
(
    select
        cast(ASSET_TYPE as NUMBER(38,0)) as ASSET_TYPE,
        cast(ASSET_TYPE_NAME as VARCHAR(16777216)) as ASSET_TYPE_NAME,
        cast(ASSET_TYPE_ICON_10 as VARCHAR(16777216)) as ASSET_TYPE_ICON_10,
        cast(ASSET_TYPE_ICON_16 as VARCHAR(16777216)) as ASSET_TYPE_ICON_16,
        cast(ASSET_TYPE_ICON_48 as VARCHAR(16777216)) as ASSET_TYPE_ICON_48,
        cast(LAST_CHANGED as TIMESTAMP_NTZ(9)) as LAST_CHANGED,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data