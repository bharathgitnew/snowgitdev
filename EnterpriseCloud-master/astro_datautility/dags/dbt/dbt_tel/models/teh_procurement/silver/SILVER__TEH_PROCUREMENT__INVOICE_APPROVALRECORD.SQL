/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Invoice_ApprovalRecord.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Invoice_ApprovalRecord.SQL
-materialized incremental
-alias Invoice_ApprovalRecord
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
    alias='Invoice_ApprovalRecord',
    unique_key = ['REALMNAME',
    'INVOICEIDKEY',
    'INVOICEVERSIONKEY',
    'INVOICEAPPROVALRECORDKEY']
) }}

with source_data as
(
    SELECT
        InvoiceApprovalRecord.LastUpdated AS LASTUPDATED,
        InvoiceApprovalRecord.RealmName AS REALMNAME,
        InvoiceApprovalRecord.InvoiceIdKey AS INVOICEIDKEY,
        InvoiceApprovalRecord.InvoiceVersionKey AS INVOICEVERSIONKEY,
        InvoiceApprovalRecord.InvoiceApprovalRecordKey AS INVOICEAPPROVALRECORDKEY,
        InvoiceApprovalRecord.ActivationDate AS ACTIVATIONDATE,
        InvoiceApprovalRecord.CommentDate AS COMMENTDATE,
        InvoiceApprovalRecord.CommentExternalComment AS COMMENTEXTERNALCOMMENT,
        InvoiceApprovalRecord.CommentTitle AS COMMENTTITLE,
        InvoiceApprovalRecord.CommentUser AS COMMENTUSER,
        InvoiceApprovalRecord.Date AS DATE,
        InvoiceApprovalRecord.RealUser AS REALUSER,
        InvoiceApprovalRecord.ReceivedFromEmail AS RECEIVEDFROMEMAIL,
        InvoiceApprovalRecord.State AS STATE,
        InvoiceApprovalRecord.User AS USER,
        InvoiceApprovalRecord.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICEAPPROVALRECORD') }} InvoiceApprovalRecord
)
,transform_data as
(
    SELECT 
        LASTUPDATED,
        REALMNAME,
        INVOICEIDKEY,
        INVOICEVERSIONKEY,
        INVOICEAPPROVALRECORDKEY,
        ACTIVATIONDATE,
        COMMENTDATE,
        COMMENTEXTERNALCOMMENT,
        COMMENTTITLE,
        COMMENTUSER,
        DATE,
        REALUSER,
        RECEIVEDFROMEMAIL,
        STATE,
        USER,
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
        cast(INVOICEAPPROVALRECORDKEY as TIMESTAMP_NTZ(9)) as INVOICEAPPROVALRECORDKEY,
        cast(ACTIVATIONDATE as TIMESTAMP_NTZ(9)) as ACTIVATIONDATE,
        cast(COMMENTDATE as TIMESTAMP_NTZ(9)) as COMMENTDATE,
        cast(COMMENTEXTERNALCOMMENT as VARCHAR(16777216)) as COMMENTEXTERNALCOMMENT,
        cast(COMMENTTITLE as VARCHAR(16777216)) as COMMENTTITLE,
        cast(COMMENTUSER as VARCHAR(16777216)) as COMMENTUSER,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(REALUSER as VARCHAR(16777216)) as REALUSER,
        cast(RECEIVEDFROMEMAIL as VARCHAR(16777216)) as RECEIVEDFROMEMAIL,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(USER as VARCHAR(16777216)) as USER,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data