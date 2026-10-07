{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONSPLITACCOUNTING',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey',
    'InvoiceReconciliationLineItemKey',
    'InvoiceReconciliationSplitAccountingKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::NUMBER(38,10) AS InvoiceReconciliationVersionKey
        ,LineItem.value:NumberInCollection::INTEGER AS InvoiceReconciliationLineItemKey
        ,SplitAccounting.value:Amount:AmountInReportingCurrency::NUMBER(38,10) AS AmountReportingCurrency
        ,SplitAccounting.value:Amount:ApproxAmountInBaseCurrency::STRING AS AmountBaseCurrency
        ,SplitAccounting.value:Amount:Amount::STRING AS AmountAmount
        ,SplitAccounting.value:Amount:ConversionDate::STRING AS AmountConversionDate
        ,SplitAccounting.value:Amount:Currency:UniqueName::STRING AS AmountCurrencyCode
        ,SplitAccounting.value:Asset:CompanyCode:UniqueName::STRING AS AssetCompanyCodeCode
        ,SplitAccounting.value:Asset:Name::STRING AS AssetName
        ,SplitAccounting.value:Asset:SubNumber::STRING AS AssetSubNumber
        ,SplitAccounting.value:Asset:UniqueName::STRING AS AssetCode
        ,SplitAccounting.value:CompanyCode:UniqueName::STRING AS CompanyCodeCode
        ,SplitAccounting.value:CostCenter:CompanyCode:UniqueName::STRING AS CostCenterCompanyCodeCode
        ,SplitAccounting.value:CostCenter:CostCenterDescription::STRING AS CostCenterCostCenterDescription
        ,SplitAccounting.value:CostCenter:ProcurementUnit:UniqueName::STRING AS CostCenterProcurementUnitCode
        ,SplitAccounting.value:CostCenter:UniqueName::STRING AS CostCenterCode
        ,SplitAccounting.value:ERPSplitValue::STRING AS ERPSplitValue
        ,SplitAccounting.value:GeneralLedger:CompanyCode:UniqueName::STRING AS GeneralLedgerCompanyCodeCode
        ,SplitAccounting.value:GeneralLedger:GeneralLedgerDescription::STRING AS GeneralLedgerDescription
        ,SplitAccounting.value:GeneralLedger:GeneralLedgerDescription2::STRING AS GeneralLedgerDescription2
        ,SplitAccounting.value:GeneralLedger:ExternalId::STRING AS GeneralLedgerExternalId
        ,SplitAccounting.value:GeneralLedger:FieldStatusGroup::STRING AS GeneralLedgerFieldStatusGroup
        ,SplitAccounting.value:GeneralLedger:UniqueName::STRING AS GeneralLedgerCode
        ,SplitAccounting.value:InternalOrder.Description::STRING AS InternalOrderDescription
        ,SplitAccounting.value:InternalOrder:UniqueName::STRING AS InternalOrderCode
        ,SplitAccounting.value:NumberInCollection::INTEGER AS NumberInCollection
        ,SplitAccounting.value:Percentage::NUMBER(38,10) AS Percentage
        ,SplitAccounting.value:POLineNumber::STRING AS POLineNumber
        ,SplitAccounting.value:PONumber::STRING AS PONumber
        ,SplitAccounting.value:ProcurementUnit:UniqueName::STRING AS ProcurementUnitCode
        ,SplitAccounting.value:Quantity::NUMBER(38,10) AS Quantity
        ,SplitAccounting.value:Type:UniqueName::STRING AS TypeCode
        ,SplitAccounting.value:cus_FYNumber:UniqueName::STRING AS CustomField_FYNumber
        ,SplitAccounting.value:cus_Office:UniqueName::STRING AS CustomField_Office
        ,SplitAccounting.value:cus_Project:UniqueName::STRING AS CustomField_Project
        ,SplitAccounting.value:cus_RECompanyCode:UniqueName::STRING AS CustomField_RECompanyCode
        ,SplitAccounting.value:cus_Segment:UniqueName::STRING AS CustomField_Segment
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JSonField:LineItems)) LineItem
        ,LATERAL FLATTEN (input => LineItem.value:SplitAccountings) SplitAccounting
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,LineItem.value:NumberInCollection::INTEGER
                                ,SplitAccounting.value:NumberInCollection::INTEGER
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICERECONCILIATIONIDKEY AS InvoiceReconciliationIDKey,
        source_data.INVOICERECONCILIATIONVERSIONKEY AS InvoiceReconciliationVersionKey,
        source_data.INVOICERECONCILIATIONLINEITEMKEY AS InvoiceReconciliationLineItemKey,
        source_data.NUMBERINCOLLECTION AS InvoiceReconciliationSplitAccountingKey,
        source_data.AMOUNTREPORTINGCURRENCY AS AmountReportingCurrency,
        source_data.AMOUNTBASECURRENCY AS AmountBaseCurrency,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.ASSETCOMPANYCODECODE AS AssetCompanyCodeCode,
        source_data.ASSETSUBNUMBER AS AssetSubNumber,
        source_data.ASSETCODE AS AssetCode,
        source_data.ASSETNAME AS AssetName,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.COSTCENTERCOMPANYCODECODE AS CostCenterCompanyCodeCode,
        source_data.COSTCENTERCODE AS CostCenterCode,
        source_data.COSTCENTERPROCUREMENTUNITCODE AS CostCenterProcurementUnitCode,
        source_data.COSTCENTERCOSTCENTERDESCRIPTION AS CostCenterDescription,
        source_data.ERPSPLITVALUE AS ERPSplitValue,
        source_data.GENERALLEDGERCODE AS GeneralLedgerCode,
        source_data.GENERALLEDGERCOMPANYCODECODE AS GeneralLedgerCompanyCodeCode,
        source_data.GENERALLEDGERDESCRIPTION AS GeneralLedgerDescription,
        source_data.GENERALLEDGERDESCRIPTION2 AS GeneralLedgerDescription2,
        source_data.GENERALLEDGEREXTERNALID AS GeneralLedgerExternalId,
        source_data.GENERALLEDGERFIELDSTATUSGROUP AS GeneralLedgerFieldStatusGroup,
        source_data.INTERNALORDERDESCRIPTION AS InternalOrderDescription,
        source_data.INTERNALORDERCODE AS InternalOrderCode,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.PERCENTAGE AS Percentage,
        source_data.POLINENUMBER AS POLineNumber,
        source_data.PONUMBER AS PONumber,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.QUANTITY AS Quantity,
        source_data.TYPECODE AS TypeCode,
        source_data.CUSTOMFIELD_FYNUMBER AS CustomField_FYNumber,
        source_data.CUSTOMFIELD_OFFICE AS CustomField_Office,
        source_data.CUSTOMFIELD_PROJECT AS CustomField_Project,
        source_data.CUSTOMFIELD_RECOMPANYCODE AS CustomField_RECompanyCode,
        source_data.CUSTOMFIELD_SEGMENT AS CustomField_Segment,
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
        cast(INVOICERECONCILIATIONSPLITACCOUNTINGKEY as NUMBER(38,0)) as INVOICERECONCILIATIONSPLITACCOUNTINGKEY,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
        cast(ASSETCOMPANYCODECODE as VARCHAR(16777216)) as ASSETCOMPANYCODECODE,
        cast(ASSETSUBNUMBER as VARCHAR(16777216)) as ASSETSUBNUMBER,
        cast(ASSETCODE as VARCHAR(16777216)) as ASSETCODE,
        cast(ASSETNAME as VARCHAR(16777216)) as ASSETNAME,
        cast(COMPANYCODECODE as VARCHAR(16777216)) as COMPANYCODECODE,
        cast(COSTCENTERCOMPANYCODECODE as VARCHAR(16777216)) as COSTCENTERCOMPANYCODECODE,
        cast(COSTCENTERCODE as VARCHAR(16777216)) as COSTCENTERCODE,
        cast(COSTCENTERPROCUREMENTUNITCODE as VARCHAR(16777216)) as COSTCENTERPROCUREMENTUNITCODE,
        cast(COSTCENTERDESCRIPTION as VARCHAR(16777216)) as COSTCENTERDESCRIPTION,
        cast(ERPSPLITVALUE as VARCHAR(16777216)) as ERPSPLITVALUE,
        cast(GENERALLEDGERCODE as VARCHAR(16777216)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777216)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777216)) as GENERALLEDGEREXTERNALID,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777216)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777216)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777216)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as VARCHAR(16777216)) as NUMBERINCOLLECTION,
        cast(PERCENTAGE as NUMBER(38,10)) as PERCENTAGE,
        cast(POLINENUMBER as VARCHAR(16777216)) as POLINENUMBER,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(TYPECODE as VARCHAR(16777216)) as TYPECODE,
        cast(CUSTOMFIELD_FYNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_FYNUMBER,
        cast(CUSTOMFIELD_OFFICE as VARCHAR(16777126)) as CUSTOMFIELD_OFFICE,
        cast(CUSTOMFIELD_PROJECT as VARCHAR(16777126)) as CUSTOMFIELD_PROJECT,
        cast(CUSTOMFIELD_RECOMPANYCODE as VARCHAR(16777126)) as CUSTOMFIELD_RECOMPANYCODE,
        cast(CUSTOMFIELD_SEGMENT as VARCHAR(16777126)) as CUSTOMFIELD_SEGMENT,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data