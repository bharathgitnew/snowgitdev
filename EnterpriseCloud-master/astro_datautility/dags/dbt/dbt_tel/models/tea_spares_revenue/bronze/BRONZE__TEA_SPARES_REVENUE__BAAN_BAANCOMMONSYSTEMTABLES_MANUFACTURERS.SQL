/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_MANUFACTURERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_MANUFACTURERS.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_MANUFACTURERS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONSYSTEMTABLES_MANUFACTURERS',
    unique_key = ['MANUFACTURER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'') AS MANUFACTURER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION  
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS060200") }} AS SOURCETABLE  
        {% if is_tel_incremental() %} WHERE SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'') AS MANUFACTURER  
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS060201") }} AS SOURCETABLE 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.MANUFACTURER AS MANUFACTURER,
        source_data.DESCRIPTION AS DESCRIPTION
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        MANUFACTURER,
        DESCRIPTION
    from transform_data
    )
select * from type_data