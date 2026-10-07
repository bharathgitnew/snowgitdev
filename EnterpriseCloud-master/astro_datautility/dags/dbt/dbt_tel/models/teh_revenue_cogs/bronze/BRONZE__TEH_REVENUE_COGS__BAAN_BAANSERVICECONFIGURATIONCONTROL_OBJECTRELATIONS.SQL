/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS 
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
    alias='BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS',
    unique_key = ['CONFIGURATION',
    'CONFIGURATIONVERSION',
    'PARENTOBJECT',
    'PARENTOBJECTNUMBER',
    'POSITION',
    'SEQUENCENUMBER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$ACTN.CONSTANTDESCRIPTION                                                                                                          AS ACTIONDESCRIPTION 
            ,CAST(T$ACTN AS INT)                                                                                                                 AS ACTIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROC)),'')                                                                                         AS CHILDOBJECT 
            ,CAST(T$OSQC AS INT)                                                                                                                 AS CHILDOBJECTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(T$CVER AS BIGINT)                                                                                                              AS CONFIGURATIONVERSION 
            ,CAST(CASE WHEN T$ENDT<= '1/1/1970' THEN NULL ELSE T$ENDT  END AS DATETIME) AS ENDDATEOBJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROP)),'')                                                                                         AS PARENTOBJECT 
            ,CAST(T$OSQP AS INT)                                                                                                                 AS PARENTOBJECTNUMBER 
            ,CAST(T$POSI AS INT)                                                                                                                 AS POSITION 
            ,CAST(T$SERN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$STDT<= '1/1/1970' THEN NULL ELSE T$STDT  END AS DATETIME) AS STARTDATEOBJECT 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG210201") }} AS SOURCETABLE  
            /*ACTION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ACTN 
             ON   T$ACTN.TABLENAME  = 'TSCFG210' 
              AND T$ACTN.COLUMNNAME = 'T$ACTN' 
              AND T$ACTN.CONSTANT   = SOURCETABLE.T$ACTN 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIONDESCRIPTION AS ACTIONDESCRIPTION, 
        source_data.ACTIONID AS ACTIONID, 
        source_data.CHILDOBJECT AS CHILDOBJECT, 
        source_data.CHILDOBJECTNUMBER AS CHILDOBJECTNUMBER, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONFIGURATIONVERSION AS CONFIGURATIONVERSION, 
        source_data.ENDDATEOBJECT AS ENDDATEOBJECT, 
        source_data.PARENTOBJECT AS PARENTOBJECT, 
        source_data.PARENTOBJECTNUMBER AS PARENTOBJECTNUMBER, 
        source_data.POSITION AS POSITION, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.STARTDATEOBJECT AS STARTDATEOBJECT
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIONDESCRIPTION as VARCHAR(16777216)) as ACTIONDESCRIPTION,
        cast(ACTIONID as NUMBER(38,0)) as ACTIONID,
        cast(CHILDOBJECT as VARCHAR(50)) as CHILDOBJECT,
        cast(CHILDOBJECTNUMBER as NUMBER(38,0)) as CHILDOBJECTNUMBER,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONFIGURATIONVERSION as NUMBER(38,0)) as CONFIGURATIONVERSION,
        cast(ENDDATEOBJECT as TIMESTAMP_NTZ(9)) as ENDDATEOBJECT,
        cast(PARENTOBJECT as VARCHAR(50)) as PARENTOBJECT,
        cast(PARENTOBJECTNUMBER as NUMBER(38,0)) as PARENTOBJECTNUMBER,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(STARTDATEOBJECT as TIMESTAMP_NTZ(9)) as STARTDATEOBJECT
    from transform_data
    )
select * from type_data