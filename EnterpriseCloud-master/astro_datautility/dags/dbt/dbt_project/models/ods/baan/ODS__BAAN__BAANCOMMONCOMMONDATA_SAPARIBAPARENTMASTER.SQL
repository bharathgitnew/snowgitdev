/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCOMMONCOMMONDATA_SAPARIBAPARENTMASTER',
    unique_key = ['PARENTBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ANWK)),'') AS ARIBANETWORKID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DUNS)),'') AS DUNS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAME)),'') AS NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PBPD)),'') AS PARENTBUSINESSPARTNER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM956200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ARIBANETWORKID AS ARIBANETWORKID, 
        source_data.DUNS AS DUNS, 
        source_data.NAME AS NAME, 
        source_data.PARENTBUSINESSPARTNER AS PARENTBUSINESSPARTNER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ARIBANETWORKID as VARCHAR(64)) as ARIBANETWORKID,
        cast(DUNS as VARCHAR(64)) as DUNS,
        cast(NAME as VARCHAR(35)) as NAME,
        cast(PARENTBUSINESSPARTNER as VARCHAR(9)) as PARENTBUSINESSPARTNER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data