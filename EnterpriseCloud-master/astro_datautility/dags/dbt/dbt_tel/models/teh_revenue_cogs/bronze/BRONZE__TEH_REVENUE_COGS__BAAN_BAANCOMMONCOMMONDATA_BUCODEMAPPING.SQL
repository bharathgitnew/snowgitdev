/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_BUCODEMAPPING.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_BUCODEMAPPING.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_BUCODEMAPPING 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONCOMMONDATA_BUCODEMAPPING',
    unique_key = ['BUCODETEA',
    'BUCODETEL']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BUCC)),'') AS BUCODEBYCONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BOLD)),'') AS BUCODEOLD_TEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TEAC)),'') AS BUCODETEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELC)),'') AS BUCODETEL 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM907200") }} AS SOURCETABLE  
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BUCC)),'') AS BUCODEBYCONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BOLD)),'') AS BUCODEOLD_TEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TEAC)),'') AS BUCODETEA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELC)),'') AS BUCODETEL 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM907201") }} AS SOURCETABLE  
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.BUCODETEA AS BUCODETEA, 
        source_data.BUCODETEL AS BUCODETEL,
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BUCODEBYCONFIGURATION AS BUCODEBYCONFIGURATION, 
        source_data.BUCODEOLD_TEA AS BUCODEOLD_TEA             
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(BUCODETEA as VARCHAR(6)) as BUCODETEA,
        cast(BUCODETEL as VARCHAR(6)) as BUCODETEL,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BUCODEBYCONFIGURATION as VARCHAR(2)) as BUCODEBYCONFIGURATION,
        cast(BUCODEOLD_TEA as VARCHAR(6)) as BUCODEOLD_TEA
    from transform_data
    )
select * from type_data