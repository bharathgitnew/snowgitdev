/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT.SQL 
-materialized incremental
-alias BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT',
    unique_key = ['DIMENSIONTYPE',
    'ENUMVALUE1AID',
    'INTEGRATIONELEMENT',
    'INTEGRATIONPRIORITY',
    'LOGISTICCOMPANY',
    'LONGVALUE1',
    'STRINGVALUE1']
) }}


with source_data as 
(
    SELECT 
            201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DIMX)),'') AS DIMENSIONCODE 
            ,CAST(T$DIMN AS TINYINT)                     AS DIMENSIONTYPE 
            ,T$EV1A.CONSTANTDESCRIPTION                  AS ENUMVALUE1ADESCRIPTION 
            ,CAST(T$EV1A AS INT)                         AS ENUMVALUE1AID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INEL)),'') AS INTEGRATIONELEMENT 
            ,CAST(T$PRIO AS TINYINT)                     AS INTEGRATIONPRIORITY 
            ,CAST(T$LCMP AS INT)                         AS LOGISTICCOMPANY 
            ,CAST(T$LVA1 AS BIGINT)                      AS LONGVALUE1 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SVA1)),'') AS STRINGVALUE1 
            ,SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTFGLD423201") }} AS SOURCETABLE  
            /*ENUMVALUE1A*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$EV1A 
             ON   T$EV1A.TABLENAME  = 'TFGLD423' 
              AND T$EV1A.COLUMNNAME = 'T$EV1A' 
              AND T$EV1A.CONSTANT   = SOURCETABLE.T$EV1A 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.DIMENSIONCODE AS DIMENSIONCODE, 
        source_data.DIMENSIONTYPE AS DIMENSIONTYPE, 
        source_data.ENUMVALUE1ADESCRIPTION AS ENUMVALUE1ADESCRIPTION, 
        source_data.ENUMVALUE1AID AS ENUMVALUE1AID, 
        source_data.INTEGRATIONELEMENT AS INTEGRATIONELEMENT, 
        source_data.INTEGRATIONPRIORITY AS INTEGRATIONPRIORITY, 
        source_data.LOGISTICCOMPANY AS LOGISTICCOMPANY, 
        source_data.LONGVALUE1 AS LONGVALUE1, 
        source_data.STRINGVALUE1 AS STRINGVALUE1
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(DIMENSIONCODE as VARCHAR(6)) as DIMENSIONCODE,
        cast(DIMENSIONTYPE as NUMBER(38,0)) as DIMENSIONTYPE,
        cast(ENUMVALUE1ADESCRIPTION as VARCHAR(16777216)) as ENUMVALUE1ADESCRIPTION,
        cast(ENUMVALUE1AID as NUMBER(38,0)) as ENUMVALUE1AID,
        cast(INTEGRATIONELEMENT as VARCHAR(3)) as INTEGRATIONELEMENT,
        cast(INTEGRATIONPRIORITY as NUMBER(38,0)) as INTEGRATIONPRIORITY,
        cast(LOGISTICCOMPANY as NUMBER(38,0)) as LOGISTICCOMPANY,
        cast(LONGVALUE1 as NUMBER(38,0)) as LONGVALUE1,
        cast(STRINGVALUE1 as VARCHAR(50)) as STRINGVALUE1,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME
from transform_data
    )
select * from type_data