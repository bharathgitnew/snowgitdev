/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCOMMONITEMBASEDATA_ITEMCOSTINGDATA.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCOMMONITEMBASEDATA_ITEMCOSTINGDATA.SQL 
-materialized incremental
-alias BAANCOMMONITEMBASEDATA_ITEMCOSTINGDATA 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:48 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='BAAN_BAANCOMMONITEMBASEDATA_ITEMCOSTINGDATA',
    unique_key = ['ITEM']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,200                                                                                                                                   AS _COMPANYID 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE3 
            ,CAST("T$AMTC$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST1 
            ,CAST("T$AMTC$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST2 
            ,CAST("T$AMTC$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST3 
            ,CAST("T$AOPC$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST1 
            ,CAST("T$AOPC$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST2 
            ,CAST("T$AOPC$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPM)),'')                                                                                         AS AGGREGATEDMATERIALCOSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPO)),'')                                                                                         AS AGGREGATEDOPERATIONCOSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPS)),'')                                                                                         AS AGGREGATEDSURCHARGECOSTCOMPONENT 
            ,T$DECP.CONSTANTDESCRIPTION                                                                                                          AS COSTCOMPONENTDETAILSDESCRIPTION 
            ,CAST(T$DECP AS INT)                                                                                                                 AS COSTCOMPONENTDETAILSID 
            ,CAST(T$CUID AS INT)                                                                                                                 AS COSTPRICEINDICATOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE3 
            ,CAST("T$EMTC$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST1 
            ,CAST("T$EMTC$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST2 
            ,CAST("T$EMTC$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST3 
            ,CAST("T$EOPC$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST1 
            ,CAST("T$EOPC$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST2 
            ,CAST("T$EOPC$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LCDA<= '1/1/1970' THEN NULL ELSE T$LCDA  END AS DATETIME) AS LASTCALCULATIONDATE_LCDA 
            ,CAST(CASE WHEN T$LTCP<= '1/1/1970' THEN NULL ELSE T$LTCP  END AS DATETIME) AS LASTCALCULATIONDATE_LTCP 
            ,T$LTPR.CONSTANTDESCRIPTION                                                                                                          AS LOTPRICEDESCRIPTION 
            ,CAST(T$LTPR AS INT)                                                                                                                 AS LOTPRICEID 
            ,T$SPIT.CONSTANTDESCRIPTION                                                                                                          AS SURCHARGESBYITEMDESCRIPTION 
            ,CAST(T$SPIT AS INT)                                                                                                                 AS SURCHARGESBYITEMID 
            ,T$VPWH.CONSTANTDESCRIPTION                                                                                                          AS SURCHARGESBYWAREHOUSEDESCRIPTION 
            ,CAST(T$VPWH AS INT)                                                                                                                 AS SURCHARGESBYWAREHOUSEID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD007200") }} AS SOURCETABLE  
            /*COSTCOMPONENTDETAILS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DECP 
             ON   T$DECP.TABLENAME  = 'TCIBD007' 
              AND T$DECP.COLUMNNAME = 'T$DECP' 
              AND T$DECP.CONSTANT   = SOURCETABLE.T$DECP 
            /*LOTPRICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LTPR 
             ON   T$LTPR.TABLENAME  = 'TCIBD007' 
              AND T$LTPR.COLUMNNAME = 'T$LTPR' 
              AND T$LTPR.CONSTANT   = SOURCETABLE.T$LTPR 
            /*SURCHARGESBYITEM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SPIT 
             ON   T$SPIT.TABLENAME  = 'TCIBD007' 
              AND T$SPIT.COLUMNNAME = 'T$SPIT' 
              AND T$SPIT.CONSTANT   = SOURCETABLE.T$SPIT 
            /*SURCHARGESBYWAREHOUSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VPWH 
             ON   T$VPWH.TABLENAME  = 'TCIBD007' 
              AND T$VPWH.COLUMNNAME = 'T$VPWH' 
              AND T$VPWH.CONSTANT   = SOURCETABLE.T$VPWH 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %}
        UNION ALL 
        SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,CAST("T$ACPR$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE1 
            ,CAST("T$ACPR$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE2 
            ,CAST("T$ACPR$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALCOSTPRICE3 
            ,CAST("T$AMTC$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST1 
            ,CAST("T$AMTC$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST2 
            ,CAST("T$AMTC$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALMATERIALCOST3 
            ,CAST("T$AOPC$1" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST1 
            ,CAST("T$AOPC$2" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST2 
            ,CAST("T$AOPC$3" AS NUMERIC(15,2))                                                                                                     AS ACTUALOPERATIONCOST3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPM)),'')                                                                                         AS AGGREGATEDMATERIALCOSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPO)),'')                                                                                         AS AGGREGATEDOPERATIONCOSTCOMPONENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ACPS)),'')                                                                                         AS AGGREGATEDSURCHARGECOSTCOMPONENT 
            ,T$DECP.CONSTANTDESCRIPTION                                                                                                          AS COSTCOMPONENTDETAILSDESCRIPTION 
            ,CAST(T$DECP AS INT)                                                                                                                 AS COSTCOMPONENTDETAILSID 
            ,CAST(T$CUID AS INT)                                                                                                                 AS COSTPRICEINDICATOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCUR)),'')                                                                                         AS CURRENCY 
            ,CAST("T$ECPR$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE1 
            ,CAST("T$ECPR$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE2 
            ,CAST("T$ECPR$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDCOSTPRICE3 
            ,CAST("T$EMTC$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST1 
            ,CAST("T$EMTC$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST2 
            ,CAST("T$EMTC$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDMATERIALCOST3 
            ,CAST("T$EOPC$1" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST1 
            ,CAST("T$EOPC$2" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST2 
            ,CAST("T$EOPC$3" AS NUMERIC(15,2))                                                                                                     AS ESTIMATEDOPERATIONALCOST3 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS ITEM 
            ,CAST(CASE WHEN T$LCDA<= '1/1/1970' THEN NULL ELSE T$LCDA  END AS DATETIME) AS LASTCALCULATIONDATE_LCDA 
            ,CAST(CASE WHEN T$LTCP<= '1/1/1970' THEN NULL ELSE T$LTCP  END AS DATETIME) AS LASTCALCULATIONDATE_LTCP 
            ,T$LTPR.CONSTANTDESCRIPTION                                                                                                          AS LOTPRICEDESCRIPTION 
            ,CAST(T$LTPR AS INT)                                                                                                                 AS LOTPRICEID 
            ,T$SPIT.CONSTANTDESCRIPTION                                                                                                          AS SURCHARGESBYITEMDESCRIPTION 
            ,CAST(T$SPIT AS INT)                                                                                                                 AS SURCHARGESBYITEMID 
            ,T$VPWH.CONSTANTDESCRIPTION                                                                                                          AS SURCHARGESBYWAREHOUSEDESCRIPTION 
            ,CAST(T$VPWH AS INT)                                                                                                                 AS SURCHARGESBYWAREHOUSEID 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TTCIBD007201") }} AS SOURCETABLE  
            /*COSTCOMPONENTDETAILS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DECP 
             ON   T$DECP.TABLENAME  = 'TCIBD007' 
              AND T$DECP.COLUMNNAME = 'T$DECP' 
              AND T$DECP.CONSTANT   = SOURCETABLE.T$DECP 
            /*LOTPRICE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$LTPR 
             ON   T$LTPR.TABLENAME  = 'TCIBD007' 
              AND T$LTPR.COLUMNNAME = 'T$LTPR' 
              AND T$LTPR.CONSTANT   = SOURCETABLE.T$LTPR 
            /*SURCHARGESBYITEM*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SPIT 
             ON   T$SPIT.TABLENAME  = 'TCIBD007' 
              AND T$SPIT.COLUMNNAME = 'T$SPIT' 
              AND T$SPIT.CONSTANT   = SOURCETABLE.T$SPIT 
            /*SURCHARGESBYWAREHOUSE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$VPWH 
             ON   T$VPWH.TABLENAME  = 'TCIBD007' 
              AND T$VPWH.COLUMNNAME = 'T$VPWH' 
              AND T$VPWH.CONSTANT   = SOURCETABLE.T$VPWH 
        {% if is_tel_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACTUALCOSTPRICE1 AS ACTUALCOSTPRICE1, 
        source_data.ACTUALCOSTPRICE2 AS ACTUALCOSTPRICE2, 
        source_data.ACTUALCOSTPRICE3 AS ACTUALCOSTPRICE3, 
        source_data.ACTUALMATERIALCOST1 AS ACTUALMATERIALCOST1, 
        source_data.ACTUALMATERIALCOST2 AS ACTUALMATERIALCOST2, 
        source_data.ACTUALMATERIALCOST3 AS ACTUALMATERIALCOST3, 
        source_data.ACTUALOPERATIONCOST1 AS ACTUALOPERATIONCOST1, 
        source_data.ACTUALOPERATIONCOST2 AS ACTUALOPERATIONCOST2, 
        source_data.ACTUALOPERATIONCOST3 AS ACTUALOPERATIONCOST3, 
        source_data.AGGREGATEDMATERIALCOSTCOMPONENT AS AGGREGATEDMATERIALCOSTCOMPONENT, 
        source_data.AGGREGATEDOPERATIONCOSTCOMPONENT AS AGGREGATEDOPERATIONCOSTCOMPONENT, 
        source_data.AGGREGATEDSURCHARGECOSTCOMPONENT AS AGGREGATEDSURCHARGECOSTCOMPONENT, 
        source_data.COSTCOMPONENTDETAILSDESCRIPTION AS COSTCOMPONENTDETAILSDESCRIPTION, 
        source_data.COSTCOMPONENTDETAILSID AS COSTCOMPONENTDETAILSID, 
        source_data.COSTPRICEINDICATOR AS COSTPRICEINDICATOR, 
        source_data.CURRENCY AS CURRENCY, 
        source_data.ESTIMATEDCOSTPRICE1 AS ESTIMATEDCOSTPRICE1, 
        source_data.ESTIMATEDCOSTPRICE2 AS ESTIMATEDCOSTPRICE2, 
        source_data.ESTIMATEDCOSTPRICE3 AS ESTIMATEDCOSTPRICE3, 
        source_data.ESTIMATEDMATERIALCOST1 AS ESTIMATEDMATERIALCOST1, 
        source_data.ESTIMATEDMATERIALCOST2 AS ESTIMATEDMATERIALCOST2, 
        source_data.ESTIMATEDMATERIALCOST3 AS ESTIMATEDMATERIALCOST3, 
        source_data.ESTIMATEDOPERATIONALCOST1 AS ESTIMATEDOPERATIONALCOST1, 
        source_data.ESTIMATEDOPERATIONALCOST2 AS ESTIMATEDOPERATIONALCOST2, 
        source_data.ESTIMATEDOPERATIONALCOST3 AS ESTIMATEDOPERATIONALCOST3, 
        source_data.ITEM AS ITEM, 
        source_data.LASTCALCULATIONDATE_LCDA AS LASTCALCULATIONDATE_LCDA, 
        source_data.LASTCALCULATIONDATE_LTCP AS LASTCALCULATIONDATE_LTCP, 
        source_data.LOTPRICEDESCRIPTION AS LOTPRICEDESCRIPTION, 
        source_data.LOTPRICEID AS LOTPRICEID, 
        source_data.SURCHARGESBYITEMDESCRIPTION AS SURCHARGESBYITEMDESCRIPTION, 
        source_data.SURCHARGESBYITEMID AS SURCHARGESBYITEMID, 
        source_data.SURCHARGESBYWAREHOUSEDESCRIPTION AS SURCHARGESBYWAREHOUSEDESCRIPTION, 
        source_data.SURCHARGESBYWAREHOUSEID AS SURCHARGESBYWAREHOUSEID
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACTUALCOSTPRICE1 as NUMBER(15,2)) as ACTUALCOSTPRICE1,
        cast(ACTUALCOSTPRICE2 as NUMBER(15,2)) as ACTUALCOSTPRICE2,
        cast(ACTUALCOSTPRICE3 as NUMBER(15,2)) as ACTUALCOSTPRICE3,
        cast(ACTUALMATERIALCOST1 as NUMBER(15,2)) as ACTUALMATERIALCOST1,
        cast(ACTUALMATERIALCOST2 as NUMBER(15,2)) as ACTUALMATERIALCOST2,
        cast(ACTUALMATERIALCOST3 as NUMBER(15,2)) as ACTUALMATERIALCOST3,
        cast(ACTUALOPERATIONCOST1 as NUMBER(15,2)) as ACTUALOPERATIONCOST1,
        cast(ACTUALOPERATIONCOST2 as NUMBER(15,2)) as ACTUALOPERATIONCOST2,
        cast(ACTUALOPERATIONCOST3 as NUMBER(15,2)) as ACTUALOPERATIONCOST3,
        cast(AGGREGATEDMATERIALCOSTCOMPONENT as VARCHAR(8)) as AGGREGATEDMATERIALCOSTCOMPONENT,
        cast(AGGREGATEDOPERATIONCOSTCOMPONENT as VARCHAR(8)) as AGGREGATEDOPERATIONCOSTCOMPONENT,
        cast(AGGREGATEDSURCHARGECOSTCOMPONENT as VARCHAR(8)) as AGGREGATEDSURCHARGECOSTCOMPONENT,
        cast(COSTCOMPONENTDETAILSDESCRIPTION as VARCHAR(16777216)) as COSTCOMPONENTDETAILSDESCRIPTION,
        cast(COSTCOMPONENTDETAILSID as NUMBER(38,0)) as COSTCOMPONENTDETAILSID,
        cast(COSTPRICEINDICATOR as NUMBER(38,0)) as COSTPRICEINDICATOR,
        cast(CURRENCY as VARCHAR(3)) as CURRENCY,
        cast(ESTIMATEDCOSTPRICE1 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE1,
        cast(ESTIMATEDCOSTPRICE2 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE2,
        cast(ESTIMATEDCOSTPRICE3 as NUMBER(15,2)) as ESTIMATEDCOSTPRICE3,
        cast(ESTIMATEDMATERIALCOST1 as NUMBER(15,2)) as ESTIMATEDMATERIALCOST1,
        cast(ESTIMATEDMATERIALCOST2 as NUMBER(15,2)) as ESTIMATEDMATERIALCOST2,
        cast(ESTIMATEDMATERIALCOST3 as NUMBER(15,2)) as ESTIMATEDMATERIALCOST3,
        cast(ESTIMATEDOPERATIONALCOST1 as NUMBER(15,2)) as ESTIMATEDOPERATIONALCOST1,
        cast(ESTIMATEDOPERATIONALCOST2 as NUMBER(15,2)) as ESTIMATEDOPERATIONALCOST2,
        cast(ESTIMATEDOPERATIONALCOST3 as NUMBER(15,2)) as ESTIMATEDOPERATIONALCOST3,
        cast(ITEM as VARCHAR(47)) as ITEM,
        cast(LASTCALCULATIONDATE_LCDA as TIMESTAMP_NTZ(9)) as LASTCALCULATIONDATE_LCDA,
        cast(LASTCALCULATIONDATE_LTCP as TIMESTAMP_NTZ(9)) as LASTCALCULATIONDATE_LTCP,
        cast(LOTPRICEDESCRIPTION as VARCHAR(16777216)) as LOTPRICEDESCRIPTION,
        cast(LOTPRICEID as NUMBER(38,0)) as LOTPRICEID,
        cast(SURCHARGESBYITEMDESCRIPTION as VARCHAR(16777216)) as SURCHARGESBYITEMDESCRIPTION,
        cast(SURCHARGESBYITEMID as NUMBER(38,0)) as SURCHARGESBYITEMID,
        cast(SURCHARGESBYWAREHOUSEDESCRIPTION as VARCHAR(16777216)) as SURCHARGESBYWAREHOUSEDESCRIPTION,
        cast(SURCHARGESBYWAREHOUSEID as NUMBER(38,0)) as SURCHARGESBYWAREHOUSEID
    from transform_data
    )
select * from type_data