{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_REQUISITIONLINEITEM',
    unique_key = ['RealmName',
    'RequisitionIDKey',
    'RequisitionVersionKey',
    'RequisitionLineItemKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS RequisitionIDKey
        ,JsonField:Version::INTEGER AS RequisitionVersionKey
        ,LineItem.value:AccountCategory:UniqueName::STRING AS AccountCategoryCode
        ,LineItem.value:"Accountings.Type":UniqueName::STRING AS AccountingsTypeCode
        ,LineItem.value:AccountingTemplate:UniqueName::STRING AS AccountingTemplateCode
        ,LineItem.value:Amount:Amount::NUMBER AS AmountAmount
        ,LineItem.value:Amount:AmountInReportingCurrency::NUMBER AS AmountAmountInReportingCurrency
        ,LineItem.value:Amount:ApproxAmountInBaseCurrency::NUMBER AS AmountApproxAmountInBaseCurrency
        ,LineItem.value:Amount:ConversionDate::TIMESTAMP_NTZ AS AmountConversionDate
        ,LineItem.value:Amount:Currency:UniqueName::STRING AS AmountCurrencyCode
        ,LineItem.value:BasePrice:Amount::NUMBER AS BasePriceAmount
        ,LineItem.value:BasePrice:AmountInReportingCurrency::NUMBER(38,10) AS BasePriceAmountInReportingCurrency
        ,LineItem.value:BasePrice:ApproxAmountInBaseCurrency::NUMBER(38,10) AS BasePriceApproxAmountInBaseCurrency
        ,LineItem.value:BasePrice:ConversionDate::TIMESTAMP_NTZ AS BasePriceConversionDate
        ,LineItem.value:BasePrice:Currency:UniqueName::STRING AS BasePriceCurrencyCode
        ,LineItem.value:BillingAddress:City::STRING AS BillingAddressCity
        ,LineItem.value:BillingAddress:Country:UniqueName::STRING AS BillingAddressCountryCode
        ,LineItem.value:BillingAddress:Fax::STRING AS BillingAddressFax
        ,LineItem.value:BillingAddress:Lines::STRING AS BillingAddressLines
        ,LineItem.value:BillingAddress:Name::STRING AS BillingAddressName
        ,LineItem.value:BillingAddress:Phone::STRING AS BillingAddressPhone
        ,LineItem.value:BillingAddress:PostalCode::STRING AS BillingAddressPostalCode
        ,LineItem.value:BillingAddress:State::STRING AS BillingAddressState
        ,LineItem.value:BillingAddress:UniqueName::STRING AS BillingAddressCode
        ,LineItem.value:BoughtFromPreferredSupplier::BOOLEAN AS BoughtFromPreferredSupplier
        ,LineItem.value:BuyerItemMaster:BuyerPartNumber::STRING AS BuyerItemMasterBuyerPartNumber
        ,LineItem.value:BuyerName::STRING AS BuyerName
        ,LineItem.value:Carrier::STRING AS Carrier
        ,LineItem.value:CarrierMethod::STRING AS CarrierMethod
        ,LineItem.value:ChargeAmount:Amount::NUMBER(38,10) AS ChargeAmountAmount
        ,LineItem.value:ChargeAmount:AmountInReportingCurrency::NUMBER(38,10) AS ChargeAmountAmountInReportingCurrency
        ,LineItem.value:ChargeAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeAmountApproxAmountInBaseCurrency
        ,LineItem.value:ChargeAmount:ConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,LineItem.value:ChargeAmount:Currency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.ANChargeDescription"::STRING AS ChargeDetailANChargeDescription
        ,LineItem.value:"ChargeDetail.ANChargeName"::STRING AS ChargeDetailANChargeName
        ,LineItem.value:"ChargeDetail.ChargeAmount":Amount::NUMBER(38,10) AS ChargeDetailChargeAmountAmount
        ,LineItem.value:"ChargeDetail.ChargeAmount":AmountInReportingCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountAmountInReportingCurrency
        ,LineItem.value:"ChargeDetail.ChargeAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountApproxAmountInBaseCurrency
        ,LineItem.value:"ChargeDetail.ChargeAmount":ConversionDate::TIMESTAMP_NTZ AS ChargeDetailChargeAmountConversionDate
        ,LineItem.value:"ChargeDetail.ChargeAmount":Currency:UniqueName::STRING AS ChargeDetailChargeAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.ChargeType":UniqueName::STRING AS ChargeDetailChargeTypeCode
        ,LineItem.value:"ChargeDetail.TaxAmount":Amount::NUMBER(38,10) AS ChargeDetailTaxAmountAmount
        ,LineItem.value:"ChargeDetail.TaxAmount":AmountInReportingCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountAmountInReportingCurrency
        ,LineItem.value:"ChargeDetail.TaxAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:"ChargeDetail.TaxAmount":ConversionDate::TIMESTAMP_NTZ AS ChargeDetailTaxAmountConversionDate
        ,LineItem.value:"ChargeDetail.TaxAmount":Currency:UniqueName::STRING AS ChargeDetailTaxAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.TaxCode":UniqueName::STRING AS ChargeDetailTaxCodeCode
        ,LineItem.value:CommodityCode:UniqueName::STRING AS CommodityCodeCode
        ,LineItem.value:CommodityExportMapEntry:AccountType:Name::STRING AS CommodityExportMapEntryAccountTypeName
        ,LineItem.value:CommodityExportMapEntry:AccountType:UniqueName::STRING AS CommodityExportMapEntryAccountTypeCode
        ,LineItem.value:CommodityExportMapEntry:CommodityCode:Name::STRING AS CommodityExportMapEntryCommodityCodeName
        ,LineItem.value:CommodityExportMapEntry:CommodityCode:UniqueName::STRING AS CommodityExportMapEntryCommodityCodeCode
        ,LineItem.value:CommodityExportMapEntry:UniqueName::STRING AS CommodityExportMapEntryCode
        ,LineItem.value:DeliverTo::STRING AS DeliverTo
        ,LineItem.value:"Description.CatalogItemRef.CommonSupplierSystemID"::STRING AS DescriptionCatalogItemRefCommonSupplierSystemID
        ,LineItem.value:"Description.CatalogItemRef.SupplierPartAuxiliaryID"::STRING AS DescriptionCatalogItemRefSupplierPartAuxiliaryID
        ,LineItem.value:"Description.CatalogItemRef.SupplierPartNumber"::STRING AS DescriptionCatalogItemRefSupplierPartNumber
        ,LineItem.value:"Description.CommonCommodityCode":Name::STRING AS DescriptionCommonCommodityCodeName
        ,LineItem.value:"Description.CommonCommodityCode":UniqueName::STRING AS DescriptionCommonCommodityCodeCode
        ,LineItem.value:"Description.ContractPrice":Amount::NUMBER(38,10) AS DescriptionContractPriceAmount
        ,LineItem.value:"Description.ContractPrice":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionContractPriceAmountInReportingCurrency
        ,LineItem.value:"Description.ContractPrice":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionContractPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.ContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionContractPriceConversionDate
        ,LineItem.value:"Description.ContractPrice":Currency:UniqueName::STRING AS DescriptionContractPriceCurrencyCode
        ,LineItem.value:"Description.ConversionFactor"::NUMBER(38,10) AS DescriptionConversionFactor
        ,LineItem.value:"Description.CustomPrice":Amount::NUMBER(38,10) AS DescriptionCustomPriceAmount
        ,LineItem.value:"Description.CustomPrice":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionCustomPriceAmountInReportingCurrency
        ,LineItem.value:"Description.CustomPrice":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionCustomPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.CustomPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionCustomPriceConversionDate
        ,LineItem.value:"Description.CustomPrice":Currency:UniqueName::STRING AS DescriptionCustomPriceCurrencyCode
        ,LineItem.value:"Description.Description"::STRING AS DescriptionDescription
        ,LineItem.value:"Description.ExpirationDate"::TIMESTAMP_NTZ AS DescriptionExpirationDate
        ,LineItem.value:"Description.ExtendedDescription"::STRING AS DescriptionExtendedDescription
        ,LineItem.value:"Description.ExtAttributesBitMask"::INTEGER AS DescriptionExtAttributesBitMask
        ,LineItem.value:"Description.IndexContractPrice":Amount::NUMBER(38,10) AS DescriptionIndexContractPriceAmount
        ,LineItem.value:"Description.IndexContractPrice":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceAmountInReportingCurrency
        ,LineItem.value:"Description.IndexContractPrice":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.IndexContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionIndexContractPriceConversionDate
        ,LineItem.value:"Description.IndexContractPrice":Currency:UniqueName::STRING AS DescriptionIndexContractPriceCurrencyCode
        ,LineItem.value:"Description.ItemNumber"::STRING AS DescriptionItemNumber
        ,LineItem.value:"Description.KitUniqueName"::STRING AS DescriptionKitCode
        ,LineItem.value:"Description.Language"::STRING AS DescriptionLanguage
        ,LineItem.value:"Description.LeadTime"::INTEGER AS DescriptionLeadTime
        ,LineItem.value:"Description.NonContractPrice":Amount::NUMBER(38,10) AS DescriptionNonContractPriceAmount
        ,LineItem.value:"Description.NonContractPrice":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionNonContractPriceAmountInReportingCurrency
        ,LineItem.value:"Description.NonContractPrice":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionNonContractPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.NonContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionNonContractPriceConversionDate
        ,LineItem.value:"Description.NonContractPrice":Currency:UniqueName::STRING AS DescriptionNonContractPriceCurrencyCode
        ,LineItem.value:"Description.Price":Amount::NUMBER(38,10) AS DescriptionPriceAmount
        ,LineItem.value:"Description.Price":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionPriceAmountInReportingCurrency
        ,LineItem.value:"Description.Price":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.Price":ConversionDate::TIMESTAMP_NTZ AS DescriptionPriceConversionDate
        ,LineItem.value:"Description.Price":Currency:UniqueName::STRING AS DescriptionPriceCurrencyCode
        ,LineItem.value:"Description.PriceBasesQuantity"::NUMBER(38,10) AS DescriptionPriceBasesQuantity
        ,LineItem.value:"Description.PriceBasesQuantityDesc"::STRING AS DescriptionPriceBasesQuantityDesc
        ,LineItem.value:"Description.PriceBasisQuantityUOM":UniqueName::STRING AS DescriptionPriceBasisQuantityUOMCode
        ,LineItem.value:"Description.QueryId"::STRING AS DescriptionQueryId
        ,LineItem.value:"Description.ShortName:":STRING AS DescriptionShortName
        ,LineItem.value:"Description.SupplierPartAuxiliaryId"::STRING AS DescriptionSupplierPartAuxiliaryId
        ,LineItem.value:"Description.SupplierPartNumber"::STRING AS DescriptionSupplierPartNumber
        ,LineItem.value:"Description.SupplierURL"::STRING AS DescriptionSupplierURL
        ,LineItem.value:"Description.UnitOfMeasure":UniqueName::STRING AS DescriptionUnitOfMeasureCode
        ,LineItem.value:DiscountAmount:Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,LineItem.value:DiscountAmount:AmountInReportingCurrency::NUMBER(38,10) AS DiscountAmountAmountInReportingCurrency
        ,LineItem.value:DiscountAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS DiscountAmountApproxAmountInBaseCurrency
        ,LineItem.value:DiscountAmount:ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,LineItem.value:DiscountAmount:Currency:UniqueName::STRING AS DiscountAmountCurrencyCode
        ,LineItem.value:DueOn::TIMESTAMP_NTZ AS DueOn
        ,LineItem.value:ERPLineItemNumber::STRING AS ERPLineItemNumber
        ,LineItem.value:ERPPONumber::STRING AS ERPPONumber
        ,LineItem.value:ERSAllowed::BOOLEAN AS ERSAllowed
        ,LineItem.value:EndDate::TIMESTAMP_NTZ AS EndDate
        ,LineItem.value:ExpectedValue:Amount::NUMBER(38,10) AS ExpectedValueAmount
        ,LineItem.value:ExpectedValue:AmountInReportingCurrency::NUMBER(38,10) AS ExpectedValueAmountInReportingCurrency
        ,LineItem.value:ExpectedValue:ApproxAmountInBaseCurrency::NUMBER(38,10) AS ExpectedValueApproxAmountInBaseCurrency
        ,LineItem.value:ExpectedValue:ConversionDate::TIMESTAMP_NTZ AS ExpectedValueConversionDate
        ,LineItem.value:ExpectedValue:Currency:UniqueName::STRING AS ExpectedValueCurrencyCode
        ,LineItem.value:ExternalLineNumber::INTEGER AS ExternalLineNumber
        ,LineItem.value:Form::STRING AS Form
        ,LineItem.value:GBFormDocumentId::STRING AS GBFormDocumentId
        ,LineItem.value:IsAdHoc::BOOLEAN AS IsAdHoc
        ,LineItem.value:IsPriceModifiedByUser::BOOLEAN AS IsPriceModifiedByUser
        ,LineItem.value:IsRecurring::BOOLEAN AS IsRecurring
        ,LineItem.value:ItemCategory:UniqueName::STRING AS ItemCategoryCode
        ,LineItem.value:ItemMasterId:BuyerPartNumber::STRING AS ItemMasterIdBuyerPartNumber
        ,LineItem.value:ItemMasterId:Facility::STRING AS ItemMasterIdFacility
        ,LineItem.value:Kit:UniqueName::STRING AS KitCode
        ,LineItem.value:KitInstanceId::STRING AS KitInstanceId
        ,LineItem.value:KitRequiredItem::BOOLEAN AS KitRequiredItem
        ,LineItem.value:LineType:UniqueName::STRING AS LineTypeCode
        ,LineItem.value:MALineItem:UniqueName::STRING AS MALineItem
        ,LineItem.value:MasterAgreement:UniqueName::STRING AS MasterAgreementCode
        ,LineItem.value:NeedBy::TIMESTAMP_NTZ AS NeedBy
        ,LineItem.value:NumberConfirmedAccepted::NUMBER(38,10) AS NumberConfirmedAccepted
        ,LineItem.value:NumberConfirmedAcceptedWithChanges::NUMBER(38,10) AS NumberConfirmedAcceptedWithChanges
        ,LineItem.value:NumberConfirmedBackOrdered::NUMBER(38,10) AS NumberConfirmedBackOrdered
        ,LineItem.value:NumberConfirmedRejected::NUMBER(38,10) AS NumberConfirmedRejected
        ,LineItem.value:NumberConfirmedSubstituted::NUMBER(38,10) AS NumberConfirmedSubstituted
        ,LineItem.value:NumberInCollection::INTEGER AS NumberInCollection
        ,LineItem.value:NumberOnPO::INTEGER AS NumberOnPO
        ,LineItem.value:NumberShipped::NUMBER(38,10) AS NumberShipped
        ,LineItem.value:Order:UniqueName::STRING AS OrderCode
        ,LineItem.value:OrderID::STRING AS OrderId
        ,LineItem.value:OrderInfo:TransactionDate::TIMESTAMP_NTZ AS OrderInfoTransactionDate
        ,LineItem.value:OrderInfo:TransactionNumber::STRING AS OrderInfoTransactionNumber
        ,LineItem.value:OriginalPrice:Amount::NUMBER(38,10) AS OriginalPriceAmount
        ,LineItem.value:OriginalPrice:AmountInReportingCurrency::NUMBER(38,10) AS OriginalPriceAmountInReportingCurrency
        ,LineItem.value:OriginalPrice:ApproxAmountInBaseCurrency::NUMBER(38,10) AS OriginalPriceApproxAmountInBaseCurrency
        ,LineItem.value:OriginalPrice:ConversionDate::TIMESTAMP_NTZ AS OriginalPriceConversionDate
        ,LineItem.value:OriginalPrice:Currency:UniqueName::STRING AS OriginalPriceCurrencyCode
        ,LineItem.value:OriginatingSystem::STRING AS OriginatingSystem
        ,LineItem.value:OriginatingSystemLineNumber::INTEGER AS OriginatingSystemLineNumber
        ,LineItem.value:OverallLimit:Amount::NUMBER(38,10) AS OverallLimitAmount
        ,LineItem.value:OverallLimit:AmountInReportingCurrency::NUMBER(38,10) AS OverallLimitAmountInReportingCurrency
        ,LineItem.value:OverallLimit:ApproxAmountInBaseCurrency::NUMBER(38,10) AS OverallLimitApproxAmountInBaseCurrency
        ,LineItem.value:OverallLimit:ConversionDate::TIMESTAMP_NTZ AS OverallLimitConversionDate
        ,LineItem.value:OverallLimit:Currency:UniqueName::STRING AS OverallLimitCurrencyCode
        ,LineItem.value:PODeliveryDate::TIMESTAMP_NTZ AS PODeliveryDate
        ,LineItem.value:POQuantity::STRING AS POQuantity
        ,LineItem.value:POStatus::STRING AS POStatus
        ,LineItem.value:POUnitOfMeasure:UniqueName::STRING AS POUnitOfMeasureCode
        ,LineItem.value:POUnitPrice::STRING AS POUnitPrice
        ,LineItem.value:ParentKit:UniqueName::STRING AS ParentKitCode
        ,LineItem.value:ParentLineNumber::INTEGER AS ParentLineNumber
        ,LineItem.value:PaymentTerms:UniqueName::STRING AS PaymentTermsCode
        ,LineItem.value:PunchOut:UniqueName::STRING AS PunchOutCode
        ,LineItem.value:PurchaseGroup:UniqueName::STRING AS PurchaseGroupCode
        ,LineItem.value:PurchaseOrg:UniqueName::STRING AS PurchaseOrgCode
        ,LineItem.value:PushStatus::INTEGER AS PushStatus
        ,LineItem.value:Quantity::NUMBER(38,10) AS Quantity
        ,LineItem.value:QuantityInKitItem::NUMBER(38,10) AS QuantityInKitItem
        ,LineItem.value:QuickSourced::BOOLEAN AS QuickSourced
        ,LineItem.value:QuotePricingTermsNumber::INTEGER AS QuotePricingTermsNumber
        ,LineItem.value:SAPPOLineNumber::STRING AS SAPPOLineNumber
        ,LineItem.value:"ServiceDetails.ExpectedAmount":Amount::NUMBER(38,10) AS ServiceDetailsExpectedAmountAmount
        ,LineItem.value:"ServiceDetails.ExpectedAmount":AmountInReportingCurrency::NUMBER(38,10) AS ServiceDetailsExpectedAmountAmountInReportingCurrency
        ,LineItem.value:"ServiceDetails.ExpectedAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS ServiceDetailsExpectedAmountApproxAmountInBaseCurrency
        ,LineItem.value:"ServiceDetails.ExpectedAmount":ConversionDate::TIMESTAMP_NTZ AS ServiceDetailsExpectedAmountConversionDate
        ,LineItem.value:"ServiceDetails.ExpectedAmount":Currency:UniqueName::STRING AS ServiceDetailsExpectedAmountCurrencyCode
        ,LineItem.value:"ServiceDetails.MaxAmount":Amount::NUMBER(38,10) AS ServiceDetailsMaxAmountAmount
        ,LineItem.value:"ServiceDetails.MaxAmount":AmountInReportingCurrency::NUMBER(38,10) AS ServiceDetailsMaxAmountAmountInReportingCurrency
        ,LineItem.value:"ServiceDetails.MaxAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS ServiceDetailsMaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:"ServiceDetails.MaxAmount":ConversionDate::TIMESTAMP_NTZ AS ServiceDetailsMaxAmountConversionDate
        ,LineItem.value:"ServiceDetails.MaxAmount":Currency:UniqueName::STRING AS ServiceDetailsMaxAmountCurrencyCode
        ,LineItem.value:"ServiceDetails.RequiresServiceEntry"::BOOLEAN AS ServiceDetailsRequiresServiceEntry
        ,LineItem.value:"ServiceDetails.ServiceEndDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceEndDate
        ,LineItem.value:"ServiceDetails.ServiceLine"::BOOLEAN AS ServiceDetailsServiceLine
        ,LineItem.value:"ServiceDetailsServiceStartDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceStartDate
        ,LineItem.value:ShipTo:City::STRING AS ShipToCity
        ,LineItem.value:ShipTo:Country:UniqueName::STRING AS ShipToCountryCode
        ,LineItem.value:ShipTo:Fax::STRING AS ShipToFax
        ,LineItem.value:ShipTo:Lines::STRING AS ShipToLines
        ,LineItem.value:ShipTo:Name::STRING AS ShipToName
        ,LineItem.value:ShipTo:Phone::STRING AS ShipToPhone
        ,LineItem.value:ShipTo:PostalCode::STRING AS ShipToPostalCode
        ,LineItem.value:ShipTo:State::STRING AS ShipToState
        ,LineItem.value:ShipTo:UniqueName::STRING AS ShipToCode
        ,LineItem.value:SourcingRequest:UniqueName::STRING AS SourcingRequestCode
        ,LineItem.value:StartDate::TIMESTAMP_NTZ AS StartDate
        ,LineItem.value:Supplier:UniqueName::STRING AS SupplierCode
        ,LineItem.value:SupplierLocation:UniqueName::STRING AS SupplierLocationCode
        ,LineItem.value:TaxAmount:Amount::NUMBER(38,10) AS TaxAmountAmount
        ,LineItem.value:TaxAmount:AmountInReportingCurrency::NUMBER(38,10) AS TaxAmountAmountInReportingCurrency
        ,LineItem.value:TaxAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:TaxAmount:ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,LineItem.value:TaxAmount:Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,LineItem.value:TaxCode::STRING AS TaxCode
        ,LineItem.value:"TaxDetail.AbatementPercent"::NUMBER(38,10) AS TaxDetailAbatementPercent
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":Amount::NUMBER(38,10) AS TaxDetailAlternateTaxAmountAmount
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":AmountInReportingCurrency::NUMBER(38,10) AS TaxDetailAlternateTaxAmountAmountInReportingCurrency
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxDetailAlternateTaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailAlternateTaxAmountConversionDate
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":Currency:UniqueName::STRING AS TaxDetailAlternateTaxAmountCurrencyCode
        ,LineItem.value:"TaxDetail.Category"::STRING AS TaxDetailCategory
        ,LineItem.value:"TaxDetail.Component":UniqueName::STRING AS TaxDetailComponentCode
        ,LineItem.value:"TaxDetail.Description"::STRING AS TaxDetailDescription
        ,LineItem.value:"TaxDetail.ExemptDetail"::STRING AS TaxDetailExemptDetail
        ,LineItem.value:"TaxDetail.FormulaString"::STRING AS TaxDetailFormulaString
        ,LineItem.value:"TaxDetail.IsDeductible"::BOOLEAN AS TaxDetailIsDeductible
        ,LineItem.value:"TaxDetail.IsTriangularTransaction"::BOOLEAN AS TaxDetailIsTriangularTransaction
        ,LineItem.value:"TaxDetail.PaymentDate"::TIMESTAMP_NTZ AS TaxDetailPaymentDate
        ,LineItem.value:"TaxDetail.PerUnit"::NUMBER(38,10) AS TaxDetailPerUnit
        ,LineItem.value:"TaxDetail.Percent"::NUMBER(38,10) AS TaxDetailPercent
        ,LineItem.value:"TaxDetail.Purpose"::STRING AS TaxDetailPurpose
        ,LineItem.value:"TaxDetail.TaxAmount":Amount::NUMBER(38,10) AS TaxDetailTaxAmountAmount
        ,LineItem.value:"TaxDetail.TaxAmount":AmountInReportingCurrency::NUMBER(38,10) AS TaxDetailTaxAmountAmountInReportingCurrency
        ,LineItem.value:"TaxDetail.TaxAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxDetailTaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:"TaxDetail.TaxAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailTaxAmountConversionDate
        ,LineItem.value:"TaxDetail.TaxAmount":Currency:UniqueName::STRING AS TaxDetailTaxAmountCurrencyCode
        ,LineItem.value:"TaxDetail.TaxableAmount":Amount::NUMBER(38,10) AS TaxDetailTaxableAmountAmount
        ,LineItem.value:"TaxDetail.TaxableAmount":AmountInReportingCurrency::NUMBER(38,10) AS TaxDetailTaxableAmountAmountInReportingCurrency
        ,LineItem.value:"TaxDetail.TaxableAmount":ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxDetailTaxableAmountApproxAmountInBaseCurrency
        ,LineItem.value:"TaxDetail.TaxableAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailTaxableAmountConversionDate
        ,LineItem.value:"TaxDetail.TaxableAmount":Currency:UniqueName::STRING AS TaxDetailTaxableAmountCurrencyCode
        ,LineItem.value:"TaxDetail.TaxLocation"::STRING AS TaxDetailTaxLocation
        ,LineItem.value:"TaxDetail.TaxPointDate"::TIMESTAMP_NTZ AS TaxDetailTaxPointDate
        ,LineItem.value:"TaxDetail.TriangularTransactionLawReference"::STRING AS TaxDetailTriangularTransactionLawReference
        ,LineItem.value:UsedInReqPush::BOOLEAN AS UsedInReqPush
        ,LineItem.value:VATAmount:Amount::NUMBER(38,10) AS VATAmountAmount
        ,LineItem.value:VATAmount:AmountInReportingCurrency::NUMBER(38,10) AS VATAmountAmountInReportingCurrency
        ,LineItem.value:VATAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS VATAmountApproxAmountInBaseCurrency
        ,LineItem.value:VATAmount:ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,LineItem.value:VATAmount:Currency:UniqueName::STRING AS VATAmountCurrencyCode
        ,LineItem.value:cus_BIzJust::STRING AS CustomField_BusinessJustification
        FROM {{ source("ARIBA", "REQUISITION") }} LZData
        , LATERAL FLATTEN (input => parse_json(JsonField:LineItems)) LineItem
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,LineItem.value:NumberInCollection::INTEGER
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1        )
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.REQUISITIONIDKEY AS RequisitionIDKey,
        source_data.REQUISITIONVERSIONKEY AS RequisitionVersionKey,
        source_data.NUMBERINCOLLECTION AS RequisitionLineItemKey,
        source_data.ACCOUNTCATEGORYCODE AS AccountCategoryCode,
        source_data.ACCOUNTINGSTYPECODE AS AccountingsTypeCode,
        source_data.ACCOUNTINGTEMPLATECODE AS AccountingTemplateCode,
        source_data.AMOUNTAMOUNTINREPORTINGCURRENCY AS AmountAmountInReportingCurrency,
        source_data.AMOUNTAPPROXAMOUNTINBASECURRENCY AS AmountApproxAmountInBaseCurrency,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.BASEPRICEAMOUNTINREPORTINGCURRENCY AS BasePriceAmountInReportingCurrency,
        source_data.BASEPRICEAPPROXAMOUNTINBASECURRENCY AS BasePriceApproxAmountInBaseCurrency,
        source_data.BASEPRICEAMOUNT AS BasePriceAmount,
        source_data.BASEPRICECONVERSIONDATE AS BasePriceConversionDate,
        source_data.BASEPRICECURRENCYCODE AS BasePriceCurrencyCode,
        source_data.BILLINGADDRESSCODE AS BillingAddressCode,
        source_data.BILLINGADDRESSNAME AS BillingAddressName,
        source_data.BILLINGADDRESSLINES AS BillingAddressLines,
        source_data.BILLINGADDRESSCITY AS BillingAddressCity,
        source_data.BILLINGADDRESSSTATE AS BillingAddressState,
        source_data.BILLINGADDRESSPOSTALCODE AS BillingAddressPostalCode,
        source_data.BILLINGADDRESSCOUNTRYCODE AS BillingAddressCountryCode,
        source_data.BILLINGADDRESSPHONE AS BillingAddressPhone,
        source_data.BILLINGADDRESSFAX AS BillingAddressFax,
        source_data.BOUGHTFROMPREFERREDSUPPLIER AS BoughtFromPreferredSupplier,
        source_data.BUYERITEMMASTERBUYERPARTNUMBER AS BuyerItemMasterBuyerPartNumber,
        source_data.BUYERNAME AS BuyerName,
        source_data.CARRIER AS Carrier,
        source_data.CARRIERMETHOD AS CarrierMethod,
        source_data.CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeAmountAmountInReportingCurrency,
        source_data.CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeAmountApproxAmountInBaseCurrency,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CHARGEDETAILANCHARGEDESCRIPTION AS ChargeDetailANChargeDescription,
        source_data.CHARGEDETAILANCHARGENAME AS ChargeDetailANChargeName,
        source_data.CHARGEDETAILCHARGEAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeDetailChargeAmountAmountInReportingCurrency,
        source_data.CHARGEDETAILCHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeDetailChargeAmountApproxAmountInBaseCurrency,
        source_data.CHARGEDETAILCHARGEAMOUNTAMOUNT AS ChargeDetailChargeAmountAmount,
        source_data.CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE AS ChargeDetailChargeAmountConversionDate,
        source_data.CHARGEDETAILCHARGEAMOUNTCURRENCYCODE AS ChargeDetailChargeAmountCurrencyCode,
        source_data.CHARGEDETAILCHARGETYPECODE AS ChargeDetailChargeTypeCode,
        source_data.CHARGEDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeDetailTaxAmountAmountInReportingCurrency,
        source_data.CHARGEDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeDetailTaxAmountApproxAmountInBaseCurrency,
        source_data.CHARGEDETAILTAXAMOUNTAMOUNT AS ChargeDetailTaxAmountAmount,
        source_data.CHARGEDETAILTAXAMOUNTCONVERSIONDATE AS ChargeDetailTaxAmountConversionDate,
        source_data.CHARGEDETAILTAXAMOUNTCURRENCYCODE AS ChargeDetailTaxAmountCurrencyCode,
        source_data.CHARGEDETAILTAXCODECODE AS ChargeDetailTaxCodeCode,
        source_data.COMMODITYCODECODE AS CommodityCodeCode,
        source_data.COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE AS CommodityExportMapEntryCommodityCodeCode,
        source_data.COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME AS CommodityExportMapEntryCommodityCodeName,
        source_data.COMMODITYEXPORTMAPENTRYACCOUNTTYPECODE AS CommodityExportMapEntryAccountTypeCode,
        source_data.COMMODITYEXPORTMAPENTRYACCOUNTTYPENAME AS CommodityExportMapEntryAccountTypeName,
        source_data.COMMODITYEXPORTMAPENTRYCODE AS CommodityExportMapEntryCode,
        source_data.DELIVERTO AS DeliverTo,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODENAME AS DescriptionCommonCommodityCodeName,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODECODE AS DescriptionCommonCommodityCodeCode,
        source_data.DESCRIPTIONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionContractPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionContractPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONCONTRACTPRICEAMOUNT AS DescriptionContractPriceAmount,
        source_data.DESCRIPTIONCONTRACTPRICECONVERSIONDATE AS DescriptionContractPriceConversionDate,
        source_data.DESCRIPTIONCONTRACTPRICECURRENCYCODE AS DescriptionContractPriceCurrencyCode,
        source_data.DESCRIPTIONCONVERSIONFACTOR AS DescriptionConversionFactor,
        source_data.DESCRIPTIONCUSTOMPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionCustomPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONCUSTOMPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionCustomPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONCUSTOMPRICEAMOUNT AS DescriptionCustomPriceAmount,
        source_data.DESCRIPTIONCUSTOMPRICECONVERSIONDATE AS DescriptionCustomPriceConversionDate,
        source_data.DESCRIPTIONCUSTOMPRICECURRENCYCODE AS DescriptionCustomPriceCurrencyCode,
        source_data.DESCRIPTIONDESCRIPTION AS DescriptionDescription,
        source_data.DESCRIPTIONEXPIRATIONDATE AS DescriptionExpirationDate,
        source_data.DESCRIPTIONEXTENDEDDESCRIPTION AS DescriptionExtendedDescription,
        source_data.DESCRIPTIONEXTATTRIBUTESBITMASK AS DescriptionExtAttributesBitMask,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionIndexContractPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionIndexContractPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEAMOUNT AS DescriptionIndexContractPriceAmount,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE AS DescriptionIndexContractPriceConversionDate,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE AS DescriptionIndexContractPriceCurrencyCode,
        source_data.DESCRIPTIONITEMNUMBER AS DescriptionItemNumber,
        source_data.DESCRIPTIONKITCODE AS DescriptionKitCode,
        source_data.DESCRIPTIONLANGUAGE AS DescriptionLanguage,
        source_data.DESCRIPTIONLEADTIME AS DescriptionLeadTime,
        source_data.DESCRIPTIONNONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionNonContractPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONNONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionNonContractPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONNONCONTRACTPRICEAMOUNT AS DescriptionNonContractPriceAmount,
        source_data.DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE AS DescriptionNonContractPriceConversionDate,
        source_data.DESCRIPTIONNONCONTRACTPRICECURRENCYCODE AS DescriptionNonContractPriceCurrencyCode,
        source_data.DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONPRICEAMOUNT AS DescriptionPriceAmount,
        source_data.DESCRIPTIONPRICECONVERSIONDATE AS DescriptionPriceConversionDate,
        source_data.DESCRIPTIONPRICECURRENCYCODE AS DescriptionPriceCurrencyCode,
        source_data.DESCRIPTIONPRICEBASESQUANTITY AS DescriptionPriceBasesQuantity,
        source_data.DESCRIPTIONPRICEBASESQUANTITYDESC AS DescriptionPriceBasesQuantityDesc,
        source_data.DESCRIPTIONPRICEBASISQUANTITYUOMCODE AS DescriptionPriceBasisQuantityUOMCode,
        source_data.DESCRIPTIONQUERYID AS DescriptionQueryId,
        source_data.DESCRIPTIONSHORTNAME AS DescriptionShortName,
        source_data.DESCRIPTIONSUPPLIERPARTAUXILIARYID AS DescriptionSupplierPartAuxiliaryId,
        source_data.DESCRIPTIONSUPPLIERPARTNUMBER AS DescriptionSupplierPartNumber,
        source_data.DESCRIPTIONSUPPLIERURL AS DescriptionSupplierURL,
        source_data.DESCRIPTIONUNITOFMEASURECODE AS DescriptionUnitOfMeasureCode,
        source_data.DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY AS DiscountAmountAmountInReportingCurrency,
        source_data.DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY AS DiscountAmountApproxAmountInBaseCurrency,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DUEON AS DueOn,
        source_data.ENDDATE AS EndDate,
        source_data.ERPLINEITEMNUMBER AS ERPLineItemNumber,
        source_data.ERPPONUMBER AS ERPPONumber,
        source_data.ERSALLOWED AS ERSAllowed,
        source_data.EXPECTEDVALUEAMOUNTINREPORTINGCURRENCY AS ExpectedValueAmountInReportingCurrency,
        source_data.EXPECTEDVALUEAPPROXAMOUNTINBASECURRENCY AS ExpectedValueApproxAmountInBaseCurrency,
        source_data.EXPECTEDVALUEAMOUNT AS ExpectedValueAmount,
        source_data.EXPECTEDVALUECONVERSIONDATE AS ExpectedValueConversionDate,
        source_data.EXPECTEDVALUECURRENCYCODE AS ExpectedValueCurrencyCode,
        source_data.EXTERNALLINENUMBER AS ExternalLineNumber,
        source_data.FORM AS Form,
        source_data.ISADHOC AS IsAdHoc,
        source_data.ISPRICEMODIFIEDBYUSER AS IsPriceModifiedByUser,
        source_data.ISRECURRING AS IsRecurring,
        source_data.ITEMCATEGORYCODE AS ItemCategoryCode,
        source_data.ITEMMASTERIDBUYERPARTNUMBER AS ItemMasterIdBuyerPartNumber,
        source_data.ITEMMASTERIDFACILITY AS ItemMasterIdFacility,
        source_data.KITCODE AS KitCode,
        source_data.KITINSTANCEID AS KitInstanceId,
        source_data.KITREQUIREDITEM AS KitRequiredItem,
        source_data.LINETYPECODE AS LineTypeCode,
        source_data.MASTERAGREEMENTCODE AS MasterAgreementCode,
        source_data.NEEDBY AS NeedBy,
        source_data.NUMBERCONFIRMEDACCEPTED AS NumberConfirmedAccepted,
        source_data.NUMBERCONFIRMEDACCEPTEDWITHCHANGES AS NumberConfirmedAcceptedWithChanges,
        source_data.NUMBERCONFIRMEDBACKORDERED AS NumberConfirmedBackOrdered,
        source_data.NUMBERCONFIRMEDREJECTED AS NumberConfirmedRejected,
        source_data.NUMBERCONFIRMEDSUBSTITUTED AS NumberConfirmedSubstituted,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.NUMBERONPO AS NumberOnPO,
        source_data.NUMBERSHIPPED AS NumberShipped,
        source_data.ORDERID AS OrderId,
        source_data.ORDERINFOTRANSACTIONDATE AS OrderInfoTransactionDate,
        source_data.ORDERINFOTRANSACTIONNUMBER AS OrderInfoTransactionNumber,
        source_data.ORIGINALPRICEAMOUNTINREPORTINGCURRENCY AS OriginalPriceAmountInReportingCurrency,
        source_data.ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY AS OriginalPriceApproxAmountInBaseCurrency,
        source_data.ORIGINALPRICEAMOUNT AS OriginalPriceAmount,
        source_data.ORIGINALPRICECONVERSIONDATE AS OriginalPriceConversionDate,
        source_data.ORIGINALPRICECURRENCYCODE AS OriginalPriceCurrencyCode,
        source_data.ORIGINATINGSYSTEM AS OriginatingSystem,
        source_data.ORIGINATINGSYSTEMLINENUMBER AS OriginatingSystemLineNumber,
        source_data.OVERALLLIMITAMOUNTINREPORTINGCURRENCY AS OverallLimitAmountInReportingCurrency,
        source_data.OVERALLLIMITAPPROXAMOUNTINBASECURRENCY AS OverallLimitApproxAmountInBaseCurrency,
        source_data.OVERALLLIMITAMOUNT AS OverallLimitAmount,
        source_data.OVERALLLIMITCONVERSIONDATE AS OverallLimitConversionDate,
        source_data.OVERALLLIMITCURRENCYCODE AS OverallLimitCurrencyCode,
        source_data.PARENTKITCODE AS ParentKitCode,
        source_data.PARENTLINENUMBER AS ParentLineNumber,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.PODELIVERYDATE AS PODeliveryDate,
        source_data.POQUANTITY AS POQuantity,
        source_data.POSTATUS AS POStatus,
        source_data.POUNITOFMEASURECODE AS POUnitOfMeasureCode,
        source_data.POUNITPRICE AS POUnitPrice,
        source_data.PURCHASEGROUPCODE AS PurchaseGroupCode,
        source_data.PURCHASEORGCODE AS PurchaseOrgCode,
        source_data.PUSHSTATUS AS PushStatus,
        source_data.QUANTITY AS Quantity,
        source_data.QUANTITYINKITITEM AS QuantityInKitItem,
        source_data.QUICKSOURCED AS QuickSourced,
        source_data.QUOTEPRICINGTERMSNUMBER AS QuotePricingTermsNumber,
        source_data.SAPPOLINENUMBER AS SAPPOLineNumber,
        source_data.SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY AS ServiceDetailsMaxAmountAmountInReportingCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS ServiceDetailsMaxAmountApproxAmountInBaseCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTAMOUNT AS ServiceDetailsMaxAmountAmount,
        source_data.SERVICEDETAILSMAXAMOUNTCONVERSIONDATE AS ServiceDetailsMaxAmountConversionDate,
        source_data.SERVICEDETAILSMAXAMOUNTCURRENCYCODE AS ServiceDetailsMaxAmountCurrencyCode,
        source_data.SERVICEDETAILSREQUIRESSERVICEENTRY AS ServiceDetailsRequiresServiceEntry,
        source_data.SERVICEDETAILSSERVICEENDDATE AS ServiceDetailsServiceEndDate,
        source_data.SERVICEDETAILSSERVICELINE AS ServiceDetailsServiceLine,
        source_data.SERVICEDETAILSSERVICESTARTDATE AS ServiceDetailsServiceStartDate,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY AS ServiceDetailsExpectedAmountAmountInReportingCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY AS ServiceDetailsExpectedAmountApproxAmountInBaseCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAMOUNT AS ServiceDetailsExpectedAmountAmount,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE AS ServiceDetailsExpectedAmountConversionDate,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE AS ServiceDetailsExpectedAmountCurrencyCode,
        source_data.SHIPTOCODE AS ShipToCode,
        source_data.SHIPTONAME AS ShipToName,
        source_data.SHIPTOLINES AS ShipToLines,
        source_data.SHIPTOCITY AS ShipToCity,
        source_data.SHIPTOSTATE AS ShipToState,
        source_data.SHIPTOPOSTALCODE AS ShipToPostalCode,
        source_data.SHIPTOCOUNTRYCODE AS ShipToCountryCode,
        source_data.SHIPTOPHONE AS ShipToPhone,
        source_data.SHIPTOFAX AS ShipToFax,
        source_data.SOURCINGREQUESTCODE AS SourcingRequestCode,
        source_data.STARTDATE AS StartDate,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.TAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxAmountAmountInReportingCurrency,
        source_data.TAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxAmountApproxAmountInBaseCurrency,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXCODE AS TaxCode,
        source_data.TAXDETAILABATEMENTPERCENT AS TaxDetailAbatementPercent,
        source_data.TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailAlternateTaxAmountAmountInReportingCurrency,
        source_data.TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailAlternateTaxAmountApproxAmountInBaseCurrency,
        source_data.TAXDETAILALTERNATETAXAMOUNTAMOUNT AS TaxDetailAlternateTaxAmountAmount,
        source_data.TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE AS TaxDetailAlternateTaxAmountConversionDate,
        source_data.TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE AS TaxDetailAlternateTaxAmountCurrencyCode,
        source_data.TAXDETAILCATEGORY AS TaxDetailCategory,
        source_data.TAXDETAILCOMPONENTCODE AS TaxDetailComponentCode,
        source_data.TAXDETAILDESCRIPTION AS TaxDetailDescription,
        source_data.TAXDETAILEXEMPTDETAIL AS TaxDetailExemptDetail,
        source_data.TAXDETAILFORMULASTRING AS TaxDetailFormulaString,
        source_data.TAXDETAILISDEDUCTIBLE AS TaxDetailIsDeductible,
        source_data.TAXDETAILISTRIANGULARTRANSACTION AS TaxDetailIsTriangularTransaction,
        source_data.TAXDETAILPAYMENTDATE AS TaxDetailPaymentDate,
        source_data.TAXDETAILPERUNIT AS TaxDetailPerUnit,
        source_data.TAXDETAILPERCENT AS TaxDetailPercent,
        source_data.TAXDETAILPURPOSE AS TaxDetailPurpose,
        source_data.TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailTaxAmountAmountInReportingCurrency,
        source_data.TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailTaxAmountApproxAmountInBaseCurrency,
        source_data.TAXDETAILTAXAMOUNTAMOUNT AS TaxDetailTaxAmountAmount,
        source_data.TAXDETAILTAXAMOUNTCONVERSIONDATE AS TaxDetailTaxAmountConversionDate,
        source_data.TAXDETAILTAXAMOUNTCURRENCYCODE AS TaxDetailTaxAmountCurrencyCode,
        source_data.TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailTaxableAmountAmountInReportingCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailTaxableAmountApproxAmountInBaseCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTAMOUNT AS TaxDetailTaxableAmountAmount,
        source_data.TAXDETAILTAXABLEAMOUNTCONVERSIONDATE AS TaxDetailTaxableAmountConversionDate,
        source_data.TAXDETAILTAXABLEAMOUNTCURRENCYCODE AS TaxDetailTaxableAmountCurrencyCode,
        source_data.TAXDETAILTAXLOCATION AS TaxDetailTaxLocation,
        source_data.TAXDETAILTAXPOINTDATE AS TaxDetailTaxPointDate,
        source_data.TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE AS TaxDetailTriangularTransactionLawReference,
        source_data.USEDINREQPUSH AS UsedInReqPush,
        source_data.VATAMOUNTAMOUNTINREPORTINGCURRENCY AS VATAmountAmountInReportingCurrency,
        source_data.VATAMOUNTAPPROXAMOUNTINBASECURRENCY AS VATAmountApproxAmountInBaseCurrency,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.CUSTOMFIELD_BUSINESSJUSTIFICATION AS CustomField_BusinessJustification,
        'No' AS IsHistorical,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(REQUISITIONIDKEY as VARCHAR(16777216)) as REQUISITIONIDKEY,
        cast(REQUISITIONVERSIONKEY as NUMBER(38,0)) as REQUISITIONVERSIONKEY,
        cast(REQUISITIONLINEITEMKEY as NUMBER(38,0)) as REQUISITIONLINEITEMKEY,
        cast(ACCOUNTCATEGORYCODE as VARCHAR(16777216)) as ACCOUNTCATEGORYCODE,
        cast(ACCOUNTINGSTYPECODE as VARCHAR(16777216)) as ACCOUNTINGSTYPECODE,
        cast(ACCOUNTINGTEMPLATECODE as VARCHAR(16777216)) as ACCOUNTINGTEMPLATECODE,
        cast(AMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as AMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as AMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTAMOUNT as NUMBER(38,0)) as AMOUNTAMOUNT,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
        cast(BASEPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as BASEPRICEAMOUNTINREPORTINGCURRENCY,
        cast(BASEPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as BASEPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(BASEPRICEAMOUNT as NUMBER(38,0)) as BASEPRICEAMOUNT,
        cast(BASEPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as BASEPRICECONVERSIONDATE,
        cast(BASEPRICECURRENCYCODE as VARCHAR(16777216)) as BASEPRICECURRENCYCODE,
        cast(BILLINGADDRESSCODE as VARCHAR(16777216)) as BILLINGADDRESSCODE,
        cast(BILLINGADDRESSNAME as VARCHAR(16777216)) as BILLINGADDRESSNAME,
        cast(BILLINGADDRESSLINES as VARCHAR(16777216)) as BILLINGADDRESSLINES,
        cast(BILLINGADDRESSCITY as VARCHAR(16777216)) as BILLINGADDRESSCITY,
        cast(BILLINGADDRESSSTATE as VARCHAR(16777216)) as BILLINGADDRESSSTATE,
        cast(BILLINGADDRESSPOSTALCODE as VARCHAR(16777216)) as BILLINGADDRESSPOSTALCODE,
        cast(BILLINGADDRESSCOUNTRYCODE as VARCHAR(16777216)) as BILLINGADDRESSCOUNTRYCODE,
        cast(BILLINGADDRESSPHONE as VARCHAR(16777216)) as BILLINGADDRESSPHONE,
        cast(BILLINGADDRESSFAX as VARCHAR(16777216)) as BILLINGADDRESSFAX,
        cast(BOUGHTFROMPREFERREDSUPPLIER as BOOLEAN) as BOUGHTFROMPREFERREDSUPPLIER,
        cast(BUYERITEMMASTERBUYERPARTNUMBER as VARCHAR(16777216)) as BUYERITEMMASTERBUYERPARTNUMBER,
        cast(BUYERNAME as VARCHAR(16777216)) as BUYERNAME,
        cast(CARRIER as VARCHAR(16777216)) as CARRIER,
        cast(CARRIERMETHOD as VARCHAR(16777216)) as CARRIERMETHOD,
        cast(CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,0)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILANCHARGEDESCRIPTION as VARCHAR(16777216)) as CHARGEDETAILANCHARGEDESCRIPTION,
        cast(CHARGEDETAILANCHARGENAME as VARCHAR(16777216)) as CHARGEDETAILANCHARGENAME,
        cast(CHARGEDETAILCHARGEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as CHARGEDETAILCHARGEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(CHARGEDETAILCHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as CHARGEDETAILCHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEDETAILCHARGEAMOUNTAMOUNT as NUMBER(38,0)) as CHARGEDETAILCHARGEAMOUNTAMOUNT,
        cast(CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILCHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEDETAILCHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILCHARGETYPECODE as VARCHAR(16777216)) as CHARGEDETAILCHARGETYPECODE,
        cast(CHARGEDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as CHARGEDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(CHARGEDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as CHARGEDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEDETAILTAXAMOUNTAMOUNT as NUMBER(38,0)) as CHARGEDETAILTAXAMOUNTAMOUNT,
        cast(CHARGEDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILTAXAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEDETAILTAXAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILTAXCODECODE as VARCHAR(16777216)) as CHARGEDETAILTAXCODECODE,
        cast(COMMODITYCODECODE as VARCHAR(16777216)) as COMMODITYCODECODE,
        cast(COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE as VARCHAR(16777216)) as COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE,
        cast(COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME as VARCHAR(16777216)) as COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME,
        cast(COMMODITYEXPORTMAPENTRYACCOUNTTYPECODE as VARCHAR(16777216)) as COMMODITYEXPORTMAPENTRYACCOUNTTYPECODE,
        cast(COMMODITYEXPORTMAPENTRYACCOUNTTYPENAME as VARCHAR(16777216)) as COMMODITYEXPORTMAPENTRYACCOUNTTYPENAME,
        cast(COMMODITYEXPORTMAPENTRYCODE as VARCHAR(16777216)) as COMMODITYEXPORTMAPENTRYCODE,
        cast(DELIVERTO as VARCHAR(16777216)) as DELIVERTO,
        cast(DESCRIPTIONCOMMONCOMMODITYCODENAME as VARCHAR(16777216)) as DESCRIPTIONCOMMONCOMMODITYCODENAME,
        cast(DESCRIPTIONCOMMONCOMMODITYCODECODE as VARCHAR(16777216)) as DESCRIPTIONCOMMONCOMMODITYCODECODE,
        cast(DESCRIPTIONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DESCRIPTIONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DESCRIPTIONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONCONTRACTPRICEAMOUNT as NUMBER(38,0)) as DESCRIPTIONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONCONVERSIONFACTOR as NUMBER(38,0)) as DESCRIPTIONCONVERSIONFACTOR,
        cast(DESCRIPTIONCUSTOMPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DESCRIPTIONCUSTOMPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONCUSTOMPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DESCRIPTIONCUSTOMPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONCUSTOMPRICEAMOUNT as NUMBER(38,0)) as DESCRIPTIONCUSTOMPRICEAMOUNT,
        cast(DESCRIPTIONCUSTOMPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCUSTOMPRICECONVERSIONDATE,
        cast(DESCRIPTIONCUSTOMPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONCUSTOMPRICECURRENCYCODE,
        cast(DESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONDESCRIPTION,
        cast(DESCRIPTIONEXPIRATIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONEXPIRATIONDATE,
        cast(DESCRIPTIONEXTENDEDDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONEXTENDEDDESCRIPTION,
        cast(DESCRIPTIONEXTATTRIBUTESBITMASK as NUMBER(38,0)) as DESCRIPTIONEXTATTRIBUTESBITMASK,
        cast(DESCRIPTIONINDEXCONTRACTPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DESCRIPTIONINDEXCONTRACTPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONINDEXCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DESCRIPTIONINDEXCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONINDEXCONTRACTPRICEAMOUNT as NUMBER(38,0)) as DESCRIPTIONINDEXCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONITEMNUMBER as VARCHAR(16777216)) as DESCRIPTIONITEMNUMBER,
        cast(DESCRIPTIONKITCODE as VARCHAR(16777216)) as DESCRIPTIONKITCODE,
        cast(DESCRIPTIONLANGUAGE as VARCHAR(16777216)) as DESCRIPTIONLANGUAGE,
        cast(DESCRIPTIONLEADTIME as NUMBER(38,0)) as DESCRIPTIONLEADTIME,
        cast(DESCRIPTIONNONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DESCRIPTIONNONCONTRACTPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONNONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DESCRIPTIONNONCONTRACTPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONNONCONTRACTPRICEAMOUNT as NUMBER(38,0)) as DESCRIPTIONNONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONNONCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONNONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONPRICEAMOUNT as NUMBER(38,0)) as DESCRIPTIONPRICEAMOUNT,
        cast(DESCRIPTIONPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONPRICECONVERSIONDATE,
        cast(DESCRIPTIONPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONPRICECURRENCYCODE,
        cast(DESCRIPTIONPRICEBASESQUANTITY as NUMBER(38,0)) as DESCRIPTIONPRICEBASESQUANTITY,
        cast(DESCRIPTIONPRICEBASESQUANTITYDESC as VARCHAR(16777216)) as DESCRIPTIONPRICEBASESQUANTITYDESC,
        cast(DESCRIPTIONPRICEBASISQUANTITYUOMCODE as VARCHAR(16777216)) as DESCRIPTIONPRICEBASISQUANTITYUOMCODE,
        cast(DESCRIPTIONQUERYID as VARCHAR(16777216)) as DESCRIPTIONQUERYID,
        cast(DESCRIPTIONSHORTNAME as VARCHAR(16777216)) as DESCRIPTIONSHORTNAME,
        cast(DESCRIPTIONSUPPLIERPARTAUXILIARYID as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTAUXILIARYID,
        cast(DESCRIPTIONSUPPLIERPARTNUMBER as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTNUMBER,
        cast(DESCRIPTIONSUPPLIERURL as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERURL,
        cast(DESCRIPTIONUNITOFMEASURECODE as VARCHAR(16777216)) as DESCRIPTIONUNITOFMEASURECODE,
        cast(DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,0)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777216)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DUEON as TIMESTAMP_NTZ(9)) as DUEON,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(ERPLINEITEMNUMBER as VARCHAR(16777216)) as ERPLINEITEMNUMBER,
        cast(ERPPONUMBER as VARCHAR(16777216)) as ERPPONUMBER,
        cast(ERSALLOWED as BOOLEAN) as ERSALLOWED,
        cast(EXPECTEDVALUEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as EXPECTEDVALUEAMOUNTINREPORTINGCURRENCY,
        cast(EXPECTEDVALUEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as EXPECTEDVALUEAPPROXAMOUNTINBASECURRENCY,
        cast(EXPECTEDVALUEAMOUNT as NUMBER(38,0)) as EXPECTEDVALUEAMOUNT,
        cast(EXPECTEDVALUECONVERSIONDATE as TIMESTAMP_NTZ(9)) as EXPECTEDVALUECONVERSIONDATE,
        cast(EXPECTEDVALUECURRENCYCODE as VARCHAR(16777216)) as EXPECTEDVALUECURRENCYCODE,
        cast(EXTERNALLINENUMBER as NUMBER(38,0)) as EXTERNALLINENUMBER,
        cast(FORM as VARCHAR(16777216)) as FORM,
        cast(ISADHOC as BOOLEAN) as ISADHOC,
        cast(ISPRICEMODIFIEDBYUSER as BOOLEAN) as ISPRICEMODIFIEDBYUSER,
        cast(ISRECURRING as BOOLEAN) as ISRECURRING,
        cast(ITEMCATEGORYCODE as VARCHAR(16777216)) as ITEMCATEGORYCODE,
        cast(ITEMMASTERIDBUYERPARTNUMBER as VARCHAR(16777216)) as ITEMMASTERIDBUYERPARTNUMBER,
        cast(ITEMMASTERIDFACILITY as VARCHAR(16777216)) as ITEMMASTERIDFACILITY,
        cast(KITCODE as VARCHAR(16777216)) as KITCODE,
        cast(KITINSTANCEID as VARCHAR(16777216)) as KITINSTANCEID,
        cast(KITREQUIREDITEM as BOOLEAN) as KITREQUIREDITEM,
        cast(LINETYPECODE as VARCHAR(16777216)) as LINETYPECODE,
        cast(MASTERAGREEMENTCODE as VARCHAR(16777216)) as MASTERAGREEMENTCODE,
        cast(NEEDBY as TIMESTAMP_NTZ(9)) as NEEDBY,
        cast(NUMBERCONFIRMEDACCEPTED as NUMBER(38,0)) as NUMBERCONFIRMEDACCEPTED,
        cast(NUMBERCONFIRMEDACCEPTEDWITHCHANGES as NUMBER(38,0)) as NUMBERCONFIRMEDACCEPTEDWITHCHANGES,
        cast(NUMBERCONFIRMEDBACKORDERED as NUMBER(38,0)) as NUMBERCONFIRMEDBACKORDERED,
        cast(NUMBERCONFIRMEDREJECTED as NUMBER(38,0)) as NUMBERCONFIRMEDREJECTED,
        cast(NUMBERCONFIRMEDSUBSTITUTED as NUMBER(38,0)) as NUMBERCONFIRMEDSUBSTITUTED,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(NUMBERONPO as NUMBER(38,0)) as NUMBERONPO,
        cast(NUMBERSHIPPED as NUMBER(38,0)) as NUMBERSHIPPED,
        cast(ORDERID as VARCHAR(16777216)) as ORDERID,
        cast(ORDERINFOTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as ORDERINFOTRANSACTIONDATE,
        cast(ORDERINFOTRANSACTIONNUMBER as VARCHAR(16777216)) as ORDERINFOTRANSACTIONNUMBER,
        cast(ORIGINALPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as ORIGINALPRICEAMOUNTINREPORTINGCURRENCY,
        cast(ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(ORIGINALPRICEAMOUNT as NUMBER(38,0)) as ORIGINALPRICEAMOUNT,
        cast(ORIGINALPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as ORIGINALPRICECONVERSIONDATE,
        cast(ORIGINALPRICECURRENCYCODE as VARCHAR(16777216)) as ORIGINALPRICECURRENCYCODE,
        cast(ORIGINATINGSYSTEM as VARCHAR(16777216)) as ORIGINATINGSYSTEM,
        cast(ORIGINATINGSYSTEMLINENUMBER as NUMBER(38,0)) as ORIGINATINGSYSTEMLINENUMBER,
        cast(OVERALLLIMITAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as OVERALLLIMITAMOUNTINREPORTINGCURRENCY,
        cast(OVERALLLIMITAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as OVERALLLIMITAPPROXAMOUNTINBASECURRENCY,
        cast(OVERALLLIMITAMOUNT as NUMBER(38,0)) as OVERALLLIMITAMOUNT,
        cast(OVERALLLIMITCONVERSIONDATE as TIMESTAMP_NTZ(9)) as OVERALLLIMITCONVERSIONDATE,
        cast(OVERALLLIMITCURRENCYCODE as VARCHAR(16777216)) as OVERALLLIMITCURRENCYCODE,
        cast(PARENTKITCODE as VARCHAR(16777216)) as PARENTKITCODE,
        cast(PARENTLINENUMBER as NUMBER(38,0)) as PARENTLINENUMBER,
        cast(PAYMENTTERMSCODE as VARCHAR(16777216)) as PAYMENTTERMSCODE,
        cast(PODELIVERYDATE as TIMESTAMP_NTZ(9)) as PODELIVERYDATE,
        cast(POQUANTITY as VARCHAR(16777216)) as POQUANTITY,
        cast(POSTATUS as VARCHAR(16777216)) as POSTATUS,
        cast(POUNITOFMEASURECODE as VARCHAR(16777216)) as POUNITOFMEASURECODE,
        cast(POUNITPRICE as VARCHAR(16777216)) as POUNITPRICE,
        cast(PURCHASEGROUPCODE as VARCHAR(16777216)) as PURCHASEGROUPCODE,
        cast(PURCHASEORGCODE as VARCHAR(16777216)) as PURCHASEORGCODE,
        cast(PUSHSTATUS as NUMBER(38,0)) as PUSHSTATUS,
        cast(QUANTITY as NUMBER(38,0)) as QUANTITY,
        cast(QUANTITYINKITITEM as NUMBER(38,0)) as QUANTITYINKITITEM,
        cast(QUICKSOURCED as BOOLEAN) as QUICKSOURCED,
        cast(QUOTEPRICINGTERMSNUMBER as NUMBER(38,0)) as QUOTEPRICINGTERMSNUMBER,
        cast(SAPPOLINENUMBER as VARCHAR(16777216)) as SAPPOLINENUMBER,
        cast(SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTAMOUNT as NUMBER(38,0)) as SERVICEDETAILSMAXAMOUNTAMOUNT,
        cast(SERVICEDETAILSMAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSMAXAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSMAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as SERVICEDETAILSMAXAMOUNTCURRENCYCODE,
        cast(SERVICEDETAILSREQUIRESSERVICEENTRY as BOOLEAN) as SERVICEDETAILSREQUIRESSERVICEENTRY,
        cast(SERVICEDETAILSSERVICEENDDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICEENDDATE,
        cast(SERVICEDETAILSSERVICELINE as BOOLEAN) as SERVICEDETAILSSERVICELINE,
        cast(SERVICEDETAILSSERVICESTARTDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICESTARTDATE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAMOUNT as NUMBER(38,0)) as SERVICEDETAILSEXPECTEDAMOUNTAMOUNT,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE as VARCHAR(16777216)) as SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE,
        cast(SHIPTOCODE as VARCHAR(16777216)) as SHIPTOCODE,
        cast(SHIPTONAME as VARCHAR(16777216)) as SHIPTONAME,
        cast(SHIPTOLINES as VARCHAR(16777216)) as SHIPTOLINES,
        cast(SHIPTOCITY as VARCHAR(16777216)) as SHIPTOCITY,
        cast(SHIPTOSTATE as VARCHAR(16777216)) as SHIPTOSTATE,
        cast(SHIPTOPOSTALCODE as VARCHAR(16777216)) as SHIPTOPOSTALCODE,
        cast(SHIPTOCOUNTRYCODE as VARCHAR(16777216)) as SHIPTOCOUNTRYCODE,
        cast(SHIPTOPHONE as VARCHAR(16777216)) as SHIPTOPHONE,
        cast(SHIPTOFAX as VARCHAR(16777216)) as SHIPTOFAX,
        cast(SOURCINGREQUESTCODE as VARCHAR(16777216)) as SOURCINGREQUESTCODE,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777216)) as SUPPLIERLOCATIONCODE,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(TAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as TAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as TAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,0)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXCODE as VARCHAR(16777216)) as TAXCODE,
        cast(TAXDETAILABATEMENTPERCENT as NUMBER(38,0)) as TAXDETAILABATEMENTPERCENT,
        cast(TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTAMOUNT as NUMBER(38,0)) as TAXDETAILALTERNATETAXAMOUNTAMOUNT,
        cast(TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILCATEGORY as VARCHAR(16777216)) as TAXDETAILCATEGORY,
        cast(TAXDETAILCOMPONENTCODE as VARCHAR(16777216)) as TAXDETAILCOMPONENTCODE,
        cast(TAXDETAILDESCRIPTION as VARCHAR(16777216)) as TAXDETAILDESCRIPTION,
        cast(TAXDETAILEXEMPTDETAIL as VARCHAR(16777216)) as TAXDETAILEXEMPTDETAIL,
        cast(TAXDETAILFORMULASTRING as VARCHAR(16777216)) as TAXDETAILFORMULASTRING,
        cast(TAXDETAILISDEDUCTIBLE as BOOLEAN) as TAXDETAILISDEDUCTIBLE,
        cast(TAXDETAILISTRIANGULARTRANSACTION as BOOLEAN) as TAXDETAILISTRIANGULARTRANSACTION,
        cast(TAXDETAILPAYMENTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILPAYMENTDATE,
        cast(TAXDETAILPERUNIT as NUMBER(38,0)) as TAXDETAILPERUNIT,
        cast(TAXDETAILPERCENT as NUMBER(38,0)) as TAXDETAILPERCENT,
        cast(TAXDETAILPURPOSE as VARCHAR(16777216)) as TAXDETAILPURPOSE,
        cast(TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILTAXAMOUNTAMOUNT as NUMBER(38,0)) as TAXDETAILTAXAMOUNTAMOUNT,
        cast(TAXDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILTAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTAMOUNT as NUMBER(38,0)) as TAXDETAILTAXABLEAMOUNTAMOUNT,
        cast(TAXDETAILTAXABLEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXABLEAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXABLEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILTAXABLEAMOUNTCURRENCYCODE,
        cast(TAXDETAILTAXLOCATION as VARCHAR(16777216)) as TAXDETAILTAXLOCATION,
        cast(TAXDETAILTAXPOINTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXPOINTDATE,
        cast(TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE as VARCHAR(16777216)) as TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE,
        cast(USEDINREQPUSH as BOOLEAN) as USEDINREQPUSH,
        cast(VATAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,0)) as VATAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(VATAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,0)) as VATAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(VATAMOUNTAMOUNT as NUMBER(38,0)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(CUSTOMFIELD_BUSINESSJUSTIFICATION as VARCHAR(16777216)) as CUSTOMFIELD_BUSINESSJUSTIFICATION,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data