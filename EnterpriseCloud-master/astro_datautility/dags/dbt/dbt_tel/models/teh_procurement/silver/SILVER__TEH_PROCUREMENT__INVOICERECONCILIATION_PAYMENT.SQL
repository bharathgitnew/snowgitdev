/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\InvoiceReconciliation_Payment.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\InvoiceReconciliation_Payment.SQL
-materialized incremental
-alias InvoiceReconciliation_Payment
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:08 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='InvoiceReconciliation_Payment',
    unique_key= ['REALMNAME',
    'INVOICERECONCILIATIONIDKEY',
    'INVOICERECONCILIATIONVERSIONKEY',
    'INVOICERECONCILIATIONPAYMENTKEY']
) }}

with source_data as
(
    SELECT
        InvoiceReconciliationPayment.LastUpdated AS LASTUPDATED,
        InvoiceReconciliationPayment.RealmName AS REALMNAME,
        InvoiceReconciliationPayment.InvoiceReconciliationIDKey AS INVOICERECONCILIATIONIDKEY,
        InvoiceReconciliationPayment.InvoiceReconciliationVersionKey AS INVOICERECONCILIATIONVERSIONKEY,
        InvoiceReconciliationPayment.InvoiceReconciliationPaymentKey AS INVOICERECONCILIATIONPAYMENTKEY,
        InvoiceReconciliationPayment.PaymentCode AS PAYMENTCODE,
        InvoiceReconciliationPayment.NetDueDate AS NETDUEDATE,
        InvoiceReconciliationPayment.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICERECONCILIATIONPAYMENT') }} InvoiceReconciliationPayment
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        INVOICERECONCILIATIONIDKEY,
        INVOICERECONCILIATIONVERSIONKEY,
        INVOICERECONCILIATIONPAYMENTKEY,
        PAYMENTCODE,
        NETDUEDATE,
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
        cast(INVOICERECONCILIATIONPAYMENTKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONPAYMENTKEY,
        cast(PAYMENTCODE as VARCHAR(16777216)) as PAYMENTCODE,
        cast(NETDUEDATE as TIMESTAMP_NTZ(9)) as NETDUEDATE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data