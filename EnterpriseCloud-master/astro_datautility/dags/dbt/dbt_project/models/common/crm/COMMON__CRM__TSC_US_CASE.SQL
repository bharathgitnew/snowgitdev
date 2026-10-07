/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\DirectOrder_Header.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\DirectOrder_Header.SQL
-materialized incremental
-alias DirectOrder_Header
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:06 AM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='TSC_US_CASE'
) }}

with ACCOUNT_REF as (
	select * from {{ ref('ODS__CRM_FILE__ACCOUNT') }}
 	
),
STATUSMETADATA_REF as (
	select * from {{ ref('ODS__CRM_FILE__STATUSMETADATA') }}
 	
),
CONTACT_REF as (
	select * from {{ ref('ODS__CRM_FILE__CONTACT') }}
 	WHERE ISDELETE is NULL
),
SYSTEMUSER_REF as (
	select * from {{ ref('ODS__CRM_FILE__SYSTEMUSER') }}
 	
),
GLOBALOPTIONSETMETADATA_REF as (
	select * from {{ ref('ODS__CRM_FILE__GLOBALOPTIONSETMETADATA') }}
 	
),
MSDYN_CUSTOMERASSET_REF as (
	select * from {{ ref('ODS__CRM_FILE__MSDYN_CUSTOMERASSET') }}
 	
),
TERRITORY_REF as (
	select * from {{ ref('ODS__CRM_FILE__TERRITORY') }}
 	
),
TSC_ROOT_CAUSE_REF as (
	select * from {{ ref('ODS__CRM_FILE__TSC_ROOT_CAUSE') }}
 	
),
COM_TROUBLESHOOTINGDETAILS_REF as (
	select * from {{ ref('ODS__CRM_FILE__COM_TROUBLESHOOTINGDETAILS') }}
 	
),
COM_PRODUCTSYSTEMTYPE_REF as (
	select * from {{ ref('ODS__CRM_FILE__COM_PRODUCTSYSTEMTYPE') }}
 	
),
MSDYN_AGREEMENT_REF as (
	select * from {{ ref('ODS__CRM_FILE__MSDYN_AGREEMENT') }}
 	
),
TSC_KEYWORD_REF as (
	select * from {{ ref('ODS__CRM_FILE__TSC_KEYWORD') }}
 	
),
TEAM_REF as (
	select * from {{ ref('ODS__CRM_FILE__TEAM') }}
 	WHERE ISDELETE is NULL
),
COM_PRODUCTMODEL_REF as (
	select * from {{ ref('ODS__CRM_FILE__COM_PRODUCTMODEL') }}
 	
),
OPTIONSETMETADATA_REF as (
	select * from {{ ref('ODS__CRM_FILE__OPTIONSETMETADATA') }}
 	
),
INCIDENT_REF as (
	select * from {{ ref('ODS__CRM_FILE__INCIDENT') }}
 	WHERE ISDELETE is NULL
),
 source_data as
(
    SELECT
        crm_case.incidentid as Case_ID
        ,Case_Type.LocalizedLabel as Case_Type
        ,Case_Status.LocalizedLabel as Case_Status
        ,Region.name as Region
        ,CASE WHEN crm_case.ownerid_entitytype = 'systemuser' THEN OwnerU.fullname WHEN crm_case.ownerid_entitytype = 'team' THEN OwnerT.name END AS Owner
        ,Person_In_Charge.com_searchkeyword as Person_In_Charge
        ,Team_in_Charge.LocalizedLabel as Team_in_Charge
        ,crm_case.TicketNumber as Case_No
        ,Process_Stage.LocalizedLabel as Process_Stage
        ,crm_case.Title as Case_Title
        ,TEA_Case_Status.LocalizedLabel as TEA_Case_Status
        ,TEA_Case_Substatus.LocalizedLabel as TEA_Case_Substatus
        ,TEA_Priority.LocalizedLabel as Priority_TEA
        ,CASE WHEN crm_case.tea_caseageflag = 0 THEN 'No' ELSE 'Yes' END as Case_Flag
        ,crm_case.tel_casestatustimer as Case_Status_Timer
        ,crm_case.tel_lastcasestatuschanged as Last_Case_Status_Changed
        ,crm_case.tea_caseage as Case_Flag_Hours
        ,crm_case.tea_caseageflagresetdatetime as Flag_Start_Time
        ,Account.name as Fab
        ,Contact.fullname as Customer_Contact
        ,CASE WHEN crm_case.tsc_issendnotification = 0 THEN 'No' ELSE 'Yes' END as Send_Notification
        ,crm_case.followupby as Follow_up_By
        ,crm_case.tea_follow_up_reason as Follow_up_reason
        ,CASE WHEN crm_case.tsc_closing = 0 THEN 'No' ELSE 'Yes' END as Closed
        ,crm_case.tsc_closedtime as Close_Date_Time
        ,Close_Reason.LocalizedLabel as Close_Reason
        ,crm_case.tsc_close_reason_detail as Close_Reason_Detail
        ,crm_case.tea_rma_number as RMA_Number
        ,RMA_Type.LocalizedLabel as RMA_Type
        ,crm_case.tea_rma_comments as RMA_Comments
        ,crm_case.tea_customer_po_number as Customer_PO_Number
        ,crm_case.tea_part_number as Part_Number
        ,crm_case.tea_part_description as Part_Description
        ,crm_case.tea_part_serial_number as Part_Serial_Number
        ,crm_case.tea_problem_description as Problem_Description
        ,crm_case.tea_tsc_special_instructions as TSC_Special_Instructions
        ,crm_case.tsc_noofcats as CATS_Call_No
        ,Original_Case.TicketNumber as Original_Case
        ,Reoccurrence.LocalizedLabel as Reoccurrence
        ,crm_case.tsc_reccurrencecount as Reoccurrence_Count
        ,crm_case.tsc_firstactivitiestime as Initial_Touch_Date_Time
        ,crm_case.tsc_firstactivityduration as Initial_Response_Time
        ,crm_case.tsc_firstactivitiestime as Case_Closed_Date_Time
        ,crm_case.tsc_resolve_time_minute as Time_To_Solve
        ,crm_case.tsc_activitiestotaltime_minutes as Total_Minutes_Taken
        ,crm_case.tsc_mailactivitytotalminutes as Total_Minutes_Taken_on_Email_Action
        ,crm_case.tsc_activitiestotaltime as Total_Minutes_Taken_on_CRM_Action
        ,Channel.LocalizedLabel as Channel
        ,crm_case.tea_casescore as Case_Score
        ,CASE WHEN crm_case.tel_gsrmupdated = 0 THEN 'No' ELSE 'Yes' END as GSRM_Updated
        ,crm_case.tea_mdts as IPN_MDTS
        ,crm_case.tea_kit_eta as Kit_Ship_Date
        ,crm_case.tea_tkmsnumber as TKMS_Number
        ,crm_case.ProductSerialNumber as Machine_Serial_No
        ,Equipment.com_toolid_en as Customer_Tool_ID
        ,Model.com_name as Model
        ,System_Type.com_name as Machine_System_Type
        ,crm_case.tea_secondaryordercontact as Secondary_Order_Contact
        ,crm_case.tsc_contactmemo as Contact_related_Notes
        ,Requested_By.com_searchkeyword as Requested_By
        ,crm_case.tea_teatimespentthistouch as TEA_Time_Spent_This_Touch
        ,crm_case.tea_teatimespenttotal as TEA_Time_Spent_Total
        ,crm_case.tea_intelponotes as Intel_PO_Notes
        ,crm_case.tea_op_related_sales_order as OP_Related_Sales_Order
        ,Blanket_PO.LocalizedLabel as Blanket_PO
        ,OP_Status.LocalizedLabel as OP_Status
        ,crm_case.tea_to_op_comments as To_OP_Comments
        ,crm_case.tsc_receiptdate as Open_Date_Time
        ,CASE WHEN crm_case.tsc_hasnewmessage = 0 THEN 'No' ELSE 'Yes' END as Has_New_Message
        ,Request_From.LocalizedLabel as Request_From
        ,Customer_Request_Type.LocalizedLabel as Customer_Request_Type
        ,Billing_Type.LocalizedLabel as Billing_Type
        ,crm_case.tsc_preferreddate as Due_Date
        ,CASE WHEN crm_case.tsc_istsc = 0 THEN 'No' ELSE 'Yes' END as TSC_Respond
        ,Notification_User1.com_searchkeyword as Notification_User1
        ,Notification_User2.com_searchkeyword as Notification_User2
        ,Notification_User3.com_searchkeyword as Notification_User3
        ,Notification_User4.com_searchkeyword as Notification_User4
        ,Notification_User5.com_searchkeyword as Notification_User5
        ,Contract_Scope.msdyn_name as Contract_Scopes
        ,Escalation_Level.LocalizedLabel as Escalation_Level
        ,Product_Category.com_name as Product
        ,Sub_Contact1.fullname as Sub_Contact1
        ,Sub_Contact2.fullname as Sub_Contact2
        ,Sub_Contact3.fullname as Sub_Contact3
        ,Sub_Contact4.fullname as Sub_Contact4
        ,Sub_Contact5.fullname as Sub_Contact5
        ,crm_case.tsc_software_version as Software_Version
        ,crm_case.tsc_timeofoccurrence as Incident_Date_Time
        ,crm_case.tsc_frequency as Frequency
        ,Model_Causing.com_name as Model_Causing
        ,Module_Code_Causing.com_name as Module_Code_Causing
        ,Module_Detail_Causing.com_name as Module_Detail_Causing
        ,Trouble_Code_Causing.com_name as Trouble_Code_Causing
        ,Trouble_Detail_Causing.com_name as Trouble_Detail_Causing
        ,CASE WHEN crm_case.tsc_copytofixedportion = 0 THEN 'No' ELSE 'Yes' END as Copy_to_Resolution_Detail
        ,Root_Cause.tsc_name as Root_Cause
        ,crm_case.tsc_case_for_rtissqvics as Case_for_RTISS_QVICS
        ,crm_case.tsc_open_date_time_of_rtissqvics as Issue_Date_Time_RTISS_QVICS
        ,CASE WHEN crm_case.tsc_factory_support_request = 0 THEN 'No' ELSE 'Yes' END as Factory_Support_Request
        ,crm_case.tsc_close_date_time_rtiss as RTISS_Close_Date_Time
        ,crm_case.tsc_phenomena_rtiss as RTISS_Phenomena
        ,crm_case.tsc_cause_rtiss as RTISS_Cause
        ,crm_case.tsc_status_rtiss as RTISS_Status
        ,crm_case.tsc_measure_rtiss as RTISS_Measure
        ,crm_case.tsc_others_rtiss as RTISS_Others
        ,crm_case.tsc_close_date_time_qvics as QVICS_Close_Date_Time
        ,crm_case.tsc_phenomena_qvics as QVICS_Phenomena
        ,crm_case.tsc_cause_qvics as QVICS_Cause
        ,crm_case.tsc_status_qvics as QVICS_Status
        ,crm_case.tsc_measure_qvics as QVICS_Measure
        ,crm_case.tsc_others_qvics as QVICS_Others
        ,crm_case.tsc_close_date_time_tiss as TISS_Close_Date_Time
        ,crm_case.tsc_phenomena_tiss as TISS_Phenomena
        ,crm_case.tsc_cause_tiss as TISS_Cause
        ,crm_case.tsc_status_tiss as TISS_Status
        ,crm_case.tsc_measure_tiss as TISS_Measure
        ,crm_case.tsc_others_tiss as TISS_Others
        ,Keyword1.tsc_keyword as Keyword1
        ,Keyword2.tsc_keyword as Keyword2
        ,Keyword3.tsc_keyword as Keyword3
        ,Model_Fixed.com_name as Model_Fixed
        ,Module_Code_Fixed.com_name as Module_Code_Fixed
        ,Module_Detail_Fixed.com_name as Module_Detail_Fixed
        ,Trouble_Code_Fixed.com_name as Trouble_Code_Fixed
        ,Trouble_Detail_Fixed.com_name as Trouble_Detail_Fixed
        ,crm_case.modifiedon as modifiedon
        ,crm_case.createdbyname as createdbyname
        ,crm_case.modifiedbyyominame as modifiedby 
        ,Status_Reason.LOCALIZEDLABEL as Status_Reason
        ,priority.localizedlabel as Priority
        ,crm_case.TSC_PRODUCT_CATEGORYNAME as Product_Category
        ,crm_case.TSC_NOTES as TSC_NOTES

    FROM INCIDENT_REF  as crm_case
        LEFT OUTER JOIN (SELECT * FROM OPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_casestatus') as TEA_Case_Status on crm_case.tea_casestatus = TEA_Case_Status.Option
        LEFT OUTER JOIN (SELECT * FROM OPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_casestatus_substatus') as TEA_Case_Substatus on crm_case.tea_casestatus_substatus = TEA_Case_Substatus.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_priority') as TEA_Priority on crm_case.tea_priority = TEA_Priority.Option
        LEFT OUTER JOIN (SELECT * FROM OPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_teamincharge') as Team_in_Charge on crm_case.tea_teamincharge = Team_in_Charge.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_case_open_close_status') as Case_Status on crm_case.tsc_case_open_close_status = Case_Status.Option
        LEFT OUTER JOIN (SELECT * FROM OPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_rmatype') as RMA_Type on crm_case.tea_rmatype = RMA_Type.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_recurrence') as Reoccurrence on crm_case.tsc_recurrence = Reoccurrence.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'caseorigincode' QUALIFY ROW_NUMBER() OVER (PARTITION BY OPTION order by _filedate desc)=1) as Channel on crm_case.caseorigincode = Channel.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_escalation_level') as Escalation_Level on crm_case.tsc_escalation_level = Escalation_Level.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_blanketpo') as Blanket_PO on crm_case.tea_blanketpo = Blanket_PO.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tea_op_status') as OP_Status on crm_case.tea_op_status = OP_Status.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_close_reason') as Close_Reason on crm_case.tsc_close_reason = Close_Reason.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_customerrequest') as Customer_Request_Type on crm_case.tsc_customerrequest = Customer_Request_Type.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_inquirytype') as Case_Type on crm_case.tsc_inquirytype = Case_Type.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_isinhouse') as Request_From on crm_case.tsc_isinhouse = Request_From.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND OptionSetName = 'tsc_maintenancestatus') as Billing_Type on crm_case.tsc_maintenancestatus = Billing_Type.Option
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND ENTITYNAME = 'incident' AND OptionSetName = 'tsc_process_stage') as Process_Stage on crm_case.tsc_process_stage = Process_Stage.Option
        LEFT OUTER JOIN (SELECT * FROM STATUSMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND ENTITYNAME = 'incident' ) as Status_Reason on crm_case.STATUSCODE = Status_Reason.STATUS
        LEFT OUTER JOIN (SELECT * FROM GLOBALOPTIONSETMETADATA_REF WHERE LocalizedLabelLanguageCode = 1033 AND ENTITYNAME = 'incident' and OPTIONSETNAME = 'tsc_priority') as priority on crm_case.TSC_PRIORITY = priority.OPTION
        LEFT OUTER JOIN ACCOUNT_REF as Account ON crm_case.CustomerId = Account.Id
        LEFT OUTER JOIN CONTACT_REF as Contact ON crm_case.tel_tsc_contact = Contact.Id
        LEFT OUTER JOIN INCIDENT_REF  as Original_Case ON crm_case.tsc_origincaseid = Original_Case.Id
        LEFT OUTER JOIN MSDYN_CUSTOMERASSET_REF as Equipment ON crm_case.tsc_customertoolid = Equipment.Id
        LEFT OUTER JOIN COM_PRODUCTMODEL_REF  as Product_Category ON crm_case.tsc_product_category = Product_Category.com_productmodelid
        LEFT OUTER JOIN COM_PRODUCTMODEL_REF  as Model ON crm_case.tsc_model = Model.com_productmodelid
        LEFT OUTER JOIN COM_PRODUCTSYSTEMTYPE_REF as System_Type ON crm_case.tsc_toolsystemtype = System_Type.com_productsystemtypeid
        LEFT OUTER JOIN SYSTEMUSER_REF as Person_In_Charge ON crm_case.tsc_pic = Person_In_Charge.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Requested_By ON crm_case.tsc_domesticcrmuser = Requested_By.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Notification_User1 ON crm_case.tsc_notification_user_1 = Notification_User1.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Notification_User2 ON crm_case.tsc_notification_user_2 = Notification_User2.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Notification_User3 ON crm_case.tsc_notification_user_3 = Notification_User3.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Notification_User4 ON crm_case.tsc_notification_user_4 = Notification_User4.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as Notification_User5 ON crm_case.tsc_notification_user_5 = Notification_User5.Id
        LEFT OUTER JOIN CONTACT_REF as Sub_Contact1 ON crm_case.tsc_sub_contact_1 = Sub_Contact1.Id
        LEFT OUTER JOIN CONTACT_REF as Sub_Contact2 ON crm_case.tsc_sub_contact_2 = Sub_Contact2.Id
        LEFT OUTER JOIN CONTACT_REF as Sub_Contact3 ON crm_case.tsc_sub_contact_3 = Sub_Contact3.Id
        LEFT OUTER JOIN CONTACT_REF as Sub_Contact4 ON crm_case.tsc_sub_contact_4 = Sub_Contact4.Id
        LEFT OUTER JOIN CONTACT_REF as Sub_Contact5 ON crm_case.tsc_sub_contact_5 = Sub_Contact5.Id
        LEFT OUTER JOIN TERRITORY_REF as Region ON crm_case.tsc_territory = Region.Id
        LEFT OUTER JOIN MSDYN_AGREEMENT_REF as Contract_Scope ON crm_case.tsc_sow = Contract_Scope.msdyn_agreementid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Model_Causing ON crm_case.tsc_causing_model = Model_Causing.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Module_Code_Causing ON crm_case.tsc_causing_process = Module_Code_Causing.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Module_Detail_Causing ON crm_case.tsc_causing_module = Module_Detail_Causing.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Trouble_Code_Causing ON crm_case.tsc_causing_trouble_code = Trouble_Code_Causing.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Trouble_Detail_Causing ON crm_case.tsc_causing_trouble_detail = Trouble_Detail_Causing.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Model_Fixed ON crm_case.tsc_fixedmodelid = Model_Fixed.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Module_Code_Fixed ON crm_case.tsc_fixedprocessid = Module_Code_Fixed.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Module_Detail_Fixed ON crm_case.tsc_fixedmoduleid = Module_Detail_Fixed.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Trouble_Code_Fixed ON crm_case.tsc_fixed_trouble_code = Trouble_Code_Fixed.com_troubleshootingdetailsid
        LEFT OUTER JOIN COM_TROUBLESHOOTINGDETAILS_REF as Trouble_Detail_Fixed ON crm_case.tsc_fixed_trouble_detail = Trouble_Detail_Fixed.com_troubleshootingdetailsid
        LEFT OUTER JOIN TSC_KEYWORD_REF as Keyword1 ON crm_case.tsc_knowledgekeyword1 = Keyword1.tsc_keywordid
        LEFT OUTER JOIN TSC_KEYWORD_REF as Keyword2 ON crm_case.tsc_knowledgekeyword2 = Keyword2.tsc_keywordid
        LEFT OUTER JOIN TSC_KEYWORD_REF as Keyword3 ON crm_case.tsc_knowledgekeyword3 = Keyword3.tsc_keywordid
        LEFT OUTER JOIN TSC_ROOT_CAUSE_REF as Root_Cause ON crm_case.tsc_trouble_cause = Root_Cause.tsc_root_causeid
        LEFT OUTER JOIN TEAM_REF as OwnerT ON crm_case.ownerid = OwnerT.Id
        LEFT OUTER JOIN SYSTEMUSER_REF as OwnerU ON crm_case.ownerid = OwnerU.Id
)

,transform_data as
(
    SELECT
        Case_ID,
        Case_Type,
        Case_Status,
        Region,
        Owner,
        Person_In_Charge,
        Team_in_Charge,
        Case_No,
        Process_Stage,
        Case_Title,
        TEA_Case_Status,
        TEA_Case_Substatus,
        Priority_TEA,
        Case_Flag,
        Case_Status_Timer,
        Last_Case_Status_Changed,
        Case_Flag_Hours,
        Flag_Start_Time,
        Fab,
        Customer_Contact,
        Send_Notification,
        Follow_up_By,
        Follow_up_reason,
        Closed,
        Close_Date_Time,
        Close_Reason,
        Close_Reason_Detail,
        RMA_Number,
        RMA_Type,
        RMA_Comments,
        Customer_PO_Number,
        Part_Number,
        Part_Description,
        Part_Serial_Number,
        Problem_Description,
        TSC_Special_Instructions,
        CATS_Call_No,
        Original_Case,
        Reoccurrence,
        Reoccurrence_Count,
        Initial_Touch_Date_Time,
        Initial_Response_Time,
        Case_Closed_Date_Time,
        Time_To_Solve,
        Total_Minutes_Taken,
        Total_Minutes_Taken_on_Email_Action,
        Total_Minutes_Taken_on_CRM_Action,
        Channel,
        Case_Score,
        GSRM_Updated,
        IPN_MDTS,
        Kit_Ship_Date,
        TKMS_Number,
        Machine_Serial_No,
        Customer_Tool_ID,
        Model,
        Machine_System_Type,
        Secondary_Order_Contact,
        Contact_related_Notes,
        Requested_By,
        TEA_Time_Spent_This_Touch,
        TEA_Time_Spent_Total,
        Intel_PO_Notes,
        OP_Related_Sales_Order,
        Blanket_PO,
        OP_Status,
        To_OP_Comments,
        Open_Date_Time,
        Has_New_Message,
        Request_From,
        Customer_Request_Type,
        Billing_Type,
        Due_Date,
        TSC_Respond,
        Notification_User1,
        Notification_User2,
        Notification_User3,
        Notification_User4,
        Notification_User5,
        Contract_Scopes,
        Escalation_Level,
        Product,
        Sub_Contact1,
        Sub_Contact2,
        Sub_Contact3,
        Sub_Contact4,
        Sub_Contact5,
        Software_Version,
        Incident_Date_Time,
        Frequency,
        Model_Causing,
        Module_Code_Causing,
        Module_Detail_Causing,
        Trouble_Code_Causing,
        Trouble_Detail_Causing,
        Copy_to_Resolution_Detail,
        Root_Cause,
        Case_for_RTISS_QVICS,
        Issue_Date_Time_RTISS_QVICS,
        Factory_Support_Request,
        RTISS_Close_Date_Time,
        RTISS_Phenomena,
        RTISS_Cause,
        RTISS_Status,
        RTISS_Measure,
        RTISS_Others,
        QVICS_Close_Date_Time,
        QVICS_Phenomena,
        QVICS_Cause,
        QVICS_Status,
        QVICS_Measure,
        QVICS_Others,
        TISS_Close_Date_Time,
        TISS_Phenomena,
        TISS_Cause,
        TISS_Status,
        TISS_Measure,
        TISS_Others,
        Keyword1,
        Keyword2,
        Keyword3,
        Model_Fixed,
        Module_Code_Fixed,
        Module_Detail_Fixed,
        Trouble_Code_Fixed,
        Trouble_Detail_Fixed,
        modifiedon,
        createdbyname,
        modifiedby,
        Status_Reason,
        Priority,
        Product_Category,
        TSC_NOTES,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)

,type_data as
(
    select
        cast(Case_ID  as VARCHAR(16777216)) as Case_ID,
        cast(Case_Type  as VARCHAR(16777216)) as Case_Type,
        cast(Case_Status  as VARCHAR(16777216)) as Case_Status,
        cast(Region  as VARCHAR(16777216)) as Region,
        cast(Owner  as VARCHAR(16777216)) as Owner,
        cast(Person_In_Charge  as VARCHAR(16777216)) as Person_In_Charge,
        cast(Team_in_Charge  as VARCHAR(16777216)) as Team_in_Charge,
        cast(Case_No  as VARCHAR(16777216)) as Case_No,
        cast(Process_Stage  as VARCHAR(16777216)) as Process_Stage,
        cast(Case_Title  as VARCHAR(16777216)) as Case_Title,
        cast(TEA_Case_Status  as VARCHAR(16777216)) as TEA_Case_Status,
        cast(TEA_Case_Substatus  as VARCHAR(16777216)) as TEA_Case_Substatus,
        cast(Priority_TEA  as VARCHAR(16777216)) as Priority_TEA,
        cast(Case_Flag  as VARCHAR(16777216)) as Case_Flag,
        cast(Case_Status_Timer  as VARCHAR(16777216)) as Case_Status_Timer,
        cast(Last_Case_Status_Changed as TIMESTAMP_NTZ(9)) as Last_Case_Status_Changed,
        cast(Case_Flag_Hours  as VARCHAR(16777216)) as Case_Flag_Hours,
        cast(Flag_Start_Time as TIMESTAMP_NTZ(9)) as Flag_Start_Time,
        cast(Fab  as VARCHAR(16777216)) as Fab,
        cast(Customer_Contact  as VARCHAR(16777216)) as Customer_Contact,
        cast(Send_Notification  as VARCHAR(16777216)) as Send_Notification,
        cast(Follow_up_By as TIMESTAMP_NTZ(9)) as Follow_up_By,
        cast(Follow_up_reason  as VARCHAR(16777216)) as Follow_up_reason,
        cast(Closed  as VARCHAR(16777216)) as Closed,
        cast(Close_Date_Time as TIMESTAMP_NTZ(9)) as Close_Date_Time,
        cast(Close_Reason  as VARCHAR(16777216)) as Close_Reason,
        cast(Close_Reason_Detail  as VARCHAR(16777216)) as Close_Reason_Detail,
        cast(RMA_Number  as VARCHAR(16777216)) as RMA_Number,
        cast(RMA_Type  as VARCHAR(16777216)) as RMA_Type,
        cast(RMA_Comments  as VARCHAR(16777216)) as RMA_Comments,
        cast(Customer_PO_Number  as VARCHAR(16777216)) as Customer_PO_Number,
        cast(Part_Number  as VARCHAR(16777216)) as Part_Number,
        cast(Part_Description  as VARCHAR(16777216)) as Part_Description,
        cast(Part_Serial_Number  as VARCHAR(16777216)) as Part_Serial_Number,
        cast(Problem_Description  as VARCHAR(16777216)) as Problem_Description,
        cast(TSC_Special_Instructions  as VARCHAR(16777216)) as TSC_Special_Instructions,
        cast(CATS_Call_No  as VARCHAR(16777216)) as CATS_Call_No,
        cast(Original_Case  as VARCHAR(16777216)) as Original_Case,
        cast(Reoccurrence  as VARCHAR(16777216)) as Reoccurrence,
        cast(Reoccurrence_Count  as VARCHAR(16777216)) as Reoccurrence_Count,
        cast(Initial_Touch_Date_Time as TIMESTAMP_NTZ(9)) as Initial_Touch_Date_Time,
        cast(Initial_Response_Time as TIMESTAMP_NTZ(9)) as Initial_Response_Time,
        cast(Case_Closed_Date_Time as TIMESTAMP_NTZ(9)) as Case_Closed_Date_Time,
        cast(Time_To_Solve  as VARCHAR(16777216)) as Time_To_Solve,
        cast(Total_Minutes_Taken  as VARCHAR(16777216)) as Total_Minutes_Taken,
        cast(Total_Minutes_Taken_on_Email_Action  as VARCHAR(16777216)) as Total_Minutes_Taken_on_Email_Action,
        cast(Total_Minutes_Taken_on_CRM_Action  as VARCHAR(16777216)) as Total_Minutes_Taken_on_CRM_Action,
        cast(Channel  as VARCHAR(16777216)) as Channel,
        cast(Case_Score  as VARCHAR(16777216)) as Case_Score,
        cast(GSRM_Updated  as VARCHAR(16777216)) as GSRM_Updated,
        cast(IPN_MDTS  as VARCHAR(16777216)) as IPN_MDTS,
        cast(Kit_Ship_Date as TIMESTAMP_NTZ(9)) as Kit_Ship_Date,
        cast(TKMS_Number  as VARCHAR(16777216)) as TKMS_Number,
        cast(Machine_Serial_No  as VARCHAR(16777216)) as Machine_Serial_No,
        cast(Customer_Tool_ID  as VARCHAR(16777216)) as Customer_Tool_ID,
        cast(Model as VARCHAR(16777216)) as Model,
        cast(Machine_System_Type  as VARCHAR(16777216)) as Machine_System_Type,
        cast(Secondary_Order_Contact  as VARCHAR(16777216)) as Secondary_Order_Contact,
        cast(Contact_related_Notes  as VARCHAR(16777216)) as Contact_related_Notes,
        cast(Requested_By  as VARCHAR(16777216)) as Requested_By,
        cast(TEA_Time_Spent_This_Touch  as VARCHAR(16777216)) as TEA_Time_Spent_This_Touch,
        cast(TEA_Time_Spent_Total  as VARCHAR(16777216)) as TEA_Time_Spent_Total,
        cast(Intel_PO_Notes  as VARCHAR(16777216)) as Intel_PO_Notes,
        cast(OP_Related_Sales_Order  as VARCHAR(16777216)) as OP_Related_Sales_Order,
        cast(Blanket_PO  as VARCHAR(16777216)) as Blanket_PO,
        cast(OP_Status  as VARCHAR(16777216)) as OP_Status,
        cast(To_OP_Comments  as VARCHAR(16777216)) as To_OP_Comments,
        cast(Open_Date_Time as TIMESTAMP_NTZ(9)) as Open_Date_Time,
        cast(Has_New_Message  as VARCHAR(16777216)) as Has_New_Message,
        cast(Request_From  as VARCHAR(16777216)) as Request_From,
        cast(Customer_Request_Type  as VARCHAR(16777216)) as Customer_Request_Type,
        cast(Billing_Type  as VARCHAR(16777216)) as Billing_Type,
        cast(Due_Date as TIMESTAMP_NTZ(9)) as Due_Date,
        cast(TSC_Respond  as VARCHAR(16777216)) as TSC_Respond,
        cast(Notification_User1  as VARCHAR(16777216)) as Notification_User1,
        cast(Notification_User2  as VARCHAR(16777216)) as Notification_User2,
        cast(Notification_User3  as VARCHAR(16777216)) as Notification_User3,
        cast(Notification_User4  as VARCHAR(16777216)) as Notification_User4,
        cast(Notification_User5  as VARCHAR(16777216)) as Notification_User5,
        cast(Contract_Scopes  as VARCHAR(16777216)) as Contract_Scopes,
        cast(Escalation_Level  as VARCHAR(16777216)) as Escalation_Level,
        cast(Product as VARCHAR(16777216)) as Product,
        cast(Sub_Contact1  as VARCHAR(16777216)) as Sub_Contact1,
        cast(Sub_Contact2  as VARCHAR(16777216)) as Sub_Contact2,
        cast(Sub_Contact3  as VARCHAR(16777216)) as Sub_Contact3,
        cast(Sub_Contact4  as VARCHAR(16777216)) as Sub_Contact4,
        cast(Sub_Contact5  as VARCHAR(16777216)) as Sub_Contact5,
        cast(Software_Version  as VARCHAR(16777216)) as Software_Version,
        cast(Incident_Date_Time as TIMESTAMP_NTZ(9)) as Incident_Date_Time,
        cast(Frequency  as VARCHAR(16777216)) as Frequency,
        cast(Model_Causing  as VARCHAR(16777216)) as Model_Causing,
        cast(Module_Code_Causing  as VARCHAR(16777216)) as Module_Code_Causing,
        cast(Module_Detail_Causing  as VARCHAR(16777216)) as Module_Detail_Causing,
        cast(Trouble_Code_Causing  as VARCHAR(16777216)) as Trouble_Code_Causing,
        cast(Trouble_Detail_Causing  as VARCHAR(16777216)) as Trouble_Detail_Causing,
        cast(Copy_to_Resolution_Detail  as VARCHAR(16777216)) as Copy_to_Resolution_Detail,
        cast(Root_Cause  as VARCHAR(16777216)) as Root_Cause,
        cast(Case_for_RTISS_QVICS  as VARCHAR(16777216)) as Case_for_RTISS_QVICS,
        cast(Issue_Date_Time_RTISS_QVICS as TIMESTAMP_NTZ(9)) as Issue_Date_Time_RTISS_QVICS,
        cast(Factory_Support_Request  as VARCHAR(16777216)) as Factory_Support_Request,
        cast(RTISS_Close_Date_Time as TIMESTAMP_NTZ(9)) as RTISS_Close_Date_Time,
        cast(RTISS_Phenomena  as VARCHAR(16777216)) as RTISS_Phenomena,
        cast(RTISS_Cause  as VARCHAR(16777216)) as RTISS_Cause,
        cast(RTISS_Status  as VARCHAR(16777216)) as RTISS_Status,
        cast(RTISS_Measure  as VARCHAR(16777216)) as RTISS_Measure,
        cast(RTISS_Others  as VARCHAR(16777216)) as RTISS_Others,
        cast(QVICS_Close_Date_Time as TIMESTAMP_NTZ(9)) as QVICS_Close_Date_Time,
        cast(QVICS_Phenomena  as VARCHAR(16777216)) as QVICS_Phenomena,
        cast(QVICS_Cause  as VARCHAR(16777216)) as QVICS_Cause,
        cast(QVICS_Status  as VARCHAR(16777216)) as QVICS_Status,
        cast(QVICS_Measure  as VARCHAR(16777216)) as QVICS_Measure,
        cast(QVICS_Others  as VARCHAR(16777216)) as QVICS_Others,
        cast(TISS_Close_Date_Time as TIMESTAMP_NTZ(9)) as TISS_Close_Date_Time,
        cast(TISS_Phenomena  as VARCHAR(16777216)) as TISS_Phenomena,
        cast(TISS_Cause  as VARCHAR(16777216)) as TISS_Cause,
        cast(TISS_Status  as VARCHAR(16777216)) as TISS_Status,
        cast(TISS_Measure  as VARCHAR(16777216)) as TISS_Measure,
        cast(TISS_Others  as VARCHAR(16777216)) as TISS_Others,
        cast(Keyword1  as VARCHAR(16777216)) as Keyword1,
        cast(Keyword2  as VARCHAR(16777216)) as Keyword2,
        cast(Keyword3  as VARCHAR(16777216)) as Keyword3,
        cast(Model_Fixed  as VARCHAR(16777216)) as Model_Fixed,
        cast(Module_Code_Fixed  as VARCHAR(16777216)) as Module_Code_Fixed,
        cast(Module_Detail_Fixed  as VARCHAR(16777216)) as Module_Detail_Fixed,
        cast(Trouble_Code_Fixed  as VARCHAR(16777216)) as Trouble_Code_Fixed,
        cast(Trouble_Detail_Fixed  as VARCHAR(16777216)) as Trouble_Detail_Fixed,
        cast(modifiedon  as VARCHAR(16777216)) as modifiedon,
        cast(createdbyname  as VARCHAR(16777216)) as createdbyname,
        cast(modifiedby  as VARCHAR(16777216)) as modifiedby,
        cast(Status_Reason  as VARCHAR(16777216)) as Status_Reason,
        cast(Priority  as VARCHAR(16777216)) as Priority,
        cast(Product_Category  as VARCHAR(16777216)) as Product_Category,
        cast(TSC_NOTES  as VARCHAR(16777216)) as TSC_NOTES,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data