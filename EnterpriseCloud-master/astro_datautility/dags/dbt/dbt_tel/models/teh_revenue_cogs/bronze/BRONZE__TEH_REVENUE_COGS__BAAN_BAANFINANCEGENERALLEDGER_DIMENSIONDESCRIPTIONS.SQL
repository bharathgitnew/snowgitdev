/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS',
    unique_key = ['DIMENSIONTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'') AS DIMENSIONDESCRIPTION 
            ,CAST(T$DIMN AS TINYINT)                     AS DIMENSIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SDES)),'') AS SHORTDESCRIPTION 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD002200") }} AS SOURCETABLE 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,  
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DIMENSIONDESCRIPTION AS DIMENSIONDESCRIPTION, 
        source_data.DIMENSIONTYPE AS DIMENSIONTYPE, 
        source_data.SHORTDESCRIPTION AS SHORTDESCRIPTION
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DIMENSIONDESCRIPTION as VARCHAR(30)) as DIMENSIONDESCRIPTION,
        cast(DIMENSIONTYPE as NUMBER(38,0)) as DIMENSIONTYPE,
        cast(SHORTDESCRIPTION as VARCHAR(6)) as SHORTDESCRIPTION
    from transform_data
    )
select * from type_data