/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANCONSTRAINTPLANNINGRESOURCEPLANNINGDATA_PLANITEMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANCONSTRAINTPLANNINGRESOURCEPLANNINGDATA_PLANITEMS.SQL 
-materialized incremental
-alias BAANCONSTRAINTPLANNINGRESOURCEPLANNINGDATA_PLANITEMS 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:49 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BAANCONSTRAINTPLANNINGRESOURCEPLANNINGDATA_PLANITEMS',
    unique_key = ['CLUSTER',
    'ITEMWITHOUTPROJECT',
    'PLANITEM',
    'PROJECT']
) }}


with source_data as 
(
    SELECT  
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,T$AUDF.CONSTANTDESCRIPTION                                                                                                          AS AUTOMATICUPDATEOFDEMANDFORECASTDESCRIPTION 
            ,CAST(T$AUDF AS INT)                                                                                                                 AS AUTOMATICUPDATEOFDEMANDFORECASTID 
            ,T$AUIV.CONSTANTDESCRIPTION                                                                                                          AS AUTOMATICUPDATEOFINVENTORYPLANDESCRIPTION 
            ,CAST(T$AUIV AS INT)                                                                                                                 AS AUTOMATICUPDATEOFINVENTORYPLANID 
            ,T$AUPR.CONSTANTDESCRIPTION                                                                                                          AS AUTOMATICUPDATEOFPRODUCTIONPLANDESCRIPTION 
            ,CAST(T$AUPR AS INT)                                                                                                                 AS AUTOMATICUPDATEOFPRODUCTIONPLANID 
            ,T$AUPU.CONSTANTDESCRIPTION                                                                                                          AS AUTOMATICUPDATEOFPURCHASEPLANDESCRIPTION 
            ,CAST(T$AUPU AS INT)                                                                                                                 AS AUTOMATICUPDATEOFPURCHASEPLANID 
            ,T$CATP.CONSTANTDESCRIPTION                                                                                                          AS CAPACITYCTPDESCRIPTION 
            ,CAST(T$CATP AS INT)                                                                                                                 AS CAPACITYCTPID 
            ,T$MULT.CONSTANTDESCRIPTION                                                                                                          AS CENTRALMULTISITEPLANNINGDESCRIPTION 
            ,CAST(T$MULT AS INT)                                                                                                                 AS CENTRALMULTISITEPLANNINGID 
            ,T$CHAT.CONSTANTDESCRIPTION                                                                                                          AS CHANNELATPDESCRIPTION 
            ,CAST(T$CHAT AS INT)                                                                                                                 AS CHANNELATPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CLUS)),'')                                                                                         AS CLUSTER 
            ,T$COAT.CONSTANTDESCRIPTION                                                                                                          AS COMPONENTCTPDESCRIPTION 
            ,CAST(T$COAT AS INT)                                                                                                                 AS COMPONENTCTPID 
            ,T$FICA.CONSTANTDESCRIPTION                                                                                                          AS CONSTRAINTDESCRIPTION 
            ,CAST(T$FICA AS INT)                                                                                                                 AS CONSTRAINTID 
            ,T$CRIA.CONSTANTDESCRIPTION                                                                                                          AS CRITICALINCTPDESCRIPTION 
            ,CAST(T$CRIA AS INT)                                                                                                                 AS CRITICALINCTPID 
            ,CAST(T$HOAT AS INT)                                                                                                                 AS CTPTIMEFENCE 
            ,T$CYAT.CONSTANTDESCRIPTION                                                                                                          AS CYCLECTPDESCRIPTION 
            ,CAST(T$CYAT AS INT)                                                                                                                 AS CYCLECTPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ENTU)),'')                                                                                         AS DEFAULTENTERPRISEUNITFORPLANNING 
            ,T$SOUR.CONSTANTDESCRIPTION                                                                                                          AS DEFAULTSUPPLYSOURCEDESCRIPTION 
            ,CAST(T$SOUR AS INT)                                                                                                                 AS DEFAULTSUPPLYSOURCEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWAR)),'')                                                                                         AS DEFAULTWAREHOUSE 
            ,T$DEPD.CONSTANTDESCRIPTION                                                                                                          AS DEPENDENTDEMANDFORECASTDESCRIPTION 
            ,CAST(T$DEPD AS INT)                                                                                                                 AS DEPENDENTDEMANDFORECASTID 
            ,CAST(T$ELTM AS INT)                                                                                                                 AS EXTRALEADTIME 
            ,T$FATP.CONSTANTDESCRIPTION                                                                                                          AS FAMILYCTPDESCRIPTION 
            ,CAST(T$ATHO AS INT)                                                                                                                 AS FAMILYCTPHORIZON 
            ,CAST(T$FATP AS INT)                                                                                                                 AS FAMILYCTPID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$FITE)),'')                                                                                         AS FAMILYITEM 
            ,CAST(T$FASI AS INT)                                                                                                                 AS FAMILYSITE 
            ,CAST(T$RRPS AS NUMERIC(15,2))                                                                                                       AS FIELD53 
            ,CAST(T$FLTM AS INT)                                                                                                                 AS FIXEDLEADTIMEHORIZON 
            ,T$INFO.CONSTANTDESCRIPTION                                                                                                          AS FORECASTBASEDGENERATIONMETHODDESCRIPTION 
            ,CAST(T$INFO AS INT)                                                                                                                 AS FORECASTBASEDGENERATIONMETHODID 
            ,CAST(T$INHO AS INT)                                                                                                                 AS FORECASTHORIZON 
            ,CAST(T$FCTF AS INT)                                                                                                                 AS FORECASTTIMEFENCE 
            ,CAST(T$STOC AS NUMERIC(15,2))                                                                                                       AS INVENTORYONHAND 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$BLIT)),'')                                                                                         AS ITEMWITHOUTPROJECT 
            ,T$OSYS.CONSTANTDESCRIPTION                                                                                                          AS MAINTAINMASTERPLANDESCRIPTION 
            ,CAST(T$OSYS AS INT)                                                                                                                 AS MAINTAINMASTERPLANID 
            ,CAST(T$PHNU AS INT)                                                                                                                 AS MASTERPHASENUMBER 
            ,CAST(T$SPHC AS INT)                                                                                                                 AS MASTERPHASENUMBERPARENT 
            ,CAST(CASE WHEN T$NETD<= '1/1/1970' THEN NULL ELSE T$NETD  END AS DATETIME) AS MASTERPLANNETCHANGEDATE 
            ,T$NETC.CONSTANTDESCRIPTION                                                                                                          AS MASTERPLANNINGNETCHANGEDESCRIPTION 
            ,CAST(T$NETC AS INT)                                                                                                                 AS MASTERPLANNINGNETCHANGEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MRPU)),'')                                                                                         AS MASTERPLANUNIT 
            ,CAST(T$NPHN AS BIGINT)                                                                                                              AS NEGATIVEPHASENUMBER 
            ,T$ONAT.CONSTANTDESCRIPTION                                                                                                          AS ONLINECTPUPDATEDESCRIPTION 
            ,CAST(T$ONAT AS INT)                                                                                                                 AS ONLINECTPUPDATEID 
            ,CAST(T$OTMF AS INT)                                                                                                                 AS ORDER_HORIZON 
            ,T$MRNP.CONSTANTDESCRIPTION                                                                                                          AS ORDER_NETCHANGECAPACITIESDESCRIPTION 
            ,CAST(T$MRNP AS INT)                                                                                                                 AS ORDER_NETCHANGECAPACITIESID 
            ,CAST(CASE WHEN T$MRND<= '1/1/1970' THEN NULL ELSE T$MRND  END AS DATETIME) AS ORDER_NETCHANGEDATE 
            ,T$MRNC.CONSTANTDESCRIPTION                                                                                                          AS ORDER_NETCHANGEDESCRIPTION 
            ,CAST(T$MRNC AS INT)                                                                                                                 AS ORDER_NETCHANGEID 
            ,T$MRNM.CONSTANTDESCRIPTION                                                                                                          AS ORDER_NETCHANGEMATERIALSDESCRIPTION 
            ,CAST(T$MRNM AS INT)                                                                                                                 AS ORDER_NETCHANGEMATERIALSID 
            ,CAST(T$MRPH AS INT)                                                                                                                 AS ORDER_PHASENUMBER 
            ,CAST(T$PHCH AS INT)                                                                                                                 AS ORDER_PHASENUMBERPARENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLNI)),'')                                                                                         AS PLANITEM 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS PLANITEMTEXT 
            ,T$PLIT.CONSTANTDESCRIPTION                                                                                                          AS PLANITEMTYPEDESCRIPTION 
            ,CAST(T$PLIT AS INT)                                                                                                                 AS PLANITEMTYPEID 
            ,CAST(T$PLVL AS TINYINT)                                                                                                             AS PLANLEVEL 
            ,T$PBPL.CONSTANTDESCRIPTION                                                                                                          AS PLANNEDBYBAANSCSPLANNERDESCRIPTION 
            ,CAST(T$PBPL AS INT)                                                                                                                 AS PLANNEDBYBAANSCSPLANNERID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PLID)),'')                                                                                         AS PLANNER 
            ,CAST(T$PTMF AS INT)                                                                                                                 AS PLANNINGHORIZON 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$RPUN)),'')                                                                                         AS PLANUNIT 
            ,CAST(T$PUSH AS INT)                                                                                                                 AS PLANUNITMASTERPHASEPARENT 
            ,CAST(T$PUPH AS INT)                                                                                                                 AS PLANUNITORDERPHASEPARENT 
            ,T$PRIO.CONSTANTDESCRIPTION                                                                                                          AS PRIORITYDESCRIPTION 
            ,CAST(T$PRIO AS INT)                                                                                                                 AS PRIORITYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRJ)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS REFERENCETOTCIBD 
            ,CAST(T$RETF AS INT)                                                                                                                 AS RELEASETIMEFENCE 
            ,CAST(T$TMFC AS INT)                                                                                                                 AS TIMEFENCE 
         
        FROM {{ source("BAAN_ORACLE_LIVE", "TCPRPD100201") }} AS SOURCETABLE  
            /*AUTOMATICUPDATEOFDEMANDFORECAST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUDF 
             ON   T$AUDF.TABLENAME  = 'CPRPD100' 
              AND T$AUDF.COLUMNNAME = 'T$AUDF' 
              AND T$AUDF.CONSTANT   = SOURCETABLE.T$AUDF 
            /*AUTOMATICUPDATEOFINVENTORYPLAN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUIV 
             ON   T$AUIV.TABLENAME  = 'CPRPD100' 
              AND T$AUIV.COLUMNNAME = 'T$AUIV' 
              AND T$AUIV.CONSTANT   = SOURCETABLE.T$AUIV 
            /*AUTOMATICUPDATEOFPRODUCTIONPLAN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUPR 
             ON   T$AUPR.TABLENAME  = 'CPRPD100' 
              AND T$AUPR.COLUMNNAME = 'T$AUPR' 
              AND T$AUPR.CONSTANT   = SOURCETABLE.T$AUPR 
            /*AUTOMATICUPDATEOFPURCHASEPLAN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$AUPU 
             ON   T$AUPU.TABLENAME  = 'CPRPD100' 
              AND T$AUPU.COLUMNNAME = 'T$AUPU' 
              AND T$AUPU.CONSTANT   = SOURCETABLE.T$AUPU 
            /*CAPACITYCTP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CATP 
             ON   T$CATP.TABLENAME  = 'CPRPD100' 
              AND T$CATP.COLUMNNAME = 'T$CATP' 
              AND T$CATP.CONSTANT   = SOURCETABLE.T$CATP 
            /*CENTRALMULTISITEPLANNING*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MULT 
             ON   T$MULT.TABLENAME  = 'CPRPD100' 
              AND T$MULT.COLUMNNAME = 'T$MULT' 
              AND T$MULT.CONSTANT   = SOURCETABLE.T$MULT 
            /*CHANNELATP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CHAT 
             ON   T$CHAT.TABLENAME  = 'CPRPD100' 
              AND T$CHAT.COLUMNNAME = 'T$CHAT' 
              AND T$CHAT.CONSTANT   = SOURCETABLE.T$CHAT 
            /*COMPONENTCTP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$COAT 
             ON   T$COAT.TABLENAME  = 'CPRPD100' 
              AND T$COAT.COLUMNNAME = 'T$COAT' 
              AND T$COAT.CONSTANT   = SOURCETABLE.T$COAT 
            /*CONSTRAINT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FICA 
             ON   T$FICA.TABLENAME  = 'CPRPD100' 
              AND T$FICA.COLUMNNAME = 'T$FICA' 
              AND T$FICA.CONSTANT   = SOURCETABLE.T$FICA 
            /*CRITICALINCTP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CRIA 
             ON   T$CRIA.TABLENAME  = 'CPRPD100' 
              AND T$CRIA.COLUMNNAME = 'T$CRIA' 
              AND T$CRIA.CONSTANT   = SOURCETABLE.T$CRIA 
            /*CYCLECTP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$CYAT 
             ON   T$CYAT.TABLENAME  = 'CPRPD100' 
              AND T$CYAT.COLUMNNAME = 'T$CYAT' 
              AND T$CYAT.CONSTANT   = SOURCETABLE.T$CYAT 
            /*DEFAULTSUPPLYSOURCE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$SOUR 
             ON   T$SOUR.TABLENAME  = 'CPRPD100' 
              AND T$SOUR.COLUMNNAME = 'T$SOUR' 
              AND T$SOUR.CONSTANT   = SOURCETABLE.T$SOUR 
            /*DEPENDENTDEMANDFORECAST*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$DEPD 
             ON   T$DEPD.TABLENAME  = 'CPRPD100' 
              AND T$DEPD.COLUMNNAME = 'T$DEPD' 
              AND T$DEPD.CONSTANT   = SOURCETABLE.T$DEPD 
            /*FAMILYCTP*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$FATP 
             ON   T$FATP.TABLENAME  = 'CPRPD100' 
              AND T$FATP.COLUMNNAME = 'T$FATP' 
              AND T$FATP.CONSTANT   = SOURCETABLE.T$FATP 
            /*FORECASTBASEDGENERATIONMETHOD*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INFO 
             ON   T$INFO.TABLENAME  = 'CPRPD100' 
              AND T$INFO.COLUMNNAME = 'T$INFO' 
              AND T$INFO.CONSTANT   = SOURCETABLE.T$INFO 
            /*MAINTAINMASTERPLAN*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OSYS 
             ON   T$OSYS.TABLENAME  = 'CPRPD100' 
              AND T$OSYS.COLUMNNAME = 'T$OSYS' 
              AND T$OSYS.CONSTANT   = SOURCETABLE.T$OSYS 
            /*MASTERPLANNINGNETCHANGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$NETC 
             ON   T$NETC.TABLENAME  = 'CPRPD100' 
              AND T$NETC.COLUMNNAME = 'T$NETC' 
              AND T$NETC.CONSTANT   = SOURCETABLE.T$NETC 
            /*ONLINECTPUPDATE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$ONAT 
             ON   T$ONAT.TABLENAME  = 'CPRPD100' 
              AND T$ONAT.COLUMNNAME = 'T$ONAT' 
              AND T$ONAT.CONSTANT   = SOURCETABLE.T$ONAT 
            /*ORDERNETCHANGECAPACITIES*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MRNP 
             ON   T$MRNP.TABLENAME  = 'CPRPD100' 
              AND T$MRNP.COLUMNNAME = 'T$MRNP' 
              AND T$MRNP.CONSTANT   = SOURCETABLE.T$MRNP 
            /*ORDERNETCHANGE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MRNC 
             ON   T$MRNC.TABLENAME  = 'CPRPD100' 
              AND T$MRNC.COLUMNNAME = 'T$MRNC' 
              AND T$MRNC.CONSTANT   = SOURCETABLE.T$MRNC 
            /*ORDERNETCHANGEMATERIALS*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MRNM 
             ON   T$MRNM.TABLENAME  = 'CPRPD100' 
              AND T$MRNM.COLUMNNAME = 'T$MRNM' 
              AND T$MRNM.CONSTANT   = SOURCETABLE.T$MRNM 
            /*PLANITEMTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PLIT 
             ON   T$PLIT.TABLENAME  = 'CPRPD100' 
              AND T$PLIT.COLUMNNAME = 'T$PLIT' 
              AND T$PLIT.CONSTANT   = SOURCETABLE.T$PLIT 
            /*PLANNEDBYBAANSCSPLANNER*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PBPL 
             ON   T$PBPL.TABLENAME  = 'CPRPD100' 
              AND T$PBPL.COLUMNNAME = 'T$PBPL' 
              AND T$PBPL.CONSTANT   = SOURCETABLE.T$PBPL 
            /*PRIORITY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$PRIO 
             ON   T$PRIO.TABLENAME  = 'CPRPD100' 
              AND T$PRIO.COLUMNNAME = 'T$PRIO' 
              AND T$PRIO.CONSTANT   = SOURCETABLE.T$PRIO 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.AUTOMATICUPDATEOFDEMANDFORECASTDESCRIPTION AS AUTOMATICUPDATEOFDEMANDFORECASTDESCRIPTION, 
        source_data.AUTOMATICUPDATEOFDEMANDFORECASTID AS AUTOMATICUPDATEOFDEMANDFORECASTID, 
        source_data.AUTOMATICUPDATEOFINVENTORYPLANDESCRIPTION AS AUTOMATICUPDATEOFINVENTORYPLANDESCRIPTION, 
        source_data.AUTOMATICUPDATEOFINVENTORYPLANID AS AUTOMATICUPDATEOFINVENTORYPLANID, 
        source_data.AUTOMATICUPDATEOFPRODUCTIONPLANDESCRIPTION AS AUTOMATICUPDATEOFPRODUCTIONPLANDESCRIPTION, 
        source_data.AUTOMATICUPDATEOFPRODUCTIONPLANID AS AUTOMATICUPDATEOFPRODUCTIONPLANID, 
        source_data.AUTOMATICUPDATEOFPURCHASEPLANDESCRIPTION AS AUTOMATICUPDATEOFPURCHASEPLANDESCRIPTION, 
        source_data.AUTOMATICUPDATEOFPURCHASEPLANID AS AUTOMATICUPDATEOFPURCHASEPLANID, 
        source_data.CAPACITYCTPDESCRIPTION AS CAPACITYCTPDESCRIPTION, 
        source_data.CAPACITYCTPID AS CAPACITYCTPID, 
        source_data.CENTRALMULTISITEPLANNINGDESCRIPTION AS CENTRALMULTISITEPLANNINGDESCRIPTION, 
        source_data.CENTRALMULTISITEPLANNINGID AS CENTRALMULTISITEPLANNINGID, 
        source_data.CHANNELATPDESCRIPTION AS CHANNELATPDESCRIPTION, 
        source_data.CHANNELATPID AS CHANNELATPID, 
        source_data.CLUSTER AS CLUSTER, 
        source_data.COMPONENTCTPDESCRIPTION AS COMPONENTCTPDESCRIPTION, 
        source_data.COMPONENTCTPID AS COMPONENTCTPID, 
        source_data.CONSTRAINTDESCRIPTION AS CONSTRAINTDESCRIPTION, 
        source_data.CONSTRAINTID AS CONSTRAINTID, 
        source_data.CRITICALINCTPDESCRIPTION AS CRITICALINCTPDESCRIPTION, 
        source_data.CRITICALINCTPID AS CRITICALINCTPID, 
        source_data.CTPTIMEFENCE AS CTPTIMEFENCE, 
        source_data.CYCLECTPDESCRIPTION AS CYCLECTPDESCRIPTION, 
        source_data.CYCLECTPID AS CYCLECTPID, 
        source_data.DEFAULTENTERPRISEUNITFORPLANNING AS DEFAULTENTERPRISEUNITFORPLANNING, 
        source_data.DEFAULTSUPPLYSOURCEDESCRIPTION AS DEFAULTSUPPLYSOURCEDESCRIPTION, 
        source_data.DEFAULTSUPPLYSOURCEID AS DEFAULTSUPPLYSOURCEID, 
        source_data.DEFAULTWAREHOUSE AS DEFAULTWAREHOUSE, 
        source_data.DEPENDENTDEMANDFORECASTDESCRIPTION AS DEPENDENTDEMANDFORECASTDESCRIPTION, 
        source_data.DEPENDENTDEMANDFORECASTID AS DEPENDENTDEMANDFORECASTID, 
        source_data.EXTRALEADTIME AS EXTRALEADTIME, 
        source_data.FAMILYCTPDESCRIPTION AS FAMILYCTPDESCRIPTION, 
        source_data.FAMILYCTPHORIZON AS FAMILYCTPHORIZON, 
        source_data.FAMILYCTPID AS FAMILYCTPID, 
        source_data.FAMILYITEM AS FAMILYITEM, 
        source_data.FAMILYSITE AS FAMILYSITE, 
        source_data.FIELD53 AS FIELD53, 
        source_data.FIXEDLEADTIMEHORIZON AS FIXEDLEADTIMEHORIZON, 
        source_data.FORECASTBASEDGENERATIONMETHODDESCRIPTION AS FORECASTBASEDGENERATIONMETHODDESCRIPTION, 
        source_data.FORECASTBASEDGENERATIONMETHODID AS FORECASTBASEDGENERATIONMETHODID, 
        source_data.FORECASTHORIZON AS FORECASTHORIZON, 
        source_data.FORECASTTIMEFENCE AS FORECASTTIMEFENCE, 
        source_data.INVENTORYONHAND AS INVENTORYONHAND, 
        source_data.ITEMWITHOUTPROJECT AS ITEMWITHOUTPROJECT, 
        source_data.MAINTAINMASTERPLANDESCRIPTION AS MAINTAINMASTERPLANDESCRIPTION, 
        source_data.MAINTAINMASTERPLANID AS MAINTAINMASTERPLANID, 
        source_data.MASTERPHASENUMBER AS MASTERPHASENUMBER, 
        source_data.MASTERPHASENUMBERPARENT AS MASTERPHASENUMBERPARENT, 
        source_data.MASTERPLANNETCHANGEDATE AS MASTERPLANNETCHANGEDATE, 
        source_data.MASTERPLANNINGNETCHANGEDESCRIPTION AS MASTERPLANNINGNETCHANGEDESCRIPTION, 
        source_data.MASTERPLANNINGNETCHANGEID AS MASTERPLANNINGNETCHANGEID, 
        source_data.MASTERPLANUNIT AS MASTERPLANUNIT, 
        source_data.NEGATIVEPHASENUMBER AS NEGATIVEPHASENUMBER, 
        source_data.ONLINECTPUPDATEDESCRIPTION AS ONLINECTPUPDATEDESCRIPTION, 
        source_data.ONLINECTPUPDATEID AS ONLINECTPUPDATEID, 
        source_data.ORDER_HORIZON AS ORDER_HORIZON, 
        source_data.ORDER_NETCHANGECAPACITIESDESCRIPTION AS ORDER_NETCHANGECAPACITIESDESCRIPTION, 
        source_data.ORDER_NETCHANGECAPACITIESID AS ORDER_NETCHANGECAPACITIESID, 
        source_data.ORDER_NETCHANGEDATE AS ORDER_NETCHANGEDATE, 
        source_data.ORDER_NETCHANGEDESCRIPTION AS ORDER_NETCHANGEDESCRIPTION, 
        source_data.ORDER_NETCHANGEID AS ORDER_NETCHANGEID, 
        source_data.ORDER_NETCHANGEMATERIALSDESCRIPTION AS ORDER_NETCHANGEMATERIALSDESCRIPTION, 
        source_data.ORDER_NETCHANGEMATERIALSID AS ORDER_NETCHANGEMATERIALSID, 
        source_data.ORDER_PHASENUMBER AS ORDER_PHASENUMBER, 
        source_data.ORDER_PHASENUMBERPARENT AS ORDER_PHASENUMBERPARENT, 
        source_data.PLANITEM AS PLANITEM, 
        source_data.PLANITEMTEXT AS PLANITEMTEXT, 
        source_data.PLANITEMTYPEDESCRIPTION AS PLANITEMTYPEDESCRIPTION, 
        source_data.PLANITEMTYPEID AS PLANITEMTYPEID, 
        source_data.PLANLEVEL AS PLANLEVEL, 
        source_data.PLANNEDBYBAANSCSPLANNERDESCRIPTION AS PLANNEDBYBAANSCSPLANNERDESCRIPTION, 
        source_data.PLANNEDBYBAANSCSPLANNERID AS PLANNEDBYBAANSCSPLANNERID, 
        source_data.PLANNER AS PLANNER, 
        source_data.PLANNINGHORIZON AS PLANNINGHORIZON, 
        source_data.PLANUNIT AS PLANUNIT, 
        source_data.PLANUNITMASTERPHASEPARENT AS PLANUNITMASTERPHASEPARENT, 
        source_data.PLANUNITORDERPHASEPARENT AS PLANUNITORDERPHASEPARENT, 
        source_data.PRIORITYDESCRIPTION AS PRIORITYDESCRIPTION, 
        source_data.PRIORITYID AS PRIORITYID, 
        source_data.PROJECT AS PROJECT, 
        source_data.REFERENCETOTCIBD AS REFERENCETOTCIBD, 
        source_data.RELEASETIMEFENCE AS RELEASETIMEFENCE, 
        source_data.TIMEFENCE AS TIMEFENCE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(AUTOMATICUPDATEOFDEMANDFORECASTDESCRIPTION as VARCHAR(16777216)) as AUTOMATICUPDATEOFDEMANDFORECASTDESCRIPTION,
        cast(AUTOMATICUPDATEOFDEMANDFORECASTID as NUMBER(38,0)) as AUTOMATICUPDATEOFDEMANDFORECASTID,
        cast(AUTOMATICUPDATEOFINVENTORYPLANDESCRIPTION as VARCHAR(16777216)) as AUTOMATICUPDATEOFINVENTORYPLANDESCRIPTION,
        cast(AUTOMATICUPDATEOFINVENTORYPLANID as NUMBER(38,0)) as AUTOMATICUPDATEOFINVENTORYPLANID,
        cast(AUTOMATICUPDATEOFPRODUCTIONPLANDESCRIPTION as VARCHAR(16777216)) as AUTOMATICUPDATEOFPRODUCTIONPLANDESCRIPTION,
        cast(AUTOMATICUPDATEOFPRODUCTIONPLANID as NUMBER(38,0)) as AUTOMATICUPDATEOFPRODUCTIONPLANID,
        cast(AUTOMATICUPDATEOFPURCHASEPLANDESCRIPTION as VARCHAR(16777216)) as AUTOMATICUPDATEOFPURCHASEPLANDESCRIPTION,
        cast(AUTOMATICUPDATEOFPURCHASEPLANID as NUMBER(38,0)) as AUTOMATICUPDATEOFPURCHASEPLANID,
        cast(CAPACITYCTPDESCRIPTION as VARCHAR(16777216)) as CAPACITYCTPDESCRIPTION,
        cast(CAPACITYCTPID as NUMBER(38,0)) as CAPACITYCTPID,
        cast(CENTRALMULTISITEPLANNINGDESCRIPTION as VARCHAR(16777216)) as CENTRALMULTISITEPLANNINGDESCRIPTION,
        cast(CENTRALMULTISITEPLANNINGID as NUMBER(38,0)) as CENTRALMULTISITEPLANNINGID,
        cast(CHANNELATPDESCRIPTION as VARCHAR(16777216)) as CHANNELATPDESCRIPTION,
        cast(CHANNELATPID as NUMBER(38,0)) as CHANNELATPID,
        cast(CLUSTER as VARCHAR(3)) as CLUSTER,
        cast(COMPONENTCTPDESCRIPTION as VARCHAR(16777216)) as COMPONENTCTPDESCRIPTION,
        cast(COMPONENTCTPID as NUMBER(38,0)) as COMPONENTCTPID,
        cast(CONSTRAINTDESCRIPTION as VARCHAR(16777216)) as CONSTRAINTDESCRIPTION,
        cast(CONSTRAINTID as NUMBER(38,0)) as CONSTRAINTID,
        cast(CRITICALINCTPDESCRIPTION as VARCHAR(16777216)) as CRITICALINCTPDESCRIPTION,
        cast(CRITICALINCTPID as NUMBER(38,0)) as CRITICALINCTPID,
        cast(CTPTIMEFENCE as NUMBER(38,0)) as CTPTIMEFENCE,
        cast(CYCLECTPDESCRIPTION as VARCHAR(16777216)) as CYCLECTPDESCRIPTION,
        cast(CYCLECTPID as NUMBER(38,0)) as CYCLECTPID,
        cast(DEFAULTENTERPRISEUNITFORPLANNING as VARCHAR(6)) as DEFAULTENTERPRISEUNITFORPLANNING,
        cast(DEFAULTSUPPLYSOURCEDESCRIPTION as VARCHAR(16777216)) as DEFAULTSUPPLYSOURCEDESCRIPTION,
        cast(DEFAULTSUPPLYSOURCEID as NUMBER(38,0)) as DEFAULTSUPPLYSOURCEID,
        cast(DEFAULTWAREHOUSE as VARCHAR(6)) as DEFAULTWAREHOUSE,
        cast(DEPENDENTDEMANDFORECASTDESCRIPTION as VARCHAR(16777216)) as DEPENDENTDEMANDFORECASTDESCRIPTION,
        cast(DEPENDENTDEMANDFORECASTID as NUMBER(38,0)) as DEPENDENTDEMANDFORECASTID,
        cast(EXTRALEADTIME as NUMBER(38,0)) as EXTRALEADTIME,
        cast(FAMILYCTPDESCRIPTION as VARCHAR(16777216)) as FAMILYCTPDESCRIPTION,
        cast(FAMILYCTPHORIZON as NUMBER(38,0)) as FAMILYCTPHORIZON,
        cast(FAMILYCTPID as NUMBER(38,0)) as FAMILYCTPID,
        cast(FAMILYITEM as VARCHAR(50)) as FAMILYITEM,
        cast(FAMILYSITE as NUMBER(38,0)) as FAMILYSITE,
        cast(FIELD53 as NUMBER(15,2)) as FIELD53,
        cast(FIXEDLEADTIMEHORIZON as NUMBER(38,0)) as FIXEDLEADTIMEHORIZON,
        cast(FORECASTBASEDGENERATIONMETHODDESCRIPTION as VARCHAR(16777216)) as FORECASTBASEDGENERATIONMETHODDESCRIPTION,
        cast(FORECASTBASEDGENERATIONMETHODID as NUMBER(38,0)) as FORECASTBASEDGENERATIONMETHODID,
        cast(FORECASTHORIZON as NUMBER(38,0)) as FORECASTHORIZON,
        cast(FORECASTTIMEFENCE as NUMBER(38,0)) as FORECASTTIMEFENCE,
        cast(INVENTORYONHAND as NUMBER(15,2)) as INVENTORYONHAND,
        cast(ITEMWITHOUTPROJECT as VARCHAR(50)) as ITEMWITHOUTPROJECT,
        cast(MAINTAINMASTERPLANDESCRIPTION as VARCHAR(16777216)) as MAINTAINMASTERPLANDESCRIPTION,
        cast(MAINTAINMASTERPLANID as NUMBER(38,0)) as MAINTAINMASTERPLANID,
        cast(MASTERPHASENUMBER as NUMBER(38,0)) as MASTERPHASENUMBER,
        cast(MASTERPHASENUMBERPARENT as NUMBER(38,0)) as MASTERPHASENUMBERPARENT,
        cast(MASTERPLANNETCHANGEDATE as TIMESTAMP_NTZ(9)) as MASTERPLANNETCHANGEDATE,
        cast(MASTERPLANNINGNETCHANGEDESCRIPTION as VARCHAR(16777216)) as MASTERPLANNINGNETCHANGEDESCRIPTION,
        cast(MASTERPLANNINGNETCHANGEID as NUMBER(38,0)) as MASTERPLANNINGNETCHANGEID,
        cast(MASTERPLANUNIT as VARCHAR(3)) as MASTERPLANUNIT,
        cast(NEGATIVEPHASENUMBER as NUMBER(38,0)) as NEGATIVEPHASENUMBER,
        cast(ONLINECTPUPDATEDESCRIPTION as VARCHAR(16777216)) as ONLINECTPUPDATEDESCRIPTION,
        cast(ONLINECTPUPDATEID as NUMBER(38,0)) as ONLINECTPUPDATEID,
        cast(ORDER_HORIZON as NUMBER(38,0)) as ORDER_HORIZON,
        cast(ORDER_NETCHANGECAPACITIESDESCRIPTION as VARCHAR(16777216)) as ORDER_NETCHANGECAPACITIESDESCRIPTION,
        cast(ORDER_NETCHANGECAPACITIESID as NUMBER(38,0)) as ORDER_NETCHANGECAPACITIESID,
        cast(ORDER_NETCHANGEDATE as TIMESTAMP_NTZ(9)) as ORDER_NETCHANGEDATE,
        cast(ORDER_NETCHANGEDESCRIPTION as VARCHAR(16777216)) as ORDER_NETCHANGEDESCRIPTION,
        cast(ORDER_NETCHANGEID as NUMBER(38,0)) as ORDER_NETCHANGEID,
        cast(ORDER_NETCHANGEMATERIALSDESCRIPTION as VARCHAR(16777216)) as ORDER_NETCHANGEMATERIALSDESCRIPTION,
        cast(ORDER_NETCHANGEMATERIALSID as NUMBER(38,0)) as ORDER_NETCHANGEMATERIALSID,
        cast(ORDER_PHASENUMBER as NUMBER(38,0)) as ORDER_PHASENUMBER,
        cast(ORDER_PHASENUMBERPARENT as NUMBER(38,0)) as ORDER_PHASENUMBERPARENT,
        cast(PLANITEM as VARCHAR(50)) as PLANITEM,
        cast(PLANITEMTEXT as NUMBER(38,10)) as PLANITEMTEXT,
        cast(PLANITEMTYPEDESCRIPTION as VARCHAR(16777216)) as PLANITEMTYPEDESCRIPTION,
        cast(PLANITEMTYPEID as NUMBER(38,0)) as PLANITEMTYPEID,
        cast(PLANLEVEL as NUMBER(38,0)) as PLANLEVEL,
        cast(PLANNEDBYBAANSCSPLANNERDESCRIPTION as VARCHAR(16777216)) as PLANNEDBYBAANSCSPLANNERDESCRIPTION,
        cast(PLANNEDBYBAANSCSPLANNERID as NUMBER(38,0)) as PLANNEDBYBAANSCSPLANNERID,
        cast(PLANNER as VARCHAR(6)) as PLANNER,
        cast(PLANNINGHORIZON as NUMBER(38,0)) as PLANNINGHORIZON,
        cast(PLANUNIT as VARCHAR(3)) as PLANUNIT,
        cast(PLANUNITMASTERPHASEPARENT as NUMBER(38,0)) as PLANUNITMASTERPHASEPARENT,
        cast(PLANUNITORDERPHASEPARENT as NUMBER(38,0)) as PLANUNITORDERPHASEPARENT,
        cast(PRIORITYDESCRIPTION as VARCHAR(16777216)) as PRIORITYDESCRIPTION,
        cast(PRIORITYID as NUMBER(38,0)) as PRIORITYID,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(REFERENCETOTCIBD as VARCHAR(47)) as REFERENCETOTCIBD,
        cast(RELEASETIMEFENCE as NUMBER(38,0)) as RELEASETIMEFENCE,
        cast(TIMEFENCE as NUMBER(38,0)) as TIMEFENCE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data