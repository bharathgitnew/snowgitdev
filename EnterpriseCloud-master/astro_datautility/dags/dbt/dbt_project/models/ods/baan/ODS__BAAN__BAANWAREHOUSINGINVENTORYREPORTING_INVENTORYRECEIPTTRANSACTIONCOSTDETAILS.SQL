/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:57 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTTRANSACTIONCOSTDETAILS',
    unique_key = ['COSTCOMPONENT',
    'ITEM',
    'SEQUENCENUMBER',
    'TRANSACTIONDATE',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST("T$AMNT$1" AS NUMERIC(15,2))                                                                                                     AS AMOUNT1 
            ,CAST("T$AMNT$2" AS NUMERIC(15,2))                                                                                                     AS AMOUNT2 
            ,CAST("T$AMNT$3" AS NUMERIC(15,2))                                                                                                     AS AMOUNT3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST("T$MAUC$1" AS NUMERIC(15,2))                                                                                                     AS MAUC1 
            ,CAST("T$MAUC$2" AS NUMERIC(15,2))                                                                                                     AS MAUC2 
            ,CAST("T$MAUC$3" AS NUMERIC(15,2))                                                                                                     AS MAUC3 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINR113201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        ) 
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AMOUNT1 AS AMOUNT1, 
        source_data.AMOUNT2 AS AMOUNT2, 
        source_data.AMOUNT3 AS AMOUNT3, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.ITEM AS ITEM, 
        source_data.MAUC1 AS MAUC1, 
        source_data.MAUC2 AS MAUC2, 
        source_data.MAUC3 AS MAUC3, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.WAREHOUSE AS WAREHOUSE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AMOUNT1 as NUMBER(15,2)) as AMOUNT1,
        cast(AMOUNT2 as NUMBER(15,2)) as AMOUNT2,
        cast(AMOUNT3 as NUMBER(15,2)) as AMOUNT3,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(MAUC1 as NUMBER(15,2)) as MAUC1,
        cast(MAUC2 as NUMBER(15,2)) as MAUC2,
        cast(MAUC3 as NUMBER(15,2)) as MAUC3,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data