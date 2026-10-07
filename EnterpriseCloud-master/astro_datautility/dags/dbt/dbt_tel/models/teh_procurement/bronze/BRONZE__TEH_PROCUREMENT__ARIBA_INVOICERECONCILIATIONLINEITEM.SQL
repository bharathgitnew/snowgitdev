{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONLINEITEM',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey',
    'InvoiceReconciliationLineItemKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::STRING::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS InvoiceReconciliationIDKey
        ,JsonField:VersionNumber::INTEGER AS InvoiceReconciliationVersionKey
        ,LineItem.value:"Accountings.Type":UniqueName::STRING AS AccountingsTypeCode
        ,LineItem.value:AccrualTaxAmount:ReportingCurrency::NUMBER(38,10) AS AccrualTaxAmountReportingCurrency
        ,LineItem.value:AccrualTaxAmount:BaseCurrency::NUMBER(38,10) AS AccrualTaxAmountBaseCurrency
        ,LineItem.value:AccrualTaxAmount:Amount::NUMBER(38,10) AS AccrualTaxAmountAmount
        ,LineItem.value:AccrualTaxAmount:ConversionDate::TIMESTAMP_NTZ AS AccrualTaxAmountConversionDate
        ,LineItem.value:AccrualTaxAmount:Currency:UniqueName::STRING AS AccrualTaxAmountCurrencyCode
        ,LineItem.value:AmountBilled:ReportingCurrency::NUMBER(38,10) AS AmountBilledReportingCurrency
        ,LineItem.value:AmountBilled:BaseCurrency::NUMBER(38,10) AS AmountBilledBaseCurrency
        ,LineItem.value:AmountBilled:Amount::NUMBER(38,10) AS AmountBilledAmount
        ,LineItem.value:AmountBilled:ConversionDate::TIMESTAMP_NTZ AS AmountBilledConversionDate
        ,LineItem.value:AmountBilled:Currency:UniqueName::STRING AS AmountBilledCurrencyCode
        ,LineItem.value:AmountCleared:ReportingCurrency::NUMBER(38,10) AS AmountClearedReportingCurrency
        ,LineItem.value:AmountCleared:BaseCurrency::NUMBER(38,10) AS AmountClearedBaseCurrency
        ,LineItem.value:AmountCleared:Amount::NUMBER(38,10) AS AmountClearedAmount
        ,LineItem.value:AmountCleared:ConversionDate::TIMESTAMP_NTZ AS AmountClearedConversionDate
        ,LineItem.value:AmountCleared:Currency:UniqueName::STRING AS AmountClearedCurrencyCode
        ,LineItem.value:AmountInvoiced:ReportingCurrency::NUMBER(38,10) AS AmountInvoicedReportingCurrency
        ,LineItem.value:AmountInvoiced:BaseCurrency::NUMBER(38,10) AS AmountInvoicedBaseCurrency
        ,LineItem.value:AmountInvoiced:Amount::NUMBER(38,10) AS AmountInvoicedAmount
        ,LineItem.value:AmountInvoiced:ConversionDate::TIMESTAMP_NTZ AS AmountInvoicedConversionDate
        ,LineItem.value:AmountInvoiced:Currency:UniqueName::STRING AS AmountInvoicedCurrencyCode
        ,LineItem.value:BasePrice:ReportingCurrency::NUMBER(38,10) AS BasePriceReportingCurrency
        ,LineItem.value:BasePrice:BaseCurrency::NUMBER(38,10) AS BasePriceBaseCurrency
        ,LineItem.value:BasePrice:Amount::NUMBER(38,10) AS BasePriceAmount
        ,LineItem.value:BasePrice:ConversionDate::TIMESTAMP_NTZ AS BasePriceConversionDate
        ,LineItem.value:BasePrice:Currency:UniqueName::STRING AS BasePriceCurrencyCode
        ,LineItem.value:BillingAddress:City::STRING AS BillingAddressCity
        ,LineItem.value:BillingAddress:Country:UniqueName::STRING AS BillingAddressCountryCode
        ,LineItem.value:BillingAddress:Fax::STRING AS BillingAddressFaxNumber
        ,LineItem.value:BillingAddress:Lines::STRING AS BillingAddressLines
        ,LineItem.value:BillingAddress:Name::STRING AS BillingAddressName
        ,LineItem.value:BillingAddress:Phone::STRING AS BillingAddressPhoneNumber
        ,LineItem.value:BillingAddress:PostalCode::STRING AS BillingAddressPostalCode
        ,LineItem.value:BillingAddress:State::STRING AS BillingAddressState
        ,LineItem.value:BillingAddress:UniqueName::STRING AS BillingAddressCode
        ,LineItem.value:Category::INTEGER AS Category
        ,LineItem.value:ChargeAmount:ReportingCurrency::NUMBER(38,10) AS ChargeAmountReportingCurrency
        ,LineItem.value:ChargeAmount:BaseCurrency::NUMBER(38,10) AS ChargeAmountBaseCurrency
        ,LineItem.value:ChargeAmount:Amount::NUMBER(38,10) AS ChargeAmountAmount
        ,LineItem.value:ChargeAmount:ConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,LineItem.value:ChargeAmount:Currency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.ANChargeDescription"::STRING AS ChargeDetailANChargeDescription
        ,LineItem.value:"ChargeDetail.ANChargeName"::STRING AS ChargeDetailANChargeName
        ,LineItem.value:"ChargeDetail.ChargeAmount":ReportingCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountReportingCurrency
        ,LineItem.value:"ChargeDetail.ChargeAmount":BaseCurrency::NUMBER(38,10) AS ChargeDetailChargeAmountBaseCurrency
        ,LineItem.value:"ChargeDetail.ChargeAmount":Amount::NUMBER(38,10) AS ChargeDetailChargeAmountAmount
        ,LineItem.value:"ChargeDetail.ChargeAmount":ConversionDate::TIMESTAMP_NTZ AS ChargeDetailChargeAmountConversionDate
        ,LineItem.value:"ChargeDetail.ChargeAmount":Currency:UniqueName::STRING AS ChargeDetailChargeAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.ChargeType":UniqueName::STRING AS ChargeDetailChargeTypeCode
        ,LineItem.value:"ChargeDetail.TaxAmount":ReportingCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountReportingCurrency
        ,LineItem.value:"ChargeDetail.TaxAmount":BaseCurrency::NUMBER(38,10) AS ChargeDetailTaxAmountBaseCurrency
        ,LineItem.value:"ChargeDetail.TaxAmount":Amount::NUMBER(38,10) AS ChargeDetailTaxAmountAmount
        ,LineItem.value:"ChargeDetail.TaxAmount":ConversionDate::TIMESTAMP_NTZ AS ChargeDetailTaxAmountConversionDate
        ,LineItem.value:"ChargeDetail.TaxAmount":Currency:UniqueName::STRING AS ChargeDetailTaxAmountCurrencyCode
        ,LineItem.value:"ChargeDetail.TaxCode":UniqueName::STRING AS ChargeDetailTaxCode
        ,LineItem.value:CommodityCode:UniqueName::STRING AS CommodityCodeCode
        ,LineItem.value:DeliverTo::STRING AS DeliverTo
        ,LineItem.value:"Description.CommodityCode":UniqueName::NUMBER(38,10) AS DescriptionCommodityCodeCode
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
        ,LineItem.value:"Description.ExtAttributesBitMask"::INTEGER AS DescriptionExtAttributesBitMask
        ,LineItem.value:"Description.ExtendedDescription"::STRING AS DescriptionExtendedDescription
        ,LineItem.value:"Description.IndexContractPrice":ReportingCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceReportingCurrency
        ,LineItem.value:"Description.IndexContractPrice":BaseCurrency::NUMBER(38,10) AS DescriptionIndexContractPriceBaseCurrency
        ,LineItem.value:"Description.IndexContractPrice":Amount::NUMBER(38,10) AS DescriptionIndexContractPriceAmount
        ,LineItem.value:"Description.IndexContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionIndexContractPriceConversionDate
        ,LineItem.value:"Description.IndexContractPrice":Currency:UniqueName::STRING AS DescriptionIndexContractPriceCurrencyCode
        ,LineItem.value:"Description.ItemNumber"::STRING AS DescriptionItemNumber
        ,LineItem.value:"Description.KitUniqueName"::STRING AS DescriptionKitCode
        ,LineItem.value:"Description.Language"::STRING AS DescriptionLanguage
        ,LineItem.value:"Description.LeadTime"::INTEGER AS DescriptionLeadTime
        ,LineItem.value:"Description.LineItem"::STRING AS DescriptionLineItem
        ,LineItem.value:"Description.NonContractPrice":ReportingCurrency::NUMBER(38,10) AS DescriptionNonContractPriceReportingCurrency
        ,LineItem.value:"Description.NonContractPrice":BaseCurrency::NUMBER(38,10) AS DescriptionNonContractPriceBaseCurrency
        ,LineItem.value:"Description.NonContractPrice":Amount::NUMBER(38,10) AS DescriptionNonContractPriceAmount
        ,LineItem.value:"Description.NonContractPrice":ConversionDate::TIMESTAMP_NTZ AS DescriptionNonContractPriceConversionDate
        ,LineItem.value:"Description.NonContractPrice":Currency:UniqueName::STRING AS DescriptionNonContractPriceCurrencyCode
        ,LineItem.value:"Description.Price":ReportingCurrency::NUMBER(38,10) AS DescriptionPriceReportingCurrency
        ,LineItem.value:"Description.Price":BaseCurrency::NUMBER(38,10) AS DescriptionPriceBaseCurrency
        ,LineItem.value:"Description.Price":Amount::NUMBER(38,10) AS DescriptionPriceAmount
        ,LineItem.value:"Description.Price":ConversionDate::TIMESTAMP_NTZ AS DescriptionPriceConversionDate
        ,LineItem.value:"Description.Price":Currency:UniqueName::STRING AS DescriptionPriceCurrencyCode
        ,LineItem.value:"Description.PriceBasisQuantity"::NUMBER(38,10) AS DescriptionPriceBasisQuantity
        ,LineItem.value:"Description.PriceBasisQuantityDesc"::STRING AS DescriptionPriceBasisQuantityDesc
        ,LineItem.value:"Description.PriceBasisQuantityUOM":UniqueName::STRING AS DescriptionPriceBasisQuantityUOMCode
        ,LineItem.value:"Description.QueryID"::STRING AS DescriptionQueryId
        ,LineItem.value:"Description.ShortName"::STRING AS DescriptionShortName
        ,LineItem.value:"Description.SupplierPartAuxiliaryID"::STRING AS DescriptionSupplierPartAuxiliaryId
        ,LineItem.value:"Description.SupplierPartNumber"::STRING AS DescriptionSupplierPartNumber
        ,LineItem.value:"Description.SupplierURL"::STRING AS DescriptionSupplierURL
        ,LineItem.value:"Description.UnitOfMeasure":UniqueName::STRING AS DescriptionUnitOfMeasureCode
        ,LineItem.value:DiscountAmount:ReportingCurrency::NUMBER(38,10) AS DiscountAmountReportingCurrency
        ,LineItem.value:DiscountAmount:BaseCurrency::NUMBER(38,10) AS DiscountAmountBaseCurrency
        ,LineItem.value:DiscountAmount:Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,LineItem.value:DiscountAmount:ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,LineItem.value:DiscountAmount:Currency:UniqueName::STRING AS DiscountAmountCurrencyCode
        ,LineItem.value:DueOn::TIMESTAMP_NTZ AS DueOn
        ,LineItem.value:EndDate::TIMESTAMP_NTZ AS EndDate
        ,LineItem.value:ERPLineItemNumber::STRING AS ERPLineItemNumber
        ,LineItem.value:IncoTermsCode:UniqueName::STRING AS IncoTermsCode
        ,LineItem.value:IncoTermsDetail::STRING AS IncoTermsDetail
        ,LineItem.value:InspectionDate::TIMESTAMP_NTZ AS InspectionDate
        ,LineItem.value:IsAdHoc::BOOLEAN AS IsAdHoc
        ,LineItem.value:LineType:UniqueName::STRING AS LineTypeCode
        ,LineItem.value:MasterAgreement:UniqueName::STRING AS MasterAgreementCode
        ,LineItem.value:NumberBilled::INTEGER AS NumberBilled
        ,LineItem.value:NumberCleared::INTEGER AS NumberCleared
        ,LineItem.value:NumberInCollection::INTEGER AS NumberInCollection
        ,LineItem.value:Order:UniqueName::STRING AS OrderCode
        ,LineItem.value:OrderInfo:TransactionDate::TIMESTAMP_NTZ AS OrderInfoTransactionDate
        ,LineItem.value:OrderInfo:TransactionNumber::STRING AS OrderInfoTransactionNumber
        ,LineItem.value:OriginalPrice:ReportingCurrency::NUMBER(38,10) AS OriginalPriceReportingCurrency
        ,LineItem.value:OriginalPrice:BaseCurrency::NUMBER(38,10) AS OriginalPriceBaseCurrency
        ,LineItem.value:OriginalPrice:Amount::NUMBER(38,10) AS OriginalPriceAmount
        ,LineItem.value:OriginalPrice:ConversionDate::TIMESTAMP_NTZ AS OriginalPriceConversionDate
        ,LineItem.value:OriginalPrice:Currency:UniqueName::STRING AS OriginalPriceCurrencyCode
        ,LineItem.value:OriginatingSystemLineNumber::INTEGER AS OriginatingSystemLineNumber
        ,LineItem.value:PaymentTerms:UniqueName::STRING AS PaymentTermsCode
        ,LineItem.value:Quantity::NUMBER(38,10) AS Quantity
        ,LineItem.value:ReferenceDate::TIMESTAMP_NTZ AS ReferenceDate
        ,LineItem.value:ServiceLocation:City::STRING AS ServiceLocationCity
        ,LineItem.value:ServiceLocation:Country:UniqueName::STRING AS ServiceLocationCountryCode
        ,LineItem.value:ServiceLocation:Fax::STRING AS ServiceLocationFaxNumber
        ,LineItem.value:ServiceLocation:Lines::STRING AS ServiceLocationLines
        ,LineItem.value:ServiceLocation:Name::STRING AS ServiceLocationName
        ,LineItem.value:ServiceLocation:PostalCode::STRING AS ServiceLocationPostalCode
        ,LineItem.value:ServiceLocation:Phone::STRING AS ServiceLocationPhoneNumber
        ,LineItem.value:ServiceLocation:State::STRING AS ServiceLocationState
        ,LineItem.value:ServiceLocation:UniqueName::STRING AS ServiceLocationCode
        ,LineItem.value:ServicePeriodFromDate::TIMESTAMP_NTZ AS ServicePeriodFromDate
        ,LineItem.value:ServicePeriodPeriod::STRING AS ServicePeriodPeriod
        ,LineItem.value:ServicePeriodToDate::TIMESTAMP_NTZ AS ServicePeriodToDate
        ,LineItem.value:ShipFrom:City::STRING AS ShipFromCity
        ,LineItem.value:ShipFrom:Country:UniqueName::STRING AS ShipFromCountryCode
        ,LineItem.value:ShipFrom:FaxNumber::STRING AS ShipFromFaxNumber
        ,LineItem.value:ShipFrom:Name::STRING AS ShipFromName
        ,LineItem.value:ShipFrom:Lines::STRING AS ShipFromLines
        ,LineItem.value:ShipFrom:PhoneNumber::STRING AS ShipFromPhoneNumber
        ,LineItem.value:ShipFrom:PostalCode::STRING AS ShipFromPostalCode
        ,LineItem.value:ShipFrom:State::STRING AS ShipFromState
        ,LineItem.value:ShipFrom:UniqueName::STRING AS ShipFromCode
        ,LineItem.value:ShipTo:City::STRING AS ShipToCity
        ,LineItem.value:ShipTo:Country:UniqueName::STRING AS ShipToCountryCode
        ,LineItem.value:ShipTo:FaxNumber::STRING AS ShipToFaxNumber
        ,LineItem.value:ShipTo:Name::STRING AS ShipToName
        ,LineItem.value:ShipTo:Lines::STRING AS ShipToLines
        ,LineItem.value:ShipTo:PhoneNumber::STRING AS ShipToPhoneNumber
        ,LineItem.value:ShipTo:PostalCode::STRING AS ShipToPostalCode
        ,LineItem.value:ShipTo:State::STRING AS ShipToState
        ,LineItem.value:ShipTo:UniqueName::STRING AS ShipToCode
        ,LineItem.value:StartDate::TIMESTAMP_NTZ AS StartDate
        ,LineItem.value:Statement:UniqueName::STRING AS StatementCode
        ,LineItem.value:"StatementLineItem.InvoiceLineNumber"::INTEGER AS StatementLineItemInvoiceLineNumber
        ,LineItem.value:SupplementInfo:ReferenceDocument:UniqueName::STRING AS SupplementInfoReferenceDocumentCode
        ,LineItem.value:SupplementInfo:ReferenceDocument:Name::STRING AS SupplementInfoReferenceDocumentName
        ,LineItem.value:SupplementInfo:LineNumber::INTEGER AS SupplementInfoLineNumber
        ,LineItem.value:SupplierAccrualTaxAmount:ReportingCurrency::NUMBER(38,10) AS SupplierAccrualTaxAmountReportingCurrency
        ,LineItem.value:SupplierAccrualTaxAmount:BaseCurrency::NUMBER(38,10) AS SupplierAccrualTaxAmountBaseCurrency
        ,LineItem.value:SupplierAccrualTaxAmount:Amount::NUMBER(38,10) AS SupplierAccrualTaxAmountAmount
        ,LineItem.value:SupplierAccrualTaxAmount:ConversionDate::TIMESTAMP_NTZ AS SupplierAccrualTaxAmountConversionDate
        ,LineItem.value:SupplierAccrualTaxAmount:Currency:UniqueName::STRING AS SupplierAccrualTaxAmountCurrencyCode
        ,LineItem.value:TaxAmount:ReportingCurrency::NUMBER(38,10) AS TaxAmountReportingCurrency
        ,LineItem.value:TaxAmount:BaseCurrency::NUMBER(38,10) AS TaxAmountBaseCurrency
        ,LineItem.value:TaxAmount:Amount::NUMBER(38,10) AS TaxAmountAmount
        ,LineItem.value:TaxAmount:ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,LineItem.value:TaxAmount:Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,LineItem.value:TaxCode::STRING AS TaxCode
        ,LineItem.value:VATAmount:ReportingCurrency::NUMBER(38,10) AS VATAmountReportingCurrency
        ,LineItem.value:VATAmount:BaseCurrency::NUMBER(38,10) AS VATAmountBaseCurrency
        ,LineItem.value:VATAmount:Amount::NUMBER(38,10) AS VATAmountAmount
        ,LineItem.value:VATAmount:ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,LineItem.value:VATAmount:Currency:UniqueName::STRING AS VATAmountCurrencyCode
        ,LineItem.value:WHTTaxCode:UniqueName::STRING AS WHTTaxCodeCode
        ,LineItem.value:WithholdingTaxAmount:ReportingCurrency::NUMBER(38,10) AS WithholdingTaxAmountReportingCurrency
        ,LineItem.value:WithholdingTaxAmount:BaseCurrency::NUMBER(38,10) AS WithholdingTaxAmountBaseCurrency
        ,LineItem.value:WithholdingTaxAmount:Amount::NUMBER(38,10) AS WithholdingTaxAmountAmount
        ,LineItem.value:WithholdingTaxAmount:ConversionDate::TIMESTAMP_NTZ AS WithholdingTaxAmountConversionDate
        ,LineItem.value:WithholdingTaxAmount:Currency:UniqueName::STRING AS WithholdingTaxAmountCurrencyCode
        ,LineItem.value:cus_EmployeeNumber::STRING AS CustomField_EmployeeNumber
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        ,LATERAL FLATTEN (input => parse_json(JsonField:LineItems)) LineItem
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
        source_data.INVOICERECONCILIATIONIDKEY AS InvoiceReconciliationIDKey,
        source_data.INVOICERECONCILIATIONVERSIONKEY AS InvoiceReconciliationVersionKey,
        source_data.NUMBERINCOLLECTION AS InvoiceReconciliationLineItemKey,
        source_data.ACCOUNTINGSTYPECODE AS AccountingsTypeCode,
        source_data.ACCRUALTAXAMOUNTREPORTINGCURRENCY AS AccrualTaxAmountReportingCurrency,
        source_data.ACCRUALTAXAMOUNTBASECURRENCY AS AccrualTaxAmountBaseCurrency,
        source_data.ACCRUALTAXAMOUNTAMOUNT AS AccrualTaxAmountAmount,
        source_data.ACCRUALTAXAMOUNTCONVERSIONDATE AS AccrualTaxAmountConversionDate,
        source_data.ACCRUALTAXAMOUNTCURRENCYCODE AS AccrualTaxAmountCurrencyCode,
        source_data.AMOUNTBILLEDREPORTINGCURRENCY AS AmountBilledReportingCurrency,
        source_data.AMOUNTBILLEDBASECURRENCY AS AmountBilledBaseCurrency,
        source_data.AMOUNTBILLEDAMOUNT AS AmountBilledAmount,
        source_data.AMOUNTBILLEDCONVERSIONDATE AS AmountBilledConversionDate,
        source_data.AMOUNTBILLEDCURRENCYCODE AS AmountBilledCurrencyCode,
        source_data.AMOUNTCLEAREDREPORTINGCURRENCY AS AmountClearedReportingCurrency,
        source_data.AMOUNTCLEAREDBASECURRENCY AS AmountClearedBaseCurrency,
        source_data.AMOUNTCLEAREDAMOUNT AS AmountClearedAmount,
        source_data.AMOUNTCLEAREDCONVERSIONDATE AS AmountClearedConversionDate,
        source_data.AMOUNTCLEAREDCURRENCYCODE AS AmountClearedCurrencyCode,
        source_data.AMOUNTINVOICEDREPORTINGCURRENCY AS AmountInvoicedReportingCurrency,
        source_data.AMOUNTINVOICEDBASECURRENCY AS AmountInvoicedBaseCurrency,
        source_data.AMOUNTINVOICEDAMOUNT AS AmountInvoicedAmount,
        source_data.AMOUNTINVOICEDCONVERSIONDATE AS AmountInvoicedConversionDate,
        source_data.AMOUNTINVOICEDCURRENCYCODE AS AmountInvoicedCurrencyCode,
        source_data.BASEPRICEREPORTINGCURRENCY AS BasePriceReportingCurrency,
        source_data.BASEPRICEBASECURRENCY AS BasePriceBaseCurrency,
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
        source_data.BILLINGADDRESSPHONENUMBER AS BillingAddressPhoneNumber,
        source_data.BILLINGADDRESSFAXNUMBER AS BillingAddressFaxNumber,
        source_data.CATEGORY AS Category,
        source_data.CHARGEAMOUNTREPORTINGCURRENCY AS ChargeAmountReportingCurrency,
        source_data.CHARGEAMOUNTBASECURRENCY AS ChargeAmountBaseCurrency,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CHARGEDETAILANCHARGEDESCRIPTION AS ChargeDetailANChargeDescription,
        source_data.CHARGEDETAILANCHARGENAME AS ChargeDetailANChargeName,
        source_data.CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY AS ChargeDetailChargeAmountReportingCurrency,
        source_data.CHARGEDETAILCHARGEAMOUNTBASECURRENCY AS ChargeDetailChargeAmountBaseCurrency,
        source_data.CHARGEDETAILCHARGEAMOUNTAMOUNT AS ChargeDetailChargeAmountAmount,
        source_data.CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE AS ChargeDetailChargeAmountConversionDate,
        source_data.CHARGEDETAILCHARGEAMOUNTCURRENCYCODE AS ChargeDetailChargeAmountCurrencyCode,
        source_data.CHARGEDETAILCHARGETYPECODE AS ChargeDetailChargeTypeCode,
        source_data.CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY AS ChargeDetailTaxAmountReportingCurrency,
        source_data.CHARGEDETAILTAXAMOUNTBASECURRENCY AS ChargeDetailTaxAmountBaseCurrency,
        source_data.CHARGEDETAILTAXAMOUNTAMOUNT AS ChargeDetailTaxAmountAmount,
        source_data.CHARGEDETAILTAXAMOUNTCONVERSIONDATE AS ChargeDetailTaxAmountConversionDate,
        source_data.CHARGEDETAILTAXAMOUNTCURRENCYCODE AS ChargeDetailTaxAmountCurrencyCode,
        source_data.CHARGEDETAILTAXCODE AS ChargeDetailTaxCode,
        source_data.COMMODITYCODECODE AS CommodityCodeCode,
        source_data.DELIVERTO AS DeliverTo,
        source_data.DESCRIPTIONCOMMODITYCODECODE AS DescriptionCommodityCodeCode,
        source_data.DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY AS DescriptionContractPriceReportingCurrency,
        source_data.DESCRIPTIONCONTRACTPRICEBASECURRENCY AS DescriptionContractPriceBaseCurrency,
        source_data.DESCRIPTIONCONTRACTPRICEAMOUNT AS DescriptionContractPriceAmount,
        source_data.DESCRIPTIONCONTRACTPRICECONVERSIONDATE AS DescriptionContractPriceConversionDate,
        source_data.DESCRIPTIONCONTRACTPRICECURRENCYCODE AS DescriptionContractPriceCurrencyCode,
        source_data.DESCRIPTIONCONVERSIONFACTOR AS DescriptionConversionFactor,
        source_data.DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY AS DescriptionCustomPriceReportingCurrency,
        source_data.DESCRIPTIONCUSTOMPRICEBASECURRENCY AS DescriptionCustomPriceBaseCurrency,
        source_data.DESCRIPTIONCUSTOMPRICEAMOUNT AS DescriptionCustomPriceAmount,
        source_data.DESCRIPTIONCUSTOMPRICECONVERSIONDATE AS DescriptionCustomPriceConversionDate,
        source_data.DESCRIPTIONCUSTOMPRICECURRENCYCODE AS DescriptionCustomPriceCurrencyCode,
        source_data.DESCRIPTIONDESCRIPTION AS DescriptionDescription,
        source_data.DESCRIPTIONEXPIRATIONDATE AS DescriptionExpirationDate,
        source_data.DESCRIPTIONEXTATTRIBUTESBITMASK AS DescriptionExtAttributesBitMask,
        source_data.DESCRIPTIONEXTENDEDDESCRIPTION AS DescriptionExtendedDescription,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY AS DescriptionIndexContractPriceReportingCurrency,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY AS DescriptionIndexContractPriceBaseCurrency,
        source_data.DESCRIPTIONINDEXCONTRACTPRICEAMOUNT AS DescriptionIndexContractPriceAmount,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE AS DescriptionIndexContractPriceConversionDate,
        source_data.DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE AS DescriptionIndexContractPriceCurrencyCode,
        source_data.DESCRIPTIONITEMNUMBER AS DescriptionItemNumber,
        source_data.DESCRIPTIONKITCODE AS DescriptionKitCode,
        source_data.DESCRIPTIONLANGUAGE AS DescriptionLanguage,
        source_data.DESCRIPTIONLEADTIME AS DescriptionLeadTime,
        source_data.DESCRIPTIONLINEITEM AS DescriptionLineItem,
        source_data.DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY AS DescriptionNonContractPriceReportingCurrency,
        source_data.DESCRIPTIONNONCONTRACTPRICEBASECURRENCY AS DescriptionNonContractPriceBaseCurrency,
        source_data.DESCRIPTIONNONCONTRACTPRICEAMOUNT AS DescriptionNonContractPriceAmount,
        source_data.DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE AS DescriptionNonContractPriceConversionDate,
        source_data.DESCRIPTIONNONCONTRACTPRICECURRENCYCODE AS DescriptionNonContractPriceCurrencyCode,
        source_data.DESCRIPTIONPRICEREPORTINGCURRENCY AS DescriptionPriceReportingCurrency,
        source_data.DESCRIPTIONPRICEBASECURRENCY AS DescriptionPriceBaseCurrency,
        source_data.DESCRIPTIONPRICEAMOUNT AS DescriptionPriceAmount,
        source_data.DESCRIPTIONPRICECONVERSIONDATE AS DescriptionPriceConversionDate,
        source_data.DESCRIPTIONPRICECURRENCYCODE AS DescriptionPriceCurrencyCode,
        source_data.DESCRIPTIONPRICEBASISQUANTITY AS DescriptionPriceBasisQuantity,
        source_data.DESCRIPTIONPRICEBASISQUANTITYDESC AS DescriptionPriceBasisQuantityDesc,
        source_data.DESCRIPTIONPRICEBASISQUANTITYUOMCODE AS DescriptionPriceBasisQuantityUOMCode,
        source_data.DESCRIPTIONQUERYID AS DescriptionQueryId,
        source_data.DESCRIPTIONSHORTNAME AS DescriptionShortName,
        source_data.DESCRIPTIONSUPPLIERPARTAUXILIARYID AS DescriptionSupplierPartAuxiliaryId,
        source_data.DESCRIPTIONSUPPLIERPARTNUMBER AS DescriptionSupplierPartNumber,
        source_data.DESCRIPTIONSUPPLIERURL AS DescriptionSupplierURL,
        source_data.DESCRIPTIONUNITOFMEASURECODE AS DescriptionUnitOfMeasureCode,
        source_data.DISCOUNTAMOUNTREPORTINGCURRENCY AS DiscountAmountReportingCurrency,
        source_data.DISCOUNTAMOUNTBASECURRENCY AS DiscountAmountBaseCurrency,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DUEON AS DueOn,
        source_data.ENDDATE AS EndDate,
        source_data.ERPLINEITEMNUMBER AS ERPLineItemNumber,
        source_data.INCOTERMSCODE AS IncoTermsCode,
        source_data.INCOTERMSDETAIL AS IncoTermsDetail,
        source_data.INSPECTIONDATE AS InspectionDate,
        source_data.ISADHOC AS IsAdHoc,
        source_data.LINETYPECODE AS LineTypeCode,
        source_data.MASTERAGREEMENTCODE AS MasterAgreementCode,
        source_data.NUMBERBILLED AS NumberBilled,
        source_data.NUMBERCLEARED AS NumberCleared,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.ORDERCODE AS OrderCode,
        source_data.ORDERINFOTRANSACTIONDATE AS OrderInfoTransactionDate,
        source_data.ORDERINFOTRANSACTIONNUMBER AS OrderInfoTransactionNumber,
        source_data.ORIGINALPRICEREPORTINGCURRENCY AS OriginalPriceReportingCurrency,
        source_data.ORIGINALPRICEBASECURRENCY AS OriginalPriceBaseCurrency,
        source_data.ORIGINALPRICEAMOUNT AS OriginalPriceAmount,
        source_data.ORIGINALPRICECONVERSIONDATE AS OriginalPriceConversionDate,
        source_data.ORIGINALPRICECURRENCYCODE AS OriginalPriceCurrencyCode,
        source_data.ORIGINATINGSYSTEMLINENUMBER AS OriginatingSystemLineNumber,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.QUANTITY AS Quantity,
        source_data.REFERENCEDATE AS ReferenceDate,
        source_data.SERVICELOCATIONCODE AS ServiceLocationCode,
        source_data.SERVICELOCATIONNAME AS ServiceLocationName,
        source_data.SERVICELOCATIONLINES AS ServiceLocationLines,
        source_data.SERVICELOCATIONCITY AS ServiceLocationCity,
        source_data.SERVICELOCATIONSTATE AS ServiceLocationState,
        source_data.SERVICELOCATIONPOSTALCODE AS ServiceLocationPostalCode,
        source_data.SERVICELOCATIONCOUNTRYCODE AS ServiceLocationCountryCode,
        source_data.SERVICELOCATIONPHONENUMBER AS ServiceLocationPhoneNumber,
        source_data.SERVICELOCATIONFAXNUMBER AS ServiceLocationFaxNumber,
        source_data.SERVICEPERIODFROMDATE AS ServicePeriodFromDate,
        source_data.SERVICEPERIODPERIOD AS ServicePeriodPeriod,
        source_data.SERVICEPERIODTODATE AS ServicePeriodToDate,
        source_data.SHIPFROMCODE AS ShipFromCode,
        source_data.SHIPFROMNAME AS ShipFromName,
        source_data.SHIPFROMLINES AS ShipFromLines,
        source_data.SHIPFROMCITY AS ShipFromCity,
        source_data.SHIPFROMSTATE AS ShipFromState,
        source_data.SHIPFROMPOSTALCODE AS ShipFromPostalCode,
        source_data.SHIPFROMCOUNTRYCODE AS ShipFromCountryCode,
        source_data.SHIPFROMPHONENUMBER AS ShipFromPhoneNumber,
        source_data.SHIPFROMFAXNUMBER AS ShipFromFaxNumber,
        source_data.SHIPTOCODE AS ShipToCode,
        source_data.SHIPTONAME AS ShipToName,
        source_data.SHIPTOLINES AS ShipToLines,
        source_data.SHIPTOCITY AS ShipToCity,
        source_data.SHIPTOSTATE AS ShipToState,
        source_data.SHIPTOPOSTALCODE AS ShipToPostalCode,
        source_data.SHIPTOCOUNTRYCODE AS ShipToCountryCode,
        source_data.SHIPTOPHONENUMBER AS ShipToPhoneNumber,
        source_data.SHIPTOFAXNUMBER AS ShipToFaxNumber,
        source_data.STARTDATE AS StartDate,
        source_data.STATEMENTCODE AS StatementCode,
        source_data.STATEMENTLINEITEMINVOICELINENUMBER AS StatementLineItemInvoiceLineNumber,
        source_data.SUPPLEMENTINFOREFERENCEDOCUMENTCODE AS SupplementInfoReferenceDocumentCode,
        source_data.SUPPLEMENTINFOREFERENCEDOCUMENTNAME AS SupplementInfoReferenceDocumentName,
        source_data.SUPPLEMENTINFOLINENUMBER AS SupplementInfoLineNumber,
        source_data.SUPPLIERACCRUALTAXAMOUNTREPORTINGCURRENCY AS SupplierAccrualTaxAmountReportingCurrency,
        source_data.SUPPLIERACCRUALTAXAMOUNTBASECURRENCY AS SupplierAccrualTaxAmountBaseCurrency,
        source_data.SUPPLIERACCRUALTAXAMOUNTAMOUNT AS SupplierAccrualTaxAmountAmount,
        source_data.SUPPLIERACCRUALTAXAMOUNTCONVERSIONDATE AS SupplierAccrualTaxAmountConversionDate,
        source_data.SUPPLIERACCRUALTAXAMOUNTCURRENCYCODE AS SupplierAccrualTaxAmountCurrencyCode,
        source_data.TAXAMOUNTREPORTINGCURRENCY AS TaxAmountReportingCurrency,
        source_data.TAXAMOUNTBASECURRENCY AS TaxAmountBaseCurrency,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXCODE AS TaxCode,
        source_data.VATAMOUNTREPORTINGCURRENCY AS VATAmountReportingCurrency,
        source_data.VATAMOUNTBASECURRENCY AS VATAmountBaseCurrency,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.WHTTAXCODECODE AS WHTTaxCodeCode,
        source_data.WITHHOLDINGTAXAMOUNTREPORTINGCURRENCY AS WithholdingTaxAmountReportingCurrency,
        source_data.WITHHOLDINGTAXAMOUNTBASECURRENCY AS WithholdingTaxAmountBaseCurrency,
        source_data.WITHHOLDINGTAXAMOUNTAMOUNT AS WithholdingTaxAmountAmount,
        source_data.WITHHOLDINGTAXAMOUNTCONVERSIONDATE AS WithholdingTaxAmountConversionDate,
        source_data.WITHHOLDINGTAXAMOUNTCURRENCYCODE AS WithholdingTaxAmountCurrencyCode,
        RIGHT ( '00000' || source_data.CUSTOMFIELD_EMPLOYEENUMBER , 6 ) AS CustomField_EmployeeNumber,
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
        cast(ACCOUNTINGSTYPECODE as VARCHAR(16777216)) as ACCOUNTINGSTYPECODE,
        cast(ACCRUALTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as ACCRUALTAXAMOUNTREPORTINGCURRENCY,
        cast(ACCRUALTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as ACCRUALTAXAMOUNTBASECURRENCY,
        cast(ACCRUALTAXAMOUNTAMOUNT as NUMBER(38,10)) as ACCRUALTAXAMOUNTAMOUNT,
        cast(ACCRUALTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as ACCRUALTAXAMOUNTCONVERSIONDATE,
        cast(ACCRUALTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as ACCRUALTAXAMOUNTCURRENCYCODE,
        cast(AMOUNTBILLEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTBILLEDREPORTINGCURRENCY,
        cast(AMOUNTBILLEDBASECURRENCY as NUMBER(38,10)) as AMOUNTBILLEDBASECURRENCY,
        cast(AMOUNTBILLEDAMOUNT as NUMBER(38,10)) as AMOUNTBILLEDAMOUNT,
        cast(AMOUNTBILLEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTBILLEDCONVERSIONDATE,
        cast(AMOUNTBILLEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTBILLEDCURRENCYCODE,
        cast(AMOUNTCLEAREDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDREPORTINGCURRENCY,
        cast(AMOUNTCLEAREDBASECURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDBASECURRENCY,
        cast(AMOUNTCLEAREDAMOUNT as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNT,
        cast(AMOUNTCLEAREDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCLEAREDCONVERSIONDATE,
        cast(AMOUNTCLEAREDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCLEAREDCURRENCYCODE,
        cast(AMOUNTINVOICEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDREPORTINGCURRENCY,
        cast(AMOUNTINVOICEDBASECURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDBASECURRENCY,
        cast(AMOUNTINVOICEDAMOUNT as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNT,
        cast(AMOUNTINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTINVOICEDCONVERSIONDATE,
        cast(AMOUNTINVOICEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTINVOICEDCURRENCYCODE,
        cast(BASEPRICEREPORTINGCURRENCY as NUMBER(38,10)) as BASEPRICEREPORTINGCURRENCY,
        cast(BASEPRICEBASECURRENCY as NUMBER(38,10)) as BASEPRICEBASECURRENCY,
        cast(BASEPRICEAMOUNT as NUMBER(38,10)) as BASEPRICEAMOUNT,
        cast(BASEPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as BASEPRICECONVERSIONDATE,
        cast(BASEPRICECURRENCYCODE as VARCHAR(16777216)) as BASEPRICECURRENCYCODE,
        cast(BILLINGADDRESSCODE as VARCHAR(16777216)) as BILLINGADDRESSCODE,
        cast(BILLINGADDRESSNAME as VARCHAR(16777216)) as BILLINGADDRESSNAME,
        cast(BILLINGADDRESSLINES as VARCHAR(16777216)) as BILLINGADDRESSLINES,
        cast(BILLINGADDRESSCITY as VARCHAR(16777216)) as BILLINGADDRESSCITY,
        cast(BILLINGADDRESSSTATE as VARCHAR(16777216)) as BILLINGADDRESSSTATE,
        cast(BILLINGADDRESSPOSTALCODE as VARCHAR(16777216)) as BILLINGADDRESSPOSTALCODE,
        cast(BILLINGADDRESSCOUNTRYCODE as VARCHAR(16777216)) as BILLINGADDRESSCOUNTRYCODE,
        cast(BILLINGADDRESSPHONENUMBER as VARCHAR(16777216)) as BILLINGADDRESSPHONENUMBER,
        cast(BILLINGADDRESSFAXNUMBER as VARCHAR(16777216)) as BILLINGADDRESSFAXNUMBER,
        cast(CATEGORY as NUMBER(38,0)) as CATEGORY,
        cast(CHARGEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTREPORTINGCURRENCY,
        cast(CHARGEAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTBASECURRENCY,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILANCHARGEDESCRIPTION as VARCHAR(16777216)) as CHARGEDETAILANCHARGEDESCRIPTION,
        cast(CHARGEDETAILANCHARGENAME as VARCHAR(16777216)) as CHARGEDETAILANCHARGENAME,
        cast(CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTREPORTINGCURRENCY,
        cast(CHARGEDETAILCHARGEAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTBASECURRENCY,
        cast(CHARGEDETAILCHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEDETAILCHARGEAMOUNTAMOUNT,
        cast(CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILCHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILCHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEDETAILCHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILCHARGETYPECODE as VARCHAR(16777216)) as CHARGEDETAILCHARGETYPECODE,
        cast(CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTREPORTINGCURRENCY,
        cast(CHARGEDETAILTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTBASECURRENCY,
        cast(CHARGEDETAILTAXAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEDETAILTAXAMOUNTAMOUNT,
        cast(CHARGEDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEDETAILTAXAMOUNTCONVERSIONDATE,
        cast(CHARGEDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEDETAILTAXAMOUNTCURRENCYCODE,
        cast(CHARGEDETAILTAXCODE as VARCHAR(16777216)) as CHARGEDETAILTAXCODE,
        cast(COMMODITYCODECODE as VARCHAR(16777216)) as COMMODITYCODECODE,
        cast(DELIVERTO as VARCHAR(16777216)) as DELIVERTO,
        cast(DESCRIPTIONCOMMODITYCODECODE as VARCHAR(16777216)) as DESCRIPTIONCOMMODITYCODECODE,
        cast(DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONCONVERSIONFACTOR as NUMBER(38,10)) as DESCRIPTIONCONVERSIONFACTOR,
        cast(DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONCUSTOMPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEBASECURRENCY,
        cast(DESCRIPTIONCUSTOMPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONCUSTOMPRICEAMOUNT,
        cast(DESCRIPTIONCUSTOMPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONCUSTOMPRICECONVERSIONDATE,
        cast(DESCRIPTIONCUSTOMPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONCUSTOMPRICECURRENCYCODE,
        cast(DESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONDESCRIPTION,
        cast(DESCRIPTIONEXPIRATIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONEXPIRATIONDATE,
        cast(DESCRIPTIONEXTATTRIBUTESBITMASK as NUMBER(38,0)) as DESCRIPTIONEXTATTRIBUTESBITMASK,
        cast(DESCRIPTIONEXTENDEDDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONEXTENDEDDESCRIPTION,
        cast(DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONINDEXCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONINDEXCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONINDEXCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONINDEXCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONITEMNUMBER as VARCHAR(16777216)) as DESCRIPTIONITEMNUMBER,
        cast(DESCRIPTIONKITCODE as VARCHAR(16777216)) as DESCRIPTIONKITCODE,
        cast(DESCRIPTIONLANGUAGE as VARCHAR(16777216)) as DESCRIPTIONLANGUAGE,
        cast(DESCRIPTIONLEADTIME as NUMBER(38,0)) as DESCRIPTIONLEADTIME,
        cast(DESCRIPTIONLINEITEM as VARCHAR(16777216)) as DESCRIPTIONLINEITEM,
        cast(DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONNONCONTRACTPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEBASECURRENCY,
        cast(DESCRIPTIONNONCONTRACTPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONNONCONTRACTPRICEAMOUNT,
        cast(DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONNONCONTRACTPRICECONVERSIONDATE,
        cast(DESCRIPTIONNONCONTRACTPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONNONCONTRACTPRICECURRENCYCODE,
        cast(DESCRIPTIONPRICEREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEREPORTINGCURRENCY,
        cast(DESCRIPTIONPRICEBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEBASECURRENCY,
        cast(DESCRIPTIONPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONPRICEAMOUNT,
        cast(DESCRIPTIONPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONPRICECONVERSIONDATE,
        cast(DESCRIPTIONPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONPRICECURRENCYCODE,
        cast(DESCRIPTIONPRICEBASISQUANTITY as NUMBER(38,10)) as DESCRIPTIONPRICEBASISQUANTITY,
        cast(DESCRIPTIONPRICEBASISQUANTITYDESC as VARCHAR(16777216)) as DESCRIPTIONPRICEBASISQUANTITYDESC,
        cast(DESCRIPTIONPRICEBASISQUANTITYUOMCODE as VARCHAR(16777216)) as DESCRIPTIONPRICEBASISQUANTITYUOMCODE,
        cast(DESCRIPTIONQUERYID as VARCHAR(16777216)) as DESCRIPTIONQUERYID,
        cast(DESCRIPTIONSHORTNAME as VARCHAR(16777216)) as DESCRIPTIONSHORTNAME,
        cast(DESCRIPTIONSUPPLIERPARTAUXILIARYID as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTAUXILIARYID,
        cast(DESCRIPTIONSUPPLIERPARTNUMBER as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTNUMBER,
        cast(DESCRIPTIONSUPPLIERURL as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERURL,
        cast(DESCRIPTIONUNITOFMEASURECODE as VARCHAR(16777216)) as DESCRIPTIONUNITOFMEASURECODE,
        cast(DISCOUNTAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTREPORTINGCURRENCY,
        cast(DISCOUNTAMOUNTBASECURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTBASECURRENCY,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777216)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DUEON as TIMESTAMP_NTZ(9)) as DUEON,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(ERPLINEITEMNUMBER as VARCHAR(16777216)) as ERPLINEITEMNUMBER,
        cast(INCOTERMSCODE as VARCHAR(16777216)) as INCOTERMSCODE,
        cast(INCOTERMSDETAIL as VARCHAR(16777216)) as INCOTERMSDETAIL,
        cast(INSPECTIONDATE as TIMESTAMP_NTZ(9)) as INSPECTIONDATE,
        cast(ISADHOC as BOOLEAN) as ISADHOC,
        cast(LINETYPECODE as VARCHAR(16777216)) as LINETYPECODE,
        cast(MASTERAGREEMENTCODE as VARCHAR(16777216)) as MASTERAGREEMENTCODE,
        cast(NUMBERBILLED as NUMBER(38,0)) as NUMBERBILLED,
        cast(NUMBERCLEARED as NUMBER(38,0)) as NUMBERCLEARED,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(ORDERCODE as VARCHAR(16777216)) as ORDERCODE,
        cast(ORDERINFOTRANSACTIONDATE as TIMESTAMP_NTZ(9)) as ORDERINFOTRANSACTIONDATE,
        cast(ORDERINFOTRANSACTIONNUMBER as VARCHAR(16777216)) as ORDERINFOTRANSACTIONNUMBER,
        cast(ORIGINALPRICEREPORTINGCURRENCY as NUMBER(38,10)) as ORIGINALPRICEREPORTINGCURRENCY,
        cast(ORIGINALPRICEBASECURRENCY as NUMBER(38,10)) as ORIGINALPRICEBASECURRENCY,
        cast(ORIGINALPRICEAMOUNT as NUMBER(38,10)) as ORIGINALPRICEAMOUNT,
        cast(ORIGINALPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as ORIGINALPRICECONVERSIONDATE,
        cast(ORIGINALPRICECURRENCYCODE as VARCHAR(16777216)) as ORIGINALPRICECURRENCYCODE,
        cast(ORIGINATINGSYSTEMLINENUMBER as NUMBER(38,0)) as ORIGINATINGSYSTEMLINENUMBER,
        cast(PAYMENTTERMSCODE as VARCHAR(16777216)) as PAYMENTTERMSCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(REFERENCEDATE as TIMESTAMP_NTZ(9)) as REFERENCEDATE,
        cast(SERVICELOCATIONCODE as VARCHAR(16777216)) as SERVICELOCATIONCODE,
        cast(SERVICELOCATIONNAME as VARCHAR(16777216)) as SERVICELOCATIONNAME,
        cast(SERVICELOCATIONLINES as VARCHAR(16777216)) as SERVICELOCATIONLINES,
        cast(SERVICELOCATIONCITY as VARCHAR(16777216)) as SERVICELOCATIONCITY,
        cast(SERVICELOCATIONSTATE as VARCHAR(16777216)) as SERVICELOCATIONSTATE,
        cast(SERVICELOCATIONPOSTALCODE as VARCHAR(16777216)) as SERVICELOCATIONPOSTALCODE,
        cast(SERVICELOCATIONCOUNTRYCODE as VARCHAR(16777216)) as SERVICELOCATIONCOUNTRYCODE,
        cast(SERVICELOCATIONPHONENUMBER as VARCHAR(16777216)) as SERVICELOCATIONPHONENUMBER,
        cast(SERVICELOCATIONFAXNUMBER as VARCHAR(16777216)) as SERVICELOCATIONFAXNUMBER,
        cast(SERVICEPERIODFROMDATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODFROMDATE,
        cast(SERVICEPERIODPERIOD as VARCHAR(16777216)) as SERVICEPERIODPERIOD,
        cast(SERVICEPERIODTODATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODTODATE,
        cast(SHIPFROMCODE as VARCHAR(16777216)) as SHIPFROMCODE,
        cast(SHIPFROMNAME as VARCHAR(16777216)) as SHIPFROMNAME,
        cast(SHIPFROMLINES as VARCHAR(16777216)) as SHIPFROMLINES,
        cast(SHIPFROMCITY as VARCHAR(16777216)) as SHIPFROMCITY,
        cast(SHIPFROMSTATE as VARCHAR(16777216)) as SHIPFROMSTATE,
        cast(SHIPFROMPOSTALCODE as VARCHAR(16777216)) as SHIPFROMPOSTALCODE,
        cast(SHIPFROMCOUNTRYCODE as VARCHAR(16777216)) as SHIPFROMCOUNTRYCODE,
        cast(SHIPFROMPHONENUMBER as VARCHAR(16777216)) as SHIPFROMPHONENUMBER,
        cast(SHIPFROMFAXNUMBER as VARCHAR(16777216)) as SHIPFROMFAXNUMBER,
        cast(SHIPTOCODE as VARCHAR(16777216)) as SHIPTOCODE,
        cast(SHIPTONAME as VARCHAR(16777216)) as SHIPTONAME,
        cast(SHIPTOLINES as VARCHAR(16777216)) as SHIPTOLINES,
        cast(SHIPTOCITY as VARCHAR(16777216)) as SHIPTOCITY,
        cast(SHIPTOSTATE as VARCHAR(16777216)) as SHIPTOSTATE,
        cast(SHIPTOPOSTALCODE as VARCHAR(16777216)) as SHIPTOPOSTALCODE,
        cast(SHIPTOCOUNTRYCODE as VARCHAR(16777216)) as SHIPTOCOUNTRYCODE,
        cast(SHIPTOPHONENUMBER as VARCHAR(16777216)) as SHIPTOPHONENUMBER,
        cast(SHIPTOFAXNUMBER as VARCHAR(16777216)) as SHIPTOFAXNUMBER,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(STATEMENTCODE as VARCHAR(16777216)) as STATEMENTCODE,
        cast(STATEMENTLINEITEMINVOICELINENUMBER as NUMBER(38,0)) as STATEMENTLINEITEMINVOICELINENUMBER,
        cast(SUPPLEMENTINFOREFERENCEDOCUMENTCODE as VARCHAR(16777216)) as SUPPLEMENTINFOREFERENCEDOCUMENTCODE,
        cast(SUPPLEMENTINFOREFERENCEDOCUMENTNAME as VARCHAR(16777216)) as SUPPLEMENTINFOREFERENCEDOCUMENTNAME,
        cast(SUPPLEMENTINFOLINENUMBER as NUMBER(38,0)) as SUPPLEMENTINFOLINENUMBER,
        cast(SUPPLIERACCRUALTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as SUPPLIERACCRUALTAXAMOUNTREPORTINGCURRENCY,
        cast(SUPPLIERACCRUALTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as SUPPLIERACCRUALTAXAMOUNTBASECURRENCY,
        cast(SUPPLIERACCRUALTAXAMOUNTAMOUNT as NUMBER(38,10)) as SUPPLIERACCRUALTAXAMOUNTAMOUNT,
        cast(SUPPLIERACCRUALTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SUPPLIERACCRUALTAXAMOUNTCONVERSIONDATE,
        cast(SUPPLIERACCRUALTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as SUPPLIERACCRUALTAXAMOUNTCURRENCYCODE,
        cast(TAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTREPORTINGCURRENCY,
        cast(TAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTBASECURRENCY,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXCODE as VARCHAR(16777216)) as TAXCODE,
        cast(VATAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTREPORTINGCURRENCY,
        cast(VATAMOUNTBASECURRENCY as NUMBER(38,10)) as VATAMOUNTBASECURRENCY,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(WHTTAXCODECODE as VARCHAR(16777216)) as WHTTAXCODECODE,
        cast(WITHHOLDINGTAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as WITHHOLDINGTAXAMOUNTREPORTINGCURRENCY,
        cast(WITHHOLDINGTAXAMOUNTBASECURRENCY as NUMBER(38,10)) as WITHHOLDINGTAXAMOUNTBASECURRENCY,
        cast(WITHHOLDINGTAXAMOUNTAMOUNT as NUMBER(38,10)) as WITHHOLDINGTAXAMOUNTAMOUNT,
        cast(WITHHOLDINGTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as WITHHOLDINGTAXAMOUNTCONVERSIONDATE,
        cast(WITHHOLDINGTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as WITHHOLDINGTAXAMOUNTCURRENCYCODE,
        cast(CUSTOMFIELD_EMPLOYEENUMBER as VARCHAR(16777216)) as CUSTOMFIELD_EMPLOYEENUMBER,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data