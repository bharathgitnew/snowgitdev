/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Invoice_ApprovalRequest.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Invoice_ApprovalRequest.SQL
-materialized incremental
-alias Invoice_ApprovalRequest
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:09 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='Invoice_ApprovalRequest',
    unique_key= ['REALMNAME',
    'INVOICEIDKEY',
    'INVOICEVERSIONKEY',
    'INVOICEAPPROVALREQUESTKEY']
) }}

with source_data as
(
    SELECT
        InvoiceApprovalRequest.LastUpdated AS LASTUPDATED,
        InvoiceApprovalRequest.RealmName AS REALMNAME,
        InvoiceApprovalRequest.InvoiceIdKey AS INVOICEIDKEY,
        InvoiceApprovalRequest.InvoiceVersionKey AS INVOICEVERSIONKEY,
        InvoiceApprovalRequest.InvoiceApprovalRequestKey AS INVOICEAPPROVALREQUESTKEY,
        InvoiceApprovalRequest.ActivationDate AS ACTIVATIONDATE,
        CASE InvoiceApprovalRequest.AllowEscalationPeriodExtension WHEN 1 THEN 'Yes' ELSE 'No' END AS ALLOWESCALATIONPERIODEXTENSION,
        CASE InvoiceApprovalRequest.ApprovalRequired WHEN 1 THEN 'Yes' ELSE 'No' END AS APPROVALREQUIRED,
        InvoiceApprovalRequest.ApprovedByUniqueName AS APPROVEDBYUNIQUENAME,
        InvoiceApprovalRequest.Approver AS APPROVER,
        InvoiceApprovalRequest.ApproverComment AS APPROVERCOMMENT,
        InvoiceApprovalRequest.AssignedDate AS ASSIGNEDDATE,
        InvoiceApprovalRequest.AssignedTo AS ASSIGNEDTO,
        InvoiceApprovalRequest.Creator AS CREATOR,
        InvoiceApprovalRequest.EscalationDate AS ESCALATIONDATE,
        InvoiceApprovalRequest.EscalationExtendedByUser AS ESCALATIONEXTENDEDBYUSER,
        InvoiceApprovalRequest.EscalationExtensionDate AS ESCALATIONEXTENSIONDATE,
        InvoiceApprovalRequest.EscalationWarningDate AS ESCALATIONWARNINGDATE,
        InvoiceApprovalRequest.ExtendEscalationReasonCode AS EXTENDESCALATIONREASONCODE,
        InvoiceApprovalRequest.ExtendEscalationUserComments AS EXTENDESCALATIONUSERCOMMENTS,
        CASE InvoiceApprovalRequest.IsEscalatedToList WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATEDTOLIST,
        CASE InvoiceApprovalRequest.IsEscalationExtended WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATIONEXTENDED,
        InvoiceApprovalRequest.LastModified AS LASTMODIFIED,
        CASE InvoiceApprovalRequest.ManuallyAdded WHEN 1 THEN 'Yes' ELSE 'No' END AS MANUALLYADDED,
        InvoiceApprovalRequest.Reason AS REASON,
        InvoiceApprovalRequest.ReportingExtendEscalationReason AS REPORTINGEXTENDESCALATIONREASON,
        InvoiceApprovalRequest.ReportingReason AS REPORTINGREASON,
        InvoiceApprovalRequest.RuleName AS RULENAME,
        CASE InvoiceApprovalRequest.State WHEN 1 THEN 'NotYetActive' WHEN 2 THEN 'ActiveButNoActionYet' WHEN 4 THEN 'Denied' WHEN 8 THEN 'Approved' WHEN 16 THEN 'Rejected' ELSE 'Unknown:' || TO_CHAR ( InvoiceApprovalRequest.State ) END AS STATE,
        InvoiceApprovalRequest.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICEAPPROVALREQUEST') }} InvoiceApprovalRequest
)
,transform_data as
(
    SELECT LASTUPDATED,
        REALMNAME,
        INVOICEIDKEY,
        INVOICEVERSIONKEY,
        INVOICEAPPROVALREQUESTKEY,
        ACTIVATIONDATE,
        ALLOWESCALATIONPERIODEXTENSION,
        APPROVALREQUIRED,
        APPROVEDBYUNIQUENAME,
        APPROVER,
        APPROVERCOMMENT,
        ASSIGNEDDATE,
        ASSIGNEDTO,
        CREATOR,
        ESCALATIONDATE,
        ESCALATIONEXTENDEDBYUSER,
        ESCALATIONEXTENSIONDATE,
        ESCALATIONWARNINGDATE,
        EXTENDESCALATIONREASONCODE,
        EXTENDESCALATIONUSERCOMMENTS,
        ISESCALATEDTOLIST,
        ISESCALATIONEXTENDED,
        LASTMODIFIED,
        MANUALLYADDED,
        REASON,
        REPORTINGEXTENDESCALATIONREASON,
        REPORTINGREASON,
        RULENAME,
        STATE,
        ISHISTORICAL,
       '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(INVOICEIDKEY as VARCHAR(16777216)) as INVOICEIDKEY,
        cast(INVOICEVERSIONKEY as NUMBER(38,0)) as INVOICEVERSIONKEY,
        cast(INVOICEAPPROVALREQUESTKEY as TIMESTAMP_NTZ(9)) as INVOICEAPPROVALREQUESTKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(ALLOWESCALATIONPERIODEXTENSION as VARCHAR(16777216)) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as VARCHAR(16777216)) as APPROVALREQUIRED,
        cast(APPROVEDBYUNIQUENAME as VARCHAR(16777216)) as APPROVEDBYUNIQUENAME,
        cast(APPROVER as VARCHAR(16777216)) as APPROVER,
        cast(APPROVERCOMMENT as VARCHAR(16777216)) as APPROVERCOMMENT,
        cast(ASSIGNEDDATE as TIMESTAMP_NTZ(9)) as ASSIGNEDDATE,
        cast(ASSIGNEDTO as VARCHAR(16777216)) as ASSIGNEDTO,
        cast(CREATOR as VARCHAR(16777216)) as CREATOR,
        cast(ESCALATIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONDATE,
        cast(ESCALATIONEXTENDEDBYUSER as VARCHAR(16777216)) as ESCALATIONEXTENDEDBYUSER,
        cast(ESCALATIONEXTENSIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONEXTENSIONDATE,
        cast(ESCALATIONWARNINGDATE as TIMESTAMP_NTZ(9)) as ESCALATIONWARNINGDATE,
        cast(EXTENDESCALATIONREASONCODE as VARCHAR(16777216)) as EXTENDESCALATIONREASONCODE,
        cast(EXTENDESCALATIONUSERCOMMENTS as VARCHAR(16777216)) as EXTENDESCALATIONUSERCOMMENTS,
        cast(ISESCALATEDTOLIST as VARCHAR(16777216)) as ISESCALATEDTOLIST,
        cast(ISESCALATIONEXTENDED as VARCHAR(16777216)) as ISESCALATIONEXTENDED,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(MANUALLYADDED as VARCHAR(16777216)) as MANUALLYADDED,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(REPORTINGEXTENDESCALATIONREASON as VARCHAR(16777216)) as REPORTINGEXTENDESCALATIONREASON,
        cast(REPORTINGREASON as VARCHAR(16777216)) as REPORTINGREASON,
        cast(RULENAME as VARCHAR(16777216)) as RULENAME,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data