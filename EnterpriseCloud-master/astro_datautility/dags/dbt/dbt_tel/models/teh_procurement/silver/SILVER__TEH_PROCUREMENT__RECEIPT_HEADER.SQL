/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Receipt_Header.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Receipt_Header.SQL
-materialized incremental
-alias Receipt_Header
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
    alias='Receipt_Header',
    unique_key= ['REALMNAME',
    'RECEIPTIDKEY',
    'RECEIPTVERSIONKEY']
) }}

with source_data as
(
    SELECT
        ReceiptHeader.LastUpdated AS LASTUPDATED,
        ReceiptHeader.RealmName AS REALMNAME,
        ReceiptHeader.ReceiptIDKey AS RECEIPTIDKEY,
        ReceiptHeader.ReceiptVersionKey AS RECEIPTVERSIONKEY,
        CASE ReceiptHeader.Active WHEN 1 THEN 'Yes' ELSE 'No' END AS ACTIVE,
        CASE ReceiptHeader.ANSentState WHEN 1 THEN 'NotYetActive' WHEN 2 THEN 'Sent' WHEN 4 THEN 'Sending' WHEN 8 THEN 'Failed' ELSE 'Unknown:' || TO_CHAR ( ReceiptHeader.ANSentState ) END AS ANSENTSTATE,
        ReceiptHeader.ApprovalRequestsVersion AS APPROVALREQUESTSVERSION,
        ReceiptHeader.ApprovedDate AS APPROVEDDATE,
        CASE ReceiptHeader.ApprovedState WHEN 1 THEN 'Composing' WHEN 2 THEN 'Submitted' WHEN 4 THEN 'Approved' WHEN 8 THEN 'Invalid' WHEN 16 THEN 'Denied' ELSE 'Unknown:' || TO_CHAR ( ReceiptHeader.ApprovedState ) END AS APPROVEDSTATE,
        ReceiptHeader.ChangedByCode AS CHANGEDBYCODE,
        CASE ReceiptHeader.CloseOrder WHEN 1 THEN 'Yes' ELSE 'No' END AS CLOSEORDER,
        ReceiptHeader.CreateDate AS CREATEDATE,
        ReceiptHeader.DueDate AS DUEDATE,
        ReceiptHeader.ERPReceiptNumber AS ERPRECEIPTNUMBER,
        ReceiptHeader.GoodsReturnTrackingNumber AS GOODSRETURNTRACKINGNUMBER,
        ReceiptHeader.HoldTillDate AS HOLDTILLDATE,
        ReceiptHeader.InitialReceiptId AS INITIALRECEIPTID,
        CASE ReceiptHeader.IsImported WHEN 1 THEN 'Yes' ELSE 'No' END AS ISIMPORTED,
        CASE ReceiptHeader.IsInTransitionToManual WHEN 1 THEN 'Yes' ELSE 'No' END AS ISINTRANSITIONTOMANUAL,
        CASE ReceiptHeader.IsReceiptPushFailed WHEN 1 THEN 'Yes' ELSE 'No' END AS ISRECEIPTPUSHFAILED,
        CASE ReceiptHeader.IsUnitPriceChanged WHEN 1 THEN 'Yes' ELSE 'No' END AS ISUNITPRICECHANGED,
        ReceiptHeader.LastModified AS LASTMODIFIED,
        ReceiptHeader.Name AS NAME,
        ReceiptHeader.NextVersion AS NEXTVERSION,
        ReceiptHeader.ObjectType AS OBJECTTYPE,
        ReceiptHeader.OrderCode AS ORDERCODE,
        ReceiptHeader.PreparerCode AS PREPARERCODE,
        ReceiptHeader.PreviousApprovalRequestsVersion AS PREVIOUSAPPROVALREQUESTSVERSION,
        ReceiptHeader.PreviousVersion AS PREVIOUSVERSION,
        ReceiptHeader.ProcurementUnitCode AS PROCUREMENTUNITCODE,
        CASE ReceiptHeader.ProcessedState WHEN 1 THEN 'Unprocessed' WHEN 2 THEN 'AwaitingProcessing' WHEN 4 THEN 'Processing' WHEN 8 THEN 'FailedProcessing' WHEN 16 THEN 'Processed' ELSE 'Unknown:' || TO_CHAR ( ReceiptHeader.ProcessedState ) END AS PROCESSEDSTATE,
        ReceiptHeader.RecentReceiveDate AS RECENTRECEIVEDATE,
        ReceiptHeader.RequesterCode AS REQUESTERCODE,
        CAST ( RIGHT ( ReceiptHeader.ReceiptIDKey , LEN ( ReceiptHeader.ReceiptIDKey ) - 2 ) AS INT ) AS RECEIPTNUMBER,
        ReceiptHeader.ResubmitDate AS RESUBMITDATE,
        ReceiptHeader.StatusString AS STATUSSTRING,
        ReceiptHeader.SubmitDate AS SUBMITDATE,
        ReceiptHeader.VersionNumber AS VERSIONNUMBER,
        ReceiptHeader.UniqueName AS UNIQUENAME,
        ReceiptHeader.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_RECEIPTHEADER') }} ReceiptHeader
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        RECEIPTIDKEY,
        RECEIPTVERSIONKEY,
        ACTIVE,
        ANSENTSTATE,
        APPROVALREQUESTSVERSION,
        APPROVEDDATE,
        APPROVEDSTATE,
        CHANGEDBYCODE,
        CLOSEORDER,
        CREATEDATE,
        DUEDATE,
        ERPRECEIPTNUMBER,
        GOODSRETURNTRACKINGNUMBER,
        HOLDTILLDATE,
        INITIALRECEIPTID,
        ISIMPORTED,
        ISINTRANSITIONTOMANUAL,
        ISRECEIPTPUSHFAILED,
        ISUNITPRICECHANGED,
        LASTMODIFIED,
        NAME,
        NEXTVERSION,
        OBJECTTYPE,
        ORDERCODE,
        PREPARERCODE,
        PREVIOUSAPPROVALREQUESTSVERSION,
        PREVIOUSVERSION,
        PROCUREMENTUNITCODE,
        PROCESSEDSTATE,
        RECENTRECEIVEDATE,
        REQUESTERCODE,
        RECEIPTNUMBER,
        RESUBMITDATE,
        STATUSSTRING,
        SUBMITDATE,
        VERSIONNUMBER,
        UNIQUENAME,
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
        cast(RECEIPTIDKEY as VARCHAR(16777216)) as RECEIPTIDKEY,
        cast(RECEIPTVERSIONKEY as NUMBER(38,0)) as RECEIPTVERSIONKEY,
        cast(ACTIVE as VARCHAR(16777216)) as ACTIVE,
        cast(ANSENTSTATE as VARCHAR(16777216)) as ANSENTSTATE,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as VARCHAR(16777216)) as APPROVEDSTATE,
        cast(CHANGEDBYCODE as VARCHAR(16777216)) as CHANGEDBYCODE,
        cast(CLOSEORDER as VARCHAR(16777216)) as CLOSEORDER,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(DUEDATE as TIMESTAMP_NTZ(9)) as DUEDATE,
        cast(ERPRECEIPTNUMBER as VARCHAR(16777216)) as ERPRECEIPTNUMBER,
        cast(GOODSRETURNTRACKINGNUMBER as VARCHAR(16777216)) as GOODSRETURNTRACKINGNUMBER,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALRECEIPTID as VARCHAR(16777216)) as INITIALRECEIPTID,
        cast(ISIMPORTED as VARCHAR(16777216)) as ISIMPORTED,
        cast(ISINTRANSITIONTOMANUAL as VARCHAR(16777216)) as ISINTRANSITIONTOMANUAL,
        cast(ISRECEIPTPUSHFAILED as VARCHAR(16777216)) as ISRECEIPTPUSHFAILED,
        cast(ISUNITPRICECHANGED as VARCHAR(16777216)) as ISUNITPRICECHANGED,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NEXTVERSION as VARCHAR(16777216)) as NEXTVERSION,
        cast(OBJECTTYPE as VARCHAR(16777216)) as OBJECTTYPE,
        cast(ORDERCODE as VARCHAR(16777216)) as ORDERCODE,
        cast(PREPARERCODE as VARCHAR(16777216)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as VARCHAR(16777216)) as PREVIOUSVERSION,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(PROCESSEDSTATE as VARCHAR(16777216)) as PROCESSEDSTATE,
        cast(RECENTRECEIVEDATE as TIMESTAMP_NTZ(9)) as RECENTRECEIVEDATE,
        cast(REQUESTERCODE as VARCHAR(16777216)) as REQUESTERCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(STATUSSTRING as VARCHAR(16777216)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(UNIQUENAME as VARCHAR(16777216)) as UNIQUENAME,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(RECEIPTNUMBER as NUMBER(38,0)) as RECEIPTNUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data