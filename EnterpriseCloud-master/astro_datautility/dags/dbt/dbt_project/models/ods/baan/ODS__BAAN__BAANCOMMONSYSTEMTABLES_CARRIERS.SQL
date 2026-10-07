/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_CARRIERS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_CARRIERS.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_CARRIERS 
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
    alias='BAANCOMMONSYSTEMTABLES_CARRIERS',
    unique_key = ['CARRIER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SUNO)),'') AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFRW)),'') AS CARRIER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SCAC)),'') AS STANDARDCARRIERALPHACODE 
            ,T$TRMD.CONSTANTDESCRIPTION                  AS TRANSPORTCATERYDESCRIPTION 
            ,CAST(T$TRMD AS INT)                         AS TRANSPORTCATERYID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS080200") }} AS SOURCETABLE  
            /*TRANSPORTCATERY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TRMD 
             ON   T$TRMD.TABLENAME  = 'TCMCS080' 
              AND T$TRMD.COLUMNNAME = 'T$TRMD' 
              AND T$TRMD.CONSTANT   = SOURCETABLE.T$TRMD 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CARRIER AS CARRIER, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.STANDARDCARRIERALPHACODE AS STANDARDCARRIERALPHACODE, 
        source_data.TRANSPORTCATERYDESCRIPTION AS TRANSPORTCATERYDESCRIPTION, 
        source_data.TRANSPORTCATERYID AS TRANSPORTCATERYID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CARRIER as VARCHAR(3)) as CARRIER,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(STANDARDCARRIERALPHACODE as VARCHAR(20)) as STANDARDCARRIERALPHACODE,
        cast(TRANSPORTCATERYDESCRIPTION as VARCHAR(16777216)) as TRANSPORTCATERYDESCRIPTION,
        cast(TRANSPORTCATERYID as NUMBER(38,0)) as TRANSPORTCATERYID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data