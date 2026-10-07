/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING.SQL 
-materialized incremental
-alias BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING',
    unique_key = ['TERMID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$APPL.CONSTANTDESCRIPTION                                                                                                          AS APPLICATIONDESCRIPTION 
            ,CAST(T$APPL AS INT)                                                                                                                 AS APPLICATIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,CAST(CASE WHEN T$EFTM<= '1/1/1970' THEN NULL ELSE T$EFTM  END AS DATETIME) AS CONTRACTEFFECTIVEDATE 
            ,CAST(CASE WHEN T$EXTM<= '1/1/1970' THEN NULL ELSE T$EXTM  END AS DATETIME) AS CONTRACTEXPIRYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCQU)),'')                                                                                         AS CONTRACTQUOTATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCTE)),'')                                                                                         AS CONTRACTTEMPLATE 
            ,CAST(CASE WHEN T$HTDT<= '1/1/1970' THEN NULL ELSE T$HTDT END AS DATE)                                                             AS DATEOFPOSTINGTOHISTORY 
            ,CAST(CASE WHEN T$CRDT<= '1/1/1970' THEN NULL ELSE T$CRDT END AS DATE)                                                             AS DEFINITIONDATE 
            ,CAST(CASE WHEN T$DLDT<= '1/1/1970' THEN NULL ELSE T$DLDT END AS DATE)                                                             AS DELETIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CRLN)),'')                                                                                         AS LOGINOFDEFINEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DLLN)),'')                                                                                         AS LOGINOFDELETEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$HTLN)),'')                                                                                         AS LOGINOFPOSTEDBY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROB)),'')                                                                                         AS OBJECT 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS OBJECTNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSCO)),'')                                                                                         AS SERVICECONTRACT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSQU)),'')                                                                                         AS SERVICEORDERQUOTATION 
            ,CAST(T$TERM AS BIGINT)                                                                                                              AS TERMID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                                                                         AS WARRANTY 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCTM199201") }} AS SOURCETABLE  
            /*APPLICATION*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$APPL 
             ON   T$APPL.TABLENAME  = 'TSCTM199' 
              AND T$APPL.COLUMNNAME = 'T$APPL' 
              AND T$APPL.CONSTANT   = SOURCETABLE.T$APPL 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.APPLICATIONDESCRIPTION AS APPLICATIONDESCRIPTION, 
        source_data.APPLICATIONID AS APPLICATIONID, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTRACTEFFECTIVEDATE AS CONTRACTEFFECTIVEDATE, 
        source_data.CONTRACTEXPIRYDATE AS CONTRACTEXPIRYDATE, 
        source_data.CONTRACTQUOTATION AS CONTRACTQUOTATION, 
        source_data.CONTRACTTEMPLATE AS CONTRACTTEMPLATE, 
        source_data.DATEOFPOSTINGTOHISTORY AS DATEOFPOSTINGTOHISTORY, 
        source_data.DEFINITIONDATE AS DEFINITIONDATE, 
        source_data.DELETIONDATE AS DELETIONDATE, 
        source_data.LOGINOFDEFINEDBY AS LOGINOFDEFINEDBY, 
        source_data.LOGINOFDELETEDBY AS LOGINOFDELETEDBY, 
        source_data.LOGINOFPOSTEDBY AS LOGINOFPOSTEDBY, 
        source_data.OBJECT AS OBJECT, 
        source_data.OBJECTNUMBER AS OBJECTNUMBER, 
        source_data.SERVICECONTRACT AS SERVICECONTRACT, 
        source_data.SERVICEORDERQUOTATION AS SERVICEORDERQUOTATION, 
        source_data.TERMID AS TERMID, 
        source_data.WARRANTY AS WARRANTY
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(APPLICATIONDESCRIPTION as VARCHAR(16777216)) as APPLICATIONDESCRIPTION,
        cast(APPLICATIONID as NUMBER(38,0)) as APPLICATIONID,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTRACTEFFECTIVEDATE as TIMESTAMP_NTZ(9)) as CONTRACTEFFECTIVEDATE,
        cast(CONTRACTEXPIRYDATE as TIMESTAMP_NTZ(9)) as CONTRACTEXPIRYDATE,
        cast(CONTRACTQUOTATION as VARCHAR(9)) as CONTRACTQUOTATION,
        cast(CONTRACTTEMPLATE as VARCHAR(16)) as CONTRACTTEMPLATE,
        cast(DATEOFPOSTINGTOHISTORY as DATE) as DATEOFPOSTINGTOHISTORY,
        cast(DEFINITIONDATE as DATE) as DEFINITIONDATE,
        cast(DELETIONDATE as DATE) as DELETIONDATE,
        cast(LOGINOFDEFINEDBY as VARCHAR(16)) as LOGINOFDEFINEDBY,
        cast(LOGINOFDELETEDBY as VARCHAR(16)) as LOGINOFDELETEDBY,
        cast(LOGINOFPOSTEDBY as VARCHAR(16)) as LOGINOFPOSTEDBY,
        cast(OBJECT as VARCHAR(50)) as OBJECT,
        cast(OBJECTNUMBER as NUMBER(38,0)) as OBJECTNUMBER,
        cast(SERVICECONTRACT as VARCHAR(9)) as SERVICECONTRACT,
        cast(SERVICEORDERQUOTATION as VARCHAR(9)) as SERVICEORDERQUOTATION,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data