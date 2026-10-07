/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:53 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANFINANCEGENERALLEDGER_FINANCIALCOMPANIESBYGROUPCOMPANY',
    unique_key = ['COMPANYNUMBER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME AS _CAPTUREDATETIME 
            ,200                            AS _COMPANYID 
            ,CAST(T$NCMP AS INT)          AS COMPANYNUMBER 
            ,CAST(T$SRNO AS TINYINT)      AS PRIORITYNUMBER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD001200") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COMPANYNUMBER AS COMPANYNUMBER, 
        source_data.PRIORITYNUMBER AS PRIORITYNUMBER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COMPANYNUMBER as NUMBER(38,0)) as COMPANYNUMBER,
        cast(PRIORITYNUMBER as NUMBER(38,0)) as PRIORITYNUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data