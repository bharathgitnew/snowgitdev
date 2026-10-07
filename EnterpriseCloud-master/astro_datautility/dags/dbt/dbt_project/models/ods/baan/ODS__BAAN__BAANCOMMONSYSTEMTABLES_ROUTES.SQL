/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_ROUTES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_ROUTES.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_ROUTES 
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
    alias='BAANCOMMONSYSTEMTABLES_ROUTES',
    unique_key = ['ROUTE']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,T$DAYN.CONSTANTDESCRIPTION                  AS DAYDESCRIPTION 
            ,CAST(T$DAYN AS INT)                         AS DAYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRTE)),'') AS ROUTE  
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS004200") }} AS SOURCETABLE  
            /*DAY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DAYN 
             ON   T$DAYN.TABLENAME  = 'TCMCS004' 
              AND T$DAYN.COLUMNNAME = 'T$DAYN' 
              AND T$DAYN.CONSTANT   = SOURCETABLE.T$DAYN 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DAYDESCRIPTION AS DAYDESCRIPTION, 
        source_data.DAYID AS DAYID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.ROUTE AS ROUTE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DAYDESCRIPTION as VARCHAR(16777216)) as DAYDESCRIPTION,
        cast(DAYID as NUMBER(38,0)) as DAYID,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(ROUTE as VARCHAR(5)) as ROUTE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data