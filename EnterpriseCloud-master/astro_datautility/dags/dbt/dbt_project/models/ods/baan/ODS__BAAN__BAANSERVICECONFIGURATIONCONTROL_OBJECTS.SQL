/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_OBJECTS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_OBJECTS.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_OBJECTS 
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
    alias='BAANSERVICECONFIGURATIONCONTROL_OBJECTS',
    unique_key = ['CONFIGURATION',
    'OBJECT',
    'OBJECTNUMBER']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                        AS _CAPTUREDATETIME 
            ,201                                                                                                                                   AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ACCM$U")),'')                                                                                       AS ACCEPTANCEDELAYCOMMENTS 
            ,CAST(CASE WHEN "T$AAPD$U"<= '1/1/1970' THEN NULL ELSE "T$AAPD$U" END AS DATE)                                                         AS ACTAPPROVALDT 
            ,CAST(CASE WHEN "T$ACAD$U"<= '1/1/1970' THEN NULL ELSE "T$ACAD$U" END AS DATE)                                                         AS ACTCONDITIONALACCEPTDT 
            ,CAST(CASE WHEN "T$AEFD$U"<= '1/1/1970' THEN NULL ELSE "T$AEFD$U" END AS DATE)                                                         AS ACTEXITFACTORYDT 
            ,CAST(CASE WHEN "T$AMSD$U"<= '1/1/1970' THEN NULL ELSE "T$AMSD$U" END AS DATE)                                                         AS ACTFINALMACHINESPECDT 
            ,CAST(CASE WHEN "T$AFOD$U"<= '1/1/1970' THEN NULL ELSE "T$AFOD$U" END AS DATE)                                                         AS ACTFOBDT 
            ,CAST(CASE WHEN "T$AHED$U"<= '1/1/1970' THEN NULL ELSE "T$AHED$U" END AS DATE)                                                         AS ACTHWSTARTUPENDDT 
            ,CAST(CASE WHEN "T$AHSD$U"<= '1/1/1970' THEN NULL ELSE "T$AHSD$U" END AS DATE)                                                         AS ACTHWSTARTUPSTDT 
            ,CAST(CASE WHEN "T$AIED$U"<= '1/1/1970' THEN NULL ELSE "T$AIED$U" END AS DATE)                                                         AS ACTINSTALLATIONENDDT 
            ,CAST(CASE WHEN "T$AISD$U"<= '1/1/1970' THEN NULL ELSE "T$AISD$U" END AS DATE)                                                         AS ACTINSTALLATIONSTDT 
            ,CAST(CASE WHEN "T$AMRD$U"<= '1/1/1970' THEN NULL ELSE "T$AMRD$U" END AS DATE)                                                         AS ACTMACHINEINACTIVEDT 
            ,CAST(CASE WHEN "T$AOSD$U"<= '1/1/1970' THEN NULL ELSE "T$AOSD$U" END AS DATE)                                                         AS ACTONSITEDT 
            ,CAST(CASE WHEN "T$APED$U"<= '1/1/1970' THEN NULL ELSE "T$APED$U" END AS DATE)                                                         AS ACTPRE_WARRANTYENDDT 
            ,CAST(CASE WHEN "T$APSD$U"<= '1/1/1970' THEN NULL ELSE "T$APSD$U" END AS DATE)                                                         AS ACTPRE_WARRANTYSTDT 
            ,CAST(CASE WHEN "T$ASTD$U"<= '1/1/1970' THEN NULL ELSE "T$ASTD$U" END AS DATE)                                                         AS ACTSETUP_AND_TESTINGENDDT 
            ,CAST(CASE WHEN "T$AS1D$U"<= '1/1/1970' THEN NULL ELSE "T$AS1D$U" END AS DATE)                                                         AS ACTSL1ENDDT 
            ,CAST(CASE WHEN "T$AS2D$U"<= '1/1/1970' THEN NULL ELSE "T$AS2D$U" END AS DATE)                                                         AS ACTSL2ENDDT 
            ,CAST(CASE WHEN "T$ASAD$U"<= '1/1/1970' THEN NULL ELSE "T$ASAD$U" END AS DATE)                                                         AS ACTSYSTEMACCEPTDT 
            ,CAST(CASE WHEN "T$AQED$U"<= '1/1/1970' THEN NULL ELSE "T$AQED$U" END AS DATE)                                                         AS ACTTELPROCQUALSENDDT 
            ,CAST(CASE WHEN "T$AQSD$U"<= '1/1/1970' THEN NULL ELSE "T$AQSD$U" END AS DATE)                                                         AS ACTTELPROCQUALSSTDT 
            ,CAST(CASE WHEN "T$ATED$U"<= '1/1/1970' THEN NULL ELSE "T$ATED$U" END AS DATE)                                                         AS ACTTRAININGCREDITEXPDT 
            ,CAST(CASE WHEN "T$AWED$U"<= '1/1/1970' THEN NULL ELSE "T$AWED$U" END AS DATE)                                                         AS ACTWARRANTYENDDDAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BLDN$U")),'')                                                                                       AS BUILDNO 
            ,CAST("T$BUIN$U" AS BIGINT)                                                                                                            AS BUSINESSINQUIRYNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$OTBP)),'')                                                                                         AS BUYFROMBUSINESSPARTNER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCAL)),'')                                                                                         AS CALENDAR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COMM$U")),'')                                                                                       AS COMMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$IDSC)),'')                                                                                         AS COMPONENTINDICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCFG)),'')                                                                                         AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CCNT)),'')                                                                                         AS CONTACT 
            ,CAST(T$COUN AS NUMERIC(15,2))                                                                                                       AS COUNTERREADING 
            ,T$INCC.CONSTANTDESCRIPTION                                                                                                          AS COVEREDBYCONTRACTDESCRIPTION 
            ,CAST(T$INCC AS INT)                                                                                                                 AS COVEREDBYCONTRACTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CUPO$U")),'')                                                                                       AS CUSTPURCHASEORDER 
            ,CAST(CASE WHEN T$DLDT<= '1/1/1970' THEN NULL ELSE T$DLDT END AS DATE)                                                             AS DELIVERYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$ITEM)),'')                                                                                         AS DERIVEDFROMITEM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DESC)),'')                                                                                         AS DESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSPA)),'')                                                                                         AS ELEMENTACTIVITY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$EMPN$U")),'')                                                                                       AS EMPLOYEENUMBER 
            ,"T$EVAL$U".CONSTANTDESCRIPTION                                                                                                        AS EVALUATIONTOOLSDESCRIPTION 
            ,CAST("T$EVAL$U" AS INT)                                                                                                               AS EVALUATIONTOOLSID 
            ,"T$EXPR$U".CONSTANTDESCRIPTION                                                                                                        AS EXPIREDDESCRIPTION 
            ,CAST("T$EXPR$U" AS INT)                                                                                                               AS EXPIREDID 
            ,CAST(CASE WHEN "T$EXDT$U"<= '1/1/1970' THEN NULL ELSE "T$EXDT$U" END AS DATE)                                                         AS EXPIRYDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$FACT$U")),'')                                                                                       AS FACTORY 
            ,"T$FRFT$U".CONSTANTDESCRIPTION                                                                                                        AS FRFTOOLDESCRIPTION 
            ,CAST("T$FRFT$U" AS INT)                                                                                                               AS FRFTOOLID 
            ,SOURCETABLE.T$TXTA   /* TEXT */                                                                                                     AS GENERALTEXT 
            ,CAST(CASE WHEN T$INDT<= '1/1/1970' THEN NULL ELSE T$INDT END AS DATE)                                                             AS INSTALLATIONDATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CDEL)),'')                                                                                         AS LOCATIONADDRESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$LOCI)),'')                                                                                         AS LOCATIONDESCRIPTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$MCNO)),'')                                                                                         AS MACHINE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MASN$U")),'')                                                                                       AS MACHINESPECNUMBER 
            ,T$MANU.CONSTANTDESCRIPTION                                                                                                          AS MANUFACTUREDBYDESCRIPTION 
            ,CAST(T$MANU AS INT)                                                                                                                 AS MANUFACTUREDBYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCB)),'')                                                                                         AS MATERIAL 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMEA)),'')                                                                                         AS MEASUREMENTTYPE 
            ,T$MOBL.CONSTANTDESCRIPTION                                                                                                          AS MOBILEOBJECTDESCRIPTION 
            ,CAST(T$MOBL AS INT)                                                                                                                 AS MOBILEOBJECTID 
            ,CAST(T$MTHC AS TINYINT)                                                                                                             AS MONTHOFCONSTRUCTION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MONM$U")),'')                                                                                       AS MPIMODELNAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CROB)),'')                                                                                         AS OBJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$COGR)),'')                                                                                         AS OBJECTGROUP 
            ,CAST(T$OSEQ AS INT)                                                                                                                 AS OBJECTNUMBER 
            ,CAST(T$PRIO AS TINYINT)                                                                                                             AS OBJECTPRIORITY 
            ,T$OBTP.CONSTANTDESCRIPTION                                                                                                          AS OBJECTTYPEDESCRIPTION 
            ,CAST(T$OBTP AS INT)                                                                                                                 AS OBJECTTYPEID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$EMNO)),'')                                                                                         AS PREFERREDSERVICEENGINEER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PROC$U")),'')                                                                                       AS PROCESS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CPRO)),'')                                                                                         AS PROJECT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$PRNO)),'')                                                                                         AS PURCHASEORDER 
            ,CAST(T$PPNO AS INT)                                                                                                                 AS PURCHASEORDERPOS 
            ,CAST(T$PRIP AS NUMERIC(15,2))                                                                                                       AS PURCHASEPRICE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$RADE$U")),'')                                                                                       AS REASONACCEPTDELAYCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$RADT$U")),'')                                                                                       AS REASONACCEPTDELAYTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$REMR$U")),'')                                                                                       AS REASONMACHINERELOCATED 
            ,CAST(CASE WHEN T$CNDT<= '1/1/1970' THEN NULL ELSE T$CNDT  END AS DATETIME) AS REGISTRATIONTIME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$REVI)),'')                                                                                         AS REVISION 
            ,CAST(CASE WHEN "T$AIND$U"<= '1/1/1970' THEN NULL ELSE "T$AIND$U" END AS DATE)                                                         AS SALESFORECASTDT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SRNO)),'')                                                                                         AS SALESORDER 
            ,CAST(T$SPNO AS INT)                                                                                                                 AS SALESORDERPOS 
            ,CAST(CASE WHEN "T$CQSD$U"<= '1/1/1970' THEN NULL ELSE "T$CQSD$U" END AS DATE)                                                         AS SCHCUSTPROCQUALSSTDT 
            ,CAST(CASE WHEN "T$SHED$U"<= '1/1/1970' THEN NULL ELSE "T$SHED$U" END AS DATE)                                                         AS SCHHWSTARTUPENDDT 
            ,CAST(CASE WHEN "T$SHSD$U"<= '1/1/1970' THEN NULL ELSE "T$SHSD$U" END AS DATE)                                                         AS SCHHWSTARTUPSTDT 
            ,CAST(CASE WHEN "T$SIED$U"<= '1/1/1970' THEN NULL ELSE "T$SIED$U" END AS DATE)                                                         AS SCHINSTALLATIONENDDT 
            ,CAST(CASE WHEN "T$SISD$U"<= '1/1/1970' THEN NULL ELSE "T$SISD$U" END AS DATE)                                                         AS SCHINSTALLATIONSTDT 
            ,CAST(CASE WHEN "T$RODD$U"<= '1/1/1970' THEN NULL ELSE "T$RODD$U" END AS DATE)                                                         AS SCHONDOCKDT 
            ,CAST(CASE WHEN "T$SSTD$U"<= '1/1/1970' THEN NULL ELSE "T$SSTD$U" END AS DATE)                                                         AS SCHSETUP_AND_TESTINGENDDT 
            ,CAST(CASE WHEN "T$SS1D$U"<= '1/1/1970' THEN NULL ELSE "T$SS1D$U" END AS DATE)                                                         AS SCHSL1ENDDT 
            ,CAST(CASE WHEN "T$SS2D$U"<= '1/1/1970' THEN NULL ELSE "T$SS2D$U" END AS DATE)                                                         AS SCHSL2ENDDT 
            ,CAST(CASE WHEN "T$SACD$U"<= '1/1/1970' THEN NULL ELSE "T$SACD$U" END AS DATE)                                                         AS SCHSYSTEMACCEPTDT 
            ,CAST(CASE WHEN "T$SQED$U"<= '1/1/1970' THEN NULL ELSE "T$SQED$U" END AS DATE)                                                         AS SCHTELPROCQUALSENDDT 
            ,CAST(CASE WHEN "T$SQSD$U"<= '1/1/1970' THEN NULL ELSE "T$SQSD$U" END AS DATE)                                                         AS SCHTELPROCQUALSSTDT 
            ,CAST(CASE WHEN "T$SWED$U"<= '1/1/1970' THEN NULL ELSE "T$SWED$U" END AS DATE)                                                         AS SCHWARRANTYENDDT 
            ,CAST(CASE WHEN "T$SWSD$U"<= '1/1/1970' THEN NULL ELSE "T$SWSD$U" END AS DATE)                                                         AS SCHWARRANTYSTDT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$SEAR)),'')                                                                                         AS SEARCHARGUMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CSER)),'')                                                                                         AS SERIALNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCC)),'')                                                                                         AS SIZE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$REMT$U")),'')                                                                                       AS SOLDBASISREVENUEMETHOD 
            ,SOURCETABLE.T$TXTC   /* TEXT */                                                                                                     AS SPECIFICATIONTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$DSCD)),'')                                                                                         AS STANDARD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SUNO$U")),'')                                                                                       AS SUPPLIERCODETELBU 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SWLH$U")),'')                                                                                       AS SWLHMODELNAME 
            ,"T$STAT$U".CONSTANTDESCRIPTION                                                                                                        AS SYSTEMSTATUSDESCRIPTION 
            ,CAST("T$STAT$U" AS INT)                                                                                                               AS SYSTEMSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CMNF)),'')                                                                                         AS TCMCS060CMNF 
            ,SOURCETABLE.T$TXTB   /* TEXT */                                                                                                     AS TECHNICALTEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CONF$U")),'')                                                                                       AS TELCONFIGURATIONID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TESO$U")),'')                                                                                       AS TELSALESORDERNUMBER 
            ,"T$TWCA$U".CONSTANTDESCRIPTION                                                                                                        AS TELWTYCHANGEAPPROVALDESCRIPTION 
            ,CAST("T$TWCA$U" AS INT)                                                                                                               AS TELWTYCHANGEAPPROVALID 
            ,CAST(T$TERM AS BIGINT)                                                                                                              AS TERMID 
            ,CAST(T$TNUM AS BIGINT)                                                                                                              AS TOOLNUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TTYP)),'')                                                                                         AS TOOLTYPE 
            ,CAST("T$TRCA$U" AS INT)                                                                                                               AS TRAININGCREDITSAVAILABLE 
            ,CAST("T$TRNC$U" AS INT)                                                                                                               AS TRAININGDAYSSOLD 
            ,"T$TRNF$U".CONSTANTDESCRIPTION                                                                                                        AS TRANSFERREDDESCRIPTION 
            ,CAST("T$TRNF$U" AS INT)                                                                                                               AS TRANSFERREDID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$TDSC)),'')                                                                                         AS TYPEINDICATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CUSC)),'')                                                                                         AS USAGECLASS 
            ,"T$USED$U".CONSTANTDESCRIPTION                                                                                                        AS USEDEQUIPMENTDESCRIPTION 
            ,CAST("T$USED$U" AS INT)                                                                                                               AS USEDEQUIPMENTID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WFRS$U")),'')                                                                                       AS WAFERSIZE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE.T$CWTE)),'')                                                                                         AS WARRANTY 
            ,CAST(T$WGHT AS NUMERIC(15,2))                                                                                                       AS WEIGHT 
            ,CAST(T$YRCN AS INT)                                                                                                                 AS YEAROFCONSTRUCTION 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG200201") }} AS SOURCETABLE  
            /*COVEREDBYCONTRACT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$INCC 
             ON   T$INCC.TABLENAME  = 'TSCFG200' 
              AND T$INCC.COLUMNNAME = 'T$INCC' 
              AND T$INCC.CONSTANT   = SOURCETABLE.T$INCC 
            /*EVALUATIONTOOLSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EVAL$U" 
             ON   "T$EVAL$U".TABLENAME  = 'TSCFG200' 
              AND "T$EVAL$U".COLUMNNAME = 'T$EVAL.U' 
              AND "T$EVAL$U".CONSTANT   = SOURCETABLE."T$EVAL$U" 
            /*EXPIREDU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$EXPR$U" 
             ON   "T$EXPR$U".TABLENAME  = 'TSCFG200' 
              AND "T$EXPR$U".COLUMNNAME = 'T$EXPR.U' 
              AND "T$EXPR$U".CONSTANT   = SOURCETABLE."T$EXPR$U" 
            /*FRFTOOLU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$FRFT$U" 
             ON   "T$FRFT$U".TABLENAME  = 'TSCFG200' 
              AND "T$FRFT$U".COLUMNNAME = 'T$FRFT.U' 
              AND "T$FRFT$U".CONSTANT   = SOURCETABLE."T$FRFT$U" 
            /*MANUFACTUREDBY*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MANU 
             ON   T$MANU.TABLENAME  = 'TSCFG200' 
              AND T$MANU.COLUMNNAME = 'T$MANU' 
              AND T$MANU.CONSTANT   = SOURCETABLE.T$MANU 
            /*MOBILEOBJECT*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$MOBL 
             ON   T$MOBL.TABLENAME  = 'TSCFG200' 
              AND T$MOBL.COLUMNNAME = 'T$MOBL' 
              AND T$MOBL.CONSTANT   = SOURCETABLE.T$MOBL 
            /*OBJECTTYPE*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS T$OBTP 
             ON   T$OBTP.TABLENAME  = 'TSCFG200' 
              AND T$OBTP.COLUMNNAME = 'T$OBTP' 
              AND T$OBTP.CONSTANT   = SOURCETABLE.T$OBTP 
            /*SYSTEMSTATUSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$STAT$U" 
             ON   "T$STAT$U".TABLENAME  = 'TSCFG200' 
              AND "T$STAT$U".COLUMNNAME = 'T$STAT.U' 
              AND "T$STAT$U".CONSTANT   = SOURCETABLE."T$STAT$U" 
            /*TELWTYCHANGEAPPROVALU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$TWCA$U" 
             ON   "T$TWCA$U".TABLENAME  = 'TSCFG200' 
              AND "T$TWCA$U".COLUMNNAME = 'T$TWCA.U' 
              AND "T$TWCA$U".CONSTANT   = SOURCETABLE."T$TWCA$U" 
            /*TRANSFERREDU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$TRNF$U" 
             ON   "T$TRNF$U".TABLENAME  = 'TSCFG200' 
              AND "T$TRNF$U".COLUMNNAME = 'T$TRNF.U' 
              AND "T$TRNF$U".CONSTANT   = SOURCETABLE."T$TRNF$U" 
            /*USEDEQUIPMENTU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$USED$U" 
             ON   "T$USED$U".TABLENAME  = 'TSCFG200' 
              AND "T$USED$U".COLUMNNAME = 'T$USED.U' 
              AND "T$USED$U".CONSTANT   = SOURCETABLE."T$USED$U" 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCEPTANCEDELAYCOMMENTS AS ACCEPTANCEDELAYCOMMENTS, 
        source_data.ACTAPPROVALDT AS ACTAPPROVALDT, 
        source_data.ACTCONDITIONALACCEPTDT AS ACTCONDITIONALACCEPTDT, 
        source_data.ACTEXITFACTORYDT AS ACTEXITFACTORYDT, 
        source_data.ACTFINALMACHINESPECDT AS ACTFINALMACHINESPECDT, 
        source_data.ACTFOBDT AS ACTFOBDT, 
        source_data.ACTHWSTARTUPENDDT AS ACTHWSTARTUPENDDT, 
        source_data.ACTHWSTARTUPSTDT AS ACTHWSTARTUPSTDT, 
        source_data.ACTINSTALLATIONENDDT AS ACTINSTALLATIONENDDT, 
        source_data.ACTINSTALLATIONSTDT AS ACTINSTALLATIONSTDT, 
        source_data.ACTMACHINEINACTIVEDT AS ACTMACHINEINACTIVEDT, 
        source_data.ACTONSITEDT AS ACTONSITEDT, 
        source_data.ACTPRE_WARRANTYENDDT AS ACTPRE_WARRANTYENDDT, 
        source_data.ACTPRE_WARRANTYSTDT AS ACTPRE_WARRANTYSTDT, 
        source_data.ACTSETUP_AND_TESTINGENDDT AS ACTSETUP_AND_TESTINGENDDT, 
        source_data.ACTSL1ENDDT AS ACTSL1ENDDT, 
        source_data.ACTSL2ENDDT AS ACTSL2ENDDT, 
        source_data.ACTSYSTEMACCEPTDT AS ACTSYSTEMACCEPTDT, 
        source_data.ACTTELPROCQUALSENDDT AS ACTTELPROCQUALSENDDT, 
        source_data.ACTTELPROCQUALSSTDT AS ACTTELPROCQUALSSTDT, 
        source_data.ACTTRAININGCREDITEXPDT AS ACTTRAININGCREDITEXPDT, 
        source_data.ACTWARRANTYENDDDAT AS ACTWARRANTYENDDDAT, 
        source_data.BUILDNO AS BUILDNO, 
        source_data.BUSINESSINQUIRYNUMBER AS BUSINESSINQUIRYNUMBER, 
        source_data.BUYFROMBUSINESSPARTNER AS BUYFROMBUSINESSPARTNER, 
        source_data.CALENDAR AS CALENDAR, 
        source_data.COMMENT AS COMMENT, 
        source_data.COMPONENTINDICATION AS COMPONENTINDICATION, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTACT AS CONTACT, 
        source_data.COUNTERREADING AS COUNTERREADING, 
        source_data.COVEREDBYCONTRACTDESCRIPTION AS COVEREDBYCONTRACTDESCRIPTION, 
        source_data.COVEREDBYCONTRACTID AS COVEREDBYCONTRACTID, 
        source_data.CUSTPURCHASEORDER AS CUSTPURCHASEORDER, 
        source_data.DELIVERYDATE AS DELIVERYDATE, 
        source_data.DERIVEDFROMITEM AS DERIVEDFROMITEM, 
        source_data.DESCRIPTION AS DESCRIPTION, 
        source_data.ELEMENTACTIVITY AS ELEMENTACTIVITY, 
        source_data.EMPLOYEENUMBER AS EMPLOYEENUMBER, 
        source_data.EVALUATIONTOOLSDESCRIPTION AS EVALUATIONTOOLSDESCRIPTION, 
        source_data.EVALUATIONTOOLSID AS EVALUATIONTOOLSID, 
        source_data.EXPIREDDESCRIPTION AS EXPIREDDESCRIPTION, 
        source_data.EXPIREDID AS EXPIREDID, 
        source_data.EXPIRYDATE AS EXPIRYDATE, 
        source_data.FACTORY AS FACTORY, 
        source_data.FRFTOOLDESCRIPTION AS FRFTOOLDESCRIPTION, 
        source_data.FRFTOOLID AS FRFTOOLID, 
        source_data.GENERALTEXT AS GENERALTEXT, 
        source_data.INSTALLATIONDATE AS INSTALLATIONDATE, 
        source_data.LOCATIONADDRESS AS LOCATIONADDRESS, 
        source_data.LOCATIONDESCRIPTION AS LOCATIONDESCRIPTION, 
        source_data.MACHINE AS MACHINE, 
        source_data.MACHINESPECNUMBER AS MACHINESPECNUMBER, 
        source_data.MANUFACTUREDBYDESCRIPTION AS MANUFACTUREDBYDESCRIPTION, 
        source_data.MANUFACTUREDBYID AS MANUFACTUREDBYID, 
        source_data.MATERIAL AS MATERIAL, 
        source_data.MEASUREMENTTYPE AS MEASUREMENTTYPE, 
        source_data.MOBILEOBJECTDESCRIPTION AS MOBILEOBJECTDESCRIPTION, 
        source_data.MOBILEOBJECTID AS MOBILEOBJECTID, 
        source_data.MONTHOFCONSTRUCTION AS MONTHOFCONSTRUCTION, 
        source_data.MPIMODELNAME AS MPIMODELNAME, 
        source_data.OBJECT AS OBJECT, 
        source_data.OBJECTGROUP AS OBJECTGROUP, 
        source_data.OBJECTNUMBER AS OBJECTNUMBER, 
        source_data.OBJECTPRIORITY AS OBJECTPRIORITY, 
        source_data.OBJECTTYPEDESCRIPTION AS OBJECTTYPEDESCRIPTION, 
        source_data.OBJECTTYPEID AS OBJECTTYPEID, 
        source_data.PREFERREDSERVICEENGINEER AS PREFERREDSERVICEENGINEER, 
        source_data.PROCESS AS PROCESS, 
        source_data.PROJECT AS PROJECT, 
        source_data.PURCHASEORDER AS PURCHASEORDER, 
        source_data.PURCHASEORDERPOS AS PURCHASEORDERPOS, 
        source_data.PURCHASEPRICE AS PURCHASEPRICE, 
        source_data.REASONACCEPTDELAYCODE AS REASONACCEPTDELAYCODE, 
        source_data.REASONACCEPTDELAYTEXT AS REASONACCEPTDELAYTEXT, 
        source_data.REASONMACHINERELOCATED AS REASONMACHINERELOCATED, 
        source_data.REGISTRATIONTIME AS REGISTRATIONTIME, 
        source_data.REVISION AS REVISION, 
        source_data.SALESFORECASTDT AS SALESFORECASTDT, 
        source_data.SALESORDER AS SALESORDER, 
        source_data.SALESORDERPOS AS SALESORDERPOS, 
        source_data.SCHCUSTPROCQUALSSTDT AS SCHCUSTPROCQUALSSTDT, 
        source_data.SCHHWSTARTUPENDDT AS SCHHWSTARTUPENDDT, 
        source_data.SCHHWSTARTUPSTDT AS SCHHWSTARTUPSTDT, 
        source_data.SCHINSTALLATIONENDDT AS SCHINSTALLATIONENDDT, 
        source_data.SCHINSTALLATIONSTDT AS SCHINSTALLATIONSTDT, 
        source_data.SCHONDOCKDT AS SCHONDOCKDT, 
        source_data.SCHSETUP_AND_TESTINGENDDT AS SCHSETUP_AND_TESTINGENDDT, 
        source_data.SCHSL1ENDDT AS SCHSL1ENDDT, 
        source_data.SCHSL2ENDDT AS SCHSL2ENDDT, 
        source_data.SCHSYSTEMACCEPTDT AS SCHSYSTEMACCEPTDT, 
        source_data.SCHTELPROCQUALSENDDT AS SCHTELPROCQUALSENDDT, 
        source_data.SCHTELPROCQUALSSTDT AS SCHTELPROCQUALSSTDT, 
        source_data.SCHWARRANTYENDDT AS SCHWARRANTYENDDT, 
        source_data.SCHWARRANTYSTDT AS SCHWARRANTYSTDT, 
        source_data.SEARCHARGUMENT AS SEARCHARGUMENT, 
        source_data.SERIALNUMBER AS SERIALNUMBER, 
        source_data.SIZE AS SIZE, 
        source_data.SOLDBASISREVENUEMETHOD AS SOLDBASISREVENUEMETHOD, 
        source_data.SPECIFICATIONTEXT AS SPECIFICATIONTEXT, 
        source_data.STANDARD AS STANDARD, 
        source_data.SUPPLIERCODETELBU AS SUPPLIERCODETELBU, 
        source_data.SWLHMODELNAME AS SWLHMODELNAME, 
        source_data.SYSTEMSTATUSDESCRIPTION AS SYSTEMSTATUSDESCRIPTION, 
        source_data.SYSTEMSTATUSID AS SYSTEMSTATUSID, 
        source_data.TCMCS060CMNF AS TCMCS060CMNF, 
        source_data.TECHNICALTEXT AS TECHNICALTEXT, 
        source_data.TELCONFIGURATIONID AS TELCONFIGURATIONID, 
        source_data.TELSALESORDERNUMBER AS TELSALESORDERNUMBER, 
        source_data.TELWTYCHANGEAPPROVALDESCRIPTION AS TELWTYCHANGEAPPROVALDESCRIPTION, 
        source_data.TELWTYCHANGEAPPROVALID AS TELWTYCHANGEAPPROVALID, 
        source_data.TERMID AS TERMID, 
        source_data.TOOLNUMBER AS TOOLNUMBER, 
        source_data.TOOLTYPE AS TOOLTYPE, 
        source_data.TRAININGCREDITSAVAILABLE AS TRAININGCREDITSAVAILABLE, 
        source_data.TRAININGDAYSSOLD AS TRAININGDAYSSOLD, 
        source_data.TRANSFERREDDESCRIPTION AS TRANSFERREDDESCRIPTION, 
        source_data.TRANSFERREDID AS TRANSFERREDID, 
        source_data.TYPEINDICATION AS TYPEINDICATION, 
        source_data.USAGECLASS AS USAGECLASS, 
        source_data.USEDEQUIPMENTDESCRIPTION AS USEDEQUIPMENTDESCRIPTION, 
        source_data.USEDEQUIPMENTID AS USEDEQUIPMENTID, 
        source_data.WAFERSIZE AS WAFERSIZE, 
        source_data.WARRANTY AS WARRANTY, 
        source_data.WEIGHT AS WEIGHT, 
        source_data.YEAROFCONSTRUCTION AS YEAROFCONSTRUCTION
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCEPTANCEDELAYCOMMENTS as VARCHAR(155)) as ACCEPTANCEDELAYCOMMENTS,
        cast(ACTAPPROVALDT as DATE) as ACTAPPROVALDT,
        cast(ACTCONDITIONALACCEPTDT as DATE) as ACTCONDITIONALACCEPTDT,
        cast(ACTEXITFACTORYDT as DATE) as ACTEXITFACTORYDT,
        cast(ACTFINALMACHINESPECDT as DATE) as ACTFINALMACHINESPECDT,
        cast(ACTFOBDT as DATE) as ACTFOBDT,
        cast(ACTHWSTARTUPENDDT as DATE) as ACTHWSTARTUPENDDT,
        cast(ACTHWSTARTUPSTDT as DATE) as ACTHWSTARTUPSTDT,
        cast(ACTINSTALLATIONENDDT as DATE) as ACTINSTALLATIONENDDT,
        cast(ACTINSTALLATIONSTDT as DATE) as ACTINSTALLATIONSTDT,
        cast(ACTMACHINEINACTIVEDT as DATE) as ACTMACHINEINACTIVEDT,
        cast(ACTONSITEDT as DATE) as ACTONSITEDT,
        cast(ACTPRE_WARRANTYENDDT as DATE) as ACTPRE_WARRANTYENDDT,
        cast(ACTPRE_WARRANTYSTDT as DATE) as ACTPRE_WARRANTYSTDT,
        cast(ACTSETUP_AND_TESTINGENDDT as DATE) as ACTSETUP_AND_TESTINGENDDT,
        cast(ACTSL1ENDDT as DATE) as ACTSL1ENDDT,
        cast(ACTSL2ENDDT as DATE) as ACTSL2ENDDT,
        cast(ACTSYSTEMACCEPTDT as DATE) as ACTSYSTEMACCEPTDT,
        cast(ACTTELPROCQUALSENDDT as DATE) as ACTTELPROCQUALSENDDT,
        cast(ACTTELPROCQUALSSTDT as DATE) as ACTTELPROCQUALSSTDT,
        cast(ACTTRAININGCREDITEXPDT as DATE) as ACTTRAININGCREDITEXPDT,
        cast(ACTWARRANTYENDDDAT as DATE) as ACTWARRANTYENDDDAT,
        cast(BUILDNO as VARCHAR(20)) as BUILDNO,
        cast(BUSINESSINQUIRYNUMBER as NUMBER(38,0)) as BUSINESSINQUIRYNUMBER,
        cast(BUYFROMBUSINESSPARTNER as VARCHAR(9)) as BUYFROMBUSINESSPARTNER,
        cast(CALENDAR as VARCHAR(9)) as CALENDAR,
        cast(COMMENT as VARCHAR(80)) as COMMENT,
        cast(COMPONENTINDICATION as VARCHAR(20)) as COMPONENTINDICATION,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTACT as VARCHAR(9)) as CONTACT,
        cast(COUNTERREADING as NUMBER(15,2)) as COUNTERREADING,
        cast(COVEREDBYCONTRACTDESCRIPTION as VARCHAR(16777216)) as COVEREDBYCONTRACTDESCRIPTION,
        cast(COVEREDBYCONTRACTID as NUMBER(38,0)) as COVEREDBYCONTRACTID,
        cast(CUSTPURCHASEORDER as VARCHAR(23)) as CUSTPURCHASEORDER,
        cast(DELIVERYDATE as DATE) as DELIVERYDATE,
        cast(DERIVEDFROMITEM as VARCHAR(47)) as DERIVEDFROMITEM,
        cast(DESCRIPTION as VARCHAR(30)) as DESCRIPTION,
        cast(ELEMENTACTIVITY as VARCHAR(8)) as ELEMENTACTIVITY,
        cast(EMPLOYEENUMBER as VARCHAR(20)) as EMPLOYEENUMBER,
        cast(EVALUATIONTOOLSDESCRIPTION as VARCHAR(16777216)) as EVALUATIONTOOLSDESCRIPTION,
        cast(EVALUATIONTOOLSID as NUMBER(38,0)) as EVALUATIONTOOLSID,
        cast(EXPIREDDESCRIPTION as VARCHAR(16777216)) as EXPIREDDESCRIPTION,
        cast(EXPIREDID as NUMBER(38,0)) as EXPIREDID,
        cast(EXPIRYDATE as DATE) as EXPIRYDATE,
        cast(FACTORY as VARCHAR(4)) as FACTORY,
        cast(FRFTOOLDESCRIPTION as VARCHAR(16777216)) as FRFTOOLDESCRIPTION,
        cast(FRFTOOLID as NUMBER(38,0)) as FRFTOOLID,
        cast(GENERALTEXT as NUMBER(38,10)) as GENERALTEXT,
        cast(INSTALLATIONDATE as DATE) as INSTALLATIONDATE,
        cast(LOCATIONADDRESS as VARCHAR(9)) as LOCATIONADDRESS,
        cast(LOCATIONDESCRIPTION as VARCHAR(30)) as LOCATIONDESCRIPTION,
        cast(MACHINE as VARCHAR(6)) as MACHINE,
        cast(MACHINESPECNUMBER as VARCHAR(20)) as MACHINESPECNUMBER,
        cast(MANUFACTUREDBYDESCRIPTION as VARCHAR(16777216)) as MANUFACTUREDBYDESCRIPTION,
        cast(MANUFACTUREDBYID as NUMBER(38,0)) as MANUFACTUREDBYID,
        cast(MATERIAL as VARCHAR(8)) as MATERIAL,
        cast(MEASUREMENTTYPE as VARCHAR(6)) as MEASUREMENTTYPE,
        cast(MOBILEOBJECTDESCRIPTION as VARCHAR(16777216)) as MOBILEOBJECTDESCRIPTION,
        cast(MOBILEOBJECTID as NUMBER(38,0)) as MOBILEOBJECTID,
        cast(MONTHOFCONSTRUCTION as NUMBER(38,0)) as MONTHOFCONSTRUCTION,
        cast(MPIMODELNAME as VARCHAR(40)) as MPIMODELNAME,
        cast(OBJECT as VARCHAR(50)) as OBJECT,
        cast(OBJECTGROUP as VARCHAR(6)) as OBJECTGROUP,
        cast(OBJECTNUMBER as NUMBER(38,0)) as OBJECTNUMBER,
        cast(OBJECTPRIORITY as NUMBER(38,0)) as OBJECTPRIORITY,
        cast(OBJECTTYPEDESCRIPTION as VARCHAR(16777216)) as OBJECTTYPEDESCRIPTION,
        cast(OBJECTTYPEID as NUMBER(38,0)) as OBJECTTYPEID,
        cast(PREFERREDSERVICEENGINEER as VARCHAR(6)) as PREFERREDSERVICEENGINEER,
        cast(PROCESS as VARCHAR(12)) as PROCESS,
        cast(PROJECT as VARCHAR(9)) as PROJECT,
        cast(PURCHASEORDER as VARCHAR(9)) as PURCHASEORDER,
        cast(PURCHASEORDERPOS as NUMBER(38,0)) as PURCHASEORDERPOS,
        cast(PURCHASEPRICE as NUMBER(15,2)) as PURCHASEPRICE,
        cast(REASONACCEPTDELAYCODE as VARCHAR(3)) as REASONACCEPTDELAYCODE,
        cast(REASONACCEPTDELAYTEXT as VARCHAR(155)) as REASONACCEPTDELAYTEXT,
        cast(REASONMACHINERELOCATED as VARCHAR(20)) as REASONMACHINERELOCATED,
        cast(REGISTRATIONTIME as TIMESTAMP_NTZ(9)) as REGISTRATIONTIME,
        cast(REVISION as VARCHAR(6)) as REVISION,
        cast(SALESFORECASTDT as DATE) as SALESFORECASTDT,
        cast(SALESORDER as VARCHAR(9)) as SALESORDER,
        cast(SALESORDERPOS as NUMBER(38,0)) as SALESORDERPOS,
        cast(SCHCUSTPROCQUALSSTDT as DATE) as SCHCUSTPROCQUALSSTDT,
        cast(SCHHWSTARTUPENDDT as DATE) as SCHHWSTARTUPENDDT,
        cast(SCHHWSTARTUPSTDT as DATE) as SCHHWSTARTUPSTDT,
        cast(SCHINSTALLATIONENDDT as DATE) as SCHINSTALLATIONENDDT,
        cast(SCHINSTALLATIONSTDT as DATE) as SCHINSTALLATIONSTDT,
        cast(SCHONDOCKDT as DATE) as SCHONDOCKDT,
        cast(SCHSETUP_AND_TESTINGENDDT as DATE) as SCHSETUP_AND_TESTINGENDDT,
        cast(SCHSL1ENDDT as DATE) as SCHSL1ENDDT,
        cast(SCHSL2ENDDT as DATE) as SCHSL2ENDDT,
        cast(SCHSYSTEMACCEPTDT as DATE) as SCHSYSTEMACCEPTDT,
        cast(SCHTELPROCQUALSENDDT as DATE) as SCHTELPROCQUALSENDDT,
        cast(SCHTELPROCQUALSSTDT as DATE) as SCHTELPROCQUALSSTDT,
        cast(SCHWARRANTYENDDT as DATE) as SCHWARRANTYENDDT,
        cast(SCHWARRANTYSTDT as DATE) as SCHWARRANTYSTDT,
        cast(SEARCHARGUMENT as VARCHAR(16)) as SEARCHARGUMENT,
        cast(SERIALNUMBER as VARCHAR(20)) as SERIALNUMBER,
        cast(SIZE as VARCHAR(12)) as SIZE,
        cast(SOLDBASISREVENUEMETHOD as VARCHAR(10)) as SOLDBASISREVENUEMETHOD,
        cast(SPECIFICATIONTEXT as NUMBER(38,10)) as SPECIFICATIONTEXT,
        cast(STANDARD as VARCHAR(8)) as STANDARD,
        cast(SUPPLIERCODETELBU as VARCHAR(6)) as SUPPLIERCODETELBU,
        cast(SWLHMODELNAME as VARCHAR(50)) as SWLHMODELNAME,
        cast(SYSTEMSTATUSDESCRIPTION as VARCHAR(16777216)) as SYSTEMSTATUSDESCRIPTION,
        cast(SYSTEMSTATUSID as NUMBER(38,0)) as SYSTEMSTATUSID,
        cast(TCMCS060CMNF as VARCHAR(6)) as TCMCS060CMNF,
        cast(TECHNICALTEXT as NUMBER(38,10)) as TECHNICALTEXT,
        cast(TELCONFIGURATIONID as VARCHAR(20)) as TELCONFIGURATIONID,
        cast(TELSALESORDERNUMBER as VARCHAR(20)) as TELSALESORDERNUMBER,
        cast(TELWTYCHANGEAPPROVALDESCRIPTION as VARCHAR(16777216)) as TELWTYCHANGEAPPROVALDESCRIPTION,
        cast(TELWTYCHANGEAPPROVALID as NUMBER(38,0)) as TELWTYCHANGEAPPROVALID,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(TOOLNUMBER as NUMBER(38,0)) as TOOLNUMBER,
        cast(TOOLTYPE as VARCHAR(47)) as TOOLTYPE,
        cast(TRAININGCREDITSAVAILABLE as NUMBER(38,0)) as TRAININGCREDITSAVAILABLE,
        cast(TRAININGDAYSSOLD as NUMBER(38,0)) as TRAININGDAYSSOLD,
        cast(TRANSFERREDDESCRIPTION as VARCHAR(16777216)) as TRANSFERREDDESCRIPTION,
        cast(TRANSFERREDID as NUMBER(38,0)) as TRANSFERREDID,
        cast(TYPEINDICATION as VARCHAR(20)) as TYPEINDICATION,
        cast(USAGECLASS as VARCHAR(3)) as USAGECLASS,
        cast(USEDEQUIPMENTDESCRIPTION as VARCHAR(16777216)) as USEDEQUIPMENTDESCRIPTION,
        cast(USEDEQUIPMENTID as NUMBER(38,0)) as USEDEQUIPMENTID,
        cast(WAFERSIZE as VARCHAR(10)) as WAFERSIZE,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(WEIGHT as NUMBER(15,2)) as WEIGHT,
        cast(YEAROFCONSTRUCTION as NUMBER(38,0)) as YEAROFCONSTRUCTION,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data