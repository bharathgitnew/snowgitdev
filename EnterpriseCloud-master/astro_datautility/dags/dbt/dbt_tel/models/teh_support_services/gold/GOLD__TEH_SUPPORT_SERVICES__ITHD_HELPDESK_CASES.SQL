{{ config(
    alias='ITHD_HELPDESK_CASES',
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
) }}

-- TODO: re evaluate what data is needed for reporting and design arround ServiceNow instead of ITHD

-- IT Helpdesk Cases (Dynamics 365)
with contact as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_CONTACT') }}
),

incident as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_INCIDENT') }}
),

GlobalOptionSetMetadata as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_GLOBALOPTIONSETMETADATA') }}
),

SYSTEMUSER as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_SYSTEMUSER') }}
),

slakpiinstance as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_SLAKPIINSTANCE') }}
),

mca_location as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_LOCATION') }}
),

queue as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_QUEUE') }}
),

mca_location as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_LOCATION') }}
),

mca_internalsystemname as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_INTERNALSYSTEMNAME') }}
),

mca_internalsystemmodule as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_INTERNALSYSTEMMODULE') }}
),

mca_externalcasesubtype as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_EXTERNALCASESUBTYPE') }}
),

mca_externalcasetype as (
    select *
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__ITHD_MCA_EXTERNALCASETYPE') }}
),

all_ithd as (
    select
    ---------- CASE DETAILS ----------
		i._FILEDATE
       ,i.ticketnumber AS CaseNumber
      ,i.title AS CaseTitle
	  ,CASE i.caseorigincode
		  WHEN 1 THEN 'Phone'
		  WHEN 2 THEN 'Email'
		  WHEN 3 THEN 'Portal'
		  WHEN 2483 THEN 'Walk-in'
		  WHEN 3986 THEN 'Onboarding System'
		  WHEN 803930000 THEN 'System Generated'
		  WHEN 803930001 THEN 'IT Internal'
	  END AS Origin
	  ,CASE i.prioritycode
		  WHEN 0 THEN '1- Critical'
		  WHEN 1 THEN '2- High'
		  WHEN 2 THEN '3- Normal'
		  WHEN 3 THEN '4- Low'
	  END AS Urgency
	  ,i.mca_urgencyreason AS UrgencyReason
	  ,CASE i.mca_impacton
		  WHEN 803930000 THEN 'Location'
		  WHEN 803930001 THEN 'Team'
		  WHEN 803930002 THEN 'Department'
		  WHEN 803930003 THEN 'Individual'
		  WHEN 803930004 THEN 'Unsure'
	  END AS ImpactOn
  ,primarycontactid.fullname AS PrimaryContact
  ,primarycontactid.employeeid AS PrimaryContactEmployeeID
  ,primarycontactid.emailaddress1 AS PrimaryContactEmailAddress
        ,mca_requestorlocation.mca_name AS PrimaryContactLocation
  ,CASE i.mca_preferredcontact
		  WHEN 803930000 THEN 'Cellular'
		  WHEN 803930001 THEN 'Business Phone'
		  WHEN 803930002 THEN 'Email'
		  WHEN 803930003 THEN 'IM'
		  WHEN 803930004 THEN 'Other'
	  END AS PreferredContact
      ,i.mca_preferredcontactdetail AS PreferredContactDetail
      ,CASE i.mca_emailnotifications
		  WHEN 803930000 THEN 'Opt-In'
		  WHEN 803930001 THEN 'Opt-Out'
	  END AS EmailNotification
	  ,responsiblecontactid.fullname AS AdditionalContact
      ,CASE i.mca_duplicate
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS Duplicate
	  ,parentcaseid.ticketnumber AS ParentCase
	  ,CASE i.statuscode
		  WHEN 1 THEN 'In Progress'
		  WHEN 2 THEN 'On Hold'
		  WHEN 3 THEN 'New'
		  WHEN 4 THEN 'Resolved - Pending Confirmation'
		  WHEN 5 THEN 'Resolved - Closed'
		  WHEN 6 THEN 'Canceled'
		  WHEN 2000 THEN 'Merged'
		  WHEN 803930000 THEN 'Duplicate'
	  END AS Status
      ,i.mca_onholdreason AS OnHoldReason
      ,CASE i.mca_resolved
		  WHEN 803930000 THEN 'No'
		  WHEN 803930001 THEN 'Yes'
	  END AS ConfirmResolution
      ,CASE i.firstresponsesent
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS TriageCompleted
      ,CASE
		  WHEN i.statuscode IN (3,1,2) THEN DATEDIFF(day,i.createdon,GETDATE())
		  WHEN i.statuscode IN (4,5,6,2000,803930000) AND i.adx_resolutiondate IS NOT NULL THEN DATEDIFF(day,i.createdon,i.adx_resolutiondate)
		  WHEN i.statuscode IN (4,5,6,2000,803930000) AND i.adx_resolutiondate IS NULL THEN DATEDIFF(day,i.createdon,i.modifiedon)
	  END AS AgeDays -- i.mca_age
	  ,CASE i.mca_sendtotgis
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS SendToTGIS
      ,CASE i.mca_sendtotgisprocessed
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
		END AS SendToTGISProcessed
      ,i.mca_tgisnumber AS TGISNumber
	  ,i.mca_eta AS ETA -- stored in UTC
	  ,i.mca_pmoprogressupdate AS PMOUpdate --Added on 1/8/2024

      -------- RECORD INFORMATION ----------
	  ,createdby.fullname AS CreatedByUser
	  ,createdby.internalemailaddress AS CreatedByUserEmailAddress
	  ,mca_createdbycontact.fullname AS CreatedByContact
	  ,mca_createdbycontact.employeeid AS CreatedByContactEmployeeID
	  ,mca_createdbycontact.emailaddress1 AS CreatedByContactEmailAddress
      ,CAST(i.createdon AS datetime) AS CreatedOn -- stored in UTC
	  ,modifiedby.fullname AS ModifiedBy
	  ,modifiedby.internalemailaddress AS ModifiedByUserEmailAddress
      ,i.modifiedon AS ModifiedOn -- stored in UTC
      ,mca_resolvedby.fullname AS ResolvedBy
	  ,mca_resolvedby.internalemailaddress AS ResolvedByUserEmailAddress
      ,i.adx_resolutiondate AS ResolvedOn -- stored in UTC
	  ,CASE i.statecode
		  WHEN 0 THEN 'Active'
		  WHEN 1 THEN 'Resolved'
		  WHEN 2 THEN 'Canceled'
	  END AS State
	  --,i.owneridyominame AS Owner
	  ,ownerid.fullname AS Owner
	  ,ownerid.internalemailaddress AS OwnerUserEmailAddress
	  ,CASE i.customerid
		  WHEN lower('613DD912-6AFA-E611-8103-C4346BC4EF6C') THEN 'TEL'
	  END AS SystemCustomer
	  --,i.mca_manageryominame AS Manager
	  ,mca_manager.fullname AS Manager
	  ,mca_manager.employeeid AS ManagerContactEmployeeID
	  ,mca_manager.emailaddress1 AS ManagerContactEmailAddress
      ,i.mca_closeme AS CloseMe
	  ,mca_systemparentcaseid.ticketnumber AS SystemParentCase
       ,i.description AS Description
    -------- IT CATEGORIZATION ----------
      ,CASE i.mca_region
		  WHEN lower('DC62A3A7-73EE-E611-80FC-C4346BAC2908') THEN 'USA'
		  WHEN lower('21AE4CB0-73EE-E611-80FC-C4346BAC2908') THEN 'Europe'
	  END AS Region
	  ,CASE i.mca_internalcasetype
		  WHEN lower('60C0C58A-88E1-E611-80FF-5065F38B4251') THEN 'z Test Case type (Europe)'
		  WHEN lower('20B398BB-56E2-E611-80FF-5065F38B4251') THEN 'Request'
		  WHEN lower('BCB798C3-56E2-E611-80FF-5065F38B4251') THEN 'Issue'
		  WHEN lower('9C10D1CC-56E2-E611-80FF-5065F38B4251') THEN 'Question'
	  END AS CaseType
      ,CASE i.mca_internalcasesubtype
		  WHEN '575b0e05-57e2-e611-80fe-5065f38b5281' THEN 'New Project/Feature/Report or Change/Enhancement'
		  WHEN '5f5b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Extended Leave'
		  WHEN '595b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Hardware/Equipment'
		  WHEN '615b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Issue'
		  WHEN '4ae12e15-1585-ec11-8d21-00224809531f' THEN 'Mass Update/Upload'
		  WHEN '555b0e05-57e2-e611-80fe-5065f38b5281' THEN 'New access/Installation'
		  WHEN '5d5b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Offboarding'
		  WHEN '5b5b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Onboarding'
		  WHEN '635b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Question'
		  WHEN '535b0e05-57e2-e611-80fe-5065f38b5281' THEN 'Reset Password'
		  WHEN '4695e77d-23e5-e611-8103-5065f38b5101' THEN 'z Test Case Sub-Type (Europe)'
	  END AS CaseSubType
      ,CASE i.mca_internalsystemcategory
		  WHEN '28e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Data Center'
		  WHEN '24e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Endpoint Management'
		  WHEN '2ae64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Facility/Badge'
		  WHEN 'a9364ff8-98de-eb11-bacc-000d3a32fbe9' THEN 'Global/TGIS'
		  WHEN '2ce64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Hardware/Equipment'
		  WHEN '2ee64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Information Security'
		  WHEN '30e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Network'
		  WHEN '26e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Other'
		  WHEN '22e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'PC Operating System'
		  WHEN '20e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'PC Software'
		  WHEN '1ee64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'TEL Application'
		  WHEN '32e64bf9-66e2-e611-80fd-5065f38a99e1' THEN 'Telecom'
		  WHEN '94383724-20e5-e611-8103-5065f38b5101' THEN 'z Test System Category (Europe)'
	  END AS SystemCategory
      ,mca_internalsystemname.mca_name AS System
      ,mca_internalsystemmodule.mca_name AS SystemModule
   -------- REQUESTOR CASE CATEGORIZATION ----------
	  ,mca_externalcasetype.mca_name AS RequestorCaseType
      ,mca_externalcasesubtype.mca_name AS RequestorCaseSubType
      ,CASE i.mca_quality
		  WHEN 803930000 THEN 'Good'
		  WHEN 803930001 THEN 'Needs Improvement'
	  END AS Quality

	  ---------- RESOLUTION ---------
	  ,i.adx_resolution AS Resolution

	  ---------- ROUTE CASE ----------
      ,CASE i.routecase
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS RouteCase -- hidden on Main Case Form

	  ---------- QUEUE ----------
	  ,helpdesk_queue.name AS Queue
	  --,i.mca_workedbyyominame AS WorkedBy
	  ,mca_workedby.fullname AS WorkedBy
	  ,mca_workedby.internalemailaddress AS WorkedByUserEmailAddress

	  ---------- ENHANCEMENT ----------
	  ,mca_enhancementstatus.LocalizedLabel AS EnhancementStatus

	  ---------- BUSINESS REASON ----------
	  ,i.mca_businessreason AS BusinessReason

	  ---------- APPROVAL ----------
      ,CASE i.mca_approval
		  WHEN 803930000 THEN 'No'
		  WHEN 803930001 THEN 'Yes'
	  END AS Approval
      ,i.mca_approvalcomments AS ApprovalComments
	  --,i.mca_approvedbyyominame AS ApprovedBy
	  ,mca_approvedby.fullname AS ApprovedBy
	  ,mca_approvedby.internalemailaddress AS ApprovedByUserEmailAddress
      ,i.mca_approvedon AS ApprovedOn

	  ---------- QUICK CREATE NEXT CASE ----------
	  ,mca_nextcasenextstepcase.LocalizedLabel AS NextStepCase
      ,i.mca_nextcasedescription AS NextCaseDescription
	  ,i.mca_nextcaseassignedtoyominame AS NextCaseAssignedTo

      ---------- ONBOARDING/OFFBOARDING ----------
	  ,i.mca_obemployeecontactyominame AS OBContact
      ,CASE i.mca_obemployeetype
		  WHEN 803930000 THEN 'Temporary'
		  WHEN 803930001 THEN 'Consultant'
		  WHEN 803930002 THEN 'Employee'
	  END AS OBContactType
      ,CASE i.mca_obisconversion
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS OBIsConversion
      ,i.mca_obeffectivedate AS OBEffectiveDate -- date value entered in the portal
	  ,i.mca_obmanageryominame AS OBManager
      ,i.mca_obemployeeid AS OBContactID
      ,i.mca_obcontactfirstname AS OBFirstName
      ,i.mca_obemployeename AS OBLastName
      ,i.mca_objobtitle AS OBJobTitle
      ,i.mca_obvendor AS OBVendor
      ,CASE i.mca_obsubsidiary
		  WHEN '6d36fc70-52fd-e611-8103-c4346bc51078' THEN 'TEA'
		  WHEN '7736fc70-52fd-e611-8103-c4346bc51078' THEN 'TEF'
		  WHEN '6f36fc70-52fd-e611-8103-c4346bc51078' THEN 'TEH'
		  WHEN '7336fc70-52fd-e611-8103-c4346bc51078' THEN 'TEI'
		  WHEN '7536fc70-52fd-e611-8103-c4346bc51078' THEN 'TEN'
		  WHEN '78d0077e-f63e-ea11-a812-000d3a55dd4e' THEN 'TMEA'
		  WHEN '7136fc70-52fd-e611-8103-c4346bc51078' THEN 'TTCA'
		  WHEN '2f1869ad-2427-e711-810a-c4346bc4ef6c' THEN 'TVC'
	  END AS OBSubsidiary
      ,i.mca_obsegment AS OBSegment
      ,i.mca_obdepartment AS OBDepartment
      ,mca_obdesklocation.mca_name AS OBLocation
      ,i.mca_oblocation AS OBDeskLocation
      ,i.mca_oblocationdetail AS OBLocationDetail
      ,CASE i.mca_obislaptop
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS OBLaptop
      ,CASE i.mca_obemailoptions
		  WHEN 803930000 THEN 'Setup Email'
		  WHEN 803930001 THEN 'Use Existing Email'
	  END AS OBEmailOptions
      ,i.mca_obemailaddress AS OBEmailAddress
      ,i.mca_obdistributiongroups AS OBDistributionGroups
      ,CASE i.mca_obrsatoken
		  WHEN 803930000 THEN 'No'
		  WHEN 803930001 THEN 'Yes'
	  END AS OBRSAToken
      ,CASE i.mca_obtelpartnersaccess
		  WHEN 803930000 THEN 'No'
		  WHEN 803930001 THEN 'Yes'
	  END AS OBTELPartnersAccess
      ,i.mca_obapplicationaccessdetail AS OBApplicationAccessDetail
      ,i.mca_obsoftware AS OBSoftware
      ,i.mca_obsharedfolderaccess AS OBSharedFolderAccess
      ,i.followupby AS FollowUpBy
      ,CASE i.isescalated
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS Escalated
      ,i.escalatedon AS EscalatedOn -- stored in UTC
	  --,i.mca_escalatedtoyominame AS EscalatedTo
	  ,mca_escalatedto.fullname AS EscalatedTo
	  ,mca_escalatedto.internalemailaddress AS EscalatedToUserEmailAddress
      ,i.lastonholdtime AS LastOnHoldTime -- stored in UTC
      ,i.onholdtime AS OnHoldTimeMinutes -- Shows the duration in minutes for which the case was on hold.
      --,i.slaid -- SLA: TEL USA SLA
      --,i.firstresponsebykpiid -- Triage By KPI: Triage By KPI
      --,i.resolvebykpiid -- Resolve By KPI: Resolve By KPI

	  ---------- NO SECTION SPECIFIED ----------
      ,CASE i.merged
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS Merged
	  ,masterid.ticketnumber AS MergedMasterCaseNumber -- master ticket number when Cases are merged
      ,i.numberofchildincidents AS NumberOfChildCases -- Number of child incidents associated with the incident.

	  ---------- SLA BY KPI ----------
	  ,triage.warningtime AS TriageWarningTime -- stored in UTC
	  ,CASE triage.warningtimereached
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS TriageWarningTimeReached
	  ,triage.failuretime AS TriageByDue -- stored in UTC
	  ,CASE triage.status
		  WHEN 0 THEN 'In Progress'
		  WHEN 1 THEN 'Noncompliant'
		  WHEN 2 THEN 'Nearing Noncompliance'
		  WHEN 3 THEN 'Paused'
		  WHEN 4 THEN 'Succeeded'
		  WHEN 5 THEN 'Canceled'
	  END AS TriageStatus
	  ,triage.succeededon AS TriageSucceededOn -- stored in UTC
	  ,resolve.warningtime AS ResolveWarningTime -- stored in UTC
	  ,CASE resolve.warningtimereached
		  WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
	  END AS ResolveWarningTimeReached
	  ,resolve.failuretime AS ResolveByDue -- stored in UTC
	  ,CASE resolve.status
		  WHEN 0 THEN 'In Progress'
		  WHEN 1 THEN 'Noncompliant'
		  WHEN 2 THEN 'Nearing Noncompliance'
		  WHEN 3 THEN 'Paused'
		  WHEN 4 THEN 'Succeeded'
		  WHEN 5 THEN 'Canceled'
	  END AS ResolveStatus
	  ,resolve.succeededon AS ResolveSucceededOn -- stored in UTC
	  ,i.MCA_PROJECT as Project
	  ,i.MCA_EXTERNALCASESUBTYPENAME AS ICD_CASE_SUB_TYPE
    from incident i
    LEFT JOIN contact mca_createdbycontact ON i.mca_createdbycontact = mca_createdbycontact.id
    LEFT JOIN contact mca_manager ON i.mca_manager = mca_manager.id
    LEFT JOIN contact primarycontactid ON i.primarycontactid = primarycontactid.id
    LEFT JOIN contact responsiblecontactid ON i.responsiblecontactid = responsiblecontactid.id
    LEFT JOIN GlobalOptionSetMetadata mca_enhancementstatus ON (i.mca_enhancementstatus = mca_enhancementstatus.Option AND mca_enhancementstatus.OptionSetName = 'mca_enhancementstatus')
    LEFT JOIN GlobalOptionSetMetadata mca_nextcasenextstepcase ON (i.mca_nextcasenextstepcase = mca_nextcasenextstepcase.Option AND mca_nextcasenextstepcase.OptionSetName = 'mca_nextcasenextstepcase')
    LEFT JOIN incident masterid ON i.masterid = masterid.id
    LEFT JOIN incident mca_systemparentcaseid ON i.mca_systemparentcaseid = mca_systemparentcaseid.id
    LEFT JOIN incident parentcaseid ON i.parentcaseid = parentcaseid.id
    LEFT JOIN mca_externalcasesubtype mca_externalcasesubtype ON i.mca_externalcasesubtype = mca_externalcasesubtype.id
    LEFT JOIN mca_externalcasetype mca_externalcasetype ON i.mca_externalcasetype = mca_externalcasetype.id
    LEFT JOIN mca_internalsystemmodule mca_internalsystemmodule ON i.mca_internalsystemmodule = mca_internalsystemmodule.id
    LEFT JOIN mca_internalsystemname mca_internalsystemname ON i.mca_internalsystemname = mca_internalsystemname.id
    LEFT JOIN mca_location mca_obdesklocation ON i.mca_obdesklocation = mca_obdesklocation.id
    LEFT JOIN mca_location mca_requestorlocation ON i.mca_requestorlocation = mca_requestorlocation.id
    LEFT JOIN queue helpdesk_queue ON i.mca_queue = helpdesk_queue.id
    LEFT JOIN slakpiinstance resolve ON i.id = resolve.regarding AND upper(resolve.name) = 'RESOLVE BY KPI'
    LEFT JOIN slakpiinstance triage ON i.id = triage.regarding AND upper(triage.name) = 'TRIAGE BY KPI'
    LEFT JOIN SYSTEMUSER createdby ON i.createdby = createdby.id
    LEFT JOIN SYSTEMUSER mca_approvedby ON i.mca_approvedby = mca_approvedby.id
    LEFT JOIN SYSTEMUSER mca_escalatedto ON i.mca_escalatedto = mca_escalatedto.id
    LEFT JOIN SYSTEMUSER modifiedby ON i.modifiedby = modifiedby.id
    LEFT JOIN SYSTEMUSER ownerid ON i.ownerid = ownerid.id
    LEFT JOIN SYSTEMUSER mca_resolvedby ON i.mca_resolvedby = mca_resolvedby.id
    LEFT JOIN SYSTEMUSER mca_workedby ON i.mca_workedby = mca_workedby.id
),
-- end of ITHD base data


-- beginning of ServiceNow
task_slas as (
    select 
        -- TODO: get more clarity on what needs to be reported so this can be modeled more efficiently
        task_sla.TASK,
        max(case when contract_sla.TARGET = 'response' then task_sla.END_TIME end) as RESPONSE_END_TIME,
        max(case when contract_sla.TARGET = 'response' then task_sla.ORIGINAL_BREACH_TIME end) as RESPONSE_BREACH_TIME,
        boolor_agg(case when contract_sla.TARGET = 'response' then task_sla.HAS_BREACHED else FALSE end) as RESPONSE_BREACHED,
        boolor_agg(case when contract_sla.TARGET = 'response' then task_sla.STAGE = 'completed' else FALSE end) as RESPONSE_COMPLETED,
        max(case when contract_sla.TARGET = 'response' and task_sla.STAGE = 'completed' then task_sla.END_TIME end) as RESPONSE_COMPLETED_ON,
        max(case when contract_sla.TARGET = 'resolution' then task_sla.END_TIME end) as RESOLUTION_END_TIME,
        max(case when contract_sla.TARGET = 'resolution' then task_sla.ORIGINAL_BREACH_TIME end) as RESOLUTION_BREACH_TIME,
        boolor_agg(case when contract_sla.TARGET = 'resolution' then task_sla.HAS_BREACHED else FALSE end) as RESOLUTION_BREACHED,
        boolor_agg(case when contract_sla.TARGET = 'resolution' then task_sla.STAGE = 'completed' else FALSE end) as RESOLUTION_COMPLETED,
        max(case when contract_sla.TARGET = 'resolution' and task_sla.STAGE = 'completed' then task_sla.END_TIME end) as RESOLUTION_COMPLETED_ON,
        count(*) as NUM_SLAS,
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_TASK_SLA') }} as task_sla
    inner join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_CONTRACT_SLA') }} as contract_sla
        on task_sla.SLA = contract_sla.SYS_ID
    where task_sla.STAGE != 'cancelled'
    group by task_sla.TASK
),

state_logs as (
    select 
        ID, 
        VALUE,
        zeroifnull(sum(datediff('seconds', START_DATETIME, coalesce(END_DATETIME, current_timestamp())))) as SECONDS,
        count(*) as NUMBER_OF_OCCURENCES,
        ifnull(max(END_DATETIME), current_timestamp())::timestamp_ntz as LAST_TIME,
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_METRIC_INSTANCE') }} 
    where 1=1
        and DEFINITION = '35f2b283c0a808ae000b7132cd0a4f55' -- Incident State Duration
    group by ID, VALUE
),

incidents as (
    select 
        i._FILEDATE,
        i.SYS_ID,
        i.NUMBER as CASE_NUMBER,
        i.SHORT_DESCRIPTION as CASE_TITLE,
        i.CONTACT_TYPE as ORIGIN,
        urgency_txt.LABEL as URGENCY,
        i.U_URGENCY_REASON as URGENCY_REASON,
        impact_txt.LABEL as IMPACT_ON,
        caller_user.NAME as PRIMARY_CONTACT,
        caller_user.EMPLOYEE_NUMBER as PRIMARY_CONTACT_EMPLOYEE_ID,
        caller_user.EMAIL as PRIMARY_CONTACT_EMAIL_ADDRESS,
        caller_user.CITY as PRIMARY_CONTACT_LOCATION,
        iff(i.CLOSE_CODE = 'Duplicate', 'Yes', 'No') as DUPLICATE,
        parent_inc.NUMBER as PARENT_CASE,
        state_txt.LABEL as STATUS,
        hold_txt.LABEL as ON_HOLD_REASON,
        case task_slas.RESPONSE_COMPLETED when TRUE then 'Yes' when FALSE then 'No' end as TRIAGE_COMPLETED, -- nullability compatibility with ithd
        i.OPENED_AT as OPENED_AT,
        datediff('days', i.OPENED_AT, current_timestamp()) as AGE_DAYS,
        creator_user.NAME as CREATED_BY_USER,
        creator_user.EMAIL as CREATED_BY_USER_EMAIL_ADDRESS,
        creator_user.EMPLOYEE_NUMBER as CREATED_BY_CONTACT_EMPLOYEE_ID,
        i.SYS_CREATED_ON as CREATED_ON,
        updater_user.NAME as MODIFIED_BY,
        updater_user.EMAIL as MODIFIED_BY_USER_EMAIL_ADDRESS,
        i.SYS_UPDATED_ON as MODIFIED_ON,
        resolver_user.NAME as RESOLVED_BY,
        resolver_user.EMAIL as RESOLVED_BY_USER_EMAIL_ADDRESS,
        i.RESOLVED_AT as RESOLVED_ON,
        state_txt.LABEL as STATE,
        assigned_user.NAME as OWNER,
        assigned_user.EMAIL as OWNER_USER_EMAIL_ADDRESS,
        manager_user.NAME as MANAGER,
        manager_user.EMPLOYEE_NUMBER as MANAGER_CONTACT_EMPLOYEE_ID,
        manager_user.EMAIL as MANAGER_CONTACT_EMAIL_ADDRESS,
        i.U_VENDOR_NUMBER as SYSTEM_PARENT_CASE,
        i.DESCRIPTION as DESCRIPTION,
        caller_user.COUNTRY as REGION,
        nullif('Incident', null) as CASE_TYPE, -- nullability compatibility with ithd
        nullif('Incident', null) as CASE_SUB_TYPE, -- nullability compatibility with ithd
        category_txt.LABEL as SYSTEM_CATEGORY,
        subcategory_txt.LABEL as SYSTEM,
        i.CLOSE_NOTES as RESOLUTION,
        ass_group.NAME as QUEUE,
        task_slas.RESPONSE_END_TIME as FOLLOW_UP_BY,
        iff(i.ESCALATION > 0, 'Yes', 'No') as ESCALATED,
        case i.ESCALATION when 0 then 'Normal' when 1 then 'Moderate' when 2 then 'High' when 3 then 'Overdue' end as ESCALATED_TO,
        oh_metrics.LAST_TIME as LAST_ON_HOLD_TIME,
        ceil(oh_metrics.SECONDS / 60) as ON_HOLD_TIME_MINUTES,
        task_slas.RESPONSE_BREACHED as TRIAGE_WARNING_TIME_REACHED,    
        task_slas.RESPONSE_BREACH_TIME as TRIAGE_BY_DUE, -- TODO: how should this compare to FOLLOW_UP_BY?
        task_slas.RESPONSE_COMPLETED as TRIAGE_STATUS,
        task_slas.RESPONSE_COMPLETED_ON as TRIAGE_SUCCEEDED_ON,
        task_slas.RESOLUTION_BREACHED as RESOLVE_WARNING_TIME_REACHED,    
        task_slas.RESOLUTION_BREACH_TIME as RESOLVE_BY_DUE,
        task_slas.RESOLUTION_COMPLETED as RESOLVE_STATUS,
        task_slas.RESOLUTION_COMPLETED_ON as RESOLVE_SUCCEEDED_ON,
        initcap(i.U_SEND_TO_TGIS) as SENDTOTGIS,
        initcap(i.U_SEND_TO_TGIS_PROCESSED) as SENDTOTGISPROCESSED,
        i.U_TGIS_NUMBER as TGISNUMBER,
        subcategory_txt.LABEL as ICD_CASE_SUB_TYPE,
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_INCIDENT') }} as i
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as urgency_txt
        on urgency_txt.NAME = 'incident' 
        and urgency_txt.ELEMENT = 'urgency' 
        and urgency_txt.VALUE = i.URGENCY
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as impact_txt
        on impact_txt.NAME = 'incident' 
        and impact_txt.ELEMENT = 'impact' 
        and impact_txt.VALUE = i.IMPACT
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as caller_user
        on i.CALLER_ID = caller_user.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_INCIDENT') }} as parent_inc
        on i.PARENT_INCIDENT = parent_inc.SYS_ID
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as state_txt
        on state_txt.NAME = 'incident' 
        and state_txt.ELEMENT = 'state' 
        and state_txt.VALUE = i.STATE
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as hold_txt
        on hold_txt.NAME = 'incident' 
        and hold_txt.ELEMENT = 'hold_reason' 
        and hold_txt.VALUE = i.HOLD_REASON
    left join task_slas
        on i.SYS_ID = task_slas.TASK
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as creator_user
        on i.SYS_CREATED_BY = creator_user.USER_NAME
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as updater_user
        on i.SYS_UPDATED_BY = updater_user.USER_NAME
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as resolver_user
        on i.RESOLVED_BY = resolver_user.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as assigned_user
        on i.ASSIGNED_TO = assigned_user.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as manager_user
        on caller_user.MANAGER = manager_user.SYS_ID
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as category_txt
        on category_txt.NAME = 'incident' 
        and category_txt.ELEMENT = 'category' 
        and category_txt.VALUE = i.CATEGORY
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as subcategory_txt
        on subcategory_txt.NAME = 'incident' 
        and subcategory_txt.ELEMENT = 'subcategory'
        and subcategory_txt.DEPENDENT_VALUE = i.CATEGORY
        and subcategory_txt.VALUE = i.SUBCATEGORY
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER_GROUP') }} as ass_group
        on i.ASSIGNMENT_GROUP = ass_group.SYS_ID
    left join state_logs as oh_metrics
        on i.SYS_ID = oh_metrics.ID
        and oh_metrics.VALUE = 'On Hold'
),

catalog_tasks as (
    select 
        i._FILEDATE,
        i.SYS_ID,
        i.NUMBER as CASE_NUMBER,
        i.SHORT_DESCRIPTION as CASE_TITLE,
        i.CONTACT_TYPE as ORIGIN,
        urgency_txt.LABEL as URGENCY,
        i.U_URGENCY_REASON as URGENCY_REASON,
        impact_txt.LABEL as IMPACT_ON,
        caller_user.NAME as PRIMARY_CONTACT,
        caller_user.EMPLOYEE_NUMBER as PRIMARY_CONTACT_EMPLOYEE_ID,
        caller_user.EMAIL as PRIMARY_CONTACT_EMAIL_ADDRESS,
        caller_user.CITY as PRIMARY_CONTACT_LOCATION,
        -- iff(i.CLOSE_CODE = 'Duplicate', 'Yes', 'No') as DUPLICATE, -- duplicates in inc dont apply to sct
        null as DUPLICATE, -- duplicates in inc dont apply to sct
        -- parent_inc.NUMBER as PARENT_CASE,
        reqitm.NUMBER as PARENT_CASE,
        state_txt.LABEL as STATUS,
        -- hold_txt.LABEL as ON_HOLD_REASON, -- only inc require an on hold reason 
        null as ON_HOLD_REASON, -- only inc require an on hold reason 
        case task_slas.RESPONSE_COMPLETED when TRUE then 'Yes' when FALSE then 'No' end as TRIAGE_COMPLETED, -- nullability compatibility with ithd
        i.OPENED_AT as OPENED_AT, 
        datediff('days', i.OPENED_AT, current_timestamp()) as AGE_DAYS, 
        creator_user.NAME as CREATED_BY_USER,
        creator_user.EMAIL as CREATED_BY_USER_EMAIL_ADDRESS,
        creator_user.EMPLOYEE_NUMBER as CREATED_BY_CONTACT_EMPLOYEE_ID,
        i.SYS_CREATED_ON as CREATED_ON, 
        updater_user.NAME as MODIFIED_BY,
        updater_user.EMAIL as MODIFIED_BY_USER_EMAIL_ADDRESS,
        i.SYS_UPDATED_ON as MODIFIED_ON, 
        resolver_user.NAME as RESOLVED_BY,
        resolver_user.EMAIL as RESOLVED_BY_USER_EMAIL_ADDRESS,
        -- i.RESOLVED_AT as RESOLVED_ON, -- inc resolved 
        i.CLOSED_AT as RESOLVED_ON, -- sct closed
        state_txt.LABEL as STATE,
        assigned_user.NAME as OWNER,
        assigned_user.EMAIL as OWNER_USER_EMAIL_ADDRESS,
        manager_user.NAME as MANAGER,
        manager_user.EMPLOYEE_NUMBER as MANAGER_CONTACT_EMPLOYEE_ID,
        manager_user.EMAIL as MANAGER_CONTACT_EMAIL_ADDRESS,
        i.USER_INPUT as SYSTEM_PARENT_CASE,
        i.DESCRIPTION as DESCRIPTION,
        caller_user.COUNTRY as REGION,
        nullif('Catalog Tasks', null) as CASE_TYPE, -- nullability compatibility with ithd
        nullif('Catalog Tasks', null) as CASE_SUB_TYPE, -- nullability compatibility with ithd
        category_txt.LABEL as SYSTEM_CATEGORY,
        subcategory_txt.LABEL as SYSTEM,
        i.CLOSE_NOTES as RESOLUTION,
        ass_group.NAME as QUEUE,
        task_slas.RESPONSE_END_TIME as FOLLOW_UP_BY, 
        iff(i.ESCALATION > 0, 'Yes', 'No') as ESCALATED,
        case i.ESCALATION when 0 then 'Normal' when 1 then 'Moderate' when 2 then 'High' when 3 then 'Overdue' end as ESCALATED_TO,
        null as LAST_ON_HOLD_TIME,
        null as ON_HOLD_TIME_MINUTES,
        task_slas.RESPONSE_BREACHED as TRIAGE_WARNING_TIME_REACHED,    
        task_slas.RESPONSE_BREACH_TIME as TRIAGE_BY_DUE, -- TODO: how is this different from FOLLOW_UP_BY?
        task_slas.RESPONSE_COMPLETED as TRIAGE_STATUS,
        task_slas.RESPONSE_COMPLETED_ON as TRIAGE_SUCCEEDED_ON,
        task_slas.RESOLUTION_BREACHED as RESOLVE_WARNING_TIME_REACHED,    
        task_slas.RESOLUTION_BREACH_TIME as RESOLVE_BY_DUE,
        task_slas.RESOLUTION_COMPLETED as RESOLVE_STATUS,
        task_slas.RESOLUTION_COMPLETED_ON as RESOLVE_SUCCEEDED_ON,
        initcap(i.U_SEND_TO_TGIS) as SENDTOTGIS,
        initcap(i.U_SEND_TO_TGIS_PROCESSED) as SENDTOTGISPROCESSED,
        i.U_TGIS_NUMBER as TGISNUMBER,
        subcategory_txt.LABEL as ICD_CASE_SUB_TYPE,
    -- from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_INCIDENT') }} as i
    from {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SC_TASK') }} as i
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SC_REQ_ITEM') }} as reqitm
        on i.REQUEST_ITEM = reqitm.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SC_REQUEST') }} as req
        on i.REQUEST = req.SYS_ID
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as urgency_txt
        -- on urgency_txt.NAME = 'incident' 
        on urgency_txt.NAME = 'task' 
        and urgency_txt.ELEMENT = 'urgency' 
        and urgency_txt.VALUE = i.URGENCY
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as impact_txt
        -- on impact_txt.NAME = 'incident' 
        on impact_txt.NAME = 'task' 
        and impact_txt.ELEMENT = 'impact' 
        and impact_txt.VALUE = i.IMPACT
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as caller_user
        -- on i.CALLER_ID = caller_user.SYS_ID -- caller used in incidents
        on reqitm.REQUESTED_FOR = caller_user.SYS_ID -- opened by for tasks
    -- left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_INCIDENT') }} as parent_inc
    --     on i.PARENT_INCIDENT = parent_inc.SYS_ID
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as state_txt
        -- on state_txt.NAME = 'incident' 
        on state_txt.NAME = 'task' 
        and state_txt.ELEMENT = 'state' 
        and state_txt.VALUE = i.STATE
    left join task_slas
        on i.SYS_ID = task_slas.TASK
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as creator_user
        on i.SYS_CREATED_BY = creator_user.USER_NAME
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as updater_user
        on i.SYS_UPDATED_BY = updater_user.USER_NAME
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as resolver_user
        -- on i.RESOLVED_BY = resolver_user.SYS_ID
        on i.CLOSED_BY = resolver_user.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as assigned_user
        on i.ASSIGNED_TO = assigned_user.SYS_ID
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER') }} as manager_user
        on caller_user.MANAGER = manager_user.SYS_ID
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as category_txt
        on category_txt.NAME = 'incident' 
        and category_txt.ELEMENT = 'category' 
        -- and category_txt.VALUE = reqitm.CATEGORY
        and category_txt.VALUE = i.U_CATEGORY
    left join {{ ref('SILVER__TEH_SUPPORT_SERVICES__SN_CHOICE_LABELS') }} as subcategory_txt
        on subcategory_txt.NAME = 'incident' 
        and subcategory_txt.ELEMENT = 'subcategory'
        -- and subcategory_txt.DEPENDENT_VALUE = i.CATEGORY
        -- and subcategory_txt.VALUE = i.SUBCATEGORY
        and subcategory_txt.DEPENDENT_VALUE = i.U_CATEGORY
        and subcategory_txt.VALUE = i.U_SUBCATEGORY
    left join {{ ref('BRONZE__TEH_SUPPORT_SERVICES__SERVICENOW_SYS_USER_GROUP') }} as ass_group
        on i.ASSIGNMENT_GROUP = ass_group.SYS_ID
),

-- join sn incidents and sn tasks to create a single table of all sn cases
unioned_sn as (
    select * from incidents
    union all by name
    select * from catalog_tasks
),

-- filter out any ithd cases that were migrated to service now
old_ithd as (
	select
		_FILEDATE,
		CASENUMBER AS CASE_NUMBER,
		ADDITIONALCONTACT AS ADDITIONAL_CONTACT,
		AGEDAYS AS AGE_DAYS,
		APPROVAL AS APPROVAL,
		APPROVALCOMMENTS AS APPROVAL_COMMENTS,
		APPROVEDBY AS APPROVED_BY,
		APPROVEDBYUSEREMAILADDRESS AS APPROVED_BY_USER_EMAIL_ADDRESS,
		APPROVEDON AS APPROVED_ON,
		BUSINESSREASON AS BUSINESS_REASON,
		CASESUBTYPE AS CASE_SUB_TYPE,
		CASETITLE AS CASE_TITLE,
		CASETYPE AS CASE_TYPE,
		CLOSEME AS CLOSE_ME,
		CONFIRMRESOLUTION AS CONFIRM_RESOLUTION,
		CREATEDBYCONTACT AS CREATED_BY_CONTACT,
		CREATEDBYCONTACTEMAILADDRESS AS CREATED_BY_CONTACT_EMAIL_ADDRESS,
		CREATEDBYCONTACTEMPLOYEEID AS CREATED_BY_CONTACT_EMPLOYEE_ID,
		CREATEDBYUSER AS CREATED_BY_USER,
		CREATEDBYUSEREMAILADDRESS AS CREATED_BY_USER_EMAIL_ADDRESS,
		CREATEDON AS CREATED_ON,
		DESCRIPTION AS DESCRIPTION,
		DUPLICATE AS DUPLICATE,
		EMAILNOTIFICATION AS EMAIL_NOTIFICATION,
		ENHANCEMENTSTATUS AS ENHANCEMENT_STATUS,
		ESCALATED AS ESCALATED,
		ESCALATEDON AS ESCALATED_ON,
		ESCALATEDTO AS ESCALATED_TO,
		ESCALATEDTOUSEREMAILADDRESS AS ESCALATED_TO_USER_EMAIL_ADDRESS,
		ETA AS ETA,
		FOLLOWUPBY AS FOLLOW_UP_BY,
		IMPACTON AS IMPACT_ON,
		LASTONHOLDTIME AS LAST_ON_HOLD_TIME,
		MANAGER AS MANAGER,
		MANAGERCONTACTEMAILADDRESS AS MANAGER_CONTACT_EMAIL_ADDRESS,
		MANAGERCONTACTEMPLOYEEID AS MANAGER_CONTACT_EMPLOYEE_ID,
		MERGED AS MERGED,
		MERGEDMASTERCASENUMBER AS MERGED_MASTER_CASE_NUMBER,
		MODIFIEDBY AS MODIFIED_BY,
		MODIFIEDBYUSEREMAILADDRESS AS MODIFIED_BY_USER_EMAIL_ADDRESS,
		MODIFIEDON AS MODIFIED_ON,
		NEXTCASEASSIGNEDTO AS NEXT_CASE_ASSIGNED_TO,
		NEXTCASEDESCRIPTION AS NEXT_CASE_DESCRIPTION,
		NEXTSTEPCASE AS NEXT_STEP_CASE,
		NUMBEROFCHILDCASES AS NUMBER_OF_CHILD_CASES,
		OBAPPLICATIONACCESSDETAIL AS OB_APPLICATION_ACCESS_DETAIL,
		OBCONTACT AS OB_CONTACT,
		OBCONTACTID AS OB_CONTACT_ID,
		OBCONTACTTYPE AS OB_CONTACT_TYPE,
		OBDEPARTMENT AS OB_DEPARTMENT,
		OBDESKLOCATION AS OB_DESK_LOCATION,
		OBDISTRIBUTIONGROUPS AS OB_DISTRIBUTION_GROUPS,
		OBEFFECTIVEDATE AS OB_EFFECTIVE_DATE,
		OBEMAILADDRESS AS OB_EMAIL_ADDRESS,
		OBEMAILOPTIONS AS OB_EMAIL_OPTIONS,
		OBFIRSTNAME AS OB_FIRST_NAME,
		OBISCONVERSION AS OBIS_CONVERSION,
		OBJOBTITLE AS OB_JOB_TITLE,
		OBLAPTOP AS OB_LAPTOP,
		OBLASTNAME AS OB_LAST_NAME,
		OBLOCATION AS OB_LOCATION,
		OBLOCATIONDETAIL AS OB_LOCATION_DETAIL,
		OBMANAGER AS OB_MANAGER,
		OBRSATOKEN AS OB_RSA_TOKEN,
		OBSEGMENT AS OB_SEGMENT,
		OBSHAREDFOLDERACCESS AS OB_SHARED_FOLDER_ACCESS,
		OBSOFTWARE AS OB_SOFTWARE,
		OBSUBSIDIARY AS OB_SUBSIDIARY,
		OBTELPARTNERSACCESS AS OB_TEL_PARTNERS_ACCESS,
		OBVENDOR AS OB_VENDOR,
		ONHOLDREASON AS ON_HOLD_REASON,
		ONHOLDTIMEMINUTES AS ON_HOLD_TIME_MINUTES,
		ORIGIN AS ORIGIN,
		OWNER AS OWNER,
		OWNERUSEREMAILADDRESS AS OWNER_USER_EMAIL_ADDRESS,
		PARENTCASE AS PARENT_CASE,
		PMOUPDATE AS PMO_UPDATE,
		PREFERREDCONTACT AS PREFERRED_CONTACT,
		PREFERREDCONTACTDETAIL AS PREFERRED_CONTACT_DETAIL,
		PRIMARYCONTACT AS PRIMARY_CONTACT,
		PRIMARYCONTACTEMAILADDRESS AS PRIMARY_CONTACT_EMAIL_ADDRESS,
		PrimaryContactLocation AS Primary_Contact_Location,
		PRIMARYCONTACTEMPLOYEEID AS PRIMARY_CONTACT_EMPLOYEE_ID,
		QUALITY AS QUALITY,
		QUEUE AS QUEUE,
		REGION AS REGION,
		REQUESTORCASESUBTYPE AS REQUESTOR_CASE_SUB_TYPE,
		REQUESTORCASETYPE AS REQUESTOR_CASE_TYPE,
		RESOLUTION AS RESOLUTION,
		RESOLVEBYDUE AS RESOLVE_BY_DUE,
		RESOLVEDBY AS RESOLVED_BY,
		RESOLVEDBYUSEREMAILADDRESS AS RESOLVED_BY_USER_EMAIL_ADDRESS,
		RESOLVEDON AS RESOLVED_ON,
		RESOLVESTATUS AS RESOLVE_STATUS,
		RESOLVESUCCEEDEDON AS RESOLVE_SUCCEEDED_ON,
		RESOLVEWARNINGTIME AS RESOLVE_WARNING_TIME,
		RESOLVEWARNINGTIMEREACHED AS RESOLVE_WARNING_TIME_REACHED,
		ROUTECASE AS ROUTE_CASE,
		SENDTOTGIS AS SENDTOTGIS,
		SENDTOTGISPROCESSED AS SENDTOTGISPROCESSED,
		STATE AS STATE,
		STATUS AS STATUS,
		SYSTEM AS SYSTEM,
		SYSTEMCATEGORY AS SYSTEM_CATEGORY,
		SYSTEMCUSTOMER AS SYSTEM_CUSTOMER,
		SYSTEMMODULE AS SYSTEM_MODULE,
		SYSTEMPARENTCASE AS SYSTEM_PARENT_CASE,
		TGISNUMBER AS TGISNUMBER,
		TRIAGEBYDUE AS TRIAGE_BY_DUE,
		TRIAGECOMPLETED AS TRIAGE_COMPLETED,
		TRIAGESTATUS AS TRIAGE_STATUS,
		TRIAGESUCCEEDEDON AS TRIAGE_SUCCEEDED_ON,
		TRIAGEWARNINGTIME AS TRIAGE_WARNING_TIME,
		TRIAGEWARNINGTIMEREACHED AS TRIAGE_WARNING_TIME_REACHED,
		URGENCY AS URGENCY,
		URGENCYREASON AS URGENCY_REASON,
		WORKEDBY AS WORKED_BY,
		WORKEDBYUSEREMAILADDRESS AS WORKED_BY_USER_EMAIL_ADDRESS,
		Project AS PROJECT,
		ICD_CASE_SUB_TYPE
	from all_ithd
    where not exists (
        select 1
        from unioned_sn
        where unioned_sn.SYSTEM_PARENT_CASE = all_ithd.CASENUMBER
    )
),

-- union service now with the remaning ithd cases
final_union as (
    select
        _FILEDATE,
        SYS_ID,
        CASE_NUMBER,
        CASE_TITLE,
        ORIGIN,
        URGENCY::varchar(16777216) as URGENCY,
        URGENCY_REASON,
        IMPACT_ON,
        PRIMARY_CONTACT,
        PRIMARY_CONTACT_EMPLOYEE_ID,
        PRIMARY_CONTACT_EMAIL_ADDRESS,
        PRIMARY_CONTACT_LOCATION,
        DUPLICATE,
        PARENT_CASE,
        STATUS,
        ON_HOLD_REASON,
        TRIAGE_COMPLETED,
        OPENED_AT,
        AGE_DAYS,
        CREATED_BY_USER,
        CREATED_BY_USER_EMAIL_ADDRESS,
        CREATED_BY_CONTACT_EMPLOYEE_ID,
        CREATED_ON,
        MODIFIED_BY,
        MODIFIED_BY_USER_EMAIL_ADDRESS,
        MODIFIED_ON,
        RESOLVED_BY,
        RESOLVED_BY_USER_EMAIL_ADDRESS,
        RESOLVED_ON::varchar(16777216) as RESOLVED_ON,
        STATE,
        OWNER,
        OWNER_USER_EMAIL_ADDRESS,
        MANAGER,
        MANAGER_CONTACT_EMPLOYEE_ID,
        MANAGER_CONTACT_EMAIL_ADDRESS,
        SYSTEM_PARENT_CASE,
        DESCRIPTION,
        REGION,
        CASE_TYPE,
        CASE_SUB_TYPE,
        SYSTEM_CATEGORY,
        SYSTEM,
        RESOLUTION,
        QUEUE,
        FOLLOW_UP_BY::varchar(16777216) as FOLLOW_UP_BY,
        ESCALATED,
        ESCALATED_TO,
        LAST_ON_HOLD_TIME::varchar(16777216) as LAST_ON_HOLD_TIME,
        ON_HOLD_TIME_MINUTES,
        TRIAGE_WARNING_TIME_REACHED::varchar(16777216) as TRIAGE_WARNING_TIME_REACHED,
        TRIAGE_BY_DUE,
        TRIAGE_STATUS::varchar(16777216) as TRIAGE_STATUS,
        TRIAGE_SUCCEEDED_ON,
        RESOLVE_WARNING_TIME_REACHED::varchar(16777216) as RESOLVE_WARNING_TIME_REACHED,
        RESOLVE_BY_DUE,
        RESOLVE_STATUS::varchar(16777216) as RESOLVE_STATUS,
        RESOLVE_SUCCEEDED_ON,
        SENDTOTGIS,
        SENDTOTGISPROCESSED,
        TGISNUMBER,
        ICD_CASE_SUB_TYPE,
    from unioned_sn
    union all by name
    select * from old_ithd
),

transform_data as (
    select 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		CURRENT_DATE::DATE AS SNAPSHOT_DATE,
        *,
    from final_union
),

type_data as (
    select
        _FILEDATE,
        SNAPSHOT_DATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CASE_NUMBER,
        CASE_TITLE,
        ORIGIN,
        URGENCY,
        URGENCY_REASON,
        IMPACT_ON,
        PRIMARY_CONTACT,
        PRIMARY_CONTACT_EMPLOYEE_ID,
        PRIMARY_CONTACT_EMAIL_ADDRESS,
        Primary_Contact_Location,
        PREFERRED_CONTACT,
        PREFERRED_CONTACT_DETAIL,
        EMAIL_NOTIFICATION,
        ADDITIONAL_CONTACT,
        DUPLICATE,
        PARENT_CASE,
        STATUS,
        ON_HOLD_REASON,
        CONFIRM_RESOLUTION,
        TRIAGE_COMPLETED,
        AGE_DAYS,
        CREATED_BY_USER,
        CREATED_BY_USER_EMAIL_ADDRESS,
        CREATED_BY_CONTACT,
        CREATED_BY_CONTACT_EMPLOYEE_ID,
        CREATED_BY_CONTACT_EMAIL_ADDRESS,
        CREATED_ON,
        MODIFIED_BY,
        MODIFIED_BY_USER_EMAIL_ADDRESS,
        MODIFIED_ON,
        RESOLVED_BY,
        RESOLVED_BY_USER_EMAIL_ADDRESS,
        RESOLVED_ON,
        STATE,
        OWNER,
        OWNER_USER_EMAIL_ADDRESS,
        SYSTEM_CUSTOMER,
        MANAGER,
        MANAGER_CONTACT_EMPLOYEE_ID,
        MANAGER_CONTACT_EMAIL_ADDRESS,
        CLOSE_ME,
        SYSTEM_PARENT_CASE,
        DESCRIPTION,
        REGION,
        CASE_TYPE,
        CASE_SUB_TYPE,
        SYSTEM_CATEGORY,
        SYSTEM,
        SYSTEM_MODULE,
        REQUESTOR_CASE_TYPE,
        REQUESTOR_CASE_SUB_TYPE,
        QUALITY,
        RESOLUTION,
        ROUTE_CASE,
        QUEUE,
        WORKED_BY,
        WORKED_BY_USER_EMAIL_ADDRESS,
        ENHANCEMENT_STATUS,
        BUSINESS_REASON,
        APPROVAL,
        APPROVAL_COMMENTS,
        APPROVED_BY,
        APPROVED_BY_USER_EMAIL_ADDRESS,
        APPROVED_ON,
        NEXT_STEP_CASE,
        NEXT_CASE_DESCRIPTION,
        NEXT_CASE_ASSIGNED_TO,
        OB_CONTACT,
        OB_CONTACT_TYPE,
        OBIS_CONVERSION,
        OB_EFFECTIVE_DATE,
        OB_MANAGER,
        OB_CONTACT_ID,
        OB_FIRST_NAME,
        OB_LAST_NAME,
        OB_JOB_TITLE,
        OB_VENDOR,
        OB_SUBSIDIARY,
        OB_SEGMENT,
        OB_DEPARTMENT,
        OB_LOCATION,
        OB_DESK_LOCATION,
        OB_LOCATION_DETAIL,
        OB_LAPTOP,
        OB_EMAIL_OPTIONS,
        OB_EMAIL_ADDRESS,
        OB_DISTRIBUTION_GROUPS,
        OB_RSA_TOKEN,
        OB_TEL_PARTNERS_ACCESS,
        OB_APPLICATION_ACCESS_DETAIL,
        OB_SOFTWARE,
        OB_SHARED_FOLDER_ACCESS,
        FOLLOW_UP_BY,
        ESCALATED,
        ESCALATED_ON,
        ESCALATED_TO,
        ESCALATED_TO_USER_EMAIL_ADDRESS,
        LAST_ON_HOLD_TIME,
        ON_HOLD_TIME_MINUTES,
        MERGED,
        MERGED_MASTER_CASE_NUMBER,
        NUMBER_OF_CHILD_CASES,
        TRIAGE_WARNING_TIME,
        TRIAGE_WARNING_TIME_REACHED,
        TRIAGE_BY_DUE,
        TRIAGE_STATUS,
        TRIAGE_SUCCEEDED_ON,
        RESOLVE_WARNING_TIME,
        RESOLVE_WARNING_TIME_REACHED,
        RESOLVE_BY_DUE,
        RESOLVE_STATUS,
        RESOLVE_SUCCEEDED_ON,
        SendToTGIS,
        SendToTGISProcessed,
        TGISNumber,
        ETA,
        PMO_UPDATE,
        PROJECT,
        ICD_CASE_SUB_TYPE,
    FROM transform_data
)

select * from type_data