/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING 
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
    alias='BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING',
    unique_key = ['EMPLOYEE',
    'LINENUMBER',
    'WEEK',
    'YEARNUMBER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCMP)),'')                                                                                         AS COSTCOMPONENT 
            ,CAST("T$COWR$1" AS NUMERIC(15,2))                                                                                                     AS COSTRATE1 
            ,CAST("T$COWR$2" AS NUMERIC(15,2))                                                                                                     AS COSTRATE2 
            ,CAST("T$COWR$3" AS NUMERIC(15,2))                                                                                                     AS COSTRATE3 
            ,T$COTP.CONSTANTDESCRIPTION                                                                                                          AS COSTTYPEDESCRIPTION 
            ,CAST(T$COTP AS INT)                                                                                                                 AS COSTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS EMPLOYEE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CHLT)),'')                                                                                         AS HOURLYLABORTYPE 
            ,CAST(T$LBLN AS INT)                                                                                                                 AS LABORLINE 
            ,CAST(T$LINO AS INT)                                                                                                                 AS LINENUMBER 
            ,CAST(CASE WHEN T$RGDT<= '1/1/1970' THEN NULL ELSE T$RGDT END AS DATE)                                                             AS REGISTRATIONDATE 
            ,CAST(T$SLWR AS NUMERIC(15,2))                                                                                                       AS SALESRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS SERVICECENTER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS SERVICEORDER 
            ,CAST(T$SPTM AS NUMERIC(15,2))                                                                                                       AS SPENTTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTSK)),'')                                                                                         AS TASK 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,CAST(T$TVLN AS INT)                                                                                                                 AS TRAVELLINE 
            ,CAST(T$ACLN AS INT)                                                                                                                 AS TSSOC210ACLN 
            ,CAST(T$WEEK AS TINYINT)                                                                                                             AS WEEK 
            ,CAST(T$YEAR AS INT)                                                                                                                 AS YEARNUMBER 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSSOC235201") }} AS SOURCETABLE  
            /*COSTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COTP 
             ON   T$COTP.TABLENAME  = 'TSSOC235' 
              AND T$COTP.COLUMNNAME = 'T$COTP' 
              AND T$COTP.CONSTANT   = SOURCETABLE.T$COTP 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        source_data.WEEK AS WEEK, 
        source_data.YEARNUMBER AS YEARNUMBER,
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.COSTRATE1 AS COSTRATE1, 
        source_data.COSTRATE2 AS COSTRATE2, 
        source_data.COSTRATE3 AS COSTRATE3, 
        source_data.COSTTYPEDESCRIPTION AS COSTTYPEDESCRIPTION, 
        source_data.COSTTYPEID AS COSTTYPEID, 
        source_data.EMPLOYEE AS EMPLOYEE, 
        source_data.HOURLYLABORTYPE AS HOURLYLABORTYPE, 
        source_data.LABORLINE AS LABORLINE, 
        source_data.LINENUMBER AS LINENUMBER, 
        source_data.REGISTRATIONDATE AS REGISTRATIONDATE, 
        source_data.SALESRATE AS SALESRATE, 
        source_data.SERVICECENTER AS SERVICECENTER, 
        source_data.SERVICEORDER AS SERVICEORDER, 
        source_data.SPENTTIME AS SPENTTIME, 
        source_data.TASK AS TASK, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRAVELLINE AS TRAVELLINE, 
        source_data.TSSOC210ACLN AS TSSOC210ACLN        
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(WEEK as NUMBER(38,0)) as WEEK,
        cast(YEARNUMBER as NUMBER(38,0)) as YEARNUMBER,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(COSTRATE1 as NUMBER(15,2)) as COSTRATE1,
        cast(COSTRATE2 as NUMBER(15,2)) as COSTRATE2,
        cast(COSTRATE3 as NUMBER(15,2)) as COSTRATE3,
        cast(COSTTYPEDESCRIPTION as VARCHAR(16777216)) as COSTTYPEDESCRIPTION,
        cast(COSTTYPEID as NUMBER(38,0)) as COSTTYPEID,
        cast(EMPLOYEE as VARCHAR(6)) as EMPLOYEE,
        cast(HOURLYLABORTYPE as VARCHAR(3)) as HOURLYLABORTYPE,
        cast(LABORLINE as NUMBER(38,0)) as LABORLINE,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(REGISTRATIONDATE as DATE) as REGISTRATIONDATE,
        cast(SALESRATE as NUMBER(15,2)) as SALESRATE,
        cast(SERVICECENTER as VARCHAR(6)) as SERVICECENTER,
        cast(SERVICEORDER as VARCHAR(9)) as SERVICEORDER,
        cast(SPENTTIME as NUMBER(15,2)) as SPENTTIME,
        cast(TASK as VARCHAR(8)) as TASK,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRAVELLINE as NUMBER(38,0)) as TRAVELLINE,        
        cast(TSSOC210ACLN as NUMBER(38,0)) as TSSOC210ACLN        
    from transform_data
    )
select * from type_data