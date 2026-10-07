/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\InvoiceReconciliation_Exception.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\InvoiceReconciliation_Exception.SQL
-materialized incremental
-alias InvoiceReconciliation_Exception
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
    alias='InvoiceReconciliation_Exception',
    unique_key= ['REALMNAME',
    'INVOICERECONCILIATIONIDKEY',
    'INVOICERECONCILIATIONVERSIONKEY',
    'INVOICERECONCILIATIONLINEITEMKEY',
    'INVOICERECONCILIATIONEXCEPTIONKEY']
) }}

with source_data as
(
    SELECT
        InvoiceReconciliationException.LastUpdated AS LASTUPDATED,
        InvoiceReconciliationException.RealmName AS REALMNAME,
        InvoiceReconciliationException.InvoiceReconciliationIDKey AS INVOICERECONCILIATIONIDKEY,
        InvoiceReconciliationException.InvoiceReconciliationVersionKey AS INVOICERECONCILIATIONVERSIONKEY,
        InvoiceReconciliationException.InvoiceReconciliationLineItemKey AS INVOICERECONCILIATIONLINEITEMKEY,
        InvoiceReconciliationException.InvoiceReconciliationExceptionKey AS INVOICERECONCILIATIONEXCEPTIONKEY,
        InvoiceReconciliationException.ReconciledByCode AS RECONCILEDBYCODE,
        CASE InvoiceReconciliationException.State WHEN 1 THEN 'Unreconciled' WHEN 2 THEN 'Accepted' WHEN 4 THEN 'Disputed' WHEN 8 THEN 'CannotResolve' WHEN 16 THEN 'Cleared' ELSE 'Unknown:' || TO_CHAR ( InvoiceReconciliationException.State ) END AS STATE,
        InvoiceReconciliationException.TypeCode AS TYPECODE,
        InvoiceReconciliationException.TypeDriverName AS TYPEDRIVERNAME,
        InvoiceReconciliationException.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICERECONCILIATIONEXCEPTION') }} InvoiceReconciliationException
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        INVOICERECONCILIATIONIDKEY,
        INVOICERECONCILIATIONVERSIONKEY,
        INVOICERECONCILIATIONLINEITEMKEY,
        INVOICERECONCILIATIONEXCEPTIONKEY,
        RECONCILEDBYCODE,
        STATE,
        TYPECODE,
        TYPEDRIVERNAME,
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
        cast(INVOICERECONCILIATIONLINEITEMKEY as NUMBER(38,0)) as INVOICERECONCILIATIONLINEITEMKEY,
        cast(INVOICERECONCILIATIONEXCEPTIONKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONEXCEPTIONKEY,
        cast(RECONCILEDBYCODE as VARCHAR(16777216)) as RECONCILEDBYCODE,
        cast(STATE as VARCHAR(16777216)) as STATE,
        cast(TYPECODE as VARCHAR(16777216)) as TYPECODE,
        cast(TYPEDRIVERNAME as VARCHAR(16777216)) as TYPEDRIVERNAME,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data