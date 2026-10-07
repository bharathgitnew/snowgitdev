/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Requisition_ApprovalRecord.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Requisition_ApprovalRecord.SQL
-materialized incremental
-alias Requisition_ApprovalRecord
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
    alias='Requisition_ApprovalRecord',
    unique_key = []
) }}

with source_data as
(
    SELECT
        RequisitionApprovalRecord.ActivationDate,
        RequisitionApprovalRecord.CommentDate,
        RequisitionApprovalRecord.CommentExternalComment,
        RequisitionApprovalRecord.CommentTitle,
        RequisitionApprovalRecord.CommentUserCode,
        RequisitionApprovalRecord.Date,
        RequisitionApprovalRecord.IsHistorical,
        RequisitionApprovalRecord.LastUpdated,
        RequisitionApprovalRecord.RealmName,
        RequisitionApprovalRecord.RealUser,
        RequisitionApprovalRecord.ReceivedFromEmail,
        RequisitionApprovalRecord.RequisitionApprovalRecordKey,
        RequisitionApprovalRecord.RequisitionIDKey,
        RequisitionApprovalRecord.RequisitionVersionKey,
        RequisitionApprovalRecord.State,
        RequisitionApprovalRecord.UserCode
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_REQUISITIONAPPROVALRECORD') }} RequisitionApprovalRecord
    )
,transform_data as
(
    SELECT
        ACTIVATIONDATE,
        COMMENTDATE,
        COMMENTEXTERNALCOMMENT,
        COMMENTTITLE,
        COMMENTUSERCODE,
        DATE,
        ISHISTORICAL,
        LASTUPDATED,
        REALMNAME,
        REALUSER,
        RECEIVEDFROMEMAIL,
        REQUISITIONAPPROVALRECORDKEY,
        REQUISITIONIDKEY,
        REQUISITIONVERSIONKEY,
        STATE,
        USERCODE,
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
        cast(REQUISITIONAPPROVALRECORDKEY as VARCHAR(16777216)) as REQUISITIONAPPROVALRECORDKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(COMMENTDATE as TIMESTAMP_NTZ(9)) as COMMENTDATE,
        cast(COMMENTEXTERNALCOMMENT as VARCHAR(16777216)) as COMMENTEXTERNALCOMMENT,
        cast(COMMENTTITLE as VARCHAR(16777216)) as COMMENTTITLE,
        cast(COMMENTUSERCODE as VARCHAR(16777216)) as COMMENTUSERCODE,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(REALUSER as VARCHAR(16777216)) as REALUSER,
        cast(RECEIVEDFROMEMAIL as VARCHAR(16777216)) as RECEIVEDFROMEMAIL,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(USERCODE as VARCHAR(16777216)) as USERCODE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data