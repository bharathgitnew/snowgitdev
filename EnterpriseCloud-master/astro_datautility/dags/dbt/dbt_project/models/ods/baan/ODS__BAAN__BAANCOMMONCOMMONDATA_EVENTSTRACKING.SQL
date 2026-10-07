/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_EVENTSTRACKING.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_EVENTSTRACKING.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_EVENTSTRACKING 
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
    alias='BAANCOMMONCOMMONDATA_EVENTSTRACKING',
    unique_key = ['BUYFROMBUSINESSPARTNER',
    'CUSTOMERPO',
    'EVENTDATE',
    'EVENTSEQUENCE',
    'ORDER_NUMBER',
    'ORDER_TYPEID',
    'POSITION',
    'SEQUENCE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INFO)),'')                                                                                         AS ADDITIONALINFORMATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUPO)),'')                                                                                         AS CUSTOMERPO 
            ,CAST(CASE WHEN T$EDAT<= '1/1/1970' THEN NULL ELSE T$EDAT  END AS DATETIME) AS EVENTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EVNT)),'')                                                                                         AS EVENTS 
            ,CAST(T$ESEQ AS INT)                                                                                                                 AS EVENTSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MORE)),'')                                                                                         AS MORE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OTYP.CONSTANTDESCRIPTION                                                                                                          AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$OTYP AS INT)                                                                                                                 AS ORDER_TYPEID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$SQNB AS INT)                                                                                                                 AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$USER)),'')                                                                                         AS USER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM903201") }} AS SOURCETABLE  
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OTYP 
             ON   T$OTYP.TABLENAME  = 'TCCOM903' 
              AND T$OTYP.COLUMNNAME = 'T$OTYP' 
              AND T$OTYP.CONSTANT   = SOURCETABLE.T$OTYP 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDITIONALINFORMATION AS ADDITIONALINFORMATION, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CUSTOMERPO AS CUSTOMERPO, 
        source_data.EVENTDATE AS EVENTDATE, 
        source_data.EVENTS AS EVENTS, 
        source_data.EVENTSEQUENCE AS EVENTSEQUENCE, 
        source_data.MORE AS MORE, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_TYPEDESCRIPTION AS ORDER_TYPEDESCRIPTION, 
        source_data.ORDER_TYPEID AS ORDER_TYPEID, 
        source_data.POSITION AS POSITION, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.USER AS USER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDITIONALINFORMATION as VARCHAR(215)) as ADDITIONALINFORMATION,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CUSTOMERPO as VARCHAR(20)) as CUSTOMERPO,
        cast(EVENTDATE as TIMESTAMP_NTZ(9)) as EVENTDATE,
        cast(EVENTS as VARCHAR(20)) as EVENTS,
        cast(EVENTSEQUENCE as NUMBER(38,0)) as EVENTSEQUENCE,
        cast(MORE as VARCHAR(10)) as MORE,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_TYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_TYPEDESCRIPTION,
        cast(ORDER_TYPEID as NUMBER(38,0)) as ORDER_TYPEID,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(USER as VARCHAR(16)) as USER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data