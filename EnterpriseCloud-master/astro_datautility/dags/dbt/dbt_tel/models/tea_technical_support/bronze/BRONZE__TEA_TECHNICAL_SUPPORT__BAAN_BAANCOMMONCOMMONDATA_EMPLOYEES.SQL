/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_EMPLOYEES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_EMPLOYEES.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_EMPLOYEES 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:47 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONCOMMONDATA_EMPLOYEES',
    unique_key = ['EMPLOYEE']
) }}

 
with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CADR)),'')                                                                                         AS ADDRESSCODE 
            ,CAST(T$RATS AS NUMERIC(15,2))                                                                                                       AS BILLINGRATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDARCODE 
            ,T$CIST.CONSTANTDESCRIPTION                                                                                                          AS CIVILSTATUSDESCRIPTION 
            ,CAST(T$CIST AS INT)                                                                                                                 AS CIVILSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTCOMPONENT 
            ,CAST(CASE WHEN T$DAOB<= '1/1/1970' THEN NULL ELSE T$DAOB END AS DATE)                                                             AS DATEOFBIRTH 
            ,CAST(T$DPWK AS NUMERIC(15,2))                                                                                                       AS DAYSBYWEEK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWOC)),'')                                                                                         AS DEPARTMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$INFO)),'')                                                                                         AS E_MAIL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS EMPLOYEE 
            ,CAST(T$HWEM AS NUMERIC(15,2))                                                                                                       AS EMPLOYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TEFW)),'')                                                                                         AS FAX 
            ,CAST(CASE WHEN T$SDTE<= '1/1/1970' THEN NULL ELSE T$SDTE  END AS DATETIME) AS FIRSTDATEOFEMPLOYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FINR)),'')                                                                                         AS FISCALNUMBER 
            ,CAST("T$WGRT$1" AS NUMERIC(15,2))                                                                                                     AS HOURLYLABORRATE1 
            ,CAST("T$WGRT$2" AS NUMERIC(15,2))                                                                                                     AS HOURLYLABORRATE2 
            ,CAST("T$WGRT$3" AS NUMERIC(15,2))                                                                                                     AS HOURLYLABORRATE3 
            ,CAST(T$HRSD AS NUMERIC(15,2))                                                                                                       AS HOURSBYDAY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLAN)),'')                                                                                         AS LANGUAGE 
            ,CAST(CASE WHEN T$EDTE<= '1/1/1970' THEN NULL ELSE T$EDTE  END AS DATETIME) AS LASTDATEOFEMPLOYMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$NAMA)),'')                                                                                         AS NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAK)),'')                                                                                         AS SEARCHKEY 
            ,T$SEXE.CONSTANTDESCRIPTION                                                                                                          AS SEXDESCRIPTION 
            ,CAST(T$SEXE AS INT)                                                                                                                 AS SEXID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TELW)),'')                                                                                         AS TELEPHONE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TLW1)),'')                                                                                         AS TELEPHONE2 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CTRG)),'')                                                                                         AS TRADEGROUP 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTT)),'')                                                                                         AS WORKINGTIMETABLE
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM001200") }} AS SOURCETABLE  
            /*CIVILSTATUS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CIST 
             ON   T$CIST.TABLENAME  = 'TCCOM001' 
              AND T$CIST.COLUMNNAME = 'T$CIST' 
              AND T$CIST.CONSTANT   = SOURCETABLE.T$CIST 
            /*SEX*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SEXE 
             ON   T$SEXE.TABLENAME  = 'TCCOM001' 
              AND T$SEXE.COLUMNNAME = 'T$SEXE' 
              AND T$SEXE.CONSTANT   = SOURCETABLE.T$SEXE 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,	transform_data as
(
    SELECT 
		source_data._CAPTUREDATETIME AS _CAPTUREDATETIME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		source_data.COSTCOMPONENT AS COSTCOMPONENT,
		source_data.DEPARTMENT AS DEPARTMENT,
		source_data.EMPLOYEE AS EMPLOYEE,
		source_data._COMPANYID AS _COMPANYID,
		source_data.ADDRESSCODE AS ADDRESSCODE,
		source_data.BILLINGRATE AS BILLINGRATE,
		source_data.CALENDARCODE AS CALENDARCODE,
		source_data.CIVILSTATUSDESCRIPTION AS CIVILSTATUSDESCRIPTION,
		source_data.CIVILSTATUSID AS CIVILSTATUSID,
		source_data.DATEOFBIRTH AS DATEOFBIRTH,
		source_data.DAYSBYWEEK AS DAYSBYWEEK,
		source_data.E_MAIL AS E_MAIL,
		source_data.EMPLOYMENT AS EMPLOYMENT,
		source_data.FAX AS FAX,
		source_data.FIRSTDATEOFEMPLOYMENT AS FIRSTDATEOFEMPLOYMENT,
		source_data.FISCALNUMBER AS FISCALNUMBER,
		source_data.HOURLYLABORRATE1 AS HOURLYLABORRATE1,
		source_data.HOURLYLABORRATE2 AS HOURLYLABORRATE2,
		source_data.HOURLYLABORRATE3 AS HOURLYLABORRATE3,
		source_data.HOURSBYDAY AS HOURSBYDAY,
		source_data.LANGUAGE AS LANGUAGE,
		source_data.LASTDATEOFEMPLOYMENT AS LASTDATEOFEMPLOYMENT,
		source_data.NAME AS NAME,
		source_data.SEARCHKEY AS SEARCHKEY,
		source_data.SEXDESCRIPTION AS SEXDESCRIPTION,
		source_data.SEXID AS SEXID,
		source_data.TELEPHONE AS TELEPHONE,
		source_data.TELEPHONE2 AS TELEPHONE2,
		source_data.TEXT AS TEXT,
		source_data.TRADEGROUP AS TRADEGROUP,
		source_data.WORKINGTIMETABLE AS WORKINGTIMETABLE   
        FROM source_data
        )
,	type_data as 
(
    select
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
		CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
		cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
		cast(EMPLOYEE as VARCHAR(6)) as EMPLOYEE,
		cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
		cast(ADDRESSCODE as VARCHAR(9)) as ADDRESSCODE,
		cast(BILLINGRATE as NUMBER(15,2)) as BILLINGRATE,
		cast(CALENDARCODE as VARCHAR(9)) as CALENDARCODE,
		cast(CIVILSTATUSDESCRIPTION as VARCHAR(16777216)) as CIVILSTATUSDESCRIPTION,
		cast(CIVILSTATUSID as NUMBER(38,0)) as CIVILSTATUSID,
		cast(DATEOFBIRTH as DATE) as DATEOFBIRTH,
		cast(DAYSBYWEEK as NUMBER(15,2)) as DAYSBYWEEK,
		cast(E_MAIL as VARCHAR(50)) as E_MAIL,
		cast(EMPLOYMENT as NUMBER(15,2)) as EMPLOYMENT,
		cast(FAX as VARCHAR(15)) as FAX,
		cast(FIRSTDATEOFEMPLOYMENT as TIMESTAMP_NTZ(9)) as FIRSTDATEOFEMPLOYMENT,
		cast(FISCALNUMBER as VARCHAR(9)) as FISCALNUMBER,
		cast(HOURLYLABORRATE1 as NUMBER(15,2)) as HOURLYLABORRATE1,
		cast(HOURLYLABORRATE2 as NUMBER(15,2)) as HOURLYLABORRATE2,
		cast(HOURLYLABORRATE3 as NUMBER(15,2)) as HOURLYLABORRATE3,
		cast(HOURSBYDAY as NUMBER(15,2)) as HOURSBYDAY,
		cast(LANGUAGE as VARCHAR(3)) as LANGUAGE,
		cast(LASTDATEOFEMPLOYMENT as TIMESTAMP_NTZ(9)) as LASTDATEOFEMPLOYMENT,
		cast(NAME as VARCHAR(35)) as NAME,
		cast(SEARCHKEY as VARCHAR(16)) as SEARCHKEY,
		cast(SEXDESCRIPTION as VARCHAR(16777216)) as SEXDESCRIPTION,
		cast(SEXID as NUMBER(38,0)) as SEXID,
		cast(TELEPHONE as VARCHAR(15)) as TELEPHONE,
		cast(TELEPHONE2 as VARCHAR(15)) as TELEPHONE2,
		cast(TEXT as NUMBER(38,10)) as TEXT,
		cast(TRADEGROUP as VARCHAR(3)) as TRADEGROUP,
		cast(WORKINGTIMETABLE as VARCHAR(3)) as WORKINGTIMETABLE
    from transform_data
    )
select * from type_data