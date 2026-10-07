{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='ARIBA_REQUISITIONAPPROVALREQUEST',
    unique_key = []
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS RequisitionIDKey
        ,JsonField:Version::INTEGER AS RequisitionVersionKey
        ,ApprovalRequest.value:ActivationDate::TIMESTAMP_NTZ AS ActivationDate
        ,ApprovalRequest.value:AllowEscalationPeriodExtension::BOOLEAN AS AllowEscalationPeriodExtension
        ,ApprovalRequest.value:ApprovalRequired::BOOLEAN AS ApprovalRequired
        ,ApprovalRequest.value:ApprovedBy:UniqueName::STRING AS ApprovedByCode
        ,ApprovalRequest.value:Approver:UniqueName::STRING AS ApproverCode
        ,ApprovalRequest.value:Approver:Comment::STRING AS ApproverComment
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
        ,ApprovalRequest.value:ManuallyAdded::BOOLEAN AS ManuallyAdded
        ,ApprovalRequest.value:Reason::STRING AS Reason
        ,ApprovalRequest.value:ReportingExtendEscalationReason::STRING AS ReportingExtendEscalationReason
        ,ApprovalRequest.value:ReportingReason::STRING AS ReportingReason
        ,ApprovalRequest.value:RuleName::STRING AS RuleName
        ,ApprovalRequest.value:State::INTEGER AS State
        FROM {{ source("ARIBA", "REQUISITION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:ApprovalRequests)) ApprovalRequest
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,ApprovalRequest.value:ActivationDate::TIMESTAMP_NTZ
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1        )
,transform_data as
(
    SELECT
        source_data.ACTIVATIONDATE,
        source_data.ALLOWESCALATIONPERIODEXTENSION,
        source_data.APPROVALREQUIRED,
        source_data.APPROVEDBYCODE,
        source_data.APPROVERCODE,
        source_data.APPROVERCOMMENT,
        source_data.ASSIGNEDDATE,
        source_data.ASSIGNEDTOCODE,
        source_data.CREATORCODE,
        source_data.ESCALATIONDATE,
        source_data.ESCALATIONEXTENDEDBYUSERCODE,
        source_data.ESCALATIONEXTENSIONDATE,
        source_data.ESCALATIONWARNINGDATE,
        source_data.EXTENDESCALATIONREASONCODE,
        source_data.EXTENDESCALATIONUSERCOMMENTS,
        source_data.ISESCALATEDTOLIST,
        source_data.ISESCALATIONEXTENDED,
        'No' as ISHISTORICAL,
        source_data.LASTUPDATED,
        source_data.MANUALLYADDED,
        source_data.REALMNAME,
        source_data.REASON,
        source_data.REPORTINGEXTENDESCALATIONREASON,
        source_data.REPORTINGREASON,
        IFNULL( source_data.CREATORCODE ,'---') ||':'|| IFNULL( TO_VARCHAR(source_data.ACTIVATIONDATE,'YYYYMMDD-HH24MISS'),'---') as REQUISITIONAPPROVALREQUESTKEY,
        source_data.REQUISITIONIDKEY,
        source_data.REQUISITIONVERSIONKEY,
        source_data.RULENAME,
        source_data.STATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
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
        cast(ALLOWESCALATIONPERIODEXTENSION as BOOLEAN) as ALLOWESCALATIONPERIODEXTENSION,
        cast(APPROVALREQUIRED as BOOLEAN) as APPROVALREQUIRED,
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
        cast(ISESCALATEDTOLIST as BOOLEAN) as ISESCALATEDTOLIST,
        cast(ISESCALATIONEXTENDED as BOOLEAN) as ISESCALATIONEXTENDED,
        cast(MANUALLYADDED as BOOLEAN) as MANUALLYADDED,
        cast(REASON as VARCHAR(16777216)) as REASON,
        cast(REPORTINGEXTENDESCALATIONREASON as VARCHAR(16777216)) as REPORTINGEXTENDESCALATIONREASON,
        cast(REPORTINGREASON as VARCHAR(16777216)) as REPORTINGREASON,
        cast(RULENAME as VARCHAR(16777216)) as RULENAME,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select distinct * from type_data