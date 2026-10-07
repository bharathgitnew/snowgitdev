/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICECONFIGURATIONCONTROL_STAGINGTABLEFORBAAN_SURBINTERFACE.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICECONFIGURATIONCONTROL_STAGINGTABLEFORBAAN_SURBINTERFACE.SQL 
-materialized incremental
-alias BAANSERVICECONFIGURATIONCONTROL_STAGINGTABLEFORBAAN_SURBINTERFACE 
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
    alias='BAANSERVICECONFIGURATIONCONTROL_STAGINGTABLEFORBAAN_SURBINTERFACE',
    unique_key = ['TRANSACTIONID']
) }}


with source_data as 
(
    SELECT 
             SOURCETABLE._CAPTUREDATETIME                                                                                                            AS _CAPTUREDATETIME 
            ,201                                                                                                                                       AS _COMPANYID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ACRS$U")),'')                                                                                           AS ACCEPT_DELAY_REASON_CAT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ACTX$U")),'')                                                                                           AS ACCEPT_DELAY_REASON_TEXT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ACTP$U")),'')                                                                                           AS ACCEPTANCE_CATERY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ACCM$U")),'')                                                                                           AS ACCEPTANCEDELAYCOMMENTS 
            ,CAST(CASE WHEN "T$ACDT$U"<= '1/1/1970' THEN NULL ELSE "T$ACDT$U" END AS DATE)                                                             AS ACT_ACCEPTANCE_DATE 
            ,CAST(CASE WHEN "T$ADTL$U"<= '1/1/1970' THEN NULL ELSE "T$ADTL$U" END AS DATE)                                                             AS ACT_ACCEPTANCE_DATE_LOCAL 
            ,CAST(CASE WHEN "T$ACCD$U"<= '1/1/1970' THEN NULL ELSE "T$ACCD$U" END AS DATE)                                                             AS ACT_CST_COMPLETE_DATE 
            ,CAST(CASE WHEN "T$ACSD$U"<= '1/1/1970' THEN NULL ELSE "T$ACSD$U" END AS DATE)                                                             AS ACT_CST_SIGNED_DATE 
            ,CAST(CASE WHEN "T$ADDT$U"<= '1/1/1970' THEN NULL ELSE "T$ADDT$U" END AS DATE)                                                             AS ACT_DELIVERY_DATE 
            ,CAST(CASE WHEN "T$AHCD$U"<= '1/1/1970' THEN NULL ELSE "T$AHCD$U" END AS DATE)                                                             AS ACT_HANDOFF_TO_CUST_DATE 
            ,CAST(CASE WHEN "T$AHED$U"<= '1/1/1970' THEN NULL ELSE "T$AHED$U" END AS DATE)                                                             AS ACT_HW_SU_END_DATE 
            ,CAST(CASE WHEN "T$AHSD$U"<= '1/1/1970' THEN NULL ELSE "T$AHSD$U" END AS DATE)                                                             AS ACT_HW_SU_START_DATE 
            ,CAST(CASE WHEN "T$AISD$U"<= '1/1/1970' THEN NULL ELSE "T$AISD$U" END AS DATE)                                                             AS ACT_INSTALLATION_START_DATE 
            ,CAST(CASE WHEN "T$ALED$U"<= '1/1/1970' THEN NULL ELSE "T$ALED$U" END AS DATE)                                                             AS ACT_LABOR_WARRANTY_END_DATE 
            ,CAST(CASE WHEN "T$ALSD$U"<= '1/1/1970' THEN NULL ELSE "T$ALSD$U" END AS DATE)                                                             AS ACT_LABOR_WARRANTY_START_DATE 
            ,CAST(CASE WHEN "T$AMID$U"<= '1/1/1970' THEN NULL ELSE "T$AMID$U" END AS DATE)                                                             AS ACT_MOVE_IN_DATE 
            ,CAST(CASE WHEN "T$ARCD$U"<= '1/1/1970' THEN NULL ELSE "T$ARCD$U" END AS DATE)                                                             AS ACT_REVENUE_COMPLETE_DATE 
            ,CAST(CASE WHEN "T$AS1D$U"<= '1/1/1970' THEN NULL ELSE "T$AS1D$U" END AS DATE)                                                             AS ACT_SL1_DATE 
            ,CAST(CASE WHEN "T$AS2D$U"<= '1/1/1970' THEN NULL ELSE "T$AS2D$U" END AS DATE)                                                             AS ACT_SL2_DATE 
            ,CAST(CASE WHEN "T$AQED$U"<= '1/1/1970' THEN NULL ELSE "T$AQED$U" END AS DATE)                                                             AS ACT_TEL_PROC_QUAL_END_DATE 
            ,CAST(CASE WHEN "T$AQSD$U"<= '1/1/1970' THEN NULL ELSE "T$AQSD$U" END AS DATE)                                                             AS ACT_TEL_PROC_QUAL_START_DATE 
            ,CAST(CASE WHEN "T$AWEL$U"<= '1/1/1970' THEN NULL ELSE "T$AWEL$U" END AS DATE)                                                             AS ACT_WARRANTY_END_DATE_LOCAL 
            ,CAST(CASE WHEN "T$AWSL$U"<= '1/1/1970' THEN NULL ELSE "T$AWSL$U" END AS DATE)                                                             AS ACT_WARRANTY_START_DATE_LOCAL 
            ,CAST(CASE WHEN "T$AWED$U"<= '1/1/1970' THEN NULL ELSE "T$AWED$U" END AS DATE)                                                             AS ACT_WTY_END_DATE 
            ,CAST(CASE WHEN "T$AWSD$U"<= '1/1/1970' THEN NULL ELSE "T$AWSD$U" END AS DATE)                                                             AS ACT_WTY_START_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BUCD$U")),'')                                                                                           AS BU_CODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$BUNM$U")),'')                                                                                           AS BU_NAME 
            ,CAST("T$BUIN$U" AS BIGINT)                                                                                                                AS BUSINESS_INQUIRY_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CLFG$U")),'')                                                                                           AS CLUSTER_FLAG 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COMM$U")),'')                                                                                           AS COMMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CCFG$U")),'')                                                                                           AS CONFIGURATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$COTY$U")),'')                                                                                           AS CONTENT_TYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CMEM$U")),'')                                                                                           AS CST_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CMID$U")),'')                                                                                           AS CUST_MACHINE_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CUPO$U")),'')                                                                                           AS CUST_PO_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CPPN$U")),'')                                                                                           AS CUST_PO_PROD_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CUCD$U")),'')                                                                                           AS CUSTOMER_CODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CUNM$U")),'')                                                                                           AS CUSTOMER_NAME 
            ,CAST(CASE WHEN "T$CCLD$U"<= '1/1/1970' THEN NULL ELSE "T$CCLD$U" END AS DATE)                                                             AS CUSTOMS_CLEARED_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$DAYN$U")),'')                                                                                           AS DAY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$ECOD$U")),'')                                                                                           AS ERRORCODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$EMSG$U")),'')                                                                                           AS ERRORMESSAGE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$EVAL$U")),'')                                                                                           AS EVALUATION_TOOL_FLAG 
            ,CAST(CASE WHEN "T$FSDT$U"<= '1/1/1970' THEN NULL ELSE "T$FSDT$U" END AS DATE)                                                             AS FACTORY_SHIP_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$LOCD$U")),'')                                                                                           AS LOCATION_CODE_9_DIGIT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MRSN$U")),'')                                                                                           AS MACHINE_RELOC_RSN 
            ,CAST(CASE WHEN "T$MRDT$U"<= '1/1/1970' THEN NULL ELSE "T$MRDT$U" END AS DATE)                                                             AS MACHINE_RETIRED_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MDLC$U")),'')                                                                                           AS MACHINE_SETUP_LOCATION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MAST$U")),'')                                                                                           AS MACHINE_STATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MCME$U")),'')                                                                                           AS MAIN_CST_AREA_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MCEN$U")),'')                                                                                           AS MAIN_CST_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MSME$U")),'')                                                                                           AS MAIN_SU_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MCRQ$U")),'')                                                                                           AS MGR_CHANGE_REQUEST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MRCO$U")),'')                                                                                           AS MGR_COMMENT 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MOID$U")),'')                                                                                           AS MODEL_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MONM$U")),'')                                                                                           AS MODEL_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MOPO$U")),'')                                                                                           AS MODULE_POSITION 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$MNTH$U")),'')                                                                                           AS MONTH 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$NMOM$U")),'')                                                                                           AS NIS_MODEL_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PRSN$U")),'')                                                                                           AS PARENT_SERIAL_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$PROC$U")),'')                                                                                           AS PROCESS_NAME 
            ,CAST(CASE WHEN "T$RDLD$U"<= '1/1/1970' THEN NULL ELSE "T$RDLD$U" END AS DATE)                                                             AS REQUESTED_DELIVERY_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$REMT$U")),'')                                                                                           AS REVENUE_METHOD 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SEMN$U")),'')                                                                                           AS SALES_EMP_NUMBER 
            ,CAST(CASE WHEN "T$SMCU$U"<= '1/1/1970' THEN NULL ELSE "T$SMCU$U" END AS DATE)                                                             AS SALES_MONTH_CURRENT 
            ,CAST(CASE WHEN "T$SMFO$U"<= '1/1/1970' THEN NULL ELSE "T$SMFO$U" END AS DATE)                                                             AS SALES_MONTH_FORECAST 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SONO$U")),'')                                                                                           AS SALES_ORDER_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SSNM$U")),'')                                                                                           AS SALES_STATION_NAME 
            ,CAST(CASE WHEN "T$SACD$U"<= '1/1/1970' THEN NULL ELSE "T$SACD$U" END AS DATE)                                                             AS SCH_ACCEPTANCE_DATE 
            ,CAST(CASE WHEN "T$SSTD$U"<= '1/1/1970' THEN NULL ELSE "T$SSTD$U" END AS DATE)                                                             AS SCH_CST_DATE 
            ,CAST(CASE WHEN "T$SIED$U"<= '1/1/1970' THEN NULL ELSE "T$SIED$U" END AS DATE)                                                             AS SCH_HAND_OFF_DATE 
            ,CAST(CASE WHEN "T$SHED$U"<= '1/1/1970' THEN NULL ELSE "T$SHED$U" END AS DATE)                                                             AS SCH_HW_SU_END_DATE 
            ,CAST(CASE WHEN "T$SHSH$U"<= '1/1/1970' THEN NULL ELSE "T$SHSH$U" END AS DATE)                                                             AS SCH_HW_SU_START_DATE 
            ,CAST(CASE WHEN "T$SISD$U"<= '1/1/1970' THEN NULL ELSE "T$SISD$U" END AS DATE)                                                             AS SCH_INSTALLATION_START_DATE 
            ,CAST(CASE WHEN "T$SMID$U"<= '1/1/1970' THEN NULL ELSE "T$SMID$U" END AS DATE)                                                             AS SCH_MOVE_IN_DATE 
            ,CAST(CASE WHEN "T$SODD$U"<= '1/1/1970' THEN NULL ELSE "T$SODD$U" END AS DATE)                                                             AS SCH_ON_DOCK_DATE 
            ,CAST(CASE WHEN "T$SL1D$U"<= '1/1/1970' THEN NULL ELSE "T$SL1D$U" END AS DATE)                                                             AS SCH_SL1_DATE 
            ,CAST(CASE WHEN "T$SL2D$U"<= '1/1/1970' THEN NULL ELSE "T$SL2D$U" END AS DATE)                                                             AS SCH_SL2_DATE 
            ,CAST(CASE WHEN "T$SQED$U"<= '1/1/1970' THEN NULL ELSE "T$SQED$U" END AS DATE)                                                             AS SCH_TEL_PROC_QUAL_END_DATE 
            ,CAST(CASE WHEN "T$SQSD$U"<= '1/1/1970' THEN NULL ELSE "T$SQSD$U" END AS DATE)                                                             AS SCH_TEL_PROC_QUAL_START_DATE 
            ,CAST(CASE WHEN "T$SWSD$U"<= '1/1/1970' THEN NULL ELSE "T$SWSD$U" END AS DATE)                                                             AS SCH_WARRANTY_START_DATE 
            ,CAST(CASE WHEN "T$SWED$U"<= '1/1/1970' THEN NULL ELSE "T$SWED$U" END AS DATE)                                                             AS SCH_WTY_END_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SPID$U")),'')                                                                                           AS SEG_PROCESS_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SPON$U")),'')                                                                                           AS SEG_PROCESS_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SRNO$U")),'')                                                                                           AS SERIAL_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SSCD$U")),'')                                                                                           AS SERVICE_STATION_CODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SSTN$U")),'')                                                                                           AS SERVICE_STATION_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SMNO$U")),'')                                                                                           AS SMS_NUMBER 
            ,CAST(CASE WHEN "T$SPDT$U"<= '1/1/1970' THEN NULL ELSE "T$SPDT$U" END AS DATE)                                                             AS SPEC_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SPNO$U")),'')                                                                                           AS SPEC_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$STST$U")),'')                                                                                           AS STARTUP_SITE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SUCM$U")),'')                                                                                           AS SU_COMMENTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SUFL$U")),'')                                                                                           AS SU_FLAG 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SMEN$U")),'')                                                                                           AS SU_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SMRN$U")),'')                                                                                           AS SU_MGR_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SLEN$U")),'')                                                                                           AS SU_TEAM_LEADER_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SCEN$U")),'')                                                                                           AS SUB_CST_AREA_MGR_EMP_NUMBER_SCEN_U 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SEAN$U")),'')                                                                                           AS SUB_CST_AREA_MGR_EMP_NUMBER_SEAN_U 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SSEN$U")),'')                                                                                           AS SUB_SU_MGR_EMP_NUMBER 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SUNO$U")),'')                                                                                           AS SUPPLIER_CODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$FLNM$U")),'')                                                                                           AS SURBFILENAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SYID$U")),'')                                                                                           AS SYSTEM_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$SYNM$U")),'')                                                                                           AS SYSTEM_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TMOC$U")),'')                                                                                           AS TEL_MODEL_CODE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TMON$U")),'')                                                                                           AS TEL_MODEL_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TPON$U")),'')                                                                                           AS TEL_PO_NUMBER 
            ,CAST(CASE WHEN "T$TSHD$U"<= '1/1/1970' THEN NULL ELSE "T$TSHD$U" END AS DATE)                                                             AS TEL_SHIP_DATE 
            ,CAST(CASE WHEN "T$TCED$U"<= '1/1/1970' THEN NULL ELSE "T$TCED$U" END AS DATE)                                                             AS TRAINING_CREDIT_EXPIRY_DATE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TRNC$U")),'')                                                                                           AS TRAINING_DAYS_SOLD 
            ,CAST(CASE WHEN "T$TRDT$U"<= '1/1/1970' THEN NULL ELSE "T$TRDT$U"  END AS DATETIME) AS TRANSACTIONDATE 
            ,CAST("T$TRID$U" AS BIGINT)                                                                                                                AS TRANSACTIONID 
            ,"T$TRST$U".CONSTANTDESCRIPTION                                                                                                            AS TRANSACTIONSTATUSDESCRIPTION 
            ,CAST("T$TRST$U" AS INT)                                                                                                                   AS TRANSACTIONSTATUSID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$TTYP$U")),'')                                                                                           AS TRANSACTIONTYPE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$USED$U")),'')                                                                                           AS USED_EQUIPMENT_FLAG 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WFRS$U")),'')                                                                                           AS WAFER_SIZE 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$CWTE$U")),'')                                                                                           AS WARRANTY 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WFLL$U")),'')                                                                                           AS WARRANTY_FLAG_LABOR 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WFLP$U")),'')                                                                                           AS WARRANTY_FLAG_PARTS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WRST$U")),'')                                                                                           AS WARRANTY_STATUS 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WRTM$U")),'')                                                                                           AS WARRANTY_TERM 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WRMI$U")),'')                                                                                           AS WTY_RESERVE_MODEL_ID 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$WRMN$U")),'')                                                                                           AS WTY_RESERVE_MODEL_NAME 
            ,NULLIF(RTRIM(LTRIM(SOURCETABLE."T$YEAR$U")),'')                                                                                           AS YEAR 
             
        FROM {{ source("BAAN_ORACLE_LIVE", "TTSCFG905201") }} AS SOURCETABLE  
            /*TRANSACTIONSTATUSU*/ 
            LEFT OUTER JOIN {{ source("BAAN", "ENUMERATIONS") }} AS "T$TRST$U" 
             ON   "T$TRST$U".TABLENAME  = 'TSCFG905' 
              AND "T$TRST$U".COLUMNNAME = 'T$TRST.U' 
              AND "T$TRST$U".CONSTANT   = SOURCETABLE."T$TRST$U" 
        {% if is_incremental() %} WHERE FALSE AND SOURCETABLE._CAPTUREDATETIME >= (SELECT MAX(_CAPTUREDATETIME) FROM {{ this }}) {% endif %} 
        )
,transform_data as
(
    SELECT 
        source_data._CAPTUREDATETIME AS _CAPTUREDATETIME, 
        source_data._COMPANYID AS _COMPANYID, 
        source_data.ACCEPT_DELAY_REASON_CAT AS ACCEPT_DELAY_REASON_CAT, 
        source_data.ACCEPT_DELAY_REASON_TEXT AS ACCEPT_DELAY_REASON_TEXT, 
        source_data.ACCEPTANCE_CATERY AS ACCEPTANCE_CATERY, 
        source_data.ACCEPTANCEDELAYCOMMENTS AS ACCEPTANCEDELAYCOMMENTS, 
        source_data.ACT_ACCEPTANCE_DATE AS ACT_ACCEPTANCE_DATE, 
        source_data.ACT_ACCEPTANCE_DATE_LOCAL AS ACT_ACCEPTANCE_DATE_LOCAL, 
        source_data.ACT_CST_COMPLETE_DATE AS ACT_CST_COMPLETE_DATE, 
        source_data.ACT_CST_SIGNED_DATE AS ACT_CST_SIGNED_DATE, 
        source_data.ACT_DELIVERY_DATE AS ACT_DELIVERY_DATE, 
        source_data.ACT_HANDOFF_TO_CUST_DATE AS ACT_HANDOFF_TO_CUST_DATE, 
        source_data.ACT_HW_SU_END_DATE AS ACT_HW_SU_END_DATE, 
        source_data.ACT_HW_SU_START_DATE AS ACT_HW_SU_START_DATE, 
        source_data.ACT_INSTALLATION_START_DATE AS ACT_INSTALLATION_START_DATE, 
        source_data.ACT_LABOR_WARRANTY_END_DATE AS ACT_LABOR_WARRANTY_END_DATE, 
        source_data.ACT_LABOR_WARRANTY_START_DATE AS ACT_LABOR_WARRANTY_START_DATE, 
        source_data.ACT_MOVE_IN_DATE AS ACT_MOVE_IN_DATE, 
        source_data.ACT_REVENUE_COMPLETE_DATE AS ACT_REVENUE_COMPLETE_DATE, 
        source_data.ACT_SL1_DATE AS ACT_SL1_DATE, 
        source_data.ACT_SL2_DATE AS ACT_SL2_DATE, 
        source_data.ACT_TEL_PROC_QUAL_END_DATE AS ACT_TEL_PROC_QUAL_END_DATE, 
        source_data.ACT_TEL_PROC_QUAL_START_DATE AS ACT_TEL_PROC_QUAL_START_DATE, 
        source_data.ACT_WARRANTY_END_DATE_LOCAL AS ACT_WARRANTY_END_DATE_LOCAL, 
        source_data.ACT_WARRANTY_START_DATE_LOCAL AS ACT_WARRANTY_START_DATE_LOCAL, 
        source_data.ACT_WTY_END_DATE AS ACT_WTY_END_DATE, 
        source_data.ACT_WTY_START_DATE AS ACT_WTY_START_DATE, 
        source_data.BU_CODE AS BU_CODE, 
        source_data.BU_NAME AS BU_NAME, 
        source_data.BUSINESS_INQUIRY_NUMBER AS BUSINESS_INQUIRY_NUMBER, 
        source_data.CLUSTER_FLAG AS CLUSTER_FLAG, 
        source_data.COMMENT AS COMMENT, 
        source_data.CONFIGURATION AS CONFIGURATION, 
        source_data.CONTENT_TYPE AS CONTENT_TYPE, 
        source_data.CST_MGR_EMP_NUMBER AS CST_MGR_EMP_NUMBER, 
        source_data.CUST_MACHINE_ID AS CUST_MACHINE_ID, 
        source_data.CUST_PO_NUMBER AS CUST_PO_NUMBER, 
        source_data.CUST_PO_PROD_NAME AS CUST_PO_PROD_NAME, 
        source_data.CUSTOMER_CODE AS CUSTOMER_CODE, 
        source_data.CUSTOMER_NAME AS CUSTOMER_NAME, 
        source_data.CUSTOMS_CLEARED_DATE AS CUSTOMS_CLEARED_DATE, 
        source_data.DAY AS DAY, 
        source_data.ERRORCODE AS ERRORCODE, 
        source_data.ERRORMESSAGE AS ERRORMESSAGE, 
        source_data.EVALUATION_TOOL_FLAG AS EVALUATION_TOOL_FLAG, 
        source_data.FACTORY_SHIP_DATE AS FACTORY_SHIP_DATE, 
        source_data.LOCATION_CODE_9_DIGIT AS LOCATION_CODE_9_DIGIT, 
        source_data.MACHINE_RELOC_RSN AS MACHINE_RELOC_RSN, 
        source_data.MACHINE_RETIRED_DATE AS MACHINE_RETIRED_DATE, 
        source_data.MACHINE_SETUP_LOCATION AS MACHINE_SETUP_LOCATION, 
        source_data.MACHINE_STATUS AS MACHINE_STATUS, 
        source_data.MAIN_CST_AREA_MGR_EMP_NUMBER AS MAIN_CST_AREA_MGR_EMP_NUMBER, 
        source_data.MAIN_CST_MGR_EMP_NUMBER AS MAIN_CST_MGR_EMP_NUMBER, 
        source_data.MAIN_SU_MGR_EMP_NUMBER AS MAIN_SU_MGR_EMP_NUMBER, 
        source_data.MGR_CHANGE_REQUEST AS MGR_CHANGE_REQUEST, 
        source_data.MGR_COMMENT AS MGR_COMMENT, 
        source_data.MODEL_ID AS MODEL_ID, 
        source_data.MODEL_NAME AS MODEL_NAME, 
        source_data.MODULE_POSITION AS MODULE_POSITION, 
        source_data.MONTH AS MONTH, 
        source_data.NIS_MODEL_NAME AS NIS_MODEL_NAME, 
        source_data.PARENT_SERIAL_NUMBER AS PARENT_SERIAL_NUMBER, 
        source_data.PROCESS_NAME AS PROCESS_NAME, 
        source_data.REQUESTED_DELIVERY_DATE AS REQUESTED_DELIVERY_DATE, 
        source_data.REVENUE_METHOD AS REVENUE_METHOD, 
        source_data.SALES_EMP_NUMBER AS SALES_EMP_NUMBER, 
        source_data.SALES_MONTH_CURRENT AS SALES_MONTH_CURRENT, 
        source_data.SALES_MONTH_FORECAST AS SALES_MONTH_FORECAST, 
        source_data.SALES_ORDER_NUMBER AS SALES_ORDER_NUMBER, 
        source_data.SALES_STATION_NAME AS SALES_STATION_NAME, 
        source_data.SCH_ACCEPTANCE_DATE AS SCH_ACCEPTANCE_DATE, 
        source_data.SCH_CST_DATE AS SCH_CST_DATE, 
        source_data.SCH_HAND_OFF_DATE AS SCH_HAND_OFF_DATE, 
        source_data.SCH_HW_SU_END_DATE AS SCH_HW_SU_END_DATE, 
        source_data.SCH_HW_SU_START_DATE AS SCH_HW_SU_START_DATE, 
        source_data.SCH_INSTALLATION_START_DATE AS SCH_INSTALLATION_START_DATE, 
        source_data.SCH_MOVE_IN_DATE AS SCH_MOVE_IN_DATE, 
        source_data.SCH_ON_DOCK_DATE AS SCH_ON_DOCK_DATE, 
        source_data.SCH_SL1_DATE AS SCH_SL1_DATE, 
        source_data.SCH_SL2_DATE AS SCH_SL2_DATE, 
        source_data.SCH_TEL_PROC_QUAL_END_DATE AS SCH_TEL_PROC_QUAL_END_DATE, 
        source_data.SCH_TEL_PROC_QUAL_START_DATE AS SCH_TEL_PROC_QUAL_START_DATE, 
        source_data.SCH_WARRANTY_START_DATE AS SCH_WARRANTY_START_DATE, 
        source_data.SCH_WTY_END_DATE AS SCH_WTY_END_DATE, 
        source_data.SEG_PROCESS_ID AS SEG_PROCESS_ID, 
        source_data.SEG_PROCESS_NAME AS SEG_PROCESS_NAME, 
        source_data.SERIAL_NUMBER AS SERIAL_NUMBER, 
        source_data.SERVICE_STATION_CODE AS SERVICE_STATION_CODE, 
        source_data.SERVICE_STATION_NAME AS SERVICE_STATION_NAME, 
        source_data.SMS_NUMBER AS SMS_NUMBER, 
        source_data.SPEC_DATE AS SPEC_DATE, 
        source_data.SPEC_NUMBER AS SPEC_NUMBER, 
        source_data.STARTUP_SITE AS STARTUP_SITE, 
        source_data.SU_COMMENTS AS SU_COMMENTS, 
        source_data.SU_FLAG AS SU_FLAG, 
        source_data.SU_MGR_EMP_NUMBER AS SU_MGR_EMP_NUMBER, 
        source_data.SU_MGR_NAME AS SU_MGR_NAME, 
        source_data.SU_TEAM_LEADER_EMP_NUMBER AS SU_TEAM_LEADER_EMP_NUMBER, 
        source_data.SUB_CST_AREA_MGR_EMP_NUMBER_SCEN_U AS SUB_CST_AREA_MGR_EMP_NUMBER_SCEN_U, 
        source_data.SUB_CST_AREA_MGR_EMP_NUMBER_SEAN_U AS SUB_CST_AREA_MGR_EMP_NUMBER_SEAN_U, 
        source_data.SUB_SU_MGR_EMP_NUMBER AS SUB_SU_MGR_EMP_NUMBER, 
        source_data.SUPPLIER_CODE AS SUPPLIER_CODE, 
        source_data.SURBFILENAME AS SURBFILENAME, 
        source_data.SYSTEM_ID AS SYSTEM_ID, 
        source_data.SYSTEM_NAME AS SYSTEM_NAME, 
        source_data.TEL_MODEL_CODE AS TEL_MODEL_CODE, 
        source_data.TEL_MODEL_NAME AS TEL_MODEL_NAME, 
        source_data.TEL_PO_NUMBER AS TEL_PO_NUMBER, 
        source_data.TEL_SHIP_DATE AS TEL_SHIP_DATE, 
        source_data.TRAINING_CREDIT_EXPIRY_DATE AS TRAINING_CREDIT_EXPIRY_DATE, 
        source_data.TRAINING_DAYS_SOLD AS TRAINING_DAYS_SOLD, 
        source_data.TRANSACTIONDATE AS TRANSACTIONDATE, 
        source_data.TRANSACTIONID AS TRANSACTIONID, 
        source_data.TRANSACTIONSTATUSDESCRIPTION AS TRANSACTIONSTATUSDESCRIPTION, 
        source_data.TRANSACTIONSTATUSID AS TRANSACTIONSTATUSID, 
        source_data.TRANSACTIONTYPE AS TRANSACTIONTYPE, 
        source_data.USED_EQUIPMENT_FLAG AS USED_EQUIPMENT_FLAG, 
        source_data.WAFER_SIZE AS WAFER_SIZE, 
        source_data.WARRANTY AS WARRANTY, 
        source_data.WARRANTY_FLAG_LABOR AS WARRANTY_FLAG_LABOR, 
        source_data.WARRANTY_FLAG_PARTS AS WARRANTY_FLAG_PARTS, 
        source_data.WARRANTY_STATUS AS WARRANTY_STATUS, 
        source_data.WARRANTY_TERM AS WARRANTY_TERM, 
        source_data.WTY_RESERVE_MODEL_ID AS WTY_RESERVE_MODEL_ID, 
        source_data.WTY_RESERVE_MODEL_NAME AS WTY_RESERVE_MODEL_NAME, 
        source_data.YEAR AS YEAR
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_COMPANYID as NUMBER(3,0)) as _COMPANYID,
        cast(ACCEPT_DELAY_REASON_CAT as VARCHAR(3)) as ACCEPT_DELAY_REASON_CAT,
        cast(ACCEPT_DELAY_REASON_TEXT as VARCHAR(155)) as ACCEPT_DELAY_REASON_TEXT,
        cast(ACCEPTANCE_CATERY as VARCHAR(3)) as ACCEPTANCE_CATERY,
        cast(ACCEPTANCEDELAYCOMMENTS as VARCHAR(155)) as ACCEPTANCEDELAYCOMMENTS,
        cast(ACT_ACCEPTANCE_DATE as DATE) as ACT_ACCEPTANCE_DATE,
        cast(ACT_ACCEPTANCE_DATE_LOCAL as DATE) as ACT_ACCEPTANCE_DATE_LOCAL,
        cast(ACT_CST_COMPLETE_DATE as DATE) as ACT_CST_COMPLETE_DATE,
        cast(ACT_CST_SIGNED_DATE as DATE) as ACT_CST_SIGNED_DATE,
        cast(ACT_DELIVERY_DATE as DATE) as ACT_DELIVERY_DATE,
        cast(ACT_HANDOFF_TO_CUST_DATE as DATE) as ACT_HANDOFF_TO_CUST_DATE,
        cast(ACT_HW_SU_END_DATE as DATE) as ACT_HW_SU_END_DATE,
        cast(ACT_HW_SU_START_DATE as DATE) as ACT_HW_SU_START_DATE,
        cast(ACT_INSTALLATION_START_DATE as DATE) as ACT_INSTALLATION_START_DATE,
        cast(ACT_LABOR_WARRANTY_END_DATE as DATE) as ACT_LABOR_WARRANTY_END_DATE,
        cast(ACT_LABOR_WARRANTY_START_DATE as DATE) as ACT_LABOR_WARRANTY_START_DATE,
        cast(ACT_MOVE_IN_DATE as DATE) as ACT_MOVE_IN_DATE,
        cast(ACT_REVENUE_COMPLETE_DATE as DATE) as ACT_REVENUE_COMPLETE_DATE,
        cast(ACT_SL1_DATE as DATE) as ACT_SL1_DATE,
        cast(ACT_SL2_DATE as DATE) as ACT_SL2_DATE,
        cast(ACT_TEL_PROC_QUAL_END_DATE as DATE) as ACT_TEL_PROC_QUAL_END_DATE,
        cast(ACT_TEL_PROC_QUAL_START_DATE as DATE) as ACT_TEL_PROC_QUAL_START_DATE,
        cast(ACT_WARRANTY_END_DATE_LOCAL as DATE) as ACT_WARRANTY_END_DATE_LOCAL,
        cast(ACT_WARRANTY_START_DATE_LOCAL as DATE) as ACT_WARRANTY_START_DATE_LOCAL,
        cast(ACT_WTY_END_DATE as DATE) as ACT_WTY_END_DATE,
        cast(ACT_WTY_START_DATE as DATE) as ACT_WTY_START_DATE,
        cast(BU_CODE as VARCHAR(6)) as BU_CODE,
        cast(BU_NAME as VARCHAR(40)) as BU_NAME,
        cast(BUSINESS_INQUIRY_NUMBER as NUMBER(38,0)) as BUSINESS_INQUIRY_NUMBER,
        cast(CLUSTER_FLAG as VARCHAR(1)) as CLUSTER_FLAG,
        cast(COMMENT as VARCHAR(100)) as COMMENT,
        cast(CONFIGURATION as VARCHAR(8)) as CONFIGURATION,
        cast(CONTENT_TYPE as VARCHAR(4)) as CONTENT_TYPE,
        cast(CST_MGR_EMP_NUMBER as VARCHAR(50)) as CST_MGR_EMP_NUMBER,
        cast(CUST_MACHINE_ID as VARCHAR(30)) as CUST_MACHINE_ID,
        cast(CUST_PO_NUMBER as VARCHAR(23)) as CUST_PO_NUMBER,
        cast(CUST_PO_PROD_NAME as VARCHAR(80)) as CUST_PO_PROD_NAME,
        cast(CUSTOMER_CODE as VARCHAR(9)) as CUSTOMER_CODE,
        cast(CUSTOMER_NAME as VARCHAR(40)) as CUSTOMER_NAME,
        cast(CUSTOMS_CLEARED_DATE as DATE) as CUSTOMS_CLEARED_DATE,
        cast(DAY as VARCHAR(2)) as DAY,
        cast(ERRORCODE as VARCHAR(10)) as ERRORCODE,
        cast(ERRORMESSAGE as VARCHAR(50)) as ERRORMESSAGE,
        cast(EVALUATION_TOOL_FLAG as VARCHAR(1)) as EVALUATION_TOOL_FLAG,
        cast(FACTORY_SHIP_DATE as DATE) as FACTORY_SHIP_DATE,
        cast(LOCATION_CODE_9_DIGIT as VARCHAR(10)) as LOCATION_CODE_9_DIGIT,
        cast(MACHINE_RELOC_RSN as VARCHAR(40)) as MACHINE_RELOC_RSN,
        cast(MACHINE_RETIRED_DATE as DATE) as MACHINE_RETIRED_DATE,
        cast(MACHINE_SETUP_LOCATION as VARCHAR(20)) as MACHINE_SETUP_LOCATION,
        cast(MACHINE_STATUS as VARCHAR(40)) as MACHINE_STATUS,
        cast(MAIN_CST_AREA_MGR_EMP_NUMBER as VARCHAR(15)) as MAIN_CST_AREA_MGR_EMP_NUMBER,
        cast(MAIN_CST_MGR_EMP_NUMBER as VARCHAR(15)) as MAIN_CST_MGR_EMP_NUMBER,
        cast(MAIN_SU_MGR_EMP_NUMBER as VARCHAR(15)) as MAIN_SU_MGR_EMP_NUMBER,
        cast(MGR_CHANGE_REQUEST as VARCHAR(100)) as MGR_CHANGE_REQUEST,
        cast(MGR_COMMENT as VARCHAR(100)) as MGR_COMMENT,
        cast(MODEL_ID as VARCHAR(10)) as MODEL_ID,
        cast(MODEL_NAME as VARCHAR(40)) as MODEL_NAME,
        cast(MODULE_POSITION as VARCHAR(50)) as MODULE_POSITION,
        cast(MONTH as VARCHAR(2)) as MONTH,
        cast(NIS_MODEL_NAME as VARCHAR(32)) as NIS_MODEL_NAME,
        cast(PARENT_SERIAL_NUMBER as VARCHAR(15)) as PARENT_SERIAL_NUMBER,
        cast(PROCESS_NAME as VARCHAR(12)) as PROCESS_NAME,
        cast(REQUESTED_DELIVERY_DATE as DATE) as REQUESTED_DELIVERY_DATE,
        cast(REVENUE_METHOD as VARCHAR(10)) as REVENUE_METHOD,
        cast(SALES_EMP_NUMBER as VARCHAR(6)) as SALES_EMP_NUMBER,
        cast(SALES_MONTH_CURRENT as DATE) as SALES_MONTH_CURRENT,
        cast(SALES_MONTH_FORECAST as DATE) as SALES_MONTH_FORECAST,
        cast(SALES_ORDER_NUMBER as VARCHAR(20)) as SALES_ORDER_NUMBER,
        cast(SALES_STATION_NAME as VARCHAR(10)) as SALES_STATION_NAME,
        cast(SCH_ACCEPTANCE_DATE as DATE) as SCH_ACCEPTANCE_DATE,
        cast(SCH_CST_DATE as DATE) as SCH_CST_DATE,
        cast(SCH_HAND_OFF_DATE as DATE) as SCH_HAND_OFF_DATE,
        cast(SCH_HW_SU_END_DATE as DATE) as SCH_HW_SU_END_DATE,
        cast(SCH_HW_SU_START_DATE as DATE) as SCH_HW_SU_START_DATE,
        cast(SCH_INSTALLATION_START_DATE as DATE) as SCH_INSTALLATION_START_DATE,
        cast(SCH_MOVE_IN_DATE as DATE) as SCH_MOVE_IN_DATE,
        cast(SCH_ON_DOCK_DATE as DATE) as SCH_ON_DOCK_DATE,
        cast(SCH_SL1_DATE as DATE) as SCH_SL1_DATE,
        cast(SCH_SL2_DATE as DATE) as SCH_SL2_DATE,
        cast(SCH_TEL_PROC_QUAL_END_DATE as DATE) as SCH_TEL_PROC_QUAL_END_DATE,
        cast(SCH_TEL_PROC_QUAL_START_DATE as DATE) as SCH_TEL_PROC_QUAL_START_DATE,
        cast(SCH_WARRANTY_START_DATE as DATE) as SCH_WARRANTY_START_DATE,
        cast(SCH_WTY_END_DATE as DATE) as SCH_WTY_END_DATE,
        cast(SEG_PROCESS_ID as VARCHAR(10)) as SEG_PROCESS_ID,
        cast(SEG_PROCESS_NAME as VARCHAR(40)) as SEG_PROCESS_NAME,
        cast(SERIAL_NUMBER as VARCHAR(20)) as SERIAL_NUMBER,
        cast(SERVICE_STATION_CODE as VARCHAR(10)) as SERVICE_STATION_CODE,
        cast(SERVICE_STATION_NAME as VARCHAR(40)) as SERVICE_STATION_NAME,
        cast(SMS_NUMBER as VARCHAR(10)) as SMS_NUMBER,
        cast(SPEC_DATE as DATE) as SPEC_DATE,
        cast(SPEC_NUMBER as VARCHAR(20)) as SPEC_NUMBER,
        cast(STARTUP_SITE as VARCHAR(215)) as STARTUP_SITE,
        cast(SU_COMMENTS as VARCHAR(100)) as SU_COMMENTS,
        cast(SU_FLAG as VARCHAR(3)) as SU_FLAG,
        cast(SU_MGR_EMP_NUMBER as VARCHAR(15)) as SU_MGR_EMP_NUMBER,
        cast(SU_MGR_NAME as VARCHAR(100)) as SU_MGR_NAME,
        cast(SU_TEAM_LEADER_EMP_NUMBER as VARCHAR(15)) as SU_TEAM_LEADER_EMP_NUMBER,
        cast(SUB_CST_AREA_MGR_EMP_NUMBER_SCEN_U as VARCHAR(15)) as SUB_CST_AREA_MGR_EMP_NUMBER_SCEN_U,
        cast(SUB_CST_AREA_MGR_EMP_NUMBER_SEAN_U as VARCHAR(15)) as SUB_CST_AREA_MGR_EMP_NUMBER_SEAN_U,
        cast(SUB_SU_MGR_EMP_NUMBER as VARCHAR(15)) as SUB_SU_MGR_EMP_NUMBER,
        cast(SUPPLIER_CODE as VARCHAR(6)) as SUPPLIER_CODE,
        cast(SURBFILENAME as VARCHAR(50)) as SURBFILENAME,
        cast(SYSTEM_ID as VARCHAR(10)) as SYSTEM_ID,
        cast(SYSTEM_NAME as VARCHAR(100)) as SYSTEM_NAME,
        cast(TEL_MODEL_CODE as VARCHAR(10)) as TEL_MODEL_CODE,
        cast(TEL_MODEL_NAME as VARCHAR(32)) as TEL_MODEL_NAME,
        cast(TEL_PO_NUMBER as VARCHAR(9)) as TEL_PO_NUMBER,
        cast(TEL_SHIP_DATE as DATE) as TEL_SHIP_DATE,
        cast(TRAINING_CREDIT_EXPIRY_DATE as DATE) as TRAINING_CREDIT_EXPIRY_DATE,
        cast(TRAINING_DAYS_SOLD as VARCHAR(4)) as TRAINING_DAYS_SOLD,
        cast(TRANSACTIONDATE as TIMESTAMP_NTZ(9)) as TRANSACTIONDATE,
        cast(TRANSACTIONID as NUMBER(38,0)) as TRANSACTIONID,
        cast(TRANSACTIONSTATUSDESCRIPTION as VARCHAR(16777216)) as TRANSACTIONSTATUSDESCRIPTION,
        cast(TRANSACTIONSTATUSID as NUMBER(38,0)) as TRANSACTIONSTATUSID,
        cast(TRANSACTIONTYPE as VARCHAR(10)) as TRANSACTIONTYPE,
        cast(USED_EQUIPMENT_FLAG as VARCHAR(1)) as USED_EQUIPMENT_FLAG,
        cast(WAFER_SIZE as VARCHAR(10)) as WAFER_SIZE,
        cast(WARRANTY as VARCHAR(16)) as WARRANTY,
        cast(WARRANTY_FLAG_LABOR as VARCHAR(1)) as WARRANTY_FLAG_LABOR,
        cast(WARRANTY_FLAG_PARTS as VARCHAR(1)) as WARRANTY_FLAG_PARTS,
        cast(WARRANTY_STATUS as VARCHAR(40)) as WARRANTY_STATUS,
        cast(WARRANTY_TERM as VARCHAR(16)) as WARRANTY_TERM,
        cast(WTY_RESERVE_MODEL_ID as VARCHAR(10)) as WTY_RESERVE_MODEL_ID,
        cast(WTY_RESERVE_MODEL_NAME as VARCHAR(40)) as WTY_RESERVE_MODEL_NAME,
        cast(YEAR as VARCHAR(4)) as YEAR,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data