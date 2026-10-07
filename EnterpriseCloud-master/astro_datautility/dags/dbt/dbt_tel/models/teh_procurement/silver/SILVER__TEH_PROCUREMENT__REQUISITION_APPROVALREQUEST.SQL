/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Requisition_ApprovalRequest.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Requisition_ApprovalRequest.SQL
-materialized incremental
-alias Requisition_ApprovalRequest
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:11 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='Requisition_ApprovalRequest',
    unique_key = []
) }}

with source_data as
(
    SELECT
        RequisitionApprovalRequest.ActivationDate,
        RequisitionApprovalRequest.AllowEscalationPeriodExtension,
        RequisitionApprovalRequest.ApprovalRequired,
        RequisitionApprovalRequest.ApprovedByCode,
        RequisitionApprovalRequest.ApproverCode,
        RequisitionApprovalRequest.ApproverComment,
        RequisitionApprovalRequest.AssignedDate,
        RequisitionApprovalRequest.AssignedToCode,
        RequisitionApprovalRequest.CreatorCode,
        RequisitionApprovalRequest.EscalationDate,
        RequisitionApprovalRequest.EscalationExtendedByUserCode,
        RequisitionApprovalRequest.EscalationExtensionDate,
        RequisitionApprovalRequest.EscalationWarningDate,
        RequisitionApprovalRequest.ExtendEscalationReasonCode,
        RequisitionApprovalRequest.ExtendEscalationUserComments,
        RequisitionApprovalRequest.IsEscalatedToList,
        RequisitionApprovalRequest.IsEscalationExtended,
        RequisitionApprovalRequest.IsHistorical,
        RequisitionApprovalRequest.LastUpdated,
        RequisitionApprovalRequest.ManuallyAdded,
        RequisitionApprovalRequest.RealmName,
        RequisitionApprovalRequest.Reason,
        RequisitionApprovalRequest.ReportingExtendEscalationReason,
        RequisitionApprovalRequest.ReportingReason,
        RequisitionApprovalRequest.RequisitionApprovalRequestKey,
        RequisitionApprovalRequest.RequisitionIDKey,
        RequisitionApprovalRequest.RequisitionVersionKey,
        RequisitionApprovalRequest.RuleName,
        RequisitionApprovalRequest.State
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_REQUISITIONAPPROVALREQUEST') }} RequisitionApprovalRequest
)
,transform_data as
(
    SELECT  
            ACTIVATIONDATE,
            ALLOWESCALATIONPERIODEXTENSION,
            APPROVALREQUIRED,
            APPROVEDBYCODE,
            APPROVERCODE,
            APPROVERCOMMENT,
            ASSIGNEDDATE,
            ASSIGNEDTOCODE,
            CREATORCODE,
            ESCALATIONDATE,
            ESCALATIONEXTENDEDBYUSERCODE,
            ESCALATIONEXTENSIONDATE,
            ESCALATIONWARNINGDATE,
            EXTENDESCALATIONREASONCODE,
            EXTENDESCALATIONUSERCOMMENTS,
            ISESCALATEDTOLIST,
            ISESCALATIONEXTENDED,
            ISHISTORICAL,
            LASTUPDATED,
            MANUALLYADDED,
            REALMNAME,
            REASON,
            REPORTINGEXTENDESCALATIONREASON,
            REPORTINGREASON,
            REQUISITIONAPPROVALREQUESTKEY,
            REQUISITIONIDKEY,
            REQUISITIONVERSIONKEY,
            RULENAME,
            STATE,
            NULL AS CUSTOMFIELD_BUSINESSJUSTIFICATION,
           '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(REQUISITIONIDKEY as VARCHAR(16777216)) as REQUISITIONIDKEY,
        cast(REQUISITIONVERSIONKEY as NUMBER(38,0)) as REQUISITIONVERSIONKEY,
        cast(REQUISITIONAPPROVALREQUESTKEY as VARCHAR(16777216)) as REQUISITIONAPPROVALREQUESTKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(ALLOWESCALATIONPERIODEXTENSION as VARCHAR(16777216)) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as VARCHAR(16777216)) as APPROVALREQUIRED,
        cast(APPROVEDBYCODE as VARCHAR(16777216)) as APPROVEDBYCODE,
        cast(APPROVERCODE as VARCHAR(16777216)) as APPROVERCODE,
        cast(APPROVERCOMMENT as VARCHAR(16777216)) as APPROVERCOMMENT,
        cast(ASSIGNEDDATE as TIMESTAMP_NTZ(9)) as ASSIGNEDDATE,
        cast(ASSIGNEDTOCODE as VARCHAR(16777216)) as ASSIGNEDTOCODE,
        cast(CREATORCODE as VARCHAR(16777216)) as CREATORCODE,
        cast(ESCALATIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONDATE,
        cast(ESCALATIONEXTENDEDBYUSERCODE as VARCHAR(16777216)) as ESCALATIONEXTENDEDBYUSERCODE,
        cast(ESCALATIONEXTENSIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONEXTENSIONDATE,
        cast(ESCALATIONWARNINGDATE as TIMESTAMP_NTZ(9)) as ESCALATIONWARNINGDATE,
        cast(EXTENDESCALATIONREASONCODE as VARCHAR(16777216)) as EXTENDESCALATIONREASONCODE,
        cast(EXTENDESCALATIONUSERCOMMENTS as VARCHAR(16777216)) as EXTENDESCALATIONUSERCOMMENTS,
        cast(ISESCALATEDTOLIST as VARCHAR(16777216)) as ISESCALATEDTOLIST,
        cast(ISESCALATIONEXTENDED as VARCHAR(16777216)) as ISESCALATIONEXTENDED,
        cast(MANUALLYADDED as VARCHAR(16777216)) as MANUALLYADDED,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(REPORTINGEXTENDESCALATIONREASON as VARCHAR(16777216)) as REPORTINGEXTENDESCALATIONREASON,
        cast(REPORTINGREASON as VARCHAR(16777216)) as REPORTINGREASON,
        cast(RULENAME as VARCHAR(16777216)) as RULENAME,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(CUSTOMFIELD_BUSINESSJUSTIFICATION as VARCHAR(16777216)) as CUSTOMFIELD_BUSINESSJUSTIFICATION,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data