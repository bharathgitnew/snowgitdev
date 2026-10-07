/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANToolsTextManager_Text.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANToolsTextManager_Text.SQL 
-materialized incremental
-alias BAANToolsTextManager_Text 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANTOOLSTEXTMANAGER_TEXT',
    unique_key = ['TextNumber',
    'Language',
    'NumberofLines']
) }}


with source_data as 
(
    SELECT 
           CAST(T$CTXT AS NUMERIC(38,0))                   TextNumber 
           ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')     Language 
           ,CAST(T$SEQE AS NUMERIC(38,0))                   NumberOfLines 
           ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TEXT)),'')     TextLine 
           ,_CAPTUREDATETIME
        FROM {{ source("BAAN_ORACLE_LIVE", "TTTTXT010201") }} AS SOURCETABLE
        )
,transform_data as
(
    SELECT 
        source_data.TEXTNUMBER AS TextNumber, 
        source_data.LANGUAGE AS Language, 
        source_data.NUMBEROFLINES AS NumberOfLines, 
        source_data.TEXTLINE AS TextLine, 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(TEXTNUMBER as NUMBER(38,0)) as TEXTNUMBER,
        cast(LANGUAGE as VARCHAR(16777216)) as LANGUAGE,
        cast(NUMBEROFLINES as NUMBER(38,0)) as NUMBEROFLINES,
        cast(TEXTLINE as VARCHAR(16777216)) as TEXTLINE,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) AS _CAPTUREDATETIME,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data