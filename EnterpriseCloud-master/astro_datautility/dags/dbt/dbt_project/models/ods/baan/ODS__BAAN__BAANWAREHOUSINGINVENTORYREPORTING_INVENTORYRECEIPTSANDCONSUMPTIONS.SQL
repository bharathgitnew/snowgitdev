/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS 
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
    alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYRECEIPTSANDCONSUMPTIONS',
    unique_key = ['PARTNUMBER',
    'SEQUENCE',
    'TRANSACTIONDATE',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(CASE WHEN T$ACDT<= '1/1/1970' THEN NULL ELSE T$ACDT  END AS DATETIME) AS ACTUALRECEIPTDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$AWAR)),'')                                                                                         AS ACTUALWAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS PARTNUMBER 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$QSKT AS NUMERIC(15,2))                                                                                                       AS QUANTITYTOBECONSUMED 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCE 
            ,CAST(T$AMNT AS NUMERIC(15,2))                                                                                                       AS TOTALAMOUNT 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINR912201") }} AS SOURCETABLE  
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINR912' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTUALRECEIPTDATE AS ACTUALRECEIPTDATE, 
        source_data.ACTUALWAREHOUSE AS ACTUALWAREHOUSE, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.PARTNUMBER AS PARTNUMBER, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.QUANTITYTOBECONSUMED AS QUANTITYTOBECONSUMED, 
        source_data.SEQUENCE AS SEQUENCE, 
        source_data.TOTALAMOUNT AS TOTALAMOUNT, 
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
        cast(ACTUALRECEIPTDATE as TIMESTAMP_NTZ(9)) as ACTUALRECEIPTDATE,
        cast(ACTUALWAREHOUSE as VARCHAR(6)) as ACTUALWAREHOUSE,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(PARTNUMBER as VARCHAR(47)) as PARTNUMBER,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(QUANTITYTOBECONSUMED as NUMBER(15,2)) as QUANTITYTOBECONSUMED,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(TOTALAMOUNT as NUMBER(15,2)) as TOTALAMOUNT,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data