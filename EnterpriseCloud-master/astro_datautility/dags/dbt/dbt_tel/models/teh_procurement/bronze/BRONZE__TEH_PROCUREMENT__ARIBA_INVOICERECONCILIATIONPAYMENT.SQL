{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONPAYMENT',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey',
    'InvoiceReconciliationPaymentKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::INTEGER AS InvoiceReconciliationVersionKey
        ,Payment.value:NetDueDate::TIMESTAMP_NTZ AS NetDueDate
        ,Payment.value:UniqueName::STRING AS PaymentCode
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:Payments)) Payment
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,Payment.value:UniqueName::STRING
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICERECONCILIATIONIDKEY AS InvoiceReconciliationIDKey,
        source_data.INVOICERECONCILIATIONVERSIONKEY AS InvoiceReconciliationVersionKey,
        source_data.PAYMENTCODE AS InvoiceReconciliationPaymentKey,
        source_data.PAYMENTCODE AS PaymentCode,
        source_data.NETDUEDATE AS NetDueDate,
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
        cast(INVOICERECONCILIATIONPAYMENTKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONPAYMENTKEY,
        cast(PAYMENTCODE as VARCHAR(16777216)) as PAYMENTCODE,
        cast(NETDUEDATE as TIMESTAMP_NTZ(9)) as NETDUEDATE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data