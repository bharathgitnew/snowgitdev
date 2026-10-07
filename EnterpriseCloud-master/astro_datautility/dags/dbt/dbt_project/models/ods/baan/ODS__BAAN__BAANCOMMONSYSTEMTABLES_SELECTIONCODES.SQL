/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCommonSystemTables_SelectionCodes.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCommonSystemTables_SelectionCodes.SQL 
-materialized incremental
-alias BAANCommonSystemTables_SelectionCodes 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCommonSystemTables_SelectionCodes',
    unique_key = ['SELECT_']
) }}


with source_data as 
(
    SELECT   
            SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
        ,201                                           AS _COMPANYID 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
        ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSEL)),'') AS Select_   
    FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS022201") }} AS SOURCETABLE  
    {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
)        
,transform_data as
(
    SELECT 
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        SELECT_  
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(SELECT_ as VARCHAR(3)) as SELECT_,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data