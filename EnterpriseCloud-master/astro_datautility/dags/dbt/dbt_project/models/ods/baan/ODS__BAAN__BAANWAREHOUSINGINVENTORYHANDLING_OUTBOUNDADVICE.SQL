/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE.SQL 
-materialized incremental
-alias BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE 
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
    alias='BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE',
    unique_key = ['ADVICENUMBER',
    'ORDER_LINE',
    'ORDER_NUMBER',
    'ORDER_ORIGINID',
    'SEQUENCENUMBER',
    '_SET']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACTI)),'')                                                                                         AS ACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ATUN)),'')                                                                                         AS ACTUALSTORAGEUNIT 
            ,CAST(T$SERN AS INT)                                                                                                                 AS ADVICENUMBER 
            ,CAST(T$ASTK AS NUMERIC(15,2))                                                                                                       AS ADVICEQUANTITYININVENTORYUNIT 
            ,CAST(T$ASTR AS NUMERIC(15,2))                                                                                                       AS ADVICEQUANTITYINSTORAGEUNIT 
            ,CAST(T$BOML AS INT)                                                                                                                 AS BOMLINE 
            ,T$CONS.CONSTANTDESCRIPTION                                                                                                          AS CONSIGNMENTDESCRIPTION 
            ,CAST(T$CONS AS INT)                                                                                                                 AS CONSIGNMENTID 
            ,CAST(CASE WHEN T$IDAT<= '1/1/1970' THEN NULL ELSE T$IDAT  END AS DATETIME) AS INVENTORYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCA)),'')                                                                                         AS LOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLOT)),'')                                                                                         AS LOT 
            ,CAST(T$PONO AS INT)                                                                                                                 AS ORDER_LINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ORNO)),'')                                                                                         AS ORDER_NUMBER 
            ,T$OORG.CONSTANTDESCRIPTION                                                                                                          AS ORDER_ORIGINDESCRIPTION 
            ,CAST(T$OORG AS INT)                                                                                                                 AS ORDER_ORIGINID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PKDF)),'')                                                                                         AS PACKAGEDEFINITION 
            ,T$SHPC.CONSTANTDESCRIPTION                                                                                                          AS PICKEDDESCRIPTION 
            ,CAST(T$SHPC AS INT)                                                                                                                 AS PICKEDID 
            ,CAST(T$PICM AS INT)                                                                                                                 AS PICKINGMISSION 
            ,CAST(T$LSEQ AS BIGINT)                                                                                                              AS PICKINGSEQUENCE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PMSK)),'')                                                                                         AS PROCEDUREMASK 
            ,T$RLSD.CONSTANTDESCRIPTION                                                                                                          AS RELEASEDDESCRIPTION 
            ,CAST(T$RLSD AS INT)                                                                                                                 AS RELEASEDID 
            ,CAST(T$SEQN AS INT)                                                                                                                 AS SEQUENCENUMBER 
            ,CAST(T$OSET AS INT)                                                                                                                 AS _SET 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCT)),'')                                                                                         AS STAGINGLOCATION 
            ,CAST(CASE WHEN T$TIME<= '1/1/1970' THEN NULL ELSE T$TIME  END AS DATETIME) AS TIME 
            ,CAST(T$MTIM AS BIGINT)                                                                                                              AS TIMEINMILLISECONDS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS WAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BTNO)),'')                                                                                         AS WAVENUMBER 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHINH225201") }} AS SOURCETABLE  
            /*CONSIGNMENT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CONS 
             ON   T$CONS.TABLENAME  = 'WHINH225' 
              AND T$CONS.COLUMNNAME = 'T$CONS' 
              AND T$CONS.CONSTANT   = SOURCETABLE.T$CONS 
            /*ORDERORIGIN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OORG 
             ON   T$OORG.TABLENAME  = 'WHINH225' 
              AND T$OORG.COLUMNNAME = 'T$OORG' 
              AND T$OORG.CONSTANT   = SOURCETABLE.T$OORG 
            /*PICKED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SHPC 
             ON   T$SHPC.TABLENAME  = 'WHINH225' 
              AND T$SHPC.COLUMNNAME = 'T$SHPC' 
              AND T$SHPC.CONSTANT   = SOURCETABLE.T$SHPC 
            /*RELEASED*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$RLSD 
             ON   T$RLSD.TABLENAME  = 'WHINH225' 
              AND T$RLSD.COLUMNNAME = 'T$RLSD' 
              AND T$RLSD.CONSTANT   = SOURCETABLE.T$RLSD 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTIVITY AS ACTIVITY, 
        source_data.ACTUALSTORAGEUNIT AS ACTUALSTORAGEUNIT, 
        source_data.ADVICENUMBER AS ADVICENUMBER, 
        source_data.ADVICEQUANTITYININVENTORYUNIT AS ADVICEQUANTITYININVENTORYUNIT, 
        source_data.ADVICEQUANTITYINSTORAGEUNIT AS ADVICEQUANTITYINSTORAGEUNIT, 
        source_data.BOMLINE AS BOMLINE, 
        source_data.CONSIGNMENTDESCRIPTION AS CONSIGNMENTDESCRIPTION, 
        source_data.CONSIGNMENTID AS CONSIGNMENTID, 
        source_data.INVENTORYDATE AS INVENTORYDATE, 
        source_data.ITEM AS ITEM, 
        source_data.LOCATION AS LOCATION, 
        source_data.LOT AS LOT, 
        source_data.ORDER_LINE AS ORDER_LINE, 
        source_data.ORDER_NUMBER AS ORDER_NUMBER, 
        source_data.ORDER_ORIGINDESCRIPTION AS ORDER_ORIGINDESCRIPTION, 
        source_data.ORDER_ORIGINID AS ORDER_ORIGINID, 
        source_data.PACKAGEDEFINITION AS PACKAGEDEFINITION, 
        source_data.PICKEDDESCRIPTION AS PICKEDDESCRIPTION, 
        source_data.PICKEDID AS PICKEDID, 
        source_data.PICKINGMISSION AS PICKINGMISSION, 
        source_data.PICKINGSEQUENCE AS PICKINGSEQUENCE, 
        source_data.PROCEDUREMASK AS PROCEDUREMASK, 
        source_data.RELEASEDDESCRIPTION AS RELEASEDDESCRIPTION, 
        source_data.RELEASEDID AS RELEASEDID, 
        source_data.SEQUENCENUMBER AS SEQUENCENUMBER, 
        source_data._SET AS _SET, 
        source_data.STAGINGLOCATION AS STAGINGLOCATION, 
        source_data.TIME AS TIME, 
        source_data.TIMEINMILLISECONDS AS TIMEINMILLISECONDS, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.WAVENUMBER AS WAVENUMBER
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTIVITY as VARCHAR(20)) as ACTIVITY,
        cast(ACTUALSTORAGEUNIT as VARCHAR(3)) as ACTUALSTORAGEUNIT,
        cast(ADVICENUMBER as NUMBER(38,0)) as ADVICENUMBER,
        cast(ADVICEQUANTITYININVENTORYUNIT as NUMBER(15,2)) as ADVICEQUANTITYININVENTORYUNIT,
        cast(ADVICEQUANTITYINSTORAGEUNIT as NUMBER(15,2)) as ADVICEQUANTITYINSTORAGEUNIT,
        cast(BOMLINE as NUMBER(38,0)) as BOMLINE,
        cast(CONSIGNMENTDESCRIPTION as VARCHAR(16777216)) as CONSIGNMENTDESCRIPTION,
        cast(CONSIGNMENTID as NUMBER(38,0)) as CONSIGNMENTID,
        cast(INVENTORYDATE as TIMESTAMP_NTZ(9)) as INVENTORYDATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LOCATION as VARCHAR(10)) as LOCATION,
        cast(LOT as VARCHAR(16)) as LOT,
        cast(ORDER_LINE as NUMBER(38,0)) as ORDER_LINE,
        cast(ORDER_NUMBER as VARCHAR(9)) as ORDER_NUMBER,
        cast(ORDER_ORIGINDESCRIPTION as VARCHAR(16777216)) as ORDER_ORIGINDESCRIPTION,
        cast(ORDER_ORIGINID as NUMBER(38,0)) as ORDER_ORIGINID,
        cast(PACKAGEDEFINITION as VARCHAR(6)) as PACKAGEDEFINITION,
        cast(PICKEDDESCRIPTION as VARCHAR(16777216)) as PICKEDDESCRIPTION,
        cast(PICKEDID as NUMBER(38,0)) as PICKEDID,
        cast(PICKINGMISSION as NUMBER(38,0)) as PICKINGMISSION,
        cast(PICKINGSEQUENCE as NUMBER(38,0)) as PICKINGSEQUENCE,
        cast(PROCEDUREMASK as VARCHAR(20)) as PROCEDUREMASK,
        cast(RELEASEDDESCRIPTION as VARCHAR(16777216)) as RELEASEDDESCRIPTION,
        cast(RELEASEDID as NUMBER(38,0)) as RELEASEDID,
        cast(SEQUENCENUMBER as NUMBER(38,0)) as SEQUENCENUMBER,
        cast(_SET as NUMBER(38,0)) as _SET,
        cast(STAGINGLOCATION as VARCHAR(10)) as STAGINGLOCATION,
        cast(TIME as TIMESTAMP_NTZ(9)) as TIME,
        cast(TIMEINMILLISECONDS as NUMBER(38,0)) as TIMEINMILLISECONDS,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(WAVENUMBER as VARCHAR(12)) as WAVENUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data