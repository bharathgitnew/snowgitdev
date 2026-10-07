/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEACCOUNTSRECEIVABLE_PROBLEMCODES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEACCOUNTSRECEIVABLE_PROBLEMCODES.SQL 
-materialized incremental
-alias BAANFINANCEACCOUNTSRECEIVABLE_PROBLEMCODES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:52 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEACCOUNTSRECEIVABLE_PROBLEMCODES',
    unique_key = ['PROBLEMCODE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,T$DIRD.CONSTANTDESCRIPTION                  AS CASHVIADIRECTDEBITSDESCRIPTION 
            ,CAST(T$DIRD AS INT)                         AS CASHVIADIRECTDEBITSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PROB)),'') AS PROBLEMCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PREF)),'') AS PROBLEMREFERENCE 
            ,T$SREM.CONSTANTDESCRIPTION                  AS SENDREMINDERDESCRIPTION 
            ,CAST(T$SREM AS INT)                         AS SENDREMINDERID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFACR002200") }} AS SOURCETABLE  
            /*CASHVIADIRECTDEBITS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DIRD 
             ON   T$DIRD.TABLENAME  = 'TFACR002' 
              AND T$DIRD.COLUMNNAME = 'T$DIRD' 
              AND T$DIRD.CONSTANT   = SOURCETABLE.T$DIRD 
            /*SENDREMINDER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SREM 
             ON   T$SREM.TABLENAME  = 'TFACR002' 
              AND T$SREM.COLUMNNAME = 'T$SREM' 
              AND T$SREM.CONSTANT   = SOURCETABLE.T$SREM 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CASHVIADIRECTDEBITSDESCRIPTION AS CASHVIADIRECTDEBITSDESCRIPTION, 
        source_data.CASHVIADIRECTDEBITSID AS CASHVIADIRECTDEBITSID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.PROBLEMCODE AS PROBLEMCODE, 
        source_data.PROBLEMREFERENCE AS PROBLEMREFERENCE, 
        source_data.SENDREMINDERDESCRIPTION AS SENDREMINDERDESCRIPTION, 
        source_data.SENDREMINDERID AS SENDREMINDERID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CASHVIADIRECTDEBITSDESCRIPTION as VARCHAR(16777216)) as CASHVIADIRECTDEBITSDESCRIPTION,
        cast(CASHVIADIRECTDEBITSID as NUMBER(38,0)) as CASHVIADIRECTDEBITSID,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(PROBLEMCODE as VARCHAR(3)) as PROBLEMCODE,
        cast(PROBLEMREFERENCE as VARCHAR(3)) as PROBLEMREFERENCE,
        cast(SENDREMINDERDESCRIPTION as VARCHAR(16777216)) as SENDREMINDERDESCRIPTION,
        cast(SENDREMINDERID as NUMBER(38,0)) as SENDREMINDERID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data