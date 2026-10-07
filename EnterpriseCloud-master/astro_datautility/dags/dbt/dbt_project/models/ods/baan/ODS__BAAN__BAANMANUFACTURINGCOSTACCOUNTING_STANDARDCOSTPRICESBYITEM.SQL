/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM.SQL 
-materialized incremental
-alias BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:54 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICESBYITEM',
    unique_key = ['COSTCOMPONENT',
    'EFFECTIVEDATE',
    'ITEM']
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
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$NUNI AS NUMERIC(15,2))                                                                                                       AS NUMBEROFUNITS 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTICPR300201") }} AS SOURCETABLE  
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
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.ITEM AS ITEM, 
        source_data.NUMBEROFUNITS AS NUMBEROFUNITS
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
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(NUMBEROFUNITS as NUMBER(15,2)) as NUMBEROFUNITS,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data