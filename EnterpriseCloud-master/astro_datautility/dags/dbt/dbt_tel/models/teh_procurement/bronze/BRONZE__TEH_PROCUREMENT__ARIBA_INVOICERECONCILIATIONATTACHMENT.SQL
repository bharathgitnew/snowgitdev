{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONATTACHMENT',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey',
    'InvoiceReconciliationAttachmentKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::INTEGER AS InvoiceReconciliationVersionKey
        ,Attachment.Value:ContentLength::INTEGER AS ContentLength
        ,Attachment.Value:ContentType::STRING AS ContentType
        ,Attachment.Value:Extension::STRING AS Extension
        ,Attachment.Value:Filename::STRING AS Filename
        ,Attachment.Value:StoredFilename::STRING AS StoredFilename
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => JsonField:"Attachments.Attachments") Attachment
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,Attachment.Value:StoredFilename::STRING
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICERECONCILIATIONIDKEY AS InvoiceReconciliationIDKey,
        source_data.INVOICERECONCILIATIONVERSIONKEY AS InvoiceReconciliationVersionKey,
        source_data.STOREDFILENAME AS InvoiceReconciliationAttachmentKey,
        source_data.STOREDFILENAME AS StoredFileName,
        source_data.CONTENTLENGTH AS ContentLength,
        source_data.CONTENTTYPE AS ContentType,
        source_data.EXTENSION AS Extension,
        source_data.FILENAME AS FileName,
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
select distinct * from type_data