/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\InvoiceReconciliation_Attachment.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\InvoiceReconciliation_Attachment.SQL
-materialized incremental
-alias InvoiceReconciliation_Attachment
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
    alias='InvoiceReconciliation_Attachment',
    unique_key = ['REALMNAME',
    'INVOICERECONCILIATIONIDKEY',
    'INVOICERECONCILIATIONVERSIONKEY',
    'INVOICERECONCILIATIONATTACHMENTKEY']
) }}

with source_data as
(
    SELECT
InvoiceReconciliationAttachment.LastUpdated AS LASTUPDATED,
InvoiceReconciliationAttachment.RealmName AS REALMNAME,
InvoiceReconciliationAttachment.InvoiceReconciliationIDKey AS INVOICERECONCILIATIONIDKEY,
InvoiceReconciliationAttachment.InvoiceReconciliationVersionKey AS INVOICERECONCILIATIONVERSIONKEY,
InvoiceReconciliationAttachment.InvoiceReconciliationAttachmentKey AS INVOICERECONCILIATIONATTACHMENTKEY,
InvoiceReconciliationAttachment.StoredFileName AS STOREDFILENAME,
InvoiceReconciliationAttachment.ContentLength AS CONTENTLENGTH,
InvoiceReconciliationAttachment.ContentType AS CONTENTTYPE,
InvoiceReconciliationAttachment.Extension AS EXTENSION,
InvoiceReconciliationAttachment.FileName AS FILENAME,
InvoiceReconciliationAttachment.IsHistorical AS ISHISTORICAL
FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICERECONCILIATIONATTACHMENT') }} InvoiceReconciliationAttachment
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        INVOICERECONCILIATIONIDKEY,
        INVOICERECONCILIATIONVERSIONKEY,
        INVOICERECONCILIATIONATTACHMENTKEY,
        STOREDFILENAME,
        CONTENTLENGTH,
        CONTENTTYPE,
        EXTENSION,
        FILENAME,
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
        cast(INVOICERECONCILIATIONATTACHMENTKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONATTACHMENTKEY,
        cast(STOREDFILENAME as VARCHAR(16777216)) as STOREDFILENAME,
        cast(CONTENTLENGTH as NUMBER(38,0)) as CONTENTLENGTH,
        cast(CONTENTTYPE as VARCHAR(16777216)) as CONTENTTYPE,
        cast(EXTENSION as VARCHAR(16777216)) as EXTENSION,
        cast(FILENAME as VARCHAR(16777216)) as FILENAME,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data