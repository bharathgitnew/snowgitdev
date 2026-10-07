/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES',
    unique_key = ['CONTRACTTYPE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTPC)),'') AS CONTRACTTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'') AS DESCRIPTION 
            ,T$TXIN.CONSTANTDESCRIPTION                  AS TAXINDICATORDESCRIPTION 
            ,CAST(T$TXIN AS INT)                         AS TAXINDICATORID 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM005201") }} AS SOURCETABLE  
            /*TAXINDICATOR*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TXIN 
             ON   T$TXIN.TABLENAME  = 'TSCTM005' 
              AND T$TXIN.COLUMNNAME = 'T$TXIN' 
              AND T$TXIN.CONSTANT   = SOURCETABLE.T$TXIN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.CONTRACTTYPE AS CONTRACTTYPE, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.TAXINDICATORDESCRIPTION AS TAXINDICATORDESCRIPTION, 
        source_data.TAXINDICATORID AS TAXINDICATORID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(CONTRACTTYPE as VARCHAR(3)) as CONTRACTTYPE,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(TAXINDICATORDESCRIPTION as VARCHAR(16777216)) as TAXINDICATORDESCRIPTION,
        cast(TAXINDICATORID as NUMBER(38,0)) as TAXINDICATORID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data