{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_RECEIPTHEADER',
    unique_key = ['RealmName',
    'ReceiptIDKey',
    'ReceiptVersionKey'],
    enabled=true
) }}
with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FILENAME, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:ANSentState::INT AS ANSentState
        ,JsonField:Active::BOOLEAN AS Active
        ,JsonField:ApprovalRequestsVersion::INT AS ApprovalRequestsVersion
        ,JsonField:ApprovedDate::TIMESTAMP_NTZ AS ApprovedDate
        ,JsonField:ApprovedState::INT AS ApprovedState
        ,parse_json(JsonField:ChangedBy):UniqueName::STRING AS ChangedByCode
        ,JsonField:CloseOrder::BOOLEAN AS CloseOrder
        ,JsonField:CreateDate::TIMESTAMP_NTZ AS CreateDate
        ,JsonField:DueDate::TIMESTAMP_NTZ AS DueDate
        ,JsonField:ERPReceiptNumber::STRING AS ERPReceiptNumber
        ,JsonField:GoodsReturnTrackingNumber::STRING AS GoodsReturnTrackingNumber
        ,JsonField:HoldTillDate::TIMESTAMP_NTZ AS HoldTillDate
        ,JsonField:InitialUniqueName::STRING AS InitialReceiptId
        ,JsonField:IsImported::BOOLEAN AS IsImported
        ,JsonField:IsInTransitionToManual::BOOLEAN AS IsInTransitionToManual
        ,JsonField:IsReceiptPushFailed::BOOLEAN AS IsReceiptPushFailed
        ,JsonField:IsUnitPriceChanged::BOOLEAN AS IsUnitPriceChanged
        ,JsonField:LastModified::TIMESTAMP_NTZ AS LastModified
        ,JsonField:Name::STRING AS Name
        ,JsonField:NextVersion::STRING AS NextVersion
        ,parse_json(JsonField:Order):UniqueName::STRING AS OrderCode
        ,parse_json(JsonField:Preparer):UniqueName::STRING AS PreparerCode
        ,JsonField:PreviousApprovalRequestsVersion::INT AS PreviousApprovalRequestsVersion
        ,JsonField:PreviousVersion::STRING AS PreviousVersion
        ,JsonField:ProcessedState::INT AS ProcessedState
        ,parse_json(JsonField:ProcurementUnit):UniqueName::STRING AS ProcurementUnitCode
        ,JsonField:RecentReceiveDate::TIMESTAMP_NTZ AS RecentReceiveDate
        ,parse_json(JsonField:Requester):UniqueName::STRING AS RequesterCode
        ,JsonField:ResubmitDate::TIMESTAMP_NTZ AS ResubmitDate
        ,JsonField:StatusString::STRING AS StatusString
        ,JsonField:SubmitDate::TIMESTAMP_NTZ AS SubmitDate
        ,JsonField:TimeCreated::TIMESTAMP_NTZ AS TimeCreated
        ,JsonField:TimeUpdated::TIMESTAMP_NTZ AS TimeUpdated
        ,JsonField:Type::STRING AS Type
        ,JsonField:UniqueName::STRING AS UniqueName
        ,JsonField:VersionNumber::INT AS VersionNumber
        FROM {{ source("ARIBA", "RECEIPT") }} LZData
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                        regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                        ,LZData.JSonField:UniqueName::STRING
                                        ,LZData.JSonField:VersionNumber::INTEGER
                                    ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
        )
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.UNIQUENAME AS ReceiptIDKey,
        source_data.VERSIONNUMBER AS ReceiptVersionKey,
        source_data.ANSENTSTATE AS ANSentState,
        source_data.ACTIVE AS Active,
        source_data.APPROVALREQUESTSVERSION AS ApprovalRequestsVersion,
        source_data.APPROVEDDATE AS ApprovedDate,
        source_data.APPROVEDSTATE AS ApprovedState,
        source_data.CHANGEDBYCODE AS ChangedByCode,
        source_data.CLOSEORDER AS CloseOrder,
        source_data.CREATEDATE AS CreateDate,
        source_data.DUEDATE AS DueDate,
        source_data.ERPRECEIPTNUMBER AS ERPReceiptNumber,
        source_data.GOODSRETURNTRACKINGNUMBER AS GoodsReturnTrackingNumber,
        source_data.HOLDTILLDATE AS HoldTillDate,
        source_data.INITIALRECEIPTID AS InitialReceiptId,
        source_data.ISIMPORTED AS IsImported,
        source_data.ISINTRANSITIONTOMANUAL AS IsInTransitionToManual,
        source_data.ISRECEIPTPUSHFAILED AS IsReceiptPushFailed,
        source_data.ISUNITPRICECHANGED AS IsUnitPriceChanged,
        source_data.LASTMODIFIED AS LastModified,
        source_data.NAME AS Name,
        source_data.NEXTVERSION AS NextVersion,
        source_data.TYPE AS ObjectType,
        source_data.ORDERCODE AS OrderCode,
        source_data.PREPARERCODE AS PreparerCode,
        source_data.PREVIOUSAPPROVALREQUESTSVERSION AS PreviousApprovalRequestsVersion,
        source_data.PREVIOUSVERSION AS PreviousVersion,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.PROCESSEDSTATE AS ProcessedState,
        source_data.RECENTRECEIVEDATE AS RecentReceiveDate,
        source_data.REQUESTERCODE AS RequesterCode,
        source_data.RESUBMITDATE AS ResubmitDate,
        source_data.STATUSSTRING AS StatusString,
        source_data.SUBMITDATE AS SubmitDate,
        source_data.UNIQUENAME AS UniqueName,
        source_data.VERSIONNUMBER AS VersionNumber,
        source_data.TIMECREATED as TIMECREATED,
        source_data.TIMEUPDATED as TIMEUPDATED,
        'No' AS IsHistorical,
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
        cast(ACTIVE as BOOLEAN) as ACTIVE,
        cast(ANSENTSTATE as NUMBER(38,0)) as ANSENTSTATE,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as NUMBER(38,0)) as APPROVEDSTATE,
        cast(CHANGEDBYCODE as VARCHAR(16777216)) as CHANGEDBYCODE,
        cast(CLOSEORDER as BOOLEAN) as CLOSEORDER,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(DUEDATE as TIMESTAMP_NTZ(9)) as DUEDATE,
        cast(ERPRECEIPTNUMBER as VARCHAR(16777216)) as ERPRECEIPTNUMBER,
        cast(GOODSRETURNTRACKINGNUMBER as VARCHAR(16777216)) as GOODSRETURNTRACKINGNUMBER,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALRECEIPTID as VARCHAR(16777216)) as INITIALRECEIPTID,
        cast(ISIMPORTED as BOOLEAN) as ISIMPORTED,
        cast(ISINTRANSITIONTOMANUAL as BOOLEAN) as ISINTRANSITIONTOMANUAL,
        cast(ISRECEIPTPUSHFAILED as BOOLEAN) as ISRECEIPTPUSHFAILED,
        cast(ISUNITPRICECHANGED as BOOLEAN) as ISUNITPRICECHANGED,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NEXTVERSION as VARCHAR(16777216)) as NEXTVERSION,
        cast(OBJECTTYPE as VARCHAR(16777216)) as OBJECTTYPE,
        cast(ORDERCODE as VARCHAR(16777216)) as ORDERCODE,
        cast(PREPARERCODE as VARCHAR(16777216)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as VARCHAR(16777216)) as PREVIOUSVERSION,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(PROCESSEDSTATE as NUMBER(38,0)) as PROCESSEDSTATE,
        cast(RECENTRECEIVEDATE as TIMESTAMP_NTZ(9)) as RECENTRECEIVEDATE,
        cast(REQUESTERCODE as VARCHAR(16777216)) as REQUESTERCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(STATUSSTRING as VARCHAR(16777216)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(null as VARCHAR(16777216)) as TYPE,
        cast(TIMECREATED as TIMESTAMP_NTZ(9)) as TIMECREATED,
        cast(TIMEUPDATED as TIMESTAMP_NTZ(9)) as TIMEUPDATED,
        cast(UNIQUENAME as VARCHAR(16777216)) as UNIQUENAME,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data