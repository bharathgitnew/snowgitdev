{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONEXCEPTION',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey',
    'InvoiceReconciliationLineItemKey',
    'InvoiceReconciliationExceptionKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_LTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::INT AS InvoiceReconciliationVersionKey
        , -1 as InvoiceReconciliationLineItemKey
        ,Exception.value:ReconciledBy:UniqueName::INTEGER AS ReconciledByCode
        ,Exception.value:State::INTEGER AS State
        ,Exception.value:Type:UniqueName::STRING AS TypeCode
        ,Exception.value:Type:DriverName::STRING AS TypeDriverName
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:Exception)) Exception
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,Exception.value:Type:UniqueName::STRING
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
    union all

    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::INTEGER AS InvoiceReconciliationVersionKey
        ,LineItem.value:NumberInCollection::INTEGER AS InvoiceReconciliationLineItemKey
        ,Exception.value:ReconciledBy:UniqueName::STRING AS ReconciledByCode
        ,Exception.value:State::INTEGER AS State
        ,Exception.value:Type:UniqueName::STRING AS TypeCode
        ,Exception.value:Type:DriverName::STRING AS TypeDriverName
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JSonField:LineItems)) LineItem
        ,LATERAL FLATTEN (input => LineItem.value:Exception) Exception
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,LineItem.value:NumberInCollection::INTEGER
                                ,Exception.value:Type:UniqueName::STRING
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICERECONCILIATIONIDKEY AS InvoiceReconciliationIDKey,
        source_data.INVOICERECONCILIATIONVERSIONKEY AS InvoiceReconciliationVersionKey,
        - 1 AS InvoiceReconciliationLineItemKey,
        source_data.TYPECODE AS InvoiceReconciliationExceptionKey,
        source_data.RECONCILEDBYCODE AS ReconciledByCode,
        source_data.STATE AS State,
        source_data.TYPECODE AS TypeCode,
        source_data.TYPEDRIVERNAME AS TypeDriverName,
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
        cast(INVOICERECONCILIATIONLINEITEMKEY as NUMBER(38,0)) as INVOICERECONCILIATIONLINEITEMKEY,
        cast(INVOICERECONCILIATIONEXCEPTIONKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONEXCEPTIONKEY,
        cast(RECONCILEDBYCODE as VARCHAR(16777216)) as RECONCILEDBYCODE,
        cast(STATE as NUMBER(38,0)) as STATE,
        cast(TYPECODE as VARCHAR(16777216)) as TYPECODE,
        cast(TYPEDRIVERNAME as VARCHAR(16777216)) as TYPEDRIVERNAME,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        from transform_data
    )
select distinct * from type_data