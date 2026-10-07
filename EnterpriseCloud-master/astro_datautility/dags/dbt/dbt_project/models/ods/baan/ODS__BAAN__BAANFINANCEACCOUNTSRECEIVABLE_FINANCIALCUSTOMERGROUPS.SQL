/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS.SQL 
-materialized incremental
-alias BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:51 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEACCOUNTSRECEIVABLE_FINANCIALCUSTOMERGROUPS',
    unique_key = ['FINANCIALBPGROUPAR']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FICU)),'') AS FINANCIALBPGROUPAR 
            ,SOURCETABLE.T$TEXT   /* TEXT */             AS TEXT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFACR001200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.FINANCIALBPGROUPAR AS FINANCIALBPGROUPAR, 
        source_data.TEXT AS TEXT
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(FINANCIALBPGROUPAR as VARCHAR(3)) as FINANCIALBPGROUPAR,
        cast(TEXT as NUMBER(38,10)) as TEXT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data