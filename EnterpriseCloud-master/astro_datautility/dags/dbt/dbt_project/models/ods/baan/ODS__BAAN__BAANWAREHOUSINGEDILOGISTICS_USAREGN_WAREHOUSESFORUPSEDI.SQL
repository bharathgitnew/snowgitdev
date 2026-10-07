/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI.SQL 
-materialized incremental
-alias BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGEDILOGISTICS_USAREGN_WAREHOUSESFORUPSEDI',
    unique_key = ['WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACCT)),'') AS ACCOUNTNO 
            ,T$UXPT.CONSTANTDESCRIPTION                  AS TOBEUSEDBYXPTDESCRIPTION 
            ,CAST(T$UXPT AS INT)                         AS TOBEUSEDBYXPTID 
            ,T$UATW.CONSTANTDESCRIPTION                  AS TOBEUSEDFORATWDESCRIPTION 
            ,CAST(T$UATW AS INT)                         AS TOBEUSEDFORATWID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SWAR)),'') AS UPSWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'') AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHEDI006201") }} AS SOURCETABLE  
            /*TOBEUSEDBYXPT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UXPT 
             ON   T$UXPT.TABLENAME  = 'WHEDI006' 
              AND T$UXPT.COLUMNNAME = 'T$UXPT' 
              AND T$UXPT.CONSTANT   = SOURCETABLE.T$UXPT 
            /*TOBEUSEDFORATW*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UATW 
             ON   T$UATW.TABLENAME  = 'WHEDI006' 
              AND T$UATW.COLUMNNAME = 'T$UATW' 
              AND T$UATW.CONSTANT   = SOURCETABLE.T$UATW 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCOUNTNO AS ACCOUNTNO, 
        source_data.TOBEUSEDBYXPTDESCRIPTION AS TOBEUSEDBYXPTDESCRIPTION, 
        source_data.TOBEUSEDBYXPTID AS TOBEUSEDBYXPTID, 
        source_data.TOBEUSEDFORATWDESCRIPTION AS TOBEUSEDFORATWDESCRIPTION, 
        source_data.TOBEUSEDFORATWID AS TOBEUSEDFORATWID, 
        source_data.UPSWAREHOUSE AS UPSWAREHOUSE, 
        source_data.WAREHOUSE AS WAREHOUSE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCOUNTNO as VARCHAR(10)) as ACCOUNTNO,
        cast(TOBEUSEDBYXPTDESCRIPTION as VARCHAR(16777216)) as TOBEUSEDBYXPTDESCRIPTION,
        cast(TOBEUSEDBYXPTID as NUMBER(38,0)) as TOBEUSEDBYXPTID,
        cast(TOBEUSEDFORATWDESCRIPTION as VARCHAR(16777216)) as TOBEUSEDFORATWDESCRIPTION,
        cast(TOBEUSEDFORATWID as NUMBER(38,0)) as TOBEUSEDFORATWID,
        cast(UPSWAREHOUSE as VARCHAR(6)) as UPSWAREHOUSE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data