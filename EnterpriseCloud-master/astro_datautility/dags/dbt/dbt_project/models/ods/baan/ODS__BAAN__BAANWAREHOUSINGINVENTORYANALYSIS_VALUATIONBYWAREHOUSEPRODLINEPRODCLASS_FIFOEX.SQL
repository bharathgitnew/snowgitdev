/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:56 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANWAREHOUSINGINVENTORYANALYSIS_VALUATIONBYWAREHOUSEPRODLINEPRODCLASS_FIFOEX',
    unique_key = ['ITEM',
    'PRODUCTLINE',
    'SEQUENCE',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST(T$TRAM AS NUMERIC(15,2))                                                                                                       AS INTRANSITAMOUNT 
            ,CAST(T$INAT AS NUMERIC(15,2))                                                                                                       AS INVAMOUNT 
            ,CAST(T$ONHA AS NUMERIC(15,2))                                                                                                       AS INVENTORY_percent_ONHAND 
            ,CAST(T$STOC AS NUMERIC(15,2))                                                                                                       AS INVENTORY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LAMD<= '1/1/1970' THEN NULL ELSE T$LAMD  END AS DATETIME) AS LASTUPDATED 
            ,CAST(T$OHAM AS NUMERIC(15,2))                                                                                                       AS ONHANDAMOUNT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPLN)),'')                                                                                         AS PRODUCTLINE 
            ,CAST(T$QATR AS NUMERIC(15,2))                                                                                                       AS QUANTITYINTRANSIT 
            ,CAST(T$SEQN AS BIGINT)                                                                                                              AS SEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
           
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINA988201") }} AS SOURCETABLE 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.INTRANSITAMOUNT AS INTRANSITAMOUNT, 
        source_data.INVAMOUNT AS INVAMOUNT, 
        source_data.INVENTORY_PERCENT_ONHAND AS INVENTORY_PERCENT_ONHAND, 
        source_data.INVENTORY AS INVENTORY, 
        source_data.ITEM AS ITEM, 
        source_data.LASTUPDATED AS LASTUPDATED, 
        source_data.ONHANDAMOUNT AS ONHANDAMOUNT, 
        source_data.PRODUCTLINE AS PRODUCTLINE, 
        source_data.QUANTITYINTRANSIT AS QUANTITYINTRANSIT, 
        source_data.SEQUENCE AS SEQUENCE, 
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
        cast(INTRANSITAMOUNT as NUMBER(15,2)) as INTRANSITAMOUNT,
        cast(INVAMOUNT as NUMBER(15,2)) as INVAMOUNT,
        cast(INVENTORY_PERCENT_ONHAND as NUMBER(15,2)) as INVENTORY_PERCENT_ONHAND,
        cast(INVENTORY as NUMBER(15,2)) as INVENTORY,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(ONHANDAMOUNT as NUMBER(15,2)) as ONHANDAMOUNT,
        cast(PRODUCTLINE as VARCHAR(6)) as PRODUCTLINE,
        cast(QUANTITYINTRANSIT as NUMBER(15,2)) as QUANTITYINTRANSIT,
        cast(SEQUENCE as NUMBER(38,0)) as SEQUENCE,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data