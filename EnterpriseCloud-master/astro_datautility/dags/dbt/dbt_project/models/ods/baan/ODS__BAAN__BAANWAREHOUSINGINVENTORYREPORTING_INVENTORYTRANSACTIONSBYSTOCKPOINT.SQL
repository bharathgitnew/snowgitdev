/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT 
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
    alias='BAANWAREHOUSINGINVENTORYREPORTING_INVENTORYTRANSACTIONSBYSTOCKPOINT',
    unique_key = ['INVENTORYDATE',
    'ITEM',
    'LOCATION',
    'LOT',
    'SEQUENCENUMBER',
    'TRANSACTIONDATE',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BPID)),'')                                                                                         AS BUSINESSPARTNER 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVENTORYDATE 
            ,T$PRNT.CONSTANTDESCRIPTION                                                                                                          AS INVENTORYTRANSACTIONPRINTEDDESCRIPTION 
            ,CAST(T$PRNT AS INT)                                                                                                                 AS INVENTORYTRANSACTIONPRINTEDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCA)),'')                                                                                         AS LOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOGN)),'')                                                                                         AS LOGINNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,T$KOOR.CONSTANTDESCRIPTION                                                                                                          AS ORDER_TYPEDESCRIPTION 
            ,CAST(T$KOOR AS INT)                                                                                                                 AS ORDER_TYPEID 
            ,CAST(T$PONO AS INT)                                                                                                                 AS POSITIONNUMBER 
            ,CAST(T$QSTK AS NUMERIC(15,2))                                                                                                       AS QUANTITYINVENTORYUNIT 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(CASE WHEN T$TRDT<= '1/1/1970' THEN NULL ELSE T$TRDT  END AS DATETIME) AS TRANSACTIONDATE 
            ,T$KOST.CONSTANTDESCRIPTION                                                                                                          AS TRANSACTIONTYPEDESCRIPTION 
            ,CAST(T$KOST AS INT)                                                                                                                 AS TRANSACTIONTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINR100201") }} AS SOURCETABLE  
            /*INVENTORYTRANSACTIONPRINTED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRNT 
             ON   T$PRNT.TABLENAME  = 'WHINR100' 
              AND T$PRNT.COLUMNNAME = 'T$PRNT' 
              AND T$PRNT.CONSTANT   = SOURCETABLE.T$PRNT 
            /*ORDERTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$KOOR 
             ON   T$KOOR.TABLENAME  = 'WHINR100' 
              AND T$KOOR.COLUMNNAME = 'T$KOOR' 
              AND T$KOOR.CONSTANT   = SOURCETABLE.T$KOOR 
            /*TRANSACTIONTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$KOST 
             ON   T$KOST.TABLENAME  = 'WHINR100' 
              AND T$KOST.COLUMNNAME = 'T$KOST' 
              AND T$KOST.CONSTANT   = SOURCETABLE.T$KOST 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.BUSINESSPARTNER AS BUSINESSPARTNER, 
        source_data.INVENTORYDATE AS INVENTORYDATE, 
        source_data.INVENTORYTRANSACTIONPRINTEDDESCRIPTION AS INVENTORYTRANSACTIONPRINTEDDESCRIPTION, 
        source_data.INVENTORYTRANSACTIONPRINTEDID AS INVENTORYTRANSACTIONPRINTEDID, 
        source_data.ITEM AS ITEM, 
        source_data.LOCATION AS LOCATION, 
        source_data.LOGINNAME AS LOGINNAME, 
        source_data.LOT AS LOT, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_TYPEDESCRIPTION AS ORDER_TYPEDESCRIPTION, 
        source_data.ORDER_TYPEID AS ORDER_TYPEID, 
        source_data.POSITIONNUMBER AS POSITIONNUMBER, 
        source_data.QUANTITYINVENTORYUNIT AS QUANTITYINVENTORYUNIT, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSACTIONTYPEDESCRIPTION AS TRANSACTIONTYPEDESCRIPTION, 
        source_data.TRANSACTIONTYPEID AS TRANSACTIONTYPEID, 
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
        cast(BUSINESSPARTNER as VARCHAR(9)) as BUSINESSPARTNER,
        cast(INVENTORYDATE as TIMESTAMP_NTZ(9)) as INVENTORYDATE,
        cast(INVENTORYTRANSACTIONPRINTEDDESCRIPTION as VARCHAR(16777216)) as INVENTORYTRANSACTIONPRINTEDDESCRIPTION,
        cast(INVENTORYTRANSACTIONPRINTEDID as NUMBER(38,0)) as INVENTORYTRANSACTIONPRINTEDID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LOCATION as VARCHAR(10)) as LOCATION,
        cast(LOGINNAME as VARCHAR(16)) as LOGINNAME,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_TYPEDESCRIPTION as VARCHAR(16777216)) as ORDER_TYPEDESCRIPTION,
        cast(ORDER_TYPEID as NUMBER(38,0)) as ORDER_TYPEID,
        cast(POSITIONNUMBER as NUMBER(38,0)) as POSITIONNUMBER,
        cast(QUANTITYINVENTORYUNIT as NUMBER(15,2)) as QUANTITYINVENTORYUNIT,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSACTIONTYPEDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONTYPEDESCRIPTION,
        cast(TRANSACTIONTYPEID as NUMBER(38,0)) as TRANSACTIONTYPEID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data