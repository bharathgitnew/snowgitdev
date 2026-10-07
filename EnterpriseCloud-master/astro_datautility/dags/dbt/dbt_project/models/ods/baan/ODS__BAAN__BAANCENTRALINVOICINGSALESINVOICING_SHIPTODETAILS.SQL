/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS.SQL 
-materialized incremental
-alias BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCENTRALINVOICINGSALESINVOICING_SHIPTODETAILS',
    unique_key = ['SHIPTOBPFROMARIBA',
    'SHIPTOBPFROMBAAN']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STAP)),'') AS SHIPTOBPFROMARIBA 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$STBP)),'') AS SHIPTOBPFROMBAAN 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TCISLI907201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.SHIPTOBPFROMARIBA AS SHIPTOBPFROMARIBA, 
        source_data.SHIPTOBPFROMBAAN AS SHIPTOBPFROMBAAN
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(SHIPTOBPFROMARIBA as VARCHAR(9)) as SHIPTOBPFROMARIBA,
        cast(SHIPTOBPFROMBAAN as VARCHAR(9)) as SHIPTOBPFROMBAAN,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data