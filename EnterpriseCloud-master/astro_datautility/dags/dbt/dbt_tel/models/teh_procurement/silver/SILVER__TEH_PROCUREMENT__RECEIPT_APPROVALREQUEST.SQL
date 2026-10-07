/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Receipt_ApprovalRecord.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Receipt_ApprovalRecord.SQL
-materialized incremental
-alias Receipt_ApprovalRecord
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:10 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='Receipt_ApprovalRequest',
    unique_key= ['REALMNAME',
    'RECEIPTIDKEY',
    'RECEIPTVERSIONKEY',
    'RECEIPTAPPROVALKEY']
) }}

with source_data as
(
    SELECT
        ReceiptApprovalRequest.LastUpdated AS LASTUPDATED,
        ReceiptApprovalRequest.RealmName AS REALMNAME,
        ReceiptApprovalRequest.ReceiptIDKey AS RECEIPTIDKEY,
        ReceiptApprovalRequest.ReceiptVersionKey AS RECEIPTVERSIONKEY,
        ReceiptApprovalRequest.ReceiptApprovalKey AS RECEIPTAPPROVALKEY,
        ReceiptApprovalRequest.ActivationDate AS ACTIVATIONDATE,
        ReceiptApprovalRequest.AllowEscalationPeriodExtension AS ALLOWESCALATIONPERIODEXTENSION,
        CASE ReceiptApprovalRequest.ApprovalRequired WHEN 1 THEN 'Yes' ELSE 'No' END AS APPROVALREQUIRED,
        ReceiptApprovalRequest.ApprovedBy AS APPROVEDBY,
        ReceiptApprovalRequest.Approver AS APPROVER,
        ReceiptApprovalRequest.ApproverComment AS APPROVERCOMMENT,
        ReceiptApprovalRequest.AssignedDate AS ASSIGNEDDATE,
        ReceiptApprovalRequest.AssignedToCode AS ASSIGNEDTOCODE,
        ReceiptApprovalRequest.CreatorCode AS CREATORCODE,
        ReceiptApprovalRequest.EscalationDate AS ESCALATIONDATE,
        ReceiptApprovalRequest.EscalationExtendedByUserCode AS ESCALATIONEXTENDEDBYUSERCODE,
        ReceiptApprovalRequest.EscalationExtensionDate AS ESCALATIONEXTENSIONDATE,
        ReceiptApprovalRequest.EscalationWarningDate AS ESCALATIONWARNINGDATE,
        ReceiptApprovalRequest.ExtendEscalationReasonCode AS EXTENDESCALATIONREASONCODE,
        ReceiptApprovalRequest.ExtendEscalationUserComments AS EXTENDESCALATIONUSERCOMMENTS,
        CASE ReceiptApprovalRequest.IsEscalatedToList WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATEDTOLIST,
        CASE ReceiptApprovalRequest.IsEscalationExtended WHEN 1 THEN 'Yes' ELSE 'No' END AS ISESCALATIONEXTENDED,
        ReceiptApprovalRequest.LastModified AS LASTMODIFIED,
        CASE ReceiptApprovalRequest.ManuallyAdded WHEN 1 THEN 'Yes' ELSE 'No' END AS MANUALLYADDED,
        ReceiptApprovalRequest.Reason AS REASON,
        ReceiptApprovalRequest.ReportingExtendEscalationReason AS REPORTINGEXTENDESCALATIONREASON,
        ReceiptApprovalRequest.ReportingReason AS REPORTINGREASON,
        ReceiptApprovalRequest.RuleName AS RULENAME,
        ReceiptApprovalRequest.State AS STATE,
        'No' AS ISHistorical
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_RECEIPTAPPROVALREQUEST') }} ReceiptApprovalRequest

)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        RECEIPTIDKEY,
        RECEIPTVERSIONKEY,
        RECEIPTAPPROVALKEY,
        ACTIVATIONDATE,
        ALLOWESCALATIONPERIODEXTENSION,
        APPROVALREQUIRED,
        APPROVEDBY,
        APPROVER,
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
        LASTMODIFIED,
        MANUALLYADDED,
        REASON,
        REPORTINGEXTENDESCALATIONREASON,
        REPORTINGREASON,
        RULENAME,
        STATE,
        ISHistorical,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(RECEIPTIDKEY as VARCHAR(16777216)) as RECEIPTIDKEY,
        cast(RECEIPTVERSIONKEY as NUMBER(38,0)) as RECEIPTVERSIONKEY,
        cast(RECEIPTAPPROVALKEY as TIMESTAMP_NTZ(9)) as RECEIPTAPPROVALKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(ALLOWESCALATIONPERIODEXTENSION as VARCHAR(16777216)) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as VARCHAR(16777216)) as APPROVALREQUIRED,
        cast(APPROVEDBY as VARIANT) as APPROVEDBY,
        cast(APPROVER as VARIANT) as APPROVER,
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
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(MANUALLYADDED as VARCHAR(16777216)) as MANUALLYADDED,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(REPORTINGEXTENDESCALATIONREASON as VARCHAR(16777216)) as REPORTINGEXTENDESCALATIONREASON,
        cast(REPORTINGREASON as VARCHAR(16777216)) as REPORTINGREASON,
        cast(RULENAME as VARCHAR(16777216)) as RULENAME,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data