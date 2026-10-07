/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONSYSTEMTABLES_ITEMGROUPS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONSYSTEMTABLES_ITEMGROUPS.SQL 
-materialized incremental
-alias BAANCOMMONSYSTEMTABLES_ITEMGROUPS 
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
    alias='BAANCOMMONSYSTEMTABLES_ITEMGROUPS',
    unique_key = ['ITEMGROUP']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,T$SPEC.CONSTANTDESCRIPTION                  AS COSTSTOBESPECIFIEDDESCRIPTION 
            ,CAST(T$SPEC AS INT)                         AS COSTSTOBESPECIFIEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'') AS CURRENCY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCA)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CITG)),'') AS ITEMGROUP 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCMCS023201") }} AS SOURCETABLE  
            /*COSTSTOBESPECIFIED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SPEC 
             ON   T$SPEC.TABLENAME  = 'TCMCS023' 
              AND T$SPEC.COLUMNNAME = 'T$SPEC' 
              AND T$SPEC.CONSTANT   = SOURCETABLE.T$SPEC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COSTSTOBESPECIFIEDDESCRIPTION AS COSTSTOBESPECIFIEDDESCRIPTION, 
        source_data.COSTSTOBESPECIFIEDID AS COSTSTOBESPECIFIEDID, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.ITEMGROUP AS ITEMGROUP
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COSTSTOBESPECIFIEDDESCRIPTION as VARCHAR(16777216)) as COSTSTOBESPECIFIEDDESCRIPTION,
        cast(COSTSTOBESPECIFIEDID as NUMBER(38,0)) as COSTSTOBESPECIFIEDID,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(ITEMGROUP as VARCHAR(6)) as ITEMGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data