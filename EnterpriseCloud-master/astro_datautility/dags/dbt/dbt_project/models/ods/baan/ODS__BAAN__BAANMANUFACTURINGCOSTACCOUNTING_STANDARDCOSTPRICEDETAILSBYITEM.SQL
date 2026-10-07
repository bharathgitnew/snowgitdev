/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM.SQL 
-materialized incremental
-alias BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM 
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
    alias='BAANMANUFACTURINGCOSTACCOUNTING_STANDARDCOSTPRICEDETAILSBYITEM',
    unique_key = ['COSTCOMPONENT',
    'EFFECTIVEDATE',
    'ITEM']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST("T$AFAT$1" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_FIXEDPART1 
            ,CAST("T$AFAT$2" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_FIXEDPART2 
            ,CAST("T$AFAT$3" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_FIXEDPART3 
            ,CAST("T$AVAT$1" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_VARIABLEPART1 
            ,CAST("T$AVAT$2" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_VARIABLEPART2 
            ,CAST("T$AVAT$3" AS NUMERIC(15,2))                                                                                                     AS ADDEDAMOUNT_VARIABLEPART3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPCP)),'')                                                                                         AS COSTCOMPONENT 
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT  END AS DATETIME) AS EFFECTIVEDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(T$NUNI AS NUMERIC(15,2))                                                                                                       AS NUMBEROFUNITS 
            ,CAST("T$TFAT$1" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_FIXEDPART1 
            ,CAST("T$TFAT$2" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_FIXEDPART2 
            ,CAST("T$TFAT$3" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_FIXEDPART3 
            ,CAST("T$TVAT$1" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_VARIABLEPART1 
            ,CAST("T$TVAT$2" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_VARIABLEPART2 
            ,CAST("T$TVAT$3" AS NUMERIC(15,2))                                                                                                     AS TOTALAMOUNT_VARIABLEPART3 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTICPR305201") }} AS SOURCETABLE  
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ADDEDAMOUNT_FIXEDPART1 AS ADDEDAMOUNT_FIXEDPART1, 
        source_data.ADDEDAMOUNT_FIXEDPART2 AS ADDEDAMOUNT_FIXEDPART2, 
        source_data.ADDEDAMOUNT_FIXEDPART3 AS ADDEDAMOUNT_FIXEDPART3, 
        source_data.ADDEDAMOUNT_VARIABLEPART1 AS ADDEDAMOUNT_VARIABLEPART1, 
        source_data.ADDEDAMOUNT_VARIABLEPART2 AS ADDEDAMOUNT_VARIABLEPART2, 
        source_data.ADDEDAMOUNT_VARIABLEPART3 AS ADDEDAMOUNT_VARIABLEPART3, 
        source_data.COSTCOMPONENT AS COSTCOMPONENT, 
        source_data.EFFECTIVEDATE AS EFFECTIVEDATE, 
        source_data.ITEM AS ITEM, 
        source_data.NUMBEROFUNITS AS NUMBEROFUNITS, 
        source_data.TOTALAMOUNT_FIXEDPART1 AS TOTALAMOUNT_FIXEDPART1, 
        source_data.TOTALAMOUNT_FIXEDPART2 AS TOTALAMOUNT_FIXEDPART2, 
        source_data.TOTALAMOUNT_FIXEDPART3 AS TOTALAMOUNT_FIXEDPART3, 
        source_data.TOTALAMOUNT_VARIABLEPART1 AS TOTALAMOUNT_VARIABLEPART1, 
        source_data.TOTALAMOUNT_VARIABLEPART2 AS TOTALAMOUNT_VARIABLEPART2, 
        source_data.TOTALAMOUNT_VARIABLEPART3 AS TOTALAMOUNT_VARIABLEPART3
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ADDEDAMOUNT_FIXEDPART1 as NUMBER(15,2)) as ADDEDAMOUNT_FIXEDPART1,
        cast(ADDEDAMOUNT_FIXEDPART2 as NUMBER(15,2)) as ADDEDAMOUNT_FIXEDPART2,
        cast(ADDEDAMOUNT_FIXEDPART3 as NUMBER(15,2)) as ADDEDAMOUNT_FIXEDPART3,
        cast(ADDEDAMOUNT_VARIABLEPART1 as NUMBER(15,2)) as ADDEDAMOUNT_VARIABLEPART1,
        cast(ADDEDAMOUNT_VARIABLEPART2 as NUMBER(15,2)) as ADDEDAMOUNT_VARIABLEPART2,
        cast(ADDEDAMOUNT_VARIABLEPART3 as NUMBER(15,2)) as ADDEDAMOUNT_VARIABLEPART3,
        cast(COSTCOMPONENT as VARCHAR(8)) as COSTCOMPONENT,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(NUMBEROFUNITS as NUMBER(15,2)) as NUMBEROFUNITS,
        cast(TOTALAMOUNT_FIXEDPART1 as NUMBER(15,2)) as TOTALAMOUNT_FIXEDPART1,
        cast(TOTALAMOUNT_FIXEDPART2 as NUMBER(15,2)) as TOTALAMOUNT_FIXEDPART2,
        cast(TOTALAMOUNT_FIXEDPART3 as NUMBER(15,2)) as TOTALAMOUNT_FIXEDPART3,
        cast(TOTALAMOUNT_VARIABLEPART1 as NUMBER(15,2)) as TOTALAMOUNT_VARIABLEPART1,
        cast(TOTALAMOUNT_VARIABLEPART2 as NUMBER(15,2)) as TOTALAMOUNT_VARIABLEPART2,
        cast(TOTALAMOUNT_VARIABLEPART3 as NUMBER(15,2)) as TOTALAMOUNT_VARIABLEPART3,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data