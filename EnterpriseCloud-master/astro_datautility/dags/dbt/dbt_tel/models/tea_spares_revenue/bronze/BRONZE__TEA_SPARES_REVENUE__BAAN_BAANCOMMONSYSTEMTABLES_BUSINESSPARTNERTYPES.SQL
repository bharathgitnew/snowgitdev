/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONSYSTEMTABLES_BUSINESSPARTNERTYPES',
    unique_key = ['BUSINESSPARTNERTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CBTP)),'') AS BUSINESSPARTNERTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS029200") }} AS SOURCETABLE  
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT COALESCE(MAX(_CAPTUREDATETIME),'1900-01-01') FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.  
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BUSINESSPARTNERTYPE AS BUSINESSPARTNERTYPE, 
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
        BUSINESSPARTNERTYPE,
        DESCRIPTION
    from transform_data
    )
select * from type_data