/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES.SQL 
-materialized incremental
-alias BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES 
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
    alias='BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERBALANCES',
    unique_key = ['COMPANY',
    'DEPARTMENT',
    'INVOICETOBUSINESSPARTNER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                AS _CAPTUREDATETIME 
            ,200                                           AS _COMPANYID 
            ,CAST(T$COMP AS INT)                         AS COMPANY 
            ,CAST(T$CRYR AS INT)                         AS CURRENTYEAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COFC)),'') AS DEPARTMENT 
            ,CAST(T$BUIN AS NUMERIC(15,2))               AS INVOICEBALANCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITBP)),'') AS INVOICETOBUSINESSPARTNER 
            ,CAST(T$OBRA AS NUMERIC(15,2))               AS OPENBILLINGREQUESTAMOUNT 
            ,CAST(T$BUOR AS NUMERIC(15,2))               AS ORDER_BALANCE 
            ,CAST("T$TOVR$1" AS NUMERIC(15,2))             AS TURNOVER1 
            ,CAST("T$TOVR$2" AS NUMERIC(15,2))             AS TURNOVER2 
            ,CAST("T$TOVR$3" AS NUMERIC(15,2))             AS TURNOVER3 
            ,CAST("T$TOVR_1$1" AS NUMERIC(15,2))           AS TURNOVER_TOVR_1_1 
            ,CAST("T$TOVR_1$2" AS NUMERIC(15,2))           AS TURNOVER_TOVR_1_2 
            ,CAST("T$TOVR_1$3" AS NUMERIC(15,2))           AS TURNOVER_TOVR_1_3 
            ,CAST("T$TOVR_2$1" AS NUMERIC(15,2))           AS TURNOVER_TOVR_2_1 
            ,CAST("T$TOVR_2$2" AS NUMERIC(15,2))           AS TURNOVER_TOVR_2_2 
            ,CAST("T$TOVR_2$3" AS NUMERIC(15,2))           AS TURNOVER_TOVR_2_3 
            ,CAST("T$TOVR_3$1" AS NUMERIC(15,2))           AS TURNOVER_TOVR_3_1 
            ,CAST("T$TOVR_3$2" AS NUMERIC(15,2))           AS TURNOVER_TOVR_3_2 
            ,CAST("T$TOVR_3$3" AS NUMERIC(15,2))           AS TURNOVER_TOVR_3_3 
            ,CAST("T$TOVR_4$1" AS NUMERIC(15,2))           AS TURNOVER_TOVR_4_1 
            ,CAST("T$TOVR_4$2" AS NUMERIC(15,2))           AS TURNOVER_TOVR_4_2 
            ,CAST("T$TOVR_4$3" AS NUMERIC(15,2))           AS TURNOVER_TOVR_4_3 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCCOM113200") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.COMPANY AS COMPANY, 
        source_data.CURRENTYEAR AS CURRENTYEAR, 
        source_data.DEPARTMENT AS DEPARTMENT, 
        source_data.INVOICEBALANCE AS INVOICEBALANCE, 
        source_data.INVOICETOBUSINESSPARTNER AS INVOICETOBUSINESSPARTNER, 
        source_data.OPENBILLINGREQUESTAMOUNT AS OPENBILLINGREQUESTAMOUNT, 
        source_data.ORDER_BALANCE AS ORDER_BALANCE, 
        source_data.TURNOVER1 AS TURNOVER1, 
        source_data.TURNOVER2 AS TURNOVER2, 
        source_data.TURNOVER3 AS TURNOVER3, 
        source_data.TURNOVER_TOVR_1_1 AS TURNOVER_TOVR_1_1, 
        source_data.TURNOVER_TOVR_1_2 AS TURNOVER_TOVR_1_2, 
        source_data.TURNOVER_TOVR_1_3 AS TURNOVER_TOVR_1_3, 
        source_data.TURNOVER_TOVR_2_1 AS TURNOVER_TOVR_2_1, 
        source_data.TURNOVER_TOVR_2_2 AS TURNOVER_TOVR_2_2, 
        source_data.TURNOVER_TOVR_2_3 AS TURNOVER_TOVR_2_3, 
        source_data.TURNOVER_TOVR_3_1 AS TURNOVER_TOVR_3_1, 
        source_data.TURNOVER_TOVR_3_2 AS TURNOVER_TOVR_3_2, 
        source_data.TURNOVER_TOVR_3_3 AS TURNOVER_TOVR_3_3, 
        source_data.TURNOVER_TOVR_4_1 AS TURNOVER_TOVR_4_1, 
        source_data.TURNOVER_TOVR_4_2 AS TURNOVER_TOVR_4_2, 
        source_data.TURNOVER_TOVR_4_3 AS TURNOVER_TOVR_4_3
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(CURRENTYEAR as NUMBER(38,0)) as CURRENTYEAR,
        cast(DEPARTMENT as VARCHAR(6)) as DEPARTMENT,
        cast(INVOICEBALANCE as NUMBER(15,2)) as INVOICEBALANCE,
        cast(INVOICETOBUSINESSPARTNER as VARCHAR(9)) as INVOICETOBUSINESSPARTNER,
        cast(OPENBILLINGREQUESTAMOUNT as NUMBER(15,2)) as OPENBILLINGREQUESTAMOUNT,
        cast(ORDER_BALANCE as NUMBER(15,2)) as ORDER_BALANCE,
        cast(TURNOVER1 as NUMBER(15,2)) as TURNOVER1,
        cast(TURNOVER2 as NUMBER(15,2)) as TURNOVER2,
        cast(TURNOVER3 as NUMBER(15,2)) as TURNOVER3,
        cast(TURNOVER_TOVR_1_1 as NUMBER(15,2)) as TURNOVER_TOVR_1_1,
        cast(TURNOVER_TOVR_1_2 as NUMBER(15,2)) as TURNOVER_TOVR_1_2,
        cast(TURNOVER_TOVR_1_3 as NUMBER(15,2)) as TURNOVER_TOVR_1_3,
        cast(TURNOVER_TOVR_2_1 as NUMBER(15,2)) as TURNOVER_TOVR_2_1,
        cast(TURNOVER_TOVR_2_2 as NUMBER(15,2)) as TURNOVER_TOVR_2_2,
        cast(TURNOVER_TOVR_2_3 as NUMBER(15,2)) as TURNOVER_TOVR_2_3,
        cast(TURNOVER_TOVR_3_1 as NUMBER(15,2)) as TURNOVER_TOVR_3_1,
        cast(TURNOVER_TOVR_3_2 as NUMBER(15,2)) as TURNOVER_TOVR_3_2,
        cast(TURNOVER_TOVR_3_3 as NUMBER(15,2)) as TURNOVER_TOVR_3_3,
        cast(TURNOVER_TOVR_4_1 as NUMBER(15,2)) as TURNOVER_TOVR_4_1,
        cast(TURNOVER_TOVR_4_2 as NUMBER(15,2)) as TURNOVER_TOVR_4_2,
        cast(TURNOVER_TOVR_4_3 as NUMBER(15,2)) as TURNOVER_TOVR_4_3,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data