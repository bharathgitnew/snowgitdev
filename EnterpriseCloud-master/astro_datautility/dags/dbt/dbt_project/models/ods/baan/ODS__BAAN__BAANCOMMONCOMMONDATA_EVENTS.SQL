/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_EVENTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_EVENTS.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_EVENTS 
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
    alias='BAANCOMMONCOMMONDATA_EVENTS',
    unique_key = ['EVNT',
    'ORDER_TYPEID']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,201                                           AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EDSC)),'') AS EDSC 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EVNT)),'') AS EVNT 
            ,T$OTYP.CONSTANTDESCRIPTION                  AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$OTYP AS INT)                         AS ORDER_TYPEID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM902201") }} AS SOURCETABLE  
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OTYP 
             ON   T$OTYP.TABLENAME  = 'TCCOM902' 
              AND T$OTYP.COLUMNNAME = 'T$OTYP' 
              AND T$OTYP.CONSTANT   = SOURCETABLE.T$OTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.EDSC AS EDSC, 
        source_data.EVNT AS EVNT, 
        source_data.ORDER_TYPEDESCRIPTION AS ORDER_TYPEDESCRIPTION, 
        source_data.ORDER_TYPEID AS ORDER_TYPEID
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(EDSC as VARCHAR(80)) as EDSC,
        cast(EVNT as VARCHAR(20)) as EVNT,
        cast(ORDER_TYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_TYPEDESCRIPTION,
        cast(ORDER_TYPEID as NUMBER(38,0)) as ORDER_TYPEID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data