
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='InvoiceLineItem',
    unique_key = ['RealmName',
    'InvoiceIdKey',
    'InvoiceVersionKey',
    'InvoiceLineItemKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LASTUPDATED
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceIDKey
        ,JsonField:VersionNumber::NUMBER(38,10) AS InvoiceVersionKey
        ,LineItem.value:AccountCategoryUniqueName::STRING AS AccountCategoryCode
        ,LineItem.value:AccountingsTypeUniqueName::STRING AS AccountingsTypeCode
        ,LineItem.value:AccountingTemplateUniqueName::STRING AS AccountingTemplateCode
        ,LineItem.value:Amount:ReportingCurrency::NUMBER(38,10) AS AmountReportingCurrency
        ,LineItem.value:Amount:BaseCurrency::NUMBER(38,10) AS AmountBaseCurrency
        ,LineItem.value:Amount:Amount::NUMBER(38,10) AS AmountAmount
        ,LineItem.value:Amount:ConversionDate::TIMESTAMP_NTZ AS AmountConversionDate
        ,LineItem.value:Amount:Currency:UniqueName::STRING AS AmountCurrencyCode
        ,LineItem.value:BasePrice:ReportingCurrency::NUMBER(38,10) AS BasePriceReportingCurrency
        ,LineItem.value:BasePrice:BaseCurrency::NUMBER(38,10) AS BasePriceBaseCurrency
        ,LineItem.value:BasePrice:Amount::NUMBER(38,10) AS BasePriceAmount
        ,LineItem.value:BasePrice:ConversionDate::TIMESTAMP_NTZ AS BasePriceConversionDate
        ,LineItem.value:BasePrice:Currency::STRING AS BasePriceCurrencyCode
        ,LineItem.value:BillingAddress:City::STRING AS BillingAddressCity
        ,LineItem.value:BillingAddress:CountryUniqueName::STRING AS BillingAddressCountryCode
        ,LineItem.value:BillingAddress:Fax::STRING AS BillingAddressFax
        ,LineItem.value:BillingAddress:Lines::STRING AS BillingAddressLines
        ,LineItem.value:BillingAddress:Name::STRING AS BillingAddressName
        ,LineItem.value:BillingAddress:Phone::STRING AS BillingAddressPhone
        ,LineItem.value:BillingAddress:PostalCode::STRING AS BillingAddressPostalCode
        ,LineItem.value:BillingAddress:State::STRING AS BillingAddressState
        ,LineItem.value:BillingAddress:UniqueName::STRING AS BillingAddressCode
        ,LineItem.value:BoughtFromPreferredSupplier::BOOLEAN AS BoughtFromPreferredSupplier
        ,LineItem.value:BuyerItemMasterBuyerPartNumber::STRING AS BuyerItemMasterBuyerPartNumber
        ,LineItem.value:BuyerName::STRING AS BuyerName
        ,LineItem.value:Carrier::STRING AS Carrier
        ,LineItem.value:CarrierMethod::STRING AS CarrierMethod
        ,LineItem.value:ChargeAmountReportingCurrency::NUMBER(38,10) AS ChargeAmountReportingCurrency
        ,LineItem.value:ChargeAmountBaseCurrency::NUMBER(38,10) AS ChargeAmountBaseCurrency
        ,LineItem.value:ChargeAmountAmount::NUMBER(38,10) AS ChargeAmountAmount
        ,LineItem.value:ChargeAmountConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,LineItem.value:ChargeAmountCurrencyUniqueName::STRING AS ChargeAmountCurrencyCode
        ,LineItem.value:ChargeDetailANChargeDescription::STRING AS ChargeDetailANChargeDescription
        ,LineItem.value:ChargeDetailANChargeName::STRING AS ChargeDetailANChargeName
        ,LineItem.value:ChargeDetailChargeAmountReportingCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountReportingCurrency
        ,LineItem.value:ChargeDetailChargeAmountBaseCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountBaseCurrency
        ,LineItem.value:ChargeDetailChargeAmountAmount::NUMBER(38,10) AS ChargeDetailChargeAmountAmount
        ,LineItem.value:ChargeDetailChargeAmountConversionDate::TIMESTAMP_NTZ AS ChargeDetailChargeAmountConversionDate
        ,LineItem.value:ChargeDetailChargeAmountCurrencyUniqueName::STRING AS ChargeDetailChargeAmountCurrencyCode
        ,LineItem.value:ChargeDetailChargeTypeUniqueName::STRING AS ChargeDetailChargeTypeCode
        ,LineItem.value:ChargeDetailTaxAmountReportingCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountReportingCurrency
        ,LineItem.value:ChargeDetailTaxAmountBaseCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountBaseCurrency
        ,LineItem.value:ChargeDetailTaxAmountAmount::NUMBER(38,10) AS ChargeDetailTaxAmountAmount
        ,LineItem.value:ChargeDetailTaxAmountConversionDate::TIMESTAMP_NTZ AS ChargeDetailTaxAmountConversionDate
        ,LineItem.value:ChargeDetailTaxAmountCurrencyUniqueName::STRING AS ChargeDetailTaxAmountCurrencyCode
        ,LineItem.value:ChargeDetailTaxCodeUniqueName::STRING AS ChargeDetailTaxCodeCode
        ,LineItem.value:CommodityCode:UniqueName::STRING AS CommodityCodeCode
        ,LineItem.value:CommodityExportMapEntryCommodityCodeUniqueName::STRING AS CommodityExportMapEntryCommodityCodeCode
        ,LineItem.value:CommodityExportMapEntryCommodityCodeName::STRING AS CommodityExportMapEntryCommodityCodeName
        ,LineItem.value:CommodityExportAccountTypeUniqueName::STRING AS CommodityExportAccountTypeCode
        ,LineItem.value:CommodityExportAccountTypeName::STRING AS CommodityExportAccountTypeName
        ,LineItem.value:CommodityExportUniqueName::STRING AS CommodityExportCode
        ,LineItem.value:DeliverTo::STRING AS DeliverTo
        ,LineItem.value:Description.CommonCommodityCode:Name::STRING AS DescriptionCommonCommodityCodeName
        ,LineItem.value:Description.CommonCommodityCode:UniqueName::STRING AS DescriptionCommonCommodityCodeCode
        ,LineItem.value:"Description.ContractPrice":ReportingCurrency::NUMBER(38,10) AS DescriptionContractPriceReportingCurrency
        ,LineItem.value:"Description.ContractPrice":BaseCurrency::NUMBER(38,10) AS DescriptionContractPriceBaseCurrency
        ,LineItem.value:"Description.ContractPrice":Amount::NUMBER(38,10) AS DescriptionContractPriceAmount
        ,LineItem.value:"Description.ContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionContractPriceConversionDate
        ,LineItem.value:"Description.ContractPrice":Currency:UniqueName::STRING AS DescriptionContractPriceCurrencyCode
        ,LineItem.value:"Description.ConversionFactor"::NUMBER(38,10) AS DescriptionConversionFactor
        ,LineItem.value:"Description.CustomPrice":ReportingCurrency::NUMBER(38,10) AS DescriptionCustomPriceReportingCurrency
        ,LineItem.value:"Description.CustomPrice":BaseCurrency::NUMBER(38,10) AS DescriptionCustomPriceBaseCurrency
        ,LineItem.value:"Description.CustomPrice":Amount::NUMBER(38,10) AS DescriptionCustomPriceAmount
        ,LineItem.value:"Description.CustomPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionCustomPriceConversionDate
        ,LineItem.value:"Description.CustomPrice":Currency:UniqueName::STRING AS DescriptionCustomPriceCurrencyCode
        ,LineItem.value:"Description.Description"::STRING AS DescriptionDescription
        ,LineItem.value:"Description.ExpirationDate"::TIMESTAMP_NTZ AS DescriptionExpirationDate
        ,LineItem.value:"Description.ExtendedDescription"::STRING AS DescriptionExtendedDescription
        ,LineItem.value:"Description.ExtAttributesBitMask"::INTEGER AS DescriptionExtAttributesBitMask
        ,LineItem.value:"Description.IndexContractPrice".ReportingCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceReportingCurrency
        ,LineItem.value:"Description.IndexContractPrice".BaseCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceBaseCurrency
        ,LineItem.value:"Description.IndexContractPrice".Amount::NUMBER(38,10) AS DescriptionIndexContractPriceAmount
        ,LineItem.value:"Description.IndexContractPrice".ConversionDate::TIMESTAMP_NTZ AS DescriptionIndexContractPriceConversionDate
        ,LineItem.value:"Description.IndexContractPrice".Currency:UniqueName::STRING AS DescriptionIndexContractPriceCurrencyCode
        ,LineItem.value:"Description.ItemNumber"::STRING AS DescriptionItemNumber
        ,LineItem.value:"Description.KitUniqueName"::STRING AS DescriptionKitCode
        ,LineItem.value:"Description.Language"::STRING AS DescriptionLanguage
        ,LineItem.value:"Description.LeadTime"::INTEGER AS DescriptionLeadTime
        ,LineItem.value:"Description.NonContractPriceReportingCurrency"::NUMBER(38,10) AS DescriptionNonContractPriceReportingCurrency
        ,LineItem.value:"Description.NonContractPriceBaseCurrency"::NUMBER(38,10) AS DescriptionNonContractPriceBaseCurrency
        ,LineItem.value:"Description.NonContractPriceAmount"::NUMBER(38,10) AS DescriptionNonContractPriceAmount
        ,LineItem.value:"Description.NonContractPriceConversionDate"::TIMESTAMP_NTZ AS DescriptionNonContractPriceConversionDate
        ,LineItem.value:"Description.NonContractPriceCurrencyUniqueName"::STRING AS DescriptionNonContractPriceCurrencyCode
        ,LineItem.value:"Description.Price":Amount::NUMBER(38,10) AS DescriptionPriceAmount
        ,LineItem.value:"Description.Price":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionPriceReportingCurrency
        ,LineItem.value:"Description.Price":AmountInBaseCurrency::NUMBER(38,10) AS DescriptionPriceBaseCurrency
        ,LineItem.value:"Description.Price":ConversionDate::TIMESTAMP_NTZ AS DescriptionPriceConversionDate
        ,LineItem.value:"Description.Price":Currency:UniqueName::STRING AS DescriptionPriceCurrencyCode
        ,LineItem.value:"Description.PriceBasesQuantity"::NUMBER(38,10) AS DescriptionPriceBasesQuantity
        ,LineItem.value:"Description.PriceBasesQuantityDesc"::STRING AS DescriptionPriceBasesQuantityDesc
        ,LineItem.value:"Description.PriceBasisQuantityUOMUniqueName"::STRING AS DescriptionPriceBasisQuantityUnitOfMeasureCode
        ,LineItem.value:"Description.QueryId"::STRING AS DescriptionQueryId
        ,LineItem.value:"Description.ShortName"::STRING AS DescriptionShortName
        ,LineItem.value:"Description.SupplierPartAuxiliaryId"::STRING AS DescriptionSupplierPartAuxiliaryId
        ,LineItem.value:"Description.SupplierPartNumber"::STRING AS DescriptionSupplierPartNumber
        ,LineItem.value:"Description.SupplierURL"::STRING AS DescriptionSupplierURL
        ,LineItem.value:"Description.UnitOfMeasure:UniqueName"::STRING AS DescriptionUnitOfMeasureCode
        ,LineItem.value:DiscountAmount:ReportingCurrency::NUMBER(38,10) AS DiscountAmountReportingCurrency
        ,LineItem.value:DiscountAmount:BaseCurrency::NUMBER(38,10) AS DiscountAmountBaseCurrency
        ,LineItem.value:DiscountAmount:Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,LineItem.value:DiscountAmount:ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,LineItem.value:DiscountAmount:Currency:UniqueName::STRING AS DiscountAmountCurrencyCode
        ,LineItem.value:DueOn::TIMESTAMP_NTZ AS DueOn
        ,LineItem.value:EndDate::TIMESTAMP_NTZ AS EndDate
        ,LineItem.value:ERPLineItemNumber::STRING AS ERPLineItemNumber
        ,LineItem.value:ERPPONumber::STRING AS ERPPONumber
        ,LineItem.value:ERSAllowed::BOOLEAN AS ERSAllowed
        ,LineItem.value:"ExpectedTax.Component"::STRING AS ExpectedTaxComponent
        ,LineItem.value:"ExpectedTax.IsAccrual"::STRING AS ExpectedTaxIsAccrual
        ,LineItem.value:"ExpectedTax.TaxCode"::STRING AS ExpectedTaxTaxCode
        ,LineItem.value:"ExpectedTax.TaxRate"::STRING AS ExpectedTaxTaxRate
        ,LineItem.value:"ExpectedTax.TaxType"::STRING AS ExpectedTaxTaxType
        ,LineItem.value:"ExpectedTax.TaxableAmount"::STRING AS ExpectedTaxTaxableAmount
        ,LineItem.value:ExternalLineNumber::INTEGER AS ExternalLineNumber
        ,LineItem.value:Form::STRING AS Form
        ,LineItem.value:GRBasedInvoice::BOOLEAN AS GRBasedInvoice
        ,LineItem.value:InspectionDate::TIMESTAMP_NTZ AS InspectionDate
        ,LineItem.value:InvoiceLineNumber::INTEGER AS InvoiceLineNumber
        ,LineItem.value:IsAdHoc::BOOLEAN AS IsAdHoc
        ,LineItem.value:IsPriceModifiedByUser::BOOLEAN AS IsPriceModifiedByUser
        ,LineItem.value:IsRecurring::BOOLEAN AS IsRecurring
        ,LineItem.value:ItemCategoryUniqueName::STRING AS ItemCategoryCode
        ,LineItem.value:ItemMasterId:BuyerPartNumber::STRING AS ItemMasterIdBuyerPartNumber
        ,LineItem.value:ItemMasterId:Facility::STRING AS ItemMasterIdFacility
        ,LineItem.value:LineType:UniqueName::STRING AS LineTypeCode
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
        ,LineItem.value:OrderId::STRING AS OrderId
        ,LineItem.value:OrderInfo:TransactionDate::TIMESTAMP_NTZ AS OrderInfoTransactionDate
        ,LineItem.value:OrderInfo:TransactionNumber::STRING AS OrderInfoTransactionNumber
        ,LineItem.value:OrderLineItem:NumberInCollection::INTEGER AS OrderLineItemNumberInCollection
        ,LineItem.value:OrderLineItem:OrderLineItemId::INTEGER AS OrderLineItemOrderLineItemId
        ,LineItem.value:OrderLineNubmer::INTEGER AS OrderLineNumber
        ,LineItem.value:OriginalPrice:ReportingCurrency::NUMBER(38,10) AS OriginalPriceReportingCurrency
        ,LineItem.value:OriginalPrice:BaseCurrency::NUMBER(38,10) AS OriginalPriceBaseCurrency
        ,LineItem.value:OriginalPrice:Amount::NUMBER(38,10) AS OriginalPriceAmount
        ,LineItem.value:OriginalPrice:ConversionDate::TIMESTAMP_NTZ AS OriginalPriceConversionDate
        ,LineItem.value:OriginalPrice:Currency:UniqueName::STRING AS OriginalPriceCurrencyCode
        ,LineItem.value:PaymentTerms:UniqueName::STRING AS PaymentTermsCode
        ,LineItem.value:Quantity::NUMBER(38,10) AS Quantity
        ,LineItem.value:ReferenceDate::TIMESTAMP_NTZ AS ReferenceDate
        ,LineItem.value:"ServiceDetails.ExpectedAmount":ReportingCurrency::NUMBER(38,10) AS ServiceDetailsExpectedAmountReportingCurrency
        ,LineItem.value:"ServiceDetails.ExpectedAmount":BaseCurrency::NUMBER(38,10) AS ServiceDetailsExpectedAmountBaseCurrency
        ,LineItem.value:"ServiceDetails.ExpectedAmount":Amount::NUMBER(38,10) AS ServiceDetailsExpectedAmountAmount
        ,LineItem.value:"ServiceDetails.ExpectedAmount":ConversionDate::TIMESTAMP_NTZ AS ServiceDetailsExpectedAmountConversionDate
        ,LineItem.value:"ServiceDetails.ExpectedAmount":Currency:UniqueName::STRING AS ServiceDetailsExpectedAmountCurrencyCode
        ,LineItem.value:"ServiceDetails.MaxAmount":ReportingCurrency::NUMBER(38,10) AS ServiceDetailsMaxAmountReportingCurrency
        ,LineItem.value:"ServiceDetails.MaxAmount":BaseCurrency::NUMBER(38,10) AS ServiceDetailsMaxAmountBaseCurrency
        ,LineItem.value:"ServiceDetails.MaxAmount":Amount::NUMBER(38,10) AS ServiceDetailsMaxAmountAmount
        ,LineItem.value:"ServiceDetails.MaxAmount":ConversionDate::TIMESTAMP_NTZ AS ServiceDetailsMaxAmountConversionDate
        ,LineItem.value:"ServiceDetails.MaxAmount":Currency:UniqueName::STRING AS ServiceDetailsMaxAmountCurrencyCode
        ,LineItem.value:"ServiceDetails.RequiresServiceEntry"::BOOLEAN AS ServiceDetailsRequiresServiceEntry
        ,LineItem.value:"ServiceDetails.ServiceEndDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceEndDate
        ,LineItem.value:"ServiceDetails.ServiceLine"::BOOLEAN AS ServiceDetailsServiceLine
        ,LineItem.value:"ServiceDetails.ServiceStartDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceStartDate
        ,LineItem.value:ServicePeriod::STRING AS ServicePeriod
        ,LineItem.value:ShipFrom:City::STRING AS ShipFromCity
        ,LineItem.value:ShipFrom:CountryUniqueName::STRING AS ShipFromCountryCode
        ,LineItem.value:ShipFrom:Fax::STRING AS ShipFromFax
        ,LineItem.value:ShipFrom:Lines::STRING AS ShipFromLines
        ,LineItem.value:ShipFrom:Name::STRING AS ShipFromName
        ,LineItem.value:ShipFrom:Phone::STRING AS ShipFromPhone
        ,LineItem.value:ShipFrom:PostalCode::STRING AS ShipFromPostalCode
        ,LineItem.value:ShipFrom:State::STRING AS ShipFromState
        ,LineItem.value:ShipFrom:UniqueName::STRING AS ShipFromCode
        ,LineItem.value:ShipTo:City::STRING AS ShipToCity
        ,LineItem.value:ShipTo:CountryUniqueName::STRING AS ShipToCountryCode
        ,LineItem.value:ShipTo:Fax::STRING AS ShipToFax
        ,LineItem.value:ShipTo:Lines::STRING AS ShipToLines
        ,LineItem.value:ShipTo:Name::STRING AS ShipToName
        ,LineItem.value:ShipTo:Phone::STRING AS ShipToPhone
        ,LineItem.value:ShipTo:PostalCode::STRING AS ShipToPostalCode
        ,LineItem.value:ShipTo:State::STRING AS ShipToState
        ,LineItem.value:ShipTo:UniqueName::STRING AS ShipToCode
        ,LineItem.value:StartDate::TIMESTAMP_NTZ AS StartDate
        ,LineItem.value:Supplier:Name::STRING AS SupplierName
        ,LineItem.value:Supplier:UniqueName::STRING AS SupplierCode
        ,LineItem.value:SupplierLocation:UniqueName::STRING AS SupplierLocationCode
        ,LineItem.value:SupplierOrderInfo::STRING AS SupplierOrderInfo
        ,LineItem.value:TaxAmount:ReportingCurrency::NUMBER(38,10) AS TaxAmountReportingCurrency
        ,LineItem.value:TaxAmount:BaseCurrency::NUMBER(38,10) AS TaxAmountBaseCurrency
        ,LineItem.value:TaxAmount:Amount::NUMBER(38,10) AS TaxAmountAmount
        ,LineItem.value:TaxAmount:ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,LineItem.value:TaxAmount:Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,LineItem.value:TaxCode::STRING AS TaxCode
        ,LineItem.value:"TaxDetail.AbatementPercent"::NUMBER(38,10) AS TaxDetailAbatementPercent
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailAlternateTaxAmountReportingCurrency
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailAlternateTaxAmountBaseCurrency
        ,LineItem.value:"TaxDetail.AlternateTaxAmount":Amount::NUMBER(38,10) AS TaxDetailAlternateTaxAmountAmount
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
        ,LineItem.value:"TaxDetail.TaxAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailTaxAmountReportingCurrency
        ,LineItem.value:"TaxDetail.TaxAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailTaxAmountBaseCurrency
        ,LineItem.value:"TaxDetail.TaxAmount":Amount::NUMBER(38,10) AS TaxDetailTaxAmountAmount
        ,LineItem.value:"TaxDetail.TaxAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailTaxAmountConversionDate
        ,LineItem.value:"TaxDetail.TaxAmount":Currency:UniqueName::STRING AS TaxDetailTaxAmountCurrencyCode
        ,LineItem.value:"TaxDetail.TaxLocation"::STRING AS TaxDetailTaxLocation
        ,LineItem.value:"TaxDetail.TaxPointDate"::TIMESTAMP_NTZ AS TaxDetailTaxPointDate
        ,LineItem.value:"TaxDetail.TaxableAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailTaxableAmountReportingCurrency
        ,LineItem.value:"TaxDetail.TaxableAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailTaxableAmountBaseCurrency
        ,LineItem.value:"TaxDetail.TaxableAmount":Amount::NUMBER(38,10) AS TaxDetailTaxableAmountAmount
        ,LineItem.value:"TaxDetail.TaxableAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailTaxableAmountConversionDate
        ,LineItem.value:"TaxDetail.TaxableAmount":Currency:UniqueName::STRING AS TaxDetailTaxableAmountCurrencyCode
        ,LineItem.value:"TaxDetail.TriangularTransactionLawReference"::STRING AS TaxDetailTriangularTransactionLawReference
        ,LineItem.value:VATAmount:ReportingCurrency::NUMBER(38,10) AS VATAmountReportingCurrency
        ,LineItem.value:VATAmount:BaseCurrency::NUMBER(38,10) AS VATAmountBaseCurrency
        ,LineItem.value:VATAmount:Amount::NUMBER(38,10) AS VATAmountAmount
        ,LineItem.value:VATAmount:ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,LineItem.value:VATAmount:Currency:UniqueName::STRING AS VATAmountCurrencyCode
        ,LineItem.value:cus_EmployeeNumber::STRING AS CustomField_EmployeeNumber
        FROM {{ source("ARIBA", "INVOICE") }} LZData
        , LATERAL FLATTEN (input => parse_json(JsonField:LineItems)) LineItem
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                        regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                        ,LZData.JSonField:UniqueName::STRING
                                        ,LZData.JSonField:Version::INTEGER
                                        ,LineItem.value:NumberInCollection::INTEGER
                                    ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
        )
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICEIDKEY AS InvoiceIdKey,
        source_data.INVOICEVERSIONKEY AS InvoiceVersionKey,
        source_data.NUMBERINCOLLECTION AS InvoiceLineItemKey,
        source_data.ACCOUNTCATEGORYCODE AS AccountCategoryCode,
        source_data.ACCOUNTINGSTYPECODE AS AccountingsTypeCode,
        source_data.ACCOUNTINGTEMPLATECODE AS AccountingTemplateCode,
        source_data.AMOUNTREPORTINGCURRENCY AS AmountReportingCurrency,
        source_data.AMOUNTBASECURRENCY AS AmountBaseCurrency,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.BASEPRICEAMOUNT AS BasePriceAmount,
        source_data.BASEPRICEBASECURRENCY AS BasePriceBaseCurrency,
        source_data.BASEPRICECONVERSIONDATE AS BasePriceConversionDate,
        source_data.BASEPRICECURRENCYCODE AS BasePriceCurrencyCode,
        source_data.BASEPRICEREPORTINGCURRENCY AS BasePriceReportingCurrency,
        source_data.BILLINGADDRESSCITY AS BillingAddressCity,
        source_data.BILLINGADDRESSCODE AS BillingAddressCode,
        source_data.BILLINGADDRESSCOUNTRYCODE AS BillingAddressCountryCode,
        source_data.BILLINGADDRESSFAX AS BillingAddressFax,
        source_data.BILLINGADDRESSNAME AS BillingAddressName,
        source_data.BILLINGADDRESSLINES AS BillingAddressLines,
        source_data.BILLINGADDRESSPHONE AS BillingAddressPhone,
        source_data.BILLINGADDRESSPOSTALCODE AS BillingAddressPostalCode,
        source_data.BILLINGADDRESSSTATE AS BillingAddressState,
        source_data.BOUGHTFROMPREFERREDSUPPLIER AS BoughtFromPreferredSupplier,
        source_data.BUYERITEMMASTERBUYERPARTNUMBER AS BuyerItemMasterBuyerPartNumber,
        source_data.BUYERNAME AS BuyerName,
        source_data.CARRIER AS Carrier,
        source_data.CARRIERMETHOD AS CarrierMethod,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTBASECURRENCY AS ChargeAmountBaseCurrency,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CHARGEAMOUNTREPORTINGCURRENCY AS ChargeAmountReportingCurrency,
        source_data.CHARGEDETAILANCHARGEDESCRIPTION AS ChargeDetailANChargeDescription,
        source_data.CHARGEDETAILANCHARGENAME AS ChargeDetailANChargeName,
        source_data.CHARGEDETAILCHARGEAMOUNTAMOUNT AS ChargeDetailChargeAmountAmount,
        source_data.CHARGEDETAILCHARGEAMOUNTBASECURRENCY AS ChargeDetailChargeAmountBaseCurrency,
        source_data.CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE AS ChargeDetailChargeAmountConversionDate,
        source_data.CHARGEDETAILCHARGEAMOUNTCURRENCYCODE AS ChargeDetailChargeAmountCurrencyCode,
        source_data.CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY AS ChargeDetailChargeAmountReportingCurrency,
        source_data.CHARGEDETAILCHARGETYPECODE AS ChargeDetailChargeTypeCode,
        source_data.CHARGEDETAILTAXAMOUNTAMOUNT AS ChargeDetailTaxAmountAmount,
        source_data.CHARGEDETAILTAXAMOUNTBASECURRENCY AS ChargeDetailTaxAmountBaseCurrency,
        source_data.CHARGEDETAILTAXAMOUNTCONVERSIONDATE AS ChargeDetailTaxAmountConversionDate,
        source_data.CHARGEDETAILTAXAMOUNTCURRENCYCODE AS ChargeDetailTaxAmountCurrencyCode,
        source_data.CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY AS ChargeDetailTaxAmountReportingCurrency,
        source_data.CHARGEDETAILTAXCODECODE AS ChargeDetailTaxCodeCode,
        source_data.COMMODITYCODECODE AS CommodityCodeCode,
        source_data.COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE AS CommodityExportMapEntryCommodityCodeCode,
        source_data.COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME AS CommodityExportMapEntryCommodityCodeName,
        source_data.COMMODITYEXPORTACCOUNTTYPECODE AS CommodityExportAccountTypeCode,
        source_data.COMMODITYEXPORTACCOUNTTYPENAME AS CommodityExportAccountTypeName,
        source_data.COMMODITYEXPORTCODE AS CommodityExportCode,
        source_data.DELIVERTO AS DeliverTo,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODENAME AS DescriptionCommonCommodityCodeName,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODECODE AS DescriptionCommonCommodityCodeCode,
        source_data.DESCRIPTIONCONTRACTPRICEAMOUNT AS DescriptionContractPriceAmount,
        source_data.DESCRIPTIONCONTRACTPRICEBASECURRENCY AS DescriptionContractPriceBaseCurrency,
        source_data.DESCRIPTIONCONTRACTPRICECONVERSIONDATE AS DescriptionContractPriceConversionDate,
        source_data.DESCRIPTIONCONTRACTPRICECURRENCYCODE AS DescriptionContractPriceCurrencyCode,
        source_data.DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY AS DescriptionContractPriceReportingCurrency,
        source_data.DESCRIPTIONCONVERSIONFACTOR AS DescriptionConversionFactor,
        source_data.DESCRIPTIONCUSTOMPRICEAMOUNT AS DescriptionCustomPriceAmount,
        source_data.DESCRIPTIONCUSTOMPRICEBASECURRENCY AS DescriptionCustomPriceBaseCurrency,
        source_data.DESCRIPTIONCUSTOMPRICECONVERSIONDATE AS DescriptionCustomPriceConversionDate,
        source_data.DESCRIPTIONCUSTOMPRICECURRENCYCODE AS DescriptionCustomPriceCurrencyCode,
        source_data.DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY AS DescriptionCustomPriceReportingCurrency,
        source_data.DESCRIPTIONDESCRIPTION AS DescriptionDescription,
        source_data.DESCRIPTIONEXPIRATIONDATE AS DescriptionExpirationDate,
        source_data.DESCRIPTIONEXTENDEDDESCRIPTION AS DescriptionExtendedDescription,
        source_data.DESCRIPTIONEXTATTRIBUTESBITMASK AS DescriptionExtAttributesBitMask,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEAMOUNT AS DescriptionIndexContractPriceAmount,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY AS DescriptionIndexContractPriceBaseCurrency,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE AS DescriptionIndexContractPriceConversionDate,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE AS DescriptionIndexContractPriceCurrencyCode,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY AS DescriptionIndexContractPriceReportingCurrency,
        source_data.DESCRIPTIONITEMNUMBER AS DescriptionItemNumber,
        source_data.DESCRIPTIONKITCODE AS DescriptionKitCode,
        source_data.DESCRIPTIONLANGUAGE AS DescriptionLanguage,
        source_data.DESCRIPTIONLEADTIME AS DescriptionLeadTime,
        source_data.DESCRIPTIONNONCONTRACTPRICEAMOUNT AS DescriptionNonContractPriceAmount,
        source_data.DESCRIPTIONNONCONTRACTPRICEBASECURRENCY AS DescriptionNonContractPriceBaseCurrency,
        source_data.DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE AS DescriptionNonContractPriceConversionDate,
        source_data.DESCRIPTIONNONCONTRACTPRICECURRENCYCODE AS DescriptionNonContractPriceCurrencyCode,
        source_data.DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY AS DescriptionNonContractPriceReportingCurrency,
        source_data.DESCRIPTIONPRICEAMOUNT AS DescriptionPriceAmount,
        source_data.DESCRIPTIONPRICEBASECURRENCY AS DescriptionPriceBaseCurrency,
        source_data.DESCRIPTIONPRICECONVERSIONDATE AS DescriptionPriceConversionDate,
        source_data.DESCRIPTIONPRICECURRENCYCODE AS DescriptionPriceCurrencyCode,
        source_data.DESCRIPTIONPRICEREPORTINGCURRENCY AS DescriptionPriceReportingCurrency,
        source_data.DESCRIPTIONPRICEBASESQUANTITY AS DescriptionPriceBasesQuantity,
        source_data.DESCRIPTIONPRICEBASESQUANTITYDESC AS DescriptionPriceBasesQuantityDesc,
        source_data.DESCRIPTIONPRICEBASISQUANTITYUNITOFMEASURECODE AS DescriptionPriceBasisQuantityUnitOfMeasureCode,
        source_data.DESCRIPTIONQUERYID AS DescriptionQueryId,
        source_data.DESCRIPTIONSHORTNAME AS DescriptionShortName,
        source_data.DESCRIPTIONSUPPLIERPARTAUXILIARYID AS DescriptionSupplierPartAuxiliaryId,
        source_data.DESCRIPTIONSUPPLIERPARTNUMBER AS DescriptionSupplierPartNumber,
        source_data.DESCRIPTIONSUPPLIERURL AS DescriptionSupplierURL,
        source_data.DESCRIPTIONUNITOFMEASURECODE AS DescriptionUnitOfMeasureCode,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTBASECURRENCY AS DiscountAmountBaseCurrency,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DISCOUNTAMOUNTREPORTINGCURRENCY AS DiscountAmountReportingCurrency,
        source_data.DUEON AS DueOn,
        source_data.ENDDATE AS EndDate,
        source_data.ERPLINEITEMNUMBER AS ERPLineItemNumber,
        source_data.ERPPONUMBER AS ERPPONumber,
        source_data.ERSALLOWED AS ERSAllowed,
        source_data.EXPECTEDTAXCOMPONENT AS ExpectedTaxComponent,
        source_data.EXPECTEDTAXISACCRUAL AS ExpectedTaxIsAccrual,
        source_data.EXPECTEDTAXTAXCODE AS ExpectedTaxTaxCode,
        source_data.EXPECTEDTAXTAXRATE AS ExpectedTaxTaxRate,
        source_data.EXPECTEDTAXTAXTYPE AS ExpectedTaxTaxType,
        source_data.EXPECTEDTAXTAXABLEAMOUNT AS ExpectedTaxTaxableAmount,
        source_data.EXTERNALLINENUMBER AS ExternalLineNumber,
        source_data.FORM AS Form,
        source_data.GRBASEDINVOICE AS GRBasedInvoice,
        source_data.INSPECTIONDATE AS InspectionDate,
        source_data.INVOICELINENUMBER AS InvoiceLineNumber,
        source_data.ISADHOC AS IsAdHoc,
        source_data.ISPRICEMODIFIEDBYUSER AS IsPriceModifiedByUser,
        source_data.ISRECURRING AS IsRecurring,
        source_data.ITEMCATEGORYCODE AS ItemCategoryCode,
        source_data.ITEMMASTERIDBUYERPARTNUMBER AS ItemMasterIdBuyerPartNumber,
        source_data.ITEMMASTERIDFACILITY AS ItemMasterIdFacility,
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
        source_data.ORDERCODE AS OrderCode,
        source_data.ORDERID AS OrderId,
        source_data.ORDERINFOTRANSACTIONDATE AS OrderInfoTransactionDate,
        source_data.ORDERINFOTRANSACTIONNUMBER AS OrderInfoTransactionNumber,
        source_data.ORDERLINEITEMNUMBERINCOLLECTION AS OrderLineItemNumberInCollection,
        source_data.ORDERLINEITEMORDERLINEITEMID AS OrderLineItemOrderLineItemId,
        source_data.ORDERLINENUMBER AS OrderLineNumber,
        source_data.ORIGINALPRICEAMOUNT AS OriginalPriceAmount,
        source_data.ORIGINALPRICEBASECURRENCY AS OriginalPriceBaseCurrency,
        source_data.ORIGINALPRICECONVERSIONDATE AS OriginalPriceConversionDate,
        source_data.ORIGINALPRICECURRENCYCODE AS OriginalPriceCurrencyCode,
        source_data.ORIGINALPRICEREPORTINGCURRENCY AS OriginalPriceReportingCurrency,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.QUANTITY AS Quantity,
        source_data.REFERENCEDATE AS ReferenceDate,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTREPORTINGCURRENCY AS ServiceDetailsExpectedAmountReportingCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTBASECURRENCY AS ServiceDetailsExpectedAmountBaseCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAMOUNT AS ServiceDetailsExpectedAmountAmount,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE AS ServiceDetailsExpectedAmountConversionDate,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE AS ServiceDetailsExpectedAmountCurrencyCode,
        source_data.SERVICEDETAILSMAXAMOUNTREPORTINGCURRENCY AS ServiceDetailsMaxAmountReportingCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTBASECURRENCY AS ServiceDetailsMaxAmountBaseCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTAMOUNT AS ServiceDetailsMaxAmountAmount,
        source_data.SERVICEDETAILSMAXAMOUNTCONVERSIONDATE AS ServiceDetailsMaxAmountConversionDate,
        source_data.SERVICEDETAILSMAXAMOUNTCURRENCYCODE AS ServiceDetailsMaxAmountCurrencyCode,
        source_data.SERVICEDETAILSREQUIRESSERVICEENTRY AS ServiceDetailsRequiresServiceEntry,
        source_data.SERVICEDETAILSSERVICEENDDATE AS ServiceDetailsServiceEndDate,
        source_data.SERVICEDETAILSSERVICELINE AS ServiceDetailsServiceLine,
        source_data.SERVICEDETAILSSERVICESTARTDATE AS ServiceDetailsServiceStartDate,
        source_data.SERVICEPERIOD AS ServicePeriod,
        source_data.SHIPFROMCITY AS ShipFromCity,
        source_data.SHIPFROMCODE AS ShipFromCode,
        source_data.SHIPFROMCOUNTRYCODE AS ShipFromCountryCode,
        source_data.SHIPFROMFAX AS ShipFromFax,
        source_data.SHIPFROMLINES AS ShipFromLines,
        source_data.SHIPFROMNAME AS ShipFromName,
        source_data.SHIPFROMPHONE AS ShipFromPhone,
        source_data.SHIPFROMPOSTALCODE AS ShipFromPostalCode,
        source_data.SHIPFROMSTATE AS ShipFromState,
        source_data.SHIPTOCITY AS ShipToCity,
        source_data.SHIPTOCODE AS ShipToCode,
        source_data.SHIPTOCOUNTRYCODE AS ShipToCountryCode,
        source_data.SHIPTOFAX AS ShipToFax,
        source_data.SHIPTOLINES AS ShipToLines,
        source_data.SHIPTONAME AS ShipToName,
        source_data.SHIPTOPHONE AS ShipToPhone,
        source_data.SHIPTOPOSTALCODE AS ShipToPostalCode,
        source_data.SHIPTOSTATE AS ShipToState,
        source_data.STARTDATE AS StartDate,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.SUPPLIERORDERINFO AS SupplierOrderInfo,
        source_data.TAXAMOUNTREPORTINGCURRENCY AS TaxAmountReportingCurrency,
        source_data.TAXAMOUNTBASECURRENCY AS TaxAmountBaseCurrency,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXCODE AS TaxCode,
        source_data.TAXDETAILABATEMENTPERCENT AS TaxDetailAbatementPercent,
        source_data.TAXDETAILALTERNATETAXAMOUNTREPORTINGCURRENCY AS TaxDetailAlternateTaxAmountReportingCurrency,
        source_data.TAXDETAILALTERNATETAXAMOUNTBASECURRENCY AS TaxDetailAlternateTaxAmountBaseCurrency,
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
        source_data.TAXDETAILTAXAMOUNTREPORTINGCURRENCY AS TaxDetailTaxAmountReportingCurrency,
        source_data.TAXDETAILTAXAMOUNTBASECURRENCY AS TaxDetailTaxAmountBaseCurrency,
        source_data.TAXDETAILTAXAMOUNTAMOUNT AS TaxDetailTaxAmountAmount,
        source_data.TAXDETAILTAXAMOUNTCONVERSIONDATE AS TaxDetailTaxAmountConversionDate,
        source_data.TAXDETAILTAXAMOUNTCURRENCYCODE AS TaxDetailTaxAmountCurrencyCode,
        source_data.TAXDETAILTAXLOCATION AS TaxDetailTaxLocation,
        source_data.TAXDETAILTAXPOINTDATE AS TaxDetailTaxPointDate,
        source_data.TAXDETAILTAXABLEAMOUNTREPORTINGCURRENCY AS TaxDetailTaxableAmountReportingCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTBASECURRENCY AS TaxDetailTaxableAmountBaseCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTAMOUNT AS TaxDetailTaxableAmountAmount,
        source_data.TAXDETAILTAXABLEAMOUNTCONVERSIONDATE AS TaxDetailTaxableAmountConversionDate,
        source_data.TAXDETAILTAXABLEAMOUNTCURRENCYCODE AS TaxDetailTaxableAmountCurrencyCode,
        source_data.TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE AS TaxDetailTriangularTransactionLawReference,
        source_data.VATAMOUNTREPORTINGCURRENCY AS VATAmountReportingCurrency,
        source_data.VATAMOUNTBASECURRENCY AS VATAmountBaseCurrency,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.CUSTOMFIELD_EMPLOYEENUMBER AS CustomField_EmployeeNumber,
        'No' AS IsHistorical,
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
        cast(ACCOUNTCATEGORYCODE as VARCHAR(16777126)) as ACCOUNTCATEGORYCODE,
        cast(ACCOUNTINGSTYPECODE as VARCHAR(16777126)) as ACCOUNTINGSTYPECODE,
        cast(ACCOUNTINGTEMPLATECODE as VARCHAR(16777126)) as ACCOUNTINGTEMPLATECODE,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777126)) as AMOUNTCURRENCYCODE,
        cast(BASEPRICEAMOUNT as NUMBER(38,10)) as BASEPRICEAMOUNT,
        cast(BASEPRICEBASECURRENCY as NUMBER(38,10)) as BASEPRICEBASECURRENCY,
        cast(BASEPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as BASEPRICECONVERSIONDATE,
        cast(BASEPRICECURRENCYCODE as VARCHAR(16777126)) as BASEPRICECURRENCYCODE,
        cast(BASEPRICEREPORTINGCURRENCY as NUMBER(38,10)) as BASEPRICEREPORTINGCURRENCY,
        cast(BILLINGADDRESSCITY as VARCHAR(16777126)) as BILLINGADDRESSCITY,
        cast(BILLINGADDRESSCODE as VARCHAR(16777126)) as BILLINGADDRESSCODE,
        cast(BILLINGADDRESSCOUNTRYCODE as VARCHAR(16777126)) as BILLINGADDRESSCOUNTRYCODE,
        cast(BILLINGADDRESSFAX as VARCHAR(16777126)) as BILLINGADDRESSFAX,
        cast(BILLINGADDRESSNAME as VARCHAR(16777126)) as BILLINGADDRESSNAME,
        cast(BILLINGADDRESSLINES as VARCHAR(16777126)) as BILLINGADDRESSLINES,
        cast(BILLINGADDRESSPHONE as VARCHAR(16777126)) as BILLINGADDRESSPHONE,
        cast(BILLINGADDRESSPOSTALCODE as VARCHAR(16777126)) as BILLINGADDRESSPOSTALCODE,
        cast(BILLINGADDRESSSTATE as VARCHAR(16777126)) as BILLINGADDRESSSTATE,
        cast(BOUGHTFROMPREFERREDSUPPLIER as BOOLEAN) as BOUGHTFROMPREFERREDSUPPLIER,
        cast(BUYERITEMMASTERBUYERPARTNUMBER as VARCHAR(16777126)) as BUYERITEMMASTERBUYERPARTNUMBER,
        cast(BUYERNAME as VARCHAR(16777126)) as BUYERNAME,
        cast(CARRIER as VARCHAR(16777126)) as CARRIER,
        cast(CARRIERMETHOD as VARCHAR(16777126)) as CARRIERMETHOD,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTBASECURRENCY,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777126)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTREPORTINGCURRENCY,
        cast(CHARGEDETAILANCHARGEDESCRIPTION as VARCHAR(16777126)) as CHARGEDETAILANCHARGEDESCRIPTION,
        cast(CHARGEDETAILANCHARGENAME as VARCHAR(16777126)) as CHARGEDETAILANCHARGENAME,
        cast(CHARGEDETAILCHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTAMOUNT,
        cast(CHARGEDETAILCHARGEAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTBASECURRENCY,
        cast(CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILCHARGEAMOUNTCURRENCYCODE as VARCHAR(16777126)) as CHARGEDETAILCHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY,
        cast(CHARGEDETAILCHARGETYPECODE as VARCHAR(16777126)) as CHARGEDETAILCHARGETYPECODE,
        cast(CHARGEDETAILTAXAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTAMOUNT,
        cast(CHARGEDETAILTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTBASECURRENCY,
        cast(CHARGEDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILTAXAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777126)) as CHARGEDETAILTAXAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY,
        cast(CHARGEDETAILTAXCODECODE as VARCHAR(16777126)) as CHARGEDETAILTAXCODECODE,
        cast(COMMODITYCODECODE as VARCHAR(16777126)) as COMMODITYCODECODE,
        cast(COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE as VARCHAR(16777126)) as COMMODITYEXPORTMAPENTRYCOMMODITYCODECODE,
        cast(COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME as VARCHAR(16777126)) as COMMODITYEXPORTMAPENTRYCOMMODITYCODENAME,
        cast(COMMODITYEXPORTACCOUNTTYPECODE as VARCHAR(16777126)) as COMMODITYEXPORTACCOUNTTYPECODE,
        cast(COMMODITYEXPORTACCOUNTTYPENAME as VARCHAR(16777126)) as COMMODITYEXPORTACCOUNTTYPENAME,
        cast(COMMODITYEXPORTCODE as VARCHAR(16777126)) as COMMODITYEXPORTCODE,
        cast(DELIVERTO as VARCHAR(16777126)) as DELIVERTO,
        cast(DESCRIPTIONCOMMONCOMMODITYCODENAME as VARCHAR(16777126)) as DESCRIPTIONCOMMONCOMMODITYCODENAME,
        cast(DESCRIPTIONCOMMONCOMMODITYCODECODE as VARCHAR(16777126)) as DESCRIPTIONCOMMONCOMMODITYCODECODE,
        cast(DESCRIPTIONCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONCONTRACTPRICECURRENCYCODE as VARCHAR(16777126)) as DESCRIPTIONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONCONVERSIONFACTOR as NUMBER(38,10)) as DESCRIPTIONCONVERSIONFACTOR,
        cast(DESCRIPTIONCUSTOMPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEAMOUNT,
        cast(DESCRIPTIONCUSTOMPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEBASECURRENCY,
        cast(DESCRIPTIONCUSTOMPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCUSTOMPRICECONVERSIONDATE,
        cast(DESCRIPTIONCUSTOMPRICECURRENCYCODE as VARCHAR(16777126)) as DESCRIPTIONCUSTOMPRICECURRENCYCODE,
        cast(DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONDESCRIPTION as VARCHAR(16777126)) as DESCRIPTIONDESCRIPTION,
        cast(DESCRIPTIONEXPIRATIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONEXPIRATIONDATE,
        cast(DESCRIPTIONEXTENDEDDESCRIPTION as VARCHAR(16777126)) as DESCRIPTIONEXTENDEDDESCRIPTION,
        cast(DESCRIPTIONEXTATTRIBUTESBITMASK as NUMBER(38,0)) as DESCRIPTIONEXTATTRIBUTESBITMASK,
        cast(DESCRIPTIONINDEXCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE as VARCHAR(16777126)) as DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONITEMNUMBER as VARCHAR(16777126)) as DESCRIPTIONITEMNUMBER,
        cast(DESCRIPTIONKITCODE as VARCHAR(16777126)) as DESCRIPTIONKITCODE,
        cast(DESCRIPTIONLANGUAGE as VARCHAR(16777126)) as DESCRIPTIONLANGUAGE,
        cast(DESCRIPTIONLEADTIME as NUMBER(38,0)) as DESCRIPTIONLEADTIME,
        cast(DESCRIPTIONNONCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONNONCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONNONCONTRACTPRICECURRENCYCODE as VARCHAR(16777126)) as DESCRIPTIONNONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONPRICEAMOUNT,
        cast(DESCRIPTIONPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEBASECURRENCY,
        cast(DESCRIPTIONPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONPRICECONVERSIONDATE,
        cast(DESCRIPTIONPRICECURRENCYCODE as VARCHAR(16777126)) as DESCRIPTIONPRICECURRENCYCODE,
        cast(DESCRIPTIONPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONPRICEBASESQUANTITY as NUMBER(38,10)) as DESCRIPTIONPRICEBASESQUANTITY,
        cast(DESCRIPTIONPRICEBASESQUANTITYDESC as VARCHAR(16777126)) as DESCRIPTIONPRICEBASESQUANTITYDESC,
        cast(DESCRIPTIONPRICEBASISQUANTITYUNITOFMEASURECODE as VARCHAR(16777126)) as DESCRIPTIONPRICEBASISQUANTITYUNITOFMEASURECODE,
        cast(DESCRIPTIONQUERYID as VARCHAR(16777126)) as DESCRIPTIONQUERYID,
        cast(DESCRIPTIONSHORTNAME as VARCHAR(16777126)) as DESCRIPTIONSHORTNAME,
        cast(DESCRIPTIONSUPPLIERPARTAUXILIARYID as VARCHAR(16777126)) as DESCRIPTIONSUPPLIERPARTAUXILIARYID,
        cast(DESCRIPTIONSUPPLIERPARTNUMBER as VARCHAR(16777126)) as DESCRIPTIONSUPPLIERPARTNUMBER,
        cast(DESCRIPTIONSUPPLIERURL as VARCHAR(16777126)) as DESCRIPTIONSUPPLIERURL,
        cast(DESCRIPTIONUNITOFMEASURECODE as VARCHAR(16777126)) as DESCRIPTIONUNITOFMEASURECODE,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTBASECURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTBASECURRENCY,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777126)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DISCOUNTAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTREPORTINGCURRENCY,
        cast(DUEON as TIMESTAMP_NTZ(9)) as DUEON,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(ERPLINEITEMNUMBER as VARCHAR(16777126)) as ERPLINEITEMNUMBER,
        cast(ERPPONUMBER as VARCHAR(16777126)) as ERPPONUMBER,
        cast(ERSALLOWED as BOOLEAN) as ERSALLOWED,
        cast(EXPECTEDTAXCOMPONENT as VARCHAR(16777126)) as EXPECTEDTAXCOMPONENT,
        cast(EXPECTEDTAXISACCRUAL as VARCHAR(16777126)) as EXPECTEDTAXISACCRUAL,
        cast(EXPECTEDTAXTAXCODE as VARCHAR(16777126)) as EXPECTEDTAXTAXCODE,
        cast(EXPECTEDTAXTAXRATE as VARCHAR(16777126)) as EXPECTEDTAXTAXRATE,
        cast(EXPECTEDTAXTAXTYPE as VARCHAR(16777126)) as EXPECTEDTAXTAXTYPE,
        cast(EXPECTEDTAXTAXABLEAMOUNT as VARCHAR(16777126)) as EXPECTEDTAXTAXABLEAMOUNT,
        cast(EXTERNALLINENUMBER as NUMBER(38,0)) as EXTERNALLINENUMBER,
        cast(FORM as VARCHAR(16777126)) as FORM,
        cast(GRBASEDINVOICE as BOOLEAN) as GRBASEDINVOICE,
        cast(INSPECTIONDATE as TIMESTAMP_NTZ(9)) as INSPECTIONDATE,
        cast(INVOICELINENUMBER as NUMBER(38,0)) as INVOICELINENUMBER,
        cast(ISADHOC as BOOLEAN) as ISADHOC,
        cast(ISPRICEMODIFIEDBYUSER as BOOLEAN) as ISPRICEMODIFIEDBYUSER,
        cast(ISRECURRING as BOOLEAN) as ISRECURRING,
        cast(ITEMCATEGORYCODE as VARCHAR(16777126)) as ITEMCATEGORYCODE,
        cast(ITEMMASTERIDBUYERPARTNUMBER as VARCHAR(16777126)) as ITEMMASTERIDBUYERPARTNUMBER,
        cast(ITEMMASTERIDFACILITY as VARCHAR(16777126)) as ITEMMASTERIDFACILITY,
        cast(LINETYPECODE as VARCHAR(16777126)) as LINETYPECODE,
        cast(MASTERAGREEMENTCODE as VARCHAR(16777126)) as MASTERAGREEMENTCODE,
        cast(NEEDBY as TIMESTAMP_NTZ(9)) as NEEDBY,
        cast(NUMBERCONFIRMEDACCEPTED as NUMBER(38,10)) as NUMBERCONFIRMEDACCEPTED,
        cast(NUMBERCONFIRMEDACCEPTEDWITHCHANGES as NUMBER(38,10)) as NUMBERCONFIRMEDACCEPTEDWITHCHANGES,
        cast(NUMBERCONFIRMEDBACKORDERED as NUMBER(38,10)) as NUMBERCONFIRMEDBACKORDERED,
        cast(NUMBERCONFIRMEDREJECTED as NUMBER(38,10)) as NUMBERCONFIRMEDREJECTED,
        cast(NUMBERCONFIRMEDSUBSTITUTED as NUMBER(38,10)) as NUMBERCONFIRMEDSUBSTITUTED,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(NUMBERONPO as NUMBER(38,0)) as NUMBERONPO,
        cast(NUMBERSHIPPED as NUMBER(38,10)) as NUMBERSHIPPED,
        cast(ORDERCODE as VARCHAR(16777126)) as ORDERCODE,
        cast(ORDERID as VARCHAR(16777126)) as ORDERID,
        cast(ORDERINFOTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as ORDERINFOTRANSACTIONDATE,
        cast(ORDERINFOTRANSACTIONNUMBER as VARCHAR(16777126)) as ORDERINFOTRANSACTIONNUMBER,
        cast(ORDERLINEITEMNUMBERINCOLLECTION as NUMBER(38,0)) as ORDERLINEITEMNUMBERINCOLLECTION,
        cast(ORDERLINEITEMORDERLINEITEMID as NUMBER(38,0)) as ORDERLINEITEMORDERLINEITEMID,
        cast(ORDERLINENUMBER as NUMBER(38,0)) as ORDERLINENUMBER,
        cast(ORIGINALPRICEAMOUNT as NUMBER(38,10)) as ORIGINALPRICEAMOUNT,
        cast(ORIGINALPRICEBASECURRENCY as NUMBER(38,10)) as ORIGINALPRICEBASECURRENCY,
        cast(ORIGINALPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as ORIGINALPRICECONVERSIONDATE,
        cast(ORIGINALPRICECURRENCYCODE as VARCHAR(16777126)) as ORIGINALPRICECURRENCYCODE,
        cast(ORIGINALPRICEREPORTINGCURRENCY as NUMBER(38,10)) as ORIGINALPRICEREPORTINGCURRENCY,
        cast(PAYMENTTERMSCODE as VARCHAR(16777126)) as PAYMENTTERMSCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(REFERENCEDATE as TIMESTAMP_NTZ(9)) as REFERENCEDATE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTREPORTINGCURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTBASECURRENCY as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTBASECURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAMOUNT as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTAMOUNT,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE as VARCHAR(16777126)) as SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE,
        cast(SERVICEDETAILSMAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTREPORTINGCURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTBASECURRENCY as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTBASECURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTAMOUNT as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTAMOUNT,
        cast(SERVICEDETAILSMAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSMAXAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSMAXAMOUNTCURRENCYCODE as VARCHAR(16777126)) as SERVICEDETAILSMAXAMOUNTCURRENCYCODE,
        cast(SERVICEDETAILSREQUIRESSERVICEENTRY as BOOLEAN) as SERVICEDETAILSREQUIRESSERVICEENTRY,
        cast(SERVICEDETAILSSERVICEENDDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICEENDDATE,
        cast(SERVICEDETAILSSERVICELINE as BOOLEAN) as SERVICEDETAILSSERVICELINE,
        cast(SERVICEDETAILSSERVICESTARTDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICESTARTDATE,
        cast(SERVICEPERIOD as VARCHAR(16777126)) as SERVICEPERIOD,
        cast(SHIPFROMCITY as VARCHAR(16777126)) as SHIPFROMCITY,
        cast(SHIPFROMCODE as VARCHAR(16777126)) as SHIPFROMCODE,
        cast(SHIPFROMCOUNTRYCODE as VARCHAR(16777126)) as SHIPFROMCOUNTRYCODE,
        cast(SHIPFROMFAX as VARCHAR(16777126)) as SHIPFROMFAX,
        cast(SHIPFROMLINES as VARCHAR(16777126)) as SHIPFROMLINES,
        cast(SHIPFROMNAME as VARCHAR(16777126)) as SHIPFROMNAME,
        cast(SHIPFROMPHONE as VARCHAR(16777126)) as SHIPFROMPHONE,
        cast(SHIPFROMPOSTALCODE as VARCHAR(16777126)) as SHIPFROMPOSTALCODE,
        cast(SHIPFROMSTATE as VARCHAR(16777126)) as SHIPFROMSTATE,
        cast(SHIPTOCITY as VARCHAR(16777126)) as SHIPTOCITY,
        cast(SHIPTOCODE as VARCHAR(16777126)) as SHIPTOCODE,
        cast(SHIPTOCOUNTRYCODE as VARCHAR(16777126)) as SHIPTOCOUNTRYCODE,
        cast(SHIPTOFAX as VARCHAR(16777126)) as SHIPTOFAX,
        cast(SHIPTOLINES as VARCHAR(16777126)) as SHIPTOLINES,
        cast(SHIPTONAME as VARCHAR(16777126)) as SHIPTONAME,
        cast(SHIPTOPHONE as VARCHAR(16777126)) as SHIPTOPHONE,
        cast(SHIPTOPOSTALCODE as VARCHAR(16777126)) as SHIPTOPOSTALCODE,
        cast(SHIPTOSTATE as VARCHAR(16777126)) as SHIPTOSTATE,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(SUPPLIERCODE as VARCHAR(16777126)) as SUPPLIERCODE,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777126)) as SUPPLIERLOCATIONCODE,
        cast(SUPPLIERORDERINFO as VARCHAR(16777126)) as SUPPLIERORDERINFO,
        cast(TAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTREPORTINGCURRENCY,
        cast(TAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTBASECURRENCY,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777126)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXCODE as VARCHAR(16777126)) as TAXCODE,
        cast(TAXDETAILABATEMENTPERCENT as NUMBER(38,10)) as TAXDETAILABATEMENTPERCENT,
        cast(TAXDETAILALTERNATETAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTBASECURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTAMOUNT,
        cast(TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE as VARCHAR(16777126)) as TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILCATEGORY as VARCHAR(16777126)) as TAXDETAILCATEGORY,
        cast(TAXDETAILCOMPONENTCODE as VARCHAR(16777126)) as TAXDETAILCOMPONENTCODE,
        cast(TAXDETAILDESCRIPTION as VARCHAR(16777126)) as TAXDETAILDESCRIPTION,
        cast(TAXDETAILEXEMPTDETAIL as VARCHAR(16777126)) as TAXDETAILEXEMPTDETAIL,
        cast(TAXDETAILFORMULASTRING as VARCHAR(16777126)) as TAXDETAILFORMULASTRING,
        cast(TAXDETAILISDEDUCTIBLE as BOOLEAN) as TAXDETAILISDEDUCTIBLE,
        cast(TAXDETAILISTRIANGULARTRANSACTION as BOOLEAN) as TAXDETAILISTRIANGULARTRANSACTION,
        cast(TAXDETAILPAYMENTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILPAYMENTDATE,
        cast(TAXDETAILPERUNIT as NUMBER(38,10)) as TAXDETAILPERUNIT,
        cast(TAXDETAILPERCENT as NUMBER(38,10)) as TAXDETAILPERCENT,
        cast(TAXDETAILPURPOSE as VARCHAR(16777126)) as TAXDETAILPURPOSE,
        cast(TAXDETAILTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILTAXAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXDETAILTAXAMOUNTBASECURRENCY,
        cast(TAXDETAILTAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILTAXAMOUNTAMOUNT,
        cast(TAXDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777126)) as TAXDETAILTAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILTAXLOCATION as VARCHAR(16777126)) as TAXDETAILTAXLOCATION,
        cast(TAXDETAILTAXPOINTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXPOINTDATE,
        cast(TAXDETAILTAXABLEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTBASECURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTAMOUNT,
        cast(TAXDETAILTAXABLEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXABLEAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXABLEAMOUNTCURRENCYCODE as VARCHAR(16777126)) as TAXDETAILTAXABLEAMOUNTCURRENCYCODE,
        cast(TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE as VARCHAR(16777126)) as TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE,
        cast(VATAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTREPORTINGCURRENCY,
        cast(VATAMOUNTBASECURRENCY as NUMBER(38,10)) as VATAMOUNTBASECURRENCY,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777126)) as VATAMOUNTCURRENCYCODE,
        cast(CUSTOMFIELD_EMPLOYEENUMBER as VARCHAR(16777126)) as CUSTOMFIELD_EMPLOYEENUMBER,
        cast(INVOICELINEITEMKEY as NUMBER(38,0)) as INVOICELINEITEMKEY,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data