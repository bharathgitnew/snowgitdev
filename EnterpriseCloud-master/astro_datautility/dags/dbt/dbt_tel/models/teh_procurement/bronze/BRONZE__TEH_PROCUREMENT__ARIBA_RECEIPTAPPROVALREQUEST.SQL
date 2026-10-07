{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_RECEIPTAPPROVALREQUEST',
    unique_key = ['RealmName',
    'ReceiptIDKey',
    'ReceiptVersionKey',
    'ReceiptApprovalKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS ReceiptIDKey
        ,JsonField:VersionNumber::INTEGER AS ReceiptVersionKey
        ,ApprovalRequest.value:ActivationDate::TIMESTAMP_NTZ AS ActivationDate
        ,ApprovalRequest.value:AllowEscalationPeriodExtension::BOOLEAN AS AllowEscalationPeriodExtension
        ,ApprovalRequest.value:ApprovalRequired::BOOLEAN AS ApprovalRequired
        ,ApprovalRequest.value:ApprovedBy::VARIANT AS ApprovedBy
        ,ApprovalRequest.value:Approver::VARIANT AS Approver
        ,ApprovalRequest.value:ApproverComment::STRING AS ApproverComment
        ,ApprovalRequest.value:AssignedDate::TIMESTAMP_NTZ AS AssignedDate
        ,ApprovalRequest.value:AssignedTo:UniqueName::STRING AS AssignedToCode
        ,ApprovalRequest.value:Creator:UniqueName::STRING AS CreatorCode
        ,ApprovalRequest.value:EscalationDate::TIMESTAMP_NTZ AS EscalationDate
        ,ApprovalRequest.value:EscalationExtendedByUser:UniqueName::STRING AS EscalationExtendedByUserCode
        ,ApprovalRequest.value:EscalationExtensionDate::TIMESTAMP_NTZ AS EscalationExtensionDate
        ,ApprovalRequest.value:EscalationWarningDate::TIMESTAMP_NTZ AS EscalationWarningDate
        ,ApprovalRequest.value:ExtendEscalationReasonCode::STRING AS ExtendEscalationReasonCode
        ,ApprovalRequest.value:ExtendEscalationUserComments::STRING AS ExtendEscalationUserComments
        ,ApprovalRequest.value:IsEscalatedToList::BOOLEAN AS IsEscalatedToList
        ,ApprovalRequest.value:IsEscalationExtended::BOOLEAN AS IsEscalationExtended
        ,ApprovalRequest.value:LastModified::TIMESTAMP_NTZ AS LastModified
        ,ApprovalRequest.value:ManuallyAdded::STRING AS ManuallyAdded
        ,ApprovalRequest.value:Reason::STRING AS Reason
        ,ApprovalRequest.value:ReportingExtendEscalationReason::STRING AS ReportingExtendEscalationReason
        ,ApprovalRequest.value:ReportingReason::STRING AS ReportingReason
        ,ApprovalRequest.value:RuleName::STRING AS RuleName
        ,ApprovalRequest.value:State::INTEGER AS State
        FROM {{ source('ARIBA', 'RECEIPT') }} LZData
        , LATERAL FLATTEN (input => parse_json(JsonField:ApprovalRequests)) ApprovalRequest
        WHERE 1=2
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                        regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                        ,LZData.JSonField:UniqueName::STRING
                                        ,LZData.JSonField:Version::INTEGER
                                        ,ApprovalRequest.value:ActivationDate::TIMESTAMP_NTZ
                                    ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
        )
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.RECEIPTIDKEY AS ReceiptIDKey,
        source_data.RECEIPTVERSIONKEY AS ReceiptVersionKey,
        source_data.ACTIVATIONDATE AS ReceiptApprovalKey,
        source_data.ACTIVATIONDATE AS ActivationDate,
        source_data.ALLOWESCALATIONPERIODEXTENSION AS AllowEscalationPeriodExtension,
        source_data.APPROVALREQUIRED AS ApprovalRequired,
        source_data.APPROVEDBY AS ApprovedBy,
        source_data.APPROVER AS Approver,
        source_data.APPROVERCOMMENT AS ApproverComment,
        source_data.ASSIGNEDDATE AS AssignedDate,
        source_data.ASSIGNEDTOCODE AS AssignedToCode,
        source_data.CREATORCODE AS CreatorCode,
        source_data.ESCALATIONDATE AS EscalationDate,
        source_data.ESCALATIONEXTENDEDBYUSERCODE AS EscalationExtendedByUserCode,
        source_data.ESCALATIONEXTENSIONDATE AS EscalationExtensionDate,
        source_data.ESCALATIONWARNINGDATE AS EscalationWarningDate,
        source_data.EXTENDESCALATIONREASONCODE AS ExtendEscalationReasonCode,
        source_data.EXTENDESCALATIONUSERCOMMENTS AS ExtendEscalationUserComments,
        source_data.ISESCALATEDTOLIST AS IsEscalatedToList,
        source_data.ISESCALATIONEXTENDED AS IsEscalationExtended,
        source_data.LASTMODIFIED AS LastModified,
        source_data.MANUALLYADDED AS ManuallyAdded,
        source_data.REASON AS Reason,
        source_data.REPORTINGEXTENDESCALATIONREASON AS ReportingExtendEscalationReason,
        source_data.REPORTINGREASON AS ReportingReason,
        source_data.RULENAME AS RuleName,
        source_data.STATE AS State
        FROM source_data
        )
,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
         REALMNAME,
         RECEIPTIDKEY,
        cast(RECEIPTVERSIONKEY as NUMBER(38,0)) as RECEIPTVERSIONKEY,
        cast(RECEIPTAPPROVALKEY as TIMESTAMP_NTZ(9)) as RECEIPTAPPROVALKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(ALLOWESCALATIONPERIODEXTENSION as BOOLEAN) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as BOOLEAN) as APPROVALREQUIRED,
        cast(APPROVEDBY as VARIANT) as APPROVEDBY,
        cast(APPROVER as VARIANT) as APPROVER,
         APPROVERCOMMENT,
        cast(ASSIGNEDDATE as TIMESTAMP_NTZ(9)) as ASSIGNEDDATE,
         ASSIGNEDTOCODE,
         CREATORCODE,
        cast(ESCALATIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONDATE,
         ESCALATIONEXTENDEDBYUSERCODE,
        cast(ESCALATIONEXTENSIONDATE as TIMESTAMP_NTZ(9)) as ESCALATIONEXTENSIONDATE,
        cast(ESCALATIONWARNINGDATE as TIMESTAMP_NTZ(9)) as ESCALATIONWARNINGDATE,
         EXTENDESCALATIONREASONCODE,
         EXTENDESCALATIONUSERCOMMENTS,
        cast(ISESCALATEDTOLIST as BOOLEAN) as ISESCALATEDTOLIST,
        cast(ISESCALATIONEXTENDED as BOOLEAN) as ISESCALATIONEXTENDED,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(MANUALLYADDED as BOOLEAN) as MANUALLYADDED,
         REASON,
         REPORTINGEXTENDESCALATIONREASON,
         REPORTINGREASON,
         RULENAME,
        cast(STATE as NUMBER(38,0)) as STATE
    from transform_data
    )
select distinct * from type_data