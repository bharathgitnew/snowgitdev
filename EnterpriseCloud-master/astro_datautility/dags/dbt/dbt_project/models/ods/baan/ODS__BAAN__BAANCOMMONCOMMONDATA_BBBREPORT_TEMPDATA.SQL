/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA 
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
    alias='BAANCOMMONCOMMONDATA_BBBREPORT_TEMPDATA',
    unique_key = ['DATASOURCEID',
    'DATEOFUPDATE',
    'ORDER_NUMBER',
    'POSITION',
    'SEQUENCE',
    'USER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$ACCR AS NUMERIC(15,2))                                                                                                       AS ACCRUALAMOUNT 
            ,CAST(CASE WHEN T$ASDT<= '1/1/1970' THEN NULL ELSE T$ASDT  END AS DATETIME) AS ASONDATE 
            ,CAST(T$BBCK AS NUMERIC(15,2))                                                                                                       AS BEGINBACKLOG 
            ,CAST(T$BILL AS NUMERIC(15,2))                                                                                                       AS BILLINGAMOUNT 
            ,CAST(T$BOOK AS NUMERIC(15,2))                                                                                                       AS BOOKINGAMOUNTGROSS 
            ,CAST(T$BCHG AS NUMERIC(15,2))                                                                                                       AS BOOKINGCHANGES 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BUNT)),'')                                                                                         AS BUSINESSUNIT 
            ,CAST(T$CNCL AS NUMERIC(15,2))                                                                                                       AS CANCELAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS CUSTOMER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFCG)),'')                                                                                         AS CUSTOMERGROUP 
            ,T$SORC.CONSTANTDESCRIPTION                                                                                                          AS DATASOURCEDESCRIPTION 
            ,CAST(T$SORC AS INT)                                                                                                                 AS DATASOURCEID 
            ,CAST(CASE WHEN T$UPDT<= '1/1/1970' THEN NULL ELSE T$UPDT  END AS DATETIME) AS DATEOFUPDATE 
            ,CAST(T$DISC AS NUMERIC(15,2))                                                                                                       AS DISCOUNTAMOUNTAPPLIED 
            ,CAST(T$EBCK AS NUMERIC(15,2))                                                                                                       AS ENDINGBACKLOGAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REMK)),'')                                                                                         AS REMARKS 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS USER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM945201") }} AS SOURCETABLE  
            /*DATASOURCE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SORC 
             ON   T$SORC.TABLENAME  = 'TCCOM945' 
              AND T$SORC.COLUMNNAME = 'T$SORC' 
              AND T$SORC.CONSTANT   = SOURCETABLE.T$SORC 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCRUALAMOUNT AS ACCRUALAMOUNT, 
        source_data.ASONDATE AS ASONDATE, 
        source_data.BEGINBACKLOG AS BEGINBACKLOG, 
        source_data.BILLINGAMOUNT AS BILLINGAMOUNT, 
        source_data.BOOKINGAMOUNTGROSS AS BOOKINGAMOUNTGROSS, 
        source_data.BOOKINGCHANGES AS BOOKINGCHANGES, 
        source_data.BUSINESSUNIT AS BUSINESSUNIT, 
        source_data.CANCELAMOUNT AS CANCELAMOUNT, 
        source_data.CUSTOMER AS CUSTOMER, 
        source_data.CUSTOMERGROUP AS CUSTOMERGROUP, 
        source_data.DATASOURCEDESCRIPTION AS DATASOURCEDESCRIPTION, 
        source_data.DATASOURCEID AS DATASOURCEID, 
        source_data.DATEOFUPDATE AS DATEOFUPDATE, 
        source_data.DISCOUNTAMOUNTAPPLIED AS DISCOUNTAMOUNTAPPLIED, 
        source_data.ENDINGBACKLOGAMOUNT AS ENDINGBACKLOGAMOUNT, 
        source_data.ITEM AS ITEM, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.POSITION AS POSITION, 
        source_data.REMARKS AS REMARKS, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
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
        cast(ACCRUALAMOUNT as NUMBER(15,2)) as ACCRUALAMOUNT,
        cast(ASONDATE as TIMESTAMP_NTZ(9)) as ASONDATE,
        cast(BEGINBACKLOG as NUMBER(15,2)) as BEGINBACKLOG,
        cast(BILLINGAMOUNT as NUMBER(15,2)) as BILLINGAMOUNT,
        cast(BOOKINGAMOUNTGROSS as NUMBER(15,2)) as BOOKINGAMOUNTGROSS,
        cast(BOOKINGCHANGES as NUMBER(15,2)) as BOOKINGCHANGES,
        cast(BUSINESSUNIT as VARCHAR(2)) as BUSINESSUNIT,
        cast(CANCELAMOUNT as NUMBER(15,2)) as CANCELAMOUNT,
        cast(CUSTOMER as VARCHAR(9)) as CUSTOMER,
        cast(CUSTOMERGROUP as VARCHAR(3)) as CUSTOMERGROUP,
        cast(DATASOURCEDESCRIPTION as VARCHAR(16777216)) as DATASOURCEDESCRIPTION,
        cast(DATASOURCEID as NUMBER(38,0)) as DATASOURCEID,
        cast(DATEOFUPDATE as TIMESTAMP_NTZ(9)) as DATEOFUPDATE,
        cast(DISCOUNTAMOUNTAPPLIED as NUMBER(15,2)) as DISCOUNTAMOUNTAPPLIED,
        cast(ENDINGBACKLOGAMOUNT as NUMBER(15,2)) as ENDINGBACKLOGAMOUNT,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(POSITION as NUMBER(38,0)) as POSITION,
        cast(REMARKS as VARCHAR(100)) as REMARKS,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(USER as VARCHAR(16)) as USER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data