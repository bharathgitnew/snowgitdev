{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICESPLITACCOUNTING',
    unique_key = ['RealmName',
    'InvoiceIdKey',
    'InvoiceVersionKey',
    'InvoiceLineItemKey',
    'NumberInCollection']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceIdKey
        ,JsonField:VersionNumber::NUMBER(38,10) AS InvoiceVersionKey
        ,LineItem.value:NumberInCollection::INTEGER AS InvoiceLineItemKey
        ,SplitAccounting.value:Amount:Amount::NUMBER(38,10) AS AmountAmount
        ,SplitAccounting.value:Amount:BaseCurrency::NUMBER(38,10) AS AmountBaseCurrency
        ,SplitAccounting.value:Amount:ConversionDate::TIMESTAMP_NTZ AS AmountConversionDate
        ,SplitAccounting.value:Amount:CurrencyUniqueName::STRING AS AmountCurrencyCode
        ,SplitAccounting.value:Amount:ReportingCurrency::NUMBER(38,10) AS AmountReportingCurrency
        ,SplitAccounting.value:Asset:CompanyCode:UniqueName::STRING AS AssetCompanyCode
        ,SplitAccounting.value:Asset:SubNumber::STRING AS AssetSubNumber
        ,SplitAccounting.value:Asset:UniqueName::STRING AS AssetCode
        ,SplitAccounting.value:Asset:Name::STRING AS AssetName
        ,SplitAccounting.value:CompanyCode:UniqueName::STRING AS CompanyCodeCode
        ,SplitAccounting.value:CostCenter:CompanyCode:UniqueName::STRING AS CostCenterCompanyCodeCode
        ,SplitAccounting.value:CostCenter:UniqueName::STRING AS CostCenterCode
        ,SplitAccounting.value:CostCenter:ProcurementUnit:UniqueName::STRING AS CostCenterProcurementUnit
        ,SplitAccounting.value:CostCenter:Description::STRING AS CostCenterDescription
        ,SplitAccounting.value:ERPSplitValue::STRING AS ERPSplitValue
        ,SplitAccounting.value:GeneralLedger:Description::STRING AS GeneralLedgerDescription
        ,SplitAccounting.value:GeneralLedger:Description2::STRING AS GeneralLedgerDescription2
        ,SplitAccounting.value:GeneralLedger:UniqueName::STRING AS GeneralLedgerCode
        ,SplitAccounting.value:GeneralLedger:CompanyCodeUniqueName::STRING AS GeneralLedgerCompanyCodeCode
        ,SplitAccounting.value:GeneralLedger:FieldStatusGroup::STRING AS GeneralLedgerFieldStatusGroup
        ,SplitAccounting.value:GeneralLedger:ExternalId::STRING AS GeneralLedgerExternalId
        ,SplitAccounting.value:InternalOrder:Description::STRING AS InternalOrderDescription
        ,SplitAccounting.value:InternalOrder:UniqueName::STRING AS InternalOrderCode
        ,SplitAccounting.value:NumberInCollection::INTEGER AS NumberInCollection
        ,SplitAccounting.value:POLineNumber::STRING AS POLineNumber
        ,SplitAccounting.value:PONumber::STRING AS PONumber
        ,SplitAccounting.value:Percentage::NUMBER(38,10) AS Percentage
        ,SplitAccounting.value:ProcurementUnit:UniqueName::STRING AS ProcurementUnitCode
        ,SplitAccounting.value:Quantity::NUMBER(38,10) AS Quantity
        ,SplitAccounting.value:Type:UniqueName::STRING AS TypeCode
        ,SplitAccounting.value:WBSElementCompanyCodeUniqueNameList::STRING AS WBSElementCompanyCodeCodeList
        ,SplitAccounting.value:WBSElement:Description::STRING AS WBSElementDescription
        ,SplitAccounting.value:WBSElement:ProjectNumber::STRING AS WBSElementProjectNumber
        ,SplitAccounting.value:WBSElement:UniqueName::STRING AS WBSElement
        ,SplitAccounting.value:cus_Office:UniqueName::STRING AS CustomField_Office
        ,SplitAccounting.value:cus_FYNumber:UniqueName::STRING AS CustomField_FYNumber
        ,SplitAccounting.value:cus_RECompanyCode::STRING AS CustomField_RECompanyCode
        ,SplitAccounting.value:cus_Segment:UniqueName::STRING AS CustomField_Segment
        ,SplitAccounting.value:cus_Project:UniqueName::STRING AS CustomField_Project
        FROM {{ source("ARIBA", "INVOICE") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:LineItems)) LineItem
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
        source_data.INVOICEIDKEY AS InvoiceIdKey,
        source_data.INVOICEVERSIONKEY AS InvoiceVersionKey,
        source_data.INVOICELINEITEMKEY AS InvoiceLineItemKey,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTBASECURRENCY AS AmountBaseCurrency,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.AMOUNTREPORTINGCURRENCY AS AmountReportingCurrency,
        source_data.ASSETCOMPANYCODE AS AssetCompanyCode,
        source_data.ASSETSUBNUMBER AS AssetSubNumber,
        source_data.ASSETCODE AS AssetCode,
        source_data.ASSETNAME AS AssetName,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.COSTCENTERCOMPANYCODECODE AS CostCenterCompanyCodeCode,
        source_data.COSTCENTERCODE AS CostCenterCode,
        source_data.COSTCENTERPROCUREMENTUNIT AS CostCenterProcurementUnit,
        source_data.COSTCENTERDESCRIPTION AS CostCenterDescription,
        source_data.ERPSPLITVALUE AS ERPSplitValue,
        source_data.GENERALLEDGERDESCRIPTION AS GeneralLedgerDescription,
        source_data.GENERALLEDGERDESCRIPTION2 AS GeneralLedgerDescription2,
        source_data.GENERALLEDGERCODE AS GeneralLedgerCode,
        source_data.GENERALLEDGERCOMPANYCODECODE AS GeneralLedgerCompanyCodeCode,
        source_data.GENERALLEDGERFIELDSTATUSGROUP AS GeneralLedgerFieldStatusGroup,
        source_data.GENERALLEDGEREXTERNALID AS GeneralLedgerExternalId,
        source_data.INTERNALORDERDESCRIPTION AS InternalOrderDescription,
        source_data.INTERNALORDERCODE AS InternalOrderCode,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.POLINENUMBER AS POLineNumber,
        source_data.PONUMBER AS PONumber,
        source_data.PERCENTAGE AS Percentage,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.QUANTITY AS Quantity,
        source_data.TYPECODE AS TypeCode,
        source_data.WBSELEMENTCOMPANYCODECODELIST AS WBSElementCompanyCodeCodeList,
        source_data.WBSELEMENTDESCRIPTION AS WBSElementDescription,
        source_data.WBSELEMENTPROJECTNUMBER AS WBSElementProjectNumber,
        source_data.WBSELEMENT AS WBSElement,
        source_data.CUSTOMFIELD_OFFICE AS CustomField_Office,
        source_data.CUSTOMFIELD_FYNUMBER AS CustomField_FYNumber,
        source_data.CUSTOMFIELD_RECOMPANYCODE AS CustomField_RECompanyCode,
        source_data.CUSTOMFIELD_SEGMENT AS CustomField_Segment,
        source_data.CUSTOMFIELD_PROJECT AS CustomField_Project,
        'no' as ISHISTORICAL,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777126)) as REALMNAME,
        cast(INVOICEIDKEY as VARCHAR(16777126)) as INVOICEIDKEY,
        cast(INVOICEVERSIONKEY as NUMBER(38,0)) as INVOICEVERSIONKEY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777126)) as AMOUNTCURRENCYCODE,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(ASSETCOMPANYCODE as VARCHAR(16777126)) as ASSETCOMPANYCODE,
        cast(ASSETSUBNUMBER as VARCHAR(16777126)) as ASSETSUBNUMBER,
        cast(ASSETCODE as VARCHAR(16777126)) as ASSETCODE,
        cast(ASSETNAME as VARCHAR(16777126)) as ASSETNAME,
        cast(COMPANYCODECODE as VARCHAR(16777126)) as COMPANYCODECODE,
        cast(COSTCENTERCOMPANYCODECODE as VARCHAR(16777126)) as COSTCENTERCOMPANYCODECODE,
        cast(COSTCENTERCODE as VARCHAR(16777126)) as COSTCENTERCODE,
        cast(COSTCENTERPROCUREMENTUNIT as VARCHAR(16777126)) as COSTCENTERPROCUREMENTUNIT,
        cast(COSTCENTERDESCRIPTION as VARCHAR(16777126)) as COSTCENTERDESCRIPTION,
        cast(ERPSPLITVALUE as VARCHAR(16777126)) as ERPSPLITVALUE,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGERCODE as VARCHAR(16777126)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777126)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777126)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777126)) as GENERALLEDGEREXTERNALID,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777126)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777126)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(POLINENUMBER as VARCHAR(16777126)) as POLINENUMBER,
        cast(PONUMBER as VARCHAR(16777126)) as PONUMBER,
        cast(PERCENTAGE as NUMBER(38,10)) as PERCENTAGE,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777126)) as PROCUREMENTUNITCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(TYPECODE as VARCHAR(16777126)) as TYPECODE,
        cast(WBSELEMENTCOMPANYCODECODELIST as VARCHAR(16777126)) as WBSELEMENTCOMPANYCODECODELIST,
        cast(WBSELEMENTDESCRIPTION as VARCHAR(16777126)) as WBSELEMENTDESCRIPTION,
        cast(WBSELEMENTPROJECTNUMBER as VARCHAR(16777126)) as WBSELEMENTPROJECTNUMBER,
        cast(WBSELEMENT as VARCHAR(16777126)) as WBSELEMENT,
        cast(CUSTOMFIELD_OFFICE as VARCHAR(16777126)) as CUSTOMFIELD_OFFICE,
        cast(CUSTOMFIELD_FYNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_FYNUMBER,
        cast(CUSTOMFIELD_RECOMPANYCODE as VARCHAR(16777126)) as CUSTOMFIELD_RECOMPANYCODE,
        cast(CUSTOMFIELD_SEGMENT as VARCHAR(16777126)) as CUSTOMFIELD_SEGMENT,
        cast(CUSTOMFIELD_PROJECT as VARCHAR(16777126)) as CUSTOMFIELD_PROJECT,
        cast(INVOICELINEITEMKEY as NUMBER(38,0)) as INVOICELINEITEMKEY,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as INVOICESPLITACCOUNTINGKEY,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data