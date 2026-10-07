/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMDATABYWAREHOUSE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMDATABYWAREHOUSE.SQL 
-materialized incremental
-alias BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMDATABYWAREHOUSE 
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
    alias='BAANWAREHOUSINGWAREHOUSINGMASTERDATA_ITEMDATABYWAREHOUSE',
    unique_key = ['ITEM',
    'WAREHOUSE']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ABCC)),'')                                                                                             AS ABCCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCD)),'')                                                                                             AS DEFAULTASSEMBLYLINELOCATION 
            ,CAST("T$ECOQ$C" AS NUMERIC(15,2))                                                                                                         AS ECONOMICORDERQUANTITY_ECOQ_C 
            ,CAST(T$ECOQ AS NUMERIC(15,2))                                                                                                           AS ECONOMICORDERQUANTITY_ECOQ 
            ,CAST(T$USAB AS NUMERIC(15,2))                                                                                                           AS EXPECTEDANNUALISSUE 
            ,CAST(CASE WHEN T$FODT<= '1/1/1970' THEN NULL ELSE T$FODT  END AS DATETIME)     AS FIRSTALLOWEDORDERDATE 
            ,CAST("T$FIOQ$C" AS NUMERIC(15,2))                                                                                                         AS FIXEDORDERQUANTITY_FIOQ_C 
            ,CAST(T$FIOQ AS NUMERIC(15,2))                                                                                                           AS FIXEDORDERQUANTITY_FIOQ 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CFMD)),'')                                                                                             AS FORECASTMETHOD 
            ,CAST(T$ILTM AS INT)                                                                                                                     AS INBOUNDLEADTIME 
            ,CAST(T$SCST AS NUMERIC(15,2))                                                                                                           AS INVENTORYCARRYINGCOSTSPERYEAR 
            ,T$VALM.CONSTANTDESCRIPTION                                                                                                              AS INVENTORYVALUATIONMETHODDESCRIPTION 
            ,CAST(T$VALM AS INT)                                                                                                                     AS INVENTORYVALUATIONMETHODID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                             AS ITEM 
            ,CAST(CASE WHEN "T$LCHD$C"<= '1/1/1970' THEN NULL ELSE "T$LCHD$C"  END AS DATETIME) AS LASTUPDATEDDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$UPBY$C")),'')                                                                                           AS LASTUPDATEDUSER 
            ,T$TOPE.CONSTANTDESCRIPTION                                                                                                              AS LEADTIMEUNITDESCRIPTION 
            ,CAST(T$TOPE AS INT)                                                                                                                     AS LEADTIMEUNITID 
            ,CAST("T$MAXS$C" AS NUMERIC(15,2))                                                                                                         AS MAXIMUMINVENTORY_MAXS_C 
            ,CAST(T$MAXS AS NUMERIC(15,2))                                                                                                           AS MAXIMUMINVENTORY_MAXS 
            ,CAST("T$MAOQ$C" AS NUMERIC(15,2))                                                                                                         AS MAXIMUMORDERQUANTITY_MAOQ_C 
            ,CAST(T$MAOQ AS NUMERIC(15,2))                                                                                                           AS MAXIMUMORDERQUANTITY_MAOQ 
            ,CAST("T$MIOQ$C" AS NUMERIC(15,2))                                                                                                         AS MINIMUMORDERQUANTITY_MIOQ_C 
            ,CAST(T$MIOQ AS NUMERIC(15,2))                                                                                                           AS MINIMUMORDERQUANTITY_MIOQ 
            ,CAST(T$NOPR AS INT)                                                                                                                     AS NUMBEROFPERIODS 
            ,CAST(T$OCST AS NUMERIC(15,2))                                                                                                           AS ORDER_COSTS 
            ,CAST(T$OINT AS INT)                                                                                                                     AS ORDER_INTERVAL 
            ,"T$OMTH$C".CONSTANTDESCRIPTION                                                                                                            AS ORDER_METHOD_OMTH_CDESCRIPTION 
            ,CAST("T$OMTH$C" AS INT)                                                                                                                   AS ORDER_METHOD_OMTH_CID 
            ,T$OMTH.CONSTANTDESCRIPTION                                                                                                              AS ORDER_METHOD_OMTHDESCRIPTION 
            ,CAST(T$OMTH AS INT)                                                                                                                     AS ORDER_METHOD_OMTHID 
            ,CAST("T$OQMF$C" AS NUMERIC(15,2))                                                                                                         AS ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF_C 
            ,CAST(T$OQMF AS NUMERIC(15,2))                                                                                                           AS ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF 
            ,CAST(T$OLTM AS INT)                                                                                                                     AS OUTBOUNDLEADTIME 
            ,T$OABC.CONSTANTDESCRIPTION                                                                                                              AS OVERWRITEABCCODEDESCRIPTION 
            ,CAST(T$OABC AS INT)                                                                                                                     AS OVERWRITEABCCODEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PKDF)),'')                                                                                             AS PACKAGEDEFINITION 
            ,T$PTYP.CONSTANTDESCRIPTION                                                                                                              AS PERIODTYPEDESCRIPTION 
            ,CAST(T$PTYP AS INT)                                                                                                                     AS PERIODTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$REMK$C")),'')                                                                                           AS REMARKS 
            ,CAST("T$REOP$C" AS NUMERIC(15,2))                                                                                                         AS RE_ORDERPOINT_REOP_C 
            ,CAST(T$REOP AS NUMERIC(15,2))                                                                                                           AS RE_ORDERPOINT_REOP 
            ,CAST("T$SFST$C" AS NUMERIC(15,2))                                                                                                         AS SAFETYSTOCK_SFST_C 
            ,CAST(T$SFST AS NUMERIC(15,2))                                                                                                           AS SAFETYSTOCK_SFST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPS)),'')                                                                                             AS SEASONALPATTERNFORSAFETYSTOCK 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPD)),'')                                                                                             AS SEASONPATTERNFORDEMAND 
            ,CAST(T$SERV AS TINYINT)                                                                                                                 AS SERVICELEVELPERCENTAGE 
            ,CAST(T$SLMP AS TINYINT)                                                                                                                 AS SLOW_MOVINGPERCENTAGE 
            ,T$SUPS.CONSTANTDESCRIPTION                                                                                                              AS SUPPLYSYSTEMDESCRIPTION 
            ,CAST(T$SUPS AS INT)                                                                                                                     AS SUPPLYSYSTEMID 
            ,T$AUSO.CONSTANTDESCRIPTION                                                                                                              AS UPDATEINVENTORYORDERDATADESCRIPTION 
            ,CAST(T$AUSO AS INT)                                                                                                                     AS UPDATEINVENTORYORDERDATAID 
            ,T$UIDT.CONSTANTDESCRIPTION                                                                                                              AS USEITEMPARAMETERSDESCRIPTION 
            ,CAST(T$UIDT AS INT)                                                                                                                     AS USEITEMPARAMETERSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                             AS WAREHOUSE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ZONE)),'')                                                                                             AS ZONE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TWHWMD210201") }} AS SOURCETABLE  
            /*INVENTORYVALUATIONMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VALM 
             ON   T$VALM.TABLENAME  = 'WHWMD210' 
              AND T$VALM.COLUMNNAME = 'T$VALM' 
              AND T$VALM.CONSTANT   = SOURCETABLE.T$VALM 
            /*LEADTIMEUNIT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$TOPE 
             ON   T$TOPE.TABLENAME  = 'WHWMD210' 
              AND T$TOPE.COLUMNNAME = 'T$TOPE' 
              AND T$TOPE.CONSTANT   = SOURCETABLE.T$TOPE 
            /*ORDERMETHODC*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$OMTH$C" 
             ON   "T$OMTH$C".TABLENAME  = 'WHWMD210' 
              AND "T$OMTH$C".COLUMNNAME = 'T$OMTH.C' 
              AND "T$OMTH$C".CONSTANT   = SOURCETABLE."T$OMTH$C" 
            /*ORDERMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OMTH 
             ON   T$OMTH.TABLENAME  = 'WHWMD210' 
              AND T$OMTH.COLUMNNAME = 'T$OMTH' 
              AND T$OMTH.CONSTANT   = SOURCETABLE.T$OMTH 
            /*OVERWRITEABCCODE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OABC 
             ON   T$OABC.TABLENAME  = 'WHWMD210' 
              AND T$OABC.COLUMNNAME = 'T$OABC' 
              AND T$OABC.CONSTANT   = SOURCETABLE.T$OABC 
            /*PERIODTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PTYP 
             ON   T$PTYP.TABLENAME  = 'WHWMD210' 
              AND T$PTYP.COLUMNNAME = 'T$PTYP' 
              AND T$PTYP.CONSTANT   = SOURCETABLE.T$PTYP 
            /*SUPPLYSYSTEM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SUPS 
             ON   T$SUPS.TABLENAME  = 'WHWMD210' 
              AND T$SUPS.COLUMNNAME = 'T$SUPS' 
              AND T$SUPS.CONSTANT   = SOURCETABLE.T$SUPS 
            /*UPDATEINVENTORYORDERDATA*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUSO 
             ON   T$AUSO.TABLENAME  = 'WHWMD210' 
              AND T$AUSO.COLUMNNAME = 'T$AUSO' 
              AND T$AUSO.CONSTANT   = SOURCETABLE.T$AUSO 
            /*USEITEMPARAMETERS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$UIDT 
             ON   T$UIDT.TABLENAME  = 'WHWMD210' 
              AND T$UIDT.COLUMNNAME = 'T$UIDT' 
              AND T$UIDT.CONSTANT   = SOURCETABLE.T$UIDT 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ABCCODE AS ABCCODE, 
        source_data.DEFAULTASSEMBLYLINELOCATION AS DEFAULTASSEMBLYLINELOCATION, 
        source_data.ECONOMICORDERQUANTITY_ECOQ_C AS ECONOMICORDERQUANTITY_ECOQ_C, 
        source_data.ECONOMICORDERQUANTITY_ECOQ AS ECONOMICORDERQUANTITY_ECOQ, 
        source_data.EXPECTEDANNUALISSUE AS EXPECTEDANNUALISSUE, 
        source_data.FIRSTALLOWEDORDERDATE AS FIRSTALLOWEDORDERDATE, 
        source_data.FIXEDORDERQUANTITY_FIOQ_C AS FIXEDORDERQUANTITY_FIOQ_C, 
        source_data.FIXEDORDERQUANTITY_FIOQ AS FIXEDORDERQUANTITY_FIOQ, 
        source_data.FORECASTMETHOD AS FORECASTMETHOD, 
        source_data.INBOUNDLEADTIME AS INBOUNDLEADTIME, 
        source_data.INVENTORYCARRYINGCOSTSPERYEAR AS INVENTORYCARRYINGCOSTSPERYEAR, 
        source_data.INVENTORYVALUATIONMETHODDESCRIPTION AS INVENTORYVALUATIONMETHODDESCRIPTION, 
        source_data.INVENTORYVALUATIONMETHODID AS INVENTORYVALUATIONMETHODID, 
        source_data.ITEM AS ITEM, 
        source_data.LASTUPDATEDDATE AS LASTUPDATEDDATE, 
        source_data.LASTUPDATEDUSER AS LASTUPDATEDUSER, 
        source_data.LEADTIMEUNITDESCRIPTION AS LEADTIMEUNITDESCRIPTION, 
        source_data.LEADTIMEUNITID AS LEADTIMEUNITID, 
        source_data.MAXIMUMINVENTORY_MAXS_C AS MAXIMUMINVENTORY_MAXS_C, 
        source_data.MAXIMUMINVENTORY_MAXS AS MAXIMUMINVENTORY_MAXS, 
        source_data.MAXIMUMORDERQUANTITY_MAOQ_C AS MAXIMUMORDERQUANTITY_MAOQ_C, 
        source_data.MAXIMUMORDERQUANTITY_MAOQ AS MAXIMUMORDERQUANTITY_MAOQ, 
        source_data.MINIMUMORDERQUANTITY_MIOQ_C AS MINIMUMORDERQUANTITY_MIOQ_C, 
        source_data.MINIMUMORDERQUANTITY_MIOQ AS MINIMUMORDERQUANTITY_MIOQ, 
        source_data.NUMBEROFPERIODS AS NUMBEROFPERIODS, 
        source_data.ORDER_COSTS AS ORDER_COSTS, 
        source_data.ORDER_INTERVAL AS ORDER_INTERVAL, 
        source_data.ORDER_METHOD_OMTH_CDESCRIPTION AS ORDER_METHOD_OMTH_CDESCRIPTION, 
        source_data.ORDER_METHOD_OMTH_CID AS ORDER_METHOD_OMTH_CID, 
        source_data.ORDER_METHOD_OMTHDESCRIPTION AS ORDER_METHOD_OMTHDESCRIPTION, 
        source_data.ORDER_METHOD_OMTHID AS ORDER_METHOD_OMTHID, 
        source_data.ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF_C AS ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF_C, 
        source_data.ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF AS ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF, 
        source_data.OUTBOUNDLEADTIME AS OUTBOUNDLEADTIME, 
        source_data.OVERWRITEABCCODEDESCRIPTION AS OVERWRITEABCCODEDESCRIPTION, 
        source_data.OVERWRITEABCCODEID AS OVERWRITEABCCODEID, 
        source_data.PACKAGEDEFINITION AS PACKAGEDEFINITION, 
        source_data.PERIODTYPEDESCRIPTION AS PERIODTYPEDESCRIPTION, 
        source_data.PERIODTYPEID AS PERIODTYPEID, 
        source_data.REMARKS AS REMARKS, 
        source_data.RE_ORDERPOINT_REOP_C AS RE_ORDERPOINT_REOP_C, 
        source_data.RE_ORDERPOINT_REOP AS RE_ORDERPOINT_REOP, 
        source_data.SAFETYSTOCK_SFST_C AS SAFETYSTOCK_SFST_C, 
        source_data.SAFETYSTOCK_SFST AS SAFETYSTOCK_SFST, 
        source_data.SEASONALPATTERNFORSAFETYSTOCK AS SEASONALPATTERNFORSAFETYSTOCK, 
        source_data.SEASONPATTERNFORDEMAND AS SEASONPATTERNFORDEMAND, 
        source_data.SERVICELEVELPERCENTAGE AS SERVICELEVELPERCENTAGE, 
        source_data.SLOW_MOVINGPERCENTAGE AS SLOW_MOVINGPERCENTAGE, 
        source_data.SUPPLYSYSTEMDESCRIPTION AS SUPPLYSYSTEMDESCRIPTION, 
        source_data.SUPPLYSYSTEMID AS SUPPLYSYSTEMID, 
        source_data.UPDATEINVENTORYORDERDATADESCRIPTION AS UPDATEINVENTORYORDERDATADESCRIPTION, 
        source_data.UPDATEINVENTORYORDERDATAID AS UPDATEINVENTORYORDERDATAID, 
        source_data.USEITEMPARAMETERSDESCRIPTION AS USEITEMPARAMETERSDESCRIPTION, 
        source_data.USEITEMPARAMETERSID AS USEITEMPARAMETERSID, 
        source_data.WAREHOUSE AS WAREHOUSE, 
        source_data.ZONE AS ZONE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ABCCODE as VARCHAR(1)) as ABCCODE,
        cast(DEFAULTASSEMBLYLINELOCATION as VARCHAR(10)) as DEFAULTASSEMBLYLINELOCATION,
        cast(ECONOMICORDERQUANTITY_ECOQ_C as NUMBER(15,2)) as ECONOMICORDERQUANTITY_ECOQ_C,
        cast(ECONOMICORDERQUANTITY_ECOQ as NUMBER(15,2)) as ECONOMICORDERQUANTITY_ECOQ,
        cast(EXPECTEDANNUALISSUE as NUMBER(15,2)) as EXPECTEDANNUALISSUE,
        cast(FIRSTALLOWEDORDERDATE as TIMESTAMP_NTZ(9)) as FIRSTALLOWEDORDERDATE,
        cast(FIXEDORDERQUANTITY_FIOQ_C as NUMBER(15,2)) as FIXEDORDERQUANTITY_FIOQ_C,
        cast(FIXEDORDERQUANTITY_FIOQ as NUMBER(15,2)) as FIXEDORDERQUANTITY_FIOQ,
        cast(FORECASTMETHOD as VARCHAR(3)) as FORECASTMETHOD,
        cast(INBOUNDLEADTIME as NUMBER(38,0)) as INBOUNDLEADTIME,
        cast(INVENTORYCARRYINGCOSTSPERYEAR as NUMBER(15,2)) as INVENTORYCARRYINGCOSTSPERYEAR,
        cast(INVENTORYVALUATIONMETHODDESCRIPTION as VARCHAR(16777216)) as INVENTORYVALUATIONMETHODDESCRIPTION,
        cast(INVENTORYVALUATIONMETHODID as NUMBER(38,0)) as INVENTORYVALUATIONMETHODID,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTUPDATEDDATE as TIMESTAMP_NTZ(9)) as LASTUPDATEDDATE,
        cast(LASTUPDATEDUSER as VARCHAR(16)) as LASTUPDATEDUSER,
        cast(LEADTIMEUNITDESCRIPTION as VARCHAR(16777216)) as LEADTIMEUNITDESCRIPTION,
        cast(LEADTIMEUNITID as NUMBER(38,0)) as LEADTIMEUNITID,
        cast(MAXIMUMINVENTORY_MAXS_C as NUMBER(15,2)) as MAXIMUMINVENTORY_MAXS_C,
        cast(MAXIMUMINVENTORY_MAXS as NUMBER(15,2)) as MAXIMUMINVENTORY_MAXS,
        cast(MAXIMUMORDERQUANTITY_MAOQ_C as NUMBER(15,2)) as MAXIMUMORDERQUANTITY_MAOQ_C,
        cast(MAXIMUMORDERQUANTITY_MAOQ as NUMBER(15,2)) as MAXIMUMORDERQUANTITY_MAOQ,
        cast(MINIMUMORDERQUANTITY_MIOQ_C as NUMBER(15,2)) as MINIMUMORDERQUANTITY_MIOQ_C,
        cast(MINIMUMORDERQUANTITY_MIOQ as NUMBER(15,2)) as MINIMUMORDERQUANTITY_MIOQ,
        cast(NUMBEROFPERIODS as NUMBER(38,0)) as NUMBEROFPERIODS,
        cast(ORDER_COSTS as NUMBER(15,2)) as ORDER_COSTS,
        cast(ORDER_INTERVAL as NUMBER(38,0)) as ORDER_INTERVAL,
        cast(ORDER_METHOD_OMTH_CDESCRIPTION as VARCHAR(16777216)) as ORDER_METHOD_OMTH_CDESCRIPTION,
        cast(ORDER_METHOD_OMTH_CID as NUMBER(38,0)) as ORDER_METHOD_OMTH_CID,
        cast(ORDER_METHOD_OMTHDESCRIPTION as VARCHAR(16777216)) as ORDER_METHOD_OMTHDESCRIPTION,
        cast(ORDER_METHOD_OMTHID as NUMBER(38,0)) as ORDER_METHOD_OMTHID,
        cast(ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF_C as NUMBER(15,2)) as ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF_C,
        cast(ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF as NUMBER(15,2)) as ORDER_QUANTITYMULTIPLICATIONFACTOR_OQMF,
        cast(OUTBOUNDLEADTIME as NUMBER(38,0)) as OUTBOUNDLEADTIME,
        cast(OVERWRITEABCCODEDESCRIPTION as VARCHAR(16777216)) as OVERWRITEABCCODEDESCRIPTION,
        cast(OVERWRITEABCCODEID as NUMBER(38,0)) as OVERWRITEABCCODEID,
        cast(PACKAGEDEFINITION as VARCHAR(6)) as PACKAGEDEFINITION,
        cast(PERIODTYPEDESCRIPTION as VARCHAR(16777216)) as PERIODTYPEDESCRIPTION,
        cast(PERIODTYPEID as NUMBER(38,0)) as PERIODTYPEID,
        cast(REMARKS as VARCHAR(50)) as REMARKS,
        cast(RE_ORDERPOINT_REOP_C as NUMBER(15,2)) as RE_ORDERPOINT_REOP_C,
        cast(RE_ORDERPOINT_REOP as NUMBER(15,2)) as RE_ORDERPOINT_REOP,
        cast(SAFETYSTOCK_SFST_C as NUMBER(15,2)) as SAFETYSTOCK_SFST_C,
        cast(SAFETYSTOCK_SFST as NUMBER(15,2)) as SAFETYSTOCK_SFST,
        cast(SEASONALPATTERNFORSAFETYSTOCK as VARCHAR(3)) as SEASONALPATTERNFORSAFETYSTOCK,
        cast(SEASONPATTERNFORDEMAND as VARCHAR(3)) as SEASONPATTERNFORDEMAND,
        cast(SERVICELEVELPERCENTAGE as NUMBER(38,0)) as SERVICELEVELPERCENTAGE,
        cast(SLOW_MOVINGPERCENTAGE as NUMBER(38,0)) as SLOW_MOVINGPERCENTAGE,
        cast(SUPPLYSYSTEMDESCRIPTION as VARCHAR(16777216)) as SUPPLYSYSTEMDESCRIPTION,
        cast(SUPPLYSYSTEMID as NUMBER(38,0)) as SUPPLYSYSTEMID,
        cast(UPDATEINVENTORYORDERDATADESCRIPTION as VARCHAR(16777216)) as UPDATEINVENTORYORDERDATADESCRIPTION,
        cast(UPDATEINVENTORYORDERDATAID as NUMBER(38,0)) as UPDATEINVENTORYORDERDATAID,
        cast(USEITEMPARAMETERSDESCRIPTION as VARCHAR(16777216)) as USEITEMPARAMETERSDESCRIPTION,
        cast(USEITEMPARAMETERSID as NUMBER(38,0)) as USEITEMPARAMETERSID,
        cast(WAREHOUSE as VARCHAR(6)) as WAREHOUSE,
        cast(ZONE as VARCHAR(8)) as ZONE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data