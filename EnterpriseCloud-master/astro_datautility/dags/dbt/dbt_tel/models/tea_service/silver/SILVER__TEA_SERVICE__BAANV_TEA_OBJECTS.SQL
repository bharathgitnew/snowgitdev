{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='BaanV_TEA_Objects',
      transient=false
) }}


with source_data as
(
SELECT DISTINCT a.CONFIGURATION

                 AS Configuration,

             a.OBJECT

                 AS OBJECT,

             a.SERIALNUMBER,

             a.DESCRIPTION

                 AS Customers_Installation_Code,

             a.OBJECTGROUP

                 AS TEL_BU,

             DECODE (g.BUCODETEA, NULL, a.OBJECTGROUP, g.BUCODETEA)

                 AS TEA_BU,

             c.SOLDTOBUSINESSPARTNER

                 AS SoldTo_BP,

             e.NAME

                 AS BP_Name,

             SUBSTR (a.CONFIGURATION,

                     REGEXP_INSTR (a.CONFIGURATION, '-') + 1,

                     LENGTH (a.CONFIGURATION) - REGEXP_INSTR (a.CONFIGURATION, '-') + 1)

                 AS Customer_Site,

             a.WARRANTY

                 AS Wty,

             b.DESCRIPTION

                 AS Wty_Description,

             a.TERMID

                 AS TermID,

             a.TELWTYCHANGEAPPROVALID

                 AS TEL_Wty_Change_Approval,

             --DECODE (a.USEDEQUIPMENTDESCRIPTION,  1, 'YES',  2, 'NO',  a.USEDEQUIPMENTDESCRIPTION)

               --  AS Used_Equipment,
			   
			 CASE  WHEN  a.USEDEQUIPMENTID  = '1' THEN  'YES'
				   WHEN   a.USEDEQUIPMENTID = '2' THEN  'NO'
			 END AS Used_Equipment,

             --DECODE (a.EVALUATIONTOOLSID,  1, 'YES',  2, 'NO',  a.EVALUATIONTOOLSID)

             --AS Evaluation_Tool,
			 
			 CASE  WHEN  a.EVALUATIONTOOLSID  = '1' THEN  'YES'
				   WHEN   a.EVALUATIONTOOLSID = '2' THEN  'NO'
			 END AS Evaluation_Tool,
			 

             a.SYSTEMSTATUSID

                 AS System_Status_Code,

             /*DECODE (a.SYSTEMSTATUSDESCRIPTION,

                     1, 'Pre-Startup',

                     2, 'Startup',

                     3, 'Pre-Wty',

                     4, 'Under-Wty',

                     5, 'Wty-Out',

                     6, 'Retired',

                     7, 'Overseas',

                     8, 'UnderContract',

                     9, 'Pre-Shipment',

                     10, 'Inactive',

                     a.SYSTEMSTATUSDESCRIPTION)*/

             a.SYSTEMSTATUSDESCRIPTION  AS System_Status,

             DECODE (TO_CHAR (a.ACTFINALMACHINESPECDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTFINALMACHINESPECDT)

                 AS Final_Machine_Spec_Dt,

             DECODE (TO_CHAR (a.SALESFORECASTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SALESFORECASTDT)

                 AS Act_Inspection_Dt,

             DECODE (TO_CHAR (a.ACTEXITFACTORYDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTEXITFACTORYDT)

                 AS Act_Exit_Factory_Dt,

             DECODE (TO_CHAR (a.ACTFOBDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTFOBDT)

                 AS Act_FOB_Dt,

             DECODE (TO_CHAR (a.SCHONDOCKDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHONDOCKDT)

                 AS Sch_On_Dock_Dt,

             DECODE (TO_CHAR (a.SCHINSTALLATIONSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHINSTALLATIONSTDT)

                 AS Sch_Installation_St_Dt,

             DECODE (TO_CHAR (a.SCHINSTALLATIONENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHINSTALLATIONENDDT)

                 AS Sch_Installation_End_Dt,

             DECODE (TO_CHAR (a.SCHSL1ENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHSL1ENDDT)

                 AS Sch_SL1_End_Dt,

             DECODE (TO_CHAR (a.SCHSL2ENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHSL2ENDDT)

                 AS Sch_SL2_End_Dt,

             DECODE (TO_CHAR (a.SCHHWSTARTUPSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHHWSTARTUPSTDT)

                 AS Sch_HW_Startup_St_Dt,

             DECODE (TO_CHAR (a.SCHHWSTARTUPENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHHWSTARTUPENDDT)

                 AS Sch_HW_Startup_End_Dt,

             DECODE (TO_CHAR (a.SCHTELPROCQUALSSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHTELPROCQUALSSTDT)

                 AS Sch_TEL_Proc_Quals_St_Dt,

             DECODE (TO_CHAR (a.SCHTELPROCQUALSENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHTELPROCQUALSENDDT)

                 AS Sch_TEL_Proc_Quals_End_Dt,

             DECODE (TO_CHAR (a.SCHCUSTPROCQUALSSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHCUSTPROCQUALSSTDT)

                 AS Sch_Cust_Proc_Quals_St_Dt,

             DECODE (TO_CHAR (a.SCHSETUP_AND_TESTINGENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHSETUP_AND_TESTINGENDDT)

                 AS Sch_Setup_Testing_End_Dt,

             DECODE (TO_CHAR (a.SCHSYSTEMACCEPTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHSYSTEMACCEPTDT)

                 AS Sch_System_Accept_Dt,

             DECODE (TO_CHAR (a.SCHWARRANTYSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHWARRANTYSTDT)

                 AS Sch_Wty_St_Dt,

             DECODE (TO_CHAR (a.SCHWARRANTYENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.SCHWARRANTYENDDT)

                 AS Sch_Wty_End_Dt,

             DECODE (TO_CHAR (a.DELIVERYDATE, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.DELIVERYDATE)

                 AS Act_On_Dock_Dt,

             DECODE (TO_CHAR (a.ACTONSITEDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTONSITEDT)

                 AS Act_On_Site_Dt,

             DECODE (TO_CHAR (a.ACTINSTALLATIONSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTINSTALLATIONSTDT)

                 AS Act_Installation_St_Dt,

             DECODE (TO_CHAR (a.ACTINSTALLATIONENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTINSTALLATIONENDDT)

                 AS Act_Installation_End_Dt,

             DECODE (TO_CHAR (a.ACTSL1ENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTSL1ENDDT)

                 AS Act_SL1_End_Dt,

             DECODE (TO_CHAR (a.ACTSL2ENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTSL2ENDDT)

                 AS Act_SL2_End_Dt,

             DECODE (TO_CHAR (a.ACTHWSTARTUPSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTHWSTARTUPSTDT)

                 AS Act_HW_Startup_St_Dt,

             DECODE (TO_CHAR (a.ACTHWSTARTUPENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTHWSTARTUPENDDT)

                 AS Act_HW_Startup_End_Dt,

             DECODE (TO_CHAR (a.ACTTELPROCQUALSSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTTELPROCQUALSSTDT)

                 AS Act_TEL_Proc_Quals_St_Dt,

             DECODE (TO_CHAR (a.ACTTELPROCQUALSENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTTELPROCQUALSENDDT)

                 AS Act_TEL_Proc_Quals_End_Dt,

             DECODE (TO_CHAR (a.ACTPRE_WARRANTYSTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTPRE_WARRANTYSTDT)

                 AS Act_Pre_Wty_St_Dt,

             DECODE (TO_CHAR (a.ACTPRE_WARRANTYENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTPRE_WARRANTYENDDT)

                 AS Act_Pre_Wty_End_Dt,

             DECODE (TO_CHAR (a.ACTSETUP_AND_TESTINGENDDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTSETUP_AND_TESTINGENDDT)

                 AS Act_Setup_Testing_End_Dt,

             DECODE (TO_CHAR (a.ACTSYSTEMACCEPTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTSYSTEMACCEPTDT)

                 AS Act_System_Accept_Dt,

             DECODE (TO_CHAR (a.ACTCONDITIONALACCEPTDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTCONDITIONALACCEPTDT)

                 AS Act_Conditional_Accept_Dt,

             DECODE (TO_CHAR (a.ACTAPPROVALDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTAPPROVALDT)

                 AS Act_Approval_Dt,

             DECODE (TO_CHAR (a.INSTALLATIONDATE, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.INSTALLATIONDATE)

                 AS Act_Warr_Start_Dt,

             DECODE (TO_CHAR (a.ACTWARRANTYENDDDAT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTWARRANTYENDDDAT)

                 AS Act_Warr_End_Dt,

             DECODE (TO_CHAR (a.ACTMACHINEINACTIVEDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTMACHINEINACTIVEDT)

                 AS Act_Machine_Retired_Dt,

             DECODE (TO_CHAR (a.ACTTRAININGCREDITEXPDT, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.ACTTRAININGCREDITEXPDT)

                 AS Act_Training_Credit_Exp_Dt,

             a.TRAININGDAYSSOLD

                 AS Training_Credits_Sold,

             a.TRAININGCREDITSAVAILABLE

                 AS Training_Credits_Avail,

             a.CUSTPURCHASEORDER

                 AS Customer_Purchase_Order,

             a.TELSALESORDERNUMBER

                 AS TEL_Sales_Order_No,

             a.MACHINESPECNUMBER

                 AS Machine_Spec_No,

             a.TELCONFIGURATIONID

                 AS TEL_Configuration_ID,

             a.BUSINESSINQUIRYNUMBER

                 AS Business_Inquiry_No,

             a.BUILDNO

                 AS Build_No,

             a.WAFERSIZE

                 AS Wafer_Size,

             a.PROCESS

                 AS Process,

             a.REASONACCEPTDELAYCODE

                 AS Reason_Acceptance_Delay_Code,

             a.REASONACCEPTDELAYTEXT

                 AS Reason_Acceptance_Delay_Text,

             a.REASONMACHINERELOCATED

                 AS Reason_Machine_Relocated,

             a.EMPLOYEENUMBER

                 AS Employee_No,

             a.COMMENT

                 AS Comments,

             a.FACTORY

                 AS Factory,

             f.Dimension_Code,

        Case When f.DIMENSION_CODE='6131' Then 'Albany, NY'
            When f.DIMENSION_CODE='6140' Then 'Burlington, VT'
        Else f.DIMENSION_DESCRIPTION
        End As DIMENSION_DESCRIPTION,

             --DECODE (a.EXPIREDID,  1, 'YES',  2, 'NO',  a.EXPIREDID)

             --AS Expired,
			 
			 CASE WHEN  a.EXPIREDID  = '1' THEN 'YES'
				  WHEN  a.EXPIREDID  = '2'THEN  'NO'
			 END AS EXPIRED,

             DECODE (TO_CHAR (a.EXPIRYDATE, 'MM/DD/YYYY'),

                     '01/01/4712', TO_DATE (NULL, 'MM/DD/YYYY'),

                     a.EXPIRYDATE)

                 AS Expired_Date,

             DECODE (h.CHILDOBJECTNUMBER, NULL, 'NO', 'YES')

                AS Child_Object,

             DECODE (p.SERIALNUMBER, NULL, 'NA', p.SERIALNUMBER)

                 AS Parent_Object_SN,

             DECODE (a.SWLHMODELNAME, NULL, a.OBJECT, a.SWLHMODELNAME)

                 AS SWLH_Model,

             /*DECODE (a.OBJECTTYPEID,

                     5, 'Structure',

                     10, 'Product',

                     15, 'Component',

                     20, 'Consumable',

                     a.OBJECTTYPEID)

                 AS Object_Type,*/
				 
				 CASE WHEN  a.OBJECTTYPEID = '5' THEN 'Structure'
					  WHEN   a.OBJECTTYPEID  = '10' THEN 'Product'
					  WHEN   a.OBJECTTYPEID  = '15' THEN 'Component'
					  WHEN   a.OBJECTTYPEID  = '20' THEN 'Consumable'
			     END AS OBJECT_TYPE,
				 
             --DECODE (a.FRFTOOLID,  1, 'YES',  2, 'NO',  a.FRFTOOLID)

               --  AS FRF_Flag,
			   
			   CASE WHEN  a.FRFTOOLID = '1' THEN  'YES'
					WHEN  a.FRFTOOLID = '2' THEN  'NO'
			   END AS FRF_FLAG,

             a.ACCEPTANCEDELAYCOMMENTS

                 AS Acceptance_Delay_Comments

        FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTS') }} a                                   -- Objects Table

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_WARRANTIES') }} b                -- Warranties Table

                                            ON a.WARRANTY = b.WARRANTY

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_CONFIGURATIONS') }} c            -- Configurations Table

                                            ON a.CONFIGURATION = c.CONFIGURATION

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} d                      -- Sold-to BP

                                            ON c.SOLDTOBUSINESSPARTNER = d.SOLDTOBUSINESSPARTNER

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }} e                -- General BP Table

                                            ON d.SOLDTOBUSINESSPARTNER = e.BUSINESSPARTNER

             LEFT OUTER JOIN

             (SELECT B.DIMENSIONTYPE AS DT_Code,

                     D.DIMENSIONDESCRIPTION AS DimensionType,

                     B.STRINGVALUE1 AS Location,

                     B.DIMENSIONCODE AS Dimension_Code,

                     C.DIMENSIONDESCRIPTION AS Dimension_Description,

                     B.INTEGRATIONELEMENT

                FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANFINANCEGENERALLEDGER_SIMPLEINTEGRATIONRELATIONSBYELEMENT') }} B
                , {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONS') }} C
                , {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANFINANCEGENERALLEDGER_DIMENSIONDESCRIPTIONS') }} D

               WHERE     B.DIMENSIONCODE = C.DIMENSIONCODE

                     AND B.DIMENSIONTYPE = C.DIMENSIONTYPE

                     AND B.DIMENSIONTYPE = D.DIMENSIONTYPE

                     AND B.DIMENSIONTYPE = 3

                     AND B.INTEGRATIONELEMENT = 'SVC') f

                 ON c.SERVICECENTER = f.Location

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANCOMMONCOMMONDATA_BUCODEMAPPING') }} g ON a.OBJECTGROUP = g.BUCODETEL

             LEFT OUTER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS') }} h

                 /* Identify Child Objects */

                 ON  a.CONFIGURATION = h.CONFIGURATION

                    AND a.OBJECT = h.CHILDOBJECT

                    AND a.OBJECTNUMBER = h.CHILDOBJECTNUMBER

             LEFT OUTER JOIN

             (SELECT a.CONFIGURATION,

                     a.OBJECT,

                     a.OBJECTNUMBER,

                     b.CHILDOBJECT,

                     b.CHILDOBJECTNUMBER,

                     a.SERIALNUMBER
                FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTS') }} a

                     INNER JOIN {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTRELATIONS') }} b  -- join on parent object  

                         ON     a.CONFIGURATION = b.CONFIGURATION

                            AND a.OBJECT = b.PARENTOBJECT

                            AND a.OBJECTNUMBER = b.PARENTOBJECTNUMBER) p

                 /* Identify Parent Objects */

                 ON     a.CONFIGURATION = p.CONFIGURATION -- join on child object in order to get parent

                    AND a.OBJECT = p.CHILDOBJECT

                    AND a.OBJECTNUMBER = p.CHILDOBJECTNUMBER

       WHERE TRIM (a.SERIALNUMBER) IS NOT NULL

    ORDER BY a.CONFIGURATION, a.OBJECT, a.SERIALNUMBER
)

,transform_data as
(
    select 
          CONFIGURATION AS CONFIGURATION,
          OBJECT AS OBJECT,
          SERIALNUMBER AS SERIAL_NUMBER,
          CUSTOMERS_INSTALLATION_CODE AS CUSTOMERS_INSTALLATION_CODE,
          TEL_BU AS TEL_BU,
          TEA_BU AS TEA_BU,
          SOLDTO_BP AS SOLDTO_BP,
          BP_NAME AS BP_NAME,
          CUSTOMER_SITE AS CUSTOMER_SITE,
          WTY AS WTY,
          WTY_DESCRIPTION AS WTY_DESCRIPTION,
          TERMID AS TERMID,
          TEL_WTY_CHANGE_APPROVAL AS TEL_WTY_CHANGE_APPROVAL,
          USED_EQUIPMENT AS USED_EQUIPMENT,
          EVALUATION_TOOL AS EVALUATION_TOOL,
          SYSTEM_STATUS_CODE AS SYSTEM_STATUS_CODE,
          SYSTEM_STATUS AS SYSTEM_STATUS,
          FINAL_MACHINE_SPEC_DT AS FINAL_MACHINE_SPEC_DT,
          ACT_INSPECTION_DT AS ACT_INSPECTION_DT,
          ACT_EXIT_FACTORY_DT AS ACT_EXIT_FACTORY_DT,
          ACT_FOB_DT AS ACT_FOB_DT, 
          SCH_ON_DOCK_DT AS SCH_ON_DOCK_DT,
          SCH_INSTALLATION_ST_DT AS SCH_INSTALLATION_ST_DT,
          SCH_INSTALLATION_END_DT AS SCH_INSTALLATION_END_DT,
          SCH_SL1_END_DT AS SCH_SL1_END_DT,
          SCH_SL2_END_DT AS SCH_SL2_END_DT,
          SCH_HW_STARTUP_ST_DT AS SCH_HW_STARTUP_ST_DT,
          SCH_HW_STARTUP_END_DT AS SCH_HW_STARTUP_END_DT,
          SCH_TEL_PROC_QUALS_ST_DT AS SCH_TEL_PROC_QUALS_ST_DT,
          SCH_TEL_PROC_QUALS_END_DT AS SCH_TEL_PROC_QUALS_END_DT,
          SCH_CUST_PROC_QUALS_ST_DT AS SCH_CUST_PROC_QUALS_ST_DT,
          SCH_SETUP_TESTING_END_DT AS SCH_SETUP_TESTING_END_DT,
          SCH_SYSTEM_ACCEPT_DT AS SCH_SYSTEM_ACCEPT_DT,
          SCH_WTY_ST_DT AS SCH_WTY_ST_DT,
          SCH_WTY_END_DT AS SCH_WTY_END_DT,
          ACT_ON_DOCK_DT AS ACT_ON_DOCK_DT,
          ACT_ON_SITE_DT AS ACT_ON_SITE_DT,
          ACT_INSTALLATION_ST_DT AS ACT_INSTALLATION_ST_DT,
          ACT_INSTALLATION_END_DT AS ACT_INSTALLATION_END_DT,
          ACT_SL1_END_DT AS ACT_SL1_END_DT,
          ACT_SL2_END_DT AS ACT_SL2_END_DT,
          ACT_HW_STARTUP_ST_DT AS ACT_HW_STARTUP_ST_DT,
          ACT_HW_STARTUP_END_DT AS ACT_HW_STARTUP_END_DT,
          ACT_TEL_PROC_QUALS_ST_DT AS ACT_TEL_PROC_QUALS_ST_DT,
          ACT_TEL_PROC_QUALS_END_DT AS ACT_TEL_PROC_QUALS_END_DT,
          ACT_PRE_WTY_ST_DT AS ACT_PRE_WTY_ST_DT,
          ACT_PRE_WTY_END_DT AS ACT_PRE_WTY_END_DT,
          ACT_SETUP_TESTING_END_DT AS ACT_SETUP_TESTING_END_DT,
          ACT_SYSTEM_ACCEPT_DT AS ACT_SYSTEM_ACCEPT_DT,
          ACT_CONDITIONAL_ACCEPT_DT AS ACT_CONDITIONAL_ACCEPT_DT, 
          ACT_APPROVAL_DT AS ACT_APPROVAL_DT,
          ACT_WARR_START_DT AS ACT_WARR_START_DT,
          ACT_WARR_END_DT AS ACT_WARR_END_DT,
          ACT_MACHINE_RETIRED_DT AS ACT_MACHINE_RETIRED_DT,    
          ACT_TRAINING_CREDIT_EXP_DT AS ACT_ACCEPTANCE_DATE_LOCAL,
          --ACTTRAININGCREDITEXPDT AS ACT_TRAINING_CREDIT_EXP_DT,    
          TRAINING_CREDITS_SOLD AS TRAINING_CREDITS_SOLD,
          TRAINING_CREDITS_AVAIL AS TRAINING_CREDITS_AVAIL,
          CUSTOMER_PURCHASE_ORDER AS CUSTOMER_PURCHASE_ORDER,
          TEL_SALES_ORDER_NO AS TEL_SALES_ORDER_NO,
          MACHINE_SPEC_NO AS MACHINE_SPEC_NO,
          TEL_CONFIGURATION_ID AS MACHINE_HISTORY_REASON,
          BUSINESS_INQUIRY_NO AS BUSINESS_INQUIRY_NO,
          BUILD_NO AS BUILD_NO,
          WAFER_SIZE AS WAFER_SIZE,
          PROCESS AS PROCESS,
          REASON_ACCEPTANCE_DELAY_CODE AS REASON_ACCEPTANCE_DELAY_CODE,
          REASON_ACCEPTANCE_DELAY_TEXT AS REASON_ACCEPTANCE_DELAY_TEXT,
          REASON_MACHINE_RELOCATED AS REASON_MACHINE_RELOCATED,
          EMPLOYEE_NO AS EMPLOYEE_NO,
          COMMENTS AS COMMENTS,
          FACTORY AS FACTORY,
          DIMENSION_CODE AS DIMENSION_CODE,
          DIMENSION_DESCRIPTION AS DIMENSION_DESCRIPTION,
          EXPIRED AS EXPIRED,
          EXPIRED_DATE AS EXPIRED_DATE,
          CHILD_OBJECT AS CHILD_OBJECT,
          PARENT_OBJECT_SN AS PARENT_OBJECT_SN,
          SWLH_MODEL AS SWLH_MODEL,
          OBJECT_TYPE AS OBJECT_TYPE,
          FRF_FLAG AS FRF_FLAG,
          ACCEPTANCE_DELAY_COMMENTS AS ACCEPTANCE_DELAY_COMMENTS
FROM source_data
        )

select * from transform_data