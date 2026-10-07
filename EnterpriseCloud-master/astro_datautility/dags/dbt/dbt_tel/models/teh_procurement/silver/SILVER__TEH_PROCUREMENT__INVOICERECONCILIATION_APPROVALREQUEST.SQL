/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\InvoiceReconciliation_ApprovalRequest.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\InvoiceReconciliation_ApprovalRequest.SQL
-materialized incremental
-alias InvoiceReconciliation_ApprovalRequest
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:07 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='InvoiceReconciliation_ApprovalRequest',
    unique_key= ['REALMNAME',
    'INVOICERECONCILIATIONIDKEY',
    'INVOICERECONCILIATIONVERSIONKEY',
    'INVOICERECONCILIATIONAPPROVALREQUESTKEY']
) }}

with source_data as
(
    SELECT
InvoiceReconciliationApprovalRequest.LastUpdated AS LASTUPDATED,
InvoiceReconciliationApprovalRequest.RealmName AS REALMNAME,
InvoiceReconciliationApprovalRequest.InvoiceReconciliationIDKey AS INVOICERECONCILIATIONIDKEY,
InvoiceReconciliationApprovalRequest.InvoiceReconciliationVersionKey AS INVOICERECONCILIATIONVERSIONKEY,
InvoiceReconciliationApprovalRequest.InvoiceReconciliationApprovalRequestKey AS INVOICERECONCILIATIONAPPROVALREQUESTKEY,
InvoiceReconciliationApprovalRequest.ActivationDate AS ACTIVATIONDATE,
InvoiceReconciliationApprovalRequest.ApprovedByCode AS APPROVEDBYCODE,
InvoiceReconciliationApprovalRequest.ApproverCode AS APPROVERCODE,
InvoiceReconciliationApprovalRequest.ApproverComment AS APPROVERCOMMENT,
InvoiceReconciliationApprovalRequest.AssignedDate AS ASSIGNEDDATE,
InvoiceReconciliationApprovalRequest.AssignedToCode AS ASSIGNEDTOCODE,
InvoiceReconciliationApprovalRequest.CreatorCode AS CREATORCODE,
InvoiceReconciliationApprovalRequest.EscalationDate AS ESCALATIONDATE,
InvoiceReconciliationApprovalRequest.EscalationExtendedByUserCode AS ESCALATIONEXTENDEDBYUSERCODE,
InvoiceReconciliationApprovalRequest.EscalationExtensionDate AS ESCALATIONEXTENSIONDATE,
InvoiceReconciliationApprovalRequest.EscalationWarningDate AS ESCALATIONWARNINGDATE,
InvoiceReconciliationApprovalRequest.ExtendEscalationReasonCode AS EXTENDESCALATIONREASONCODE,
InvoiceReconciliationApprovalRequest.ExtendEscalationUserComments AS EXTENDESCALATIONUSERCOMMENTS,
InvoiceReconciliationApprovalRequest.LastModified AS LASTMODIFIED,
InvoiceReconciliationApprovalRequest.Reason AS REASON,
InvoiceReconciliationApprovalRequest.ReportingExtendEscalationReason AS REPORTINGEXTENDESCALATIONREASON,
InvoiceReconciliationApprovalRequest.ReportingReason AS REPORTINGREASON,
InvoiceReconciliationApprovalRequest.RuleName AS RULENAME,
InvoiceReconciliationApprovalRequest.StateCode AS STATECODE,
CASE InvoiceReconciliationApprovalRequest.AllowEscalationPeriodExtension WHEN 1 THEN 'Yes' ELSE 'No' END AS ALLOWESCALATIONPERIODEXTENSION,
CASE InvoiceReconciliationApprovalRequest.ApprovalRequired WHEN 1 THEN 'Yes' ELSE 'No' END AS APPROVALREQUIRED,
CASE InvoiceReconciliationApprovalRequest.IsEscalatedToList WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATEDTOLIST,
CASE InvoiceReconciliationApprovalRequest.IsEscalationExtended WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATIONEXTENDED,
CASE InvoiceReconciliationApprovalRequest.ManuallyAdded WHEN 1 THEN 'Yes' ELSE 'No' END AS MANUALLYADDED,
CAST ( NULL AS VARCHAR ( 16777216 ) ) AS ISHISTORICAL
FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICERECONCILIATIONAPPROVALREQUEST') }} InvoiceReconciliationApprovalRequest
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        INVOICERECONCILIATIONIDKEY,
        INVOICERECONCILIATIONVERSIONKEY,
        INVOICERECONCILIATIONAPPROVALREQUESTKEY,
        ACTIVATIONDATE,
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
        LASTMODIFIED,
        REASON,
        REPORTINGEXTENDESCALATIONREASON,
        REPORTINGREASON,
        RULENAME,
        STATECODE,
        ALLOWESCALATIONPERIODEXTENSION,
        APPROVALREQUIRED,
        ISESCALATEDTOLIST,
        ISESCALATIONEXTENDED,
        MANUALLYADDED,
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
        cast(INVOICERECONCILIATIONIDKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONIDKEY,
        cast(INVOICERECONCILIATIONVERSIONKEY as NUMBER(38,0)) as INVOICERECONCILIATIONVERSIONKEY,
        cast(INVOICERECONCILIATIONAPPROVALREQUESTKEY as TIMESTAMP_NTZ(9)) as INVOICERECONCILIATIONAPPROVALREQUESTKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
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
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(REPORTINGEXTENDESCALATIONREASON as VARCHAR(16777216)) as REPORTINGEXTENDESCALATIONREASON,
        cast(REPORTINGREASON as VARCHAR(16777216)) as REPORTINGREASON,
        cast(RULENAME as VARCHAR(16777216)) as RULENAME,
        cast(STATECODE as NUMBER(38,0)) as STATECODE,
        cast(ALLOWESCALATIONPERIODEXTENSION as VARCHAR(16777216)) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as VARCHAR(16777216)) as APPROVALREQUIRED,
        cast(ISESCALATEDTOLIST as VARCHAR(16777216)) as ISESCALATEDTOLIST,
        cast(ISESCALATIONEXTENDED as VARCHAR(16777216)) as ISESCALATIONEXTENDED,
        cast(MANUALLYADDED as VARCHAR(16777216)) as MANUALLYADDED,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data