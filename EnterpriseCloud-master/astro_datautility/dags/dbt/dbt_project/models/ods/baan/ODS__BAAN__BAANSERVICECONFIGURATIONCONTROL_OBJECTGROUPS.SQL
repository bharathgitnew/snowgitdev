/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS',
    unique_key = ['OBJECTGROUP']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'') AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLRT)),'') AS LABORRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COGR)),'') AS OBJECTGROUP 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG010201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.LABORRATE AS LABORRATE, 
        source_data.OBJECTGROUP AS OBJECTGROUP
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
        cast(LABORRATE as VARCHAR(3)) as LABORRATE,
        cast(OBJECTGROUP as VARCHAR(6)) as OBJECTGROUP,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data