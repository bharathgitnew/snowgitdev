
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PurchaseOrderLineItem',
    unique_key = ['RealmName',
    'PurchaseOrderIdKey',
    'PurchaseOrderVersionKey',
    'PurchaseOrderLineItemKey']
) }}

with source_data_Direct as
(
    SELECT _FILENAME, _FILEDATE, _UPLOADDATE, JSONFIELD FROM {{ source("ARIBA", "DIRECTORDER") }}
)
, source_data_ERP as
(
    SELECT _FILENAME, _FILEDATE, _UPLOADDATE, JSONFIELD FROM {{ source("ARIBA", "ERPORDER") }}
)
, source_data_FULL as
(
    SELECT _FILENAME, _FILEDATE, _UPLOADDATE, JSONFIELD FROM source_data_Direct
    UNION ALL
    SELECT _FILENAME, _FILEDATE, _UPLOADDATE, JSONFIELD FROM source_data_ERP
)
, source_data as
(
    SELECT
        JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FILENAME, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS PurchaseOrderIdKey
        ,JsonField:Version::INTEGER AS PurchaseOrderVersionKey
        ,LineItem.value:Amount:Amount::NUMBER(38,10) AS AmountAmount
        ,LineItem.value:Amount:AmountInReportingCurrency::NUMBER(38,10) AS AmountAmountInReportingCurrency
        ,LineItem.value:Amount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountApproxAmountInBaseCurrency
        ,LineItem.value:Amount:ConversionDate::TIMESTAMP_NTZ AS AmountConversionDate
        ,LineItem.value:Amount:Currency:UniqueName::STRING AS AmountCurrencyCode
        ,LineItem.value:BasePrice:Amount::NUMBER(38,10) AS BasePriceAmount
        ,LineItem.value:BasePrice:AmountInReportingCurrency::NUMBER(38,10) AS BasePriceAmountInReportingCurrency
        ,LineItem.value:BasePrice:ApproxAmountInBaseCurrency::NUMBER(38,10) AS BasePriceApproxAmountInBaseCurrency
        ,LineItem.value:BasePrice:ConversionDate::TIMESTAMP_NTZ AS BasePriceConversionDate
        ,LineItem.value:BasePrice:Currency:UniqueName::STRING AS BasePriceCurrencyCode
        ,LineItem.value:BillingAddress:City::STRING AS BillingAddressCity
        ,LineItem.value:BillingAddress:Country:UniqueName::STRING AS BillingAddressCountryCode
        ,LineItem.value:BillingAddress:FaxNumber::STRING AS BillingAddressFax
        ,LineItem.value:BillingAddress:Lines::STRING AS BillingAddressLines
        ,LineItem.value:BillingAddress:Name::STRING AS BillingAddressName
        ,LineItem.value:BillingAddress:Phone::STRING AS BillingAddressPhone
        ,LineItem.value:BillingAddress:PostalCode::STRING AS BillingAddressPostalCode
        ,LineItem.value:BillingAddress:State::STRING AS BillingAddressState
        ,LineItem.value:BillingAddress:UniqueName::STRING AS BillingAddressCode
        ,LineItem.value:BoughtFromPreferredSupplier::STRING AS BoughtFromPreferredSupplier
        ,LineItem.value:Carrier::STRING AS Carrier
        ,LineItem.value:CarrierMethod::STRING AS CarrierMethod
        ,LineItem.value:ChargeAmountAmount::NUMBER(38,10) AS ChargeAmountAmount
        ,LineItem.value:ChargeAmountAmountInReportingCurrency::NUMBER(38,10) AS ChargeAmountAmountInReportingCurrency
        ,LineItem.value:ChargeAmountApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeAmountApproxAmountInBaseCurrency
        ,LineItem.value:ChargeAmountConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,LineItem.value:ChargeAmountCurrency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,LineItem.value:Closed::STRING AS Closed
        ,LineItem.value:CommodityCode:UniqueName::STRING AS CommodityCodeCode
        ,LineItem.value:DeliverTo::STRING AS DeliverTo
        ,LineItem.value:"Description.CommonCommodityCode":Name::STRING AS DescriptionCommonCommodityCodeName
        ,LineItem.value:"Description.CommonCommodityCode":UniqueName::STRING AS DescriptionCommonCommodityCodeCode
        ,LineItem.value:"Description.Description"::STRING AS DescriptionDescription
        ,LineItem.value:"Description.ExtendedDescription"::STRING AS DescriptionExtendedDescription
        ,LineItem.value:"Description.ManName"::STRING AS DescriptionManName
        ,LineItem.value:"Description.ManPartNumber"::STRING AS DescriptionManPartNumber
        ,LineItem.value:"Description.Price":Amount::NUMBER(38,10) AS DescriptionPriceAmount
        ,LineItem.value:"Description.Price":AmountInReportingCurrency::NUMBER(38,10) AS DescriptionPriceAmountInReportingCurrency
        ,LineItem.value:"Description.Price":ApproxAmountInBaseCurrency::NUMBER(38,10) AS DescriptionPriceApproxAmountInBaseCurrency
        ,LineItem.value:"Description.Price":ConversionDate::TIMESTAMP_NTZ AS DescriptionPriceConversionDate
        ,LineItem.value:"Description.Price":Currency:UniqueName::STRING AS DescriptionPriceCurrencyCode
        ,LineItem.value:"Description.SupplierPartAuxiliaryId"::STRING AS DescriptionSupplierPartAuxiliaryId
        ,LineItem.value:"Description.SupplierPartNumber"::STRING AS DescriptionSupplierPartNumber
        ,LineItem.value:"Description.UnitOfMeasure":UniqueName::STRING AS DescriptionUnitOfMeasureCode
        ,LineItem.value:DiscountAmount:Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,LineItem.value:DiscountAmount:AmountInReportingCurrency::NUMBER(38,10) AS DiscountAmountAmountInReportingCurrency
        ,LineItem.value:DiscountAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS DiscountAmountApproxAmountInBaseCurrency
        ,LineItem.value:DiscountAmount:ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,LineItem.value:DiscountAmount:Currency:UniqueName::STRING AS DiscountAmountCurrencyCode
        ,LineItem.value:DueOn::TIMESTAMP_NTZ AS DueOn
        ,LineItem.value:EndDate::TIMESTAMP_NTZ AS EndDate
        ,LineItem.value:ERSAllowed::STRING AS ERSAllowed
        ,LineItem.value:IsAdHoc::STRING AS IsAdHoc
        ,LineItem.value:IsPriceModifiedByUser::STRING AS IsPriceModifiedByUser
        ,LineItem.value:IsRecurring::STRING AS IsRecurring
        ,LineItem.value:ItemMasterId:BuyerPartNumber::STRING AS ItemMasterIdBuyerPartNumber
        ,LineItem.value:ItemMasterId:Facility::STRING AS ItemMasterIdFacility
        ,LineItem.value:LineConfirmationStatus::STRING AS LineConfirmationStatus
        ,LineItem.value:LineType:UniqueName::STRING AS LineTypeCode
        ,LineItem.value:MasterAgreement:UniqueName::STRING AS MasterAgreementCode
        ,LineItem.value:NeedBy::TIMESTAMP_NTZ AS NeedBy
        ,LineItem.value:NumberConfirmedAccepted::NUMBER(38,10) AS NumberConfirmedAccepted
        ,LineItem.value:NumberConfirmedAcceptedWithChanges::NUMBER(38,10) AS NumberConfirmedAcceptedWithChanges
        ,LineItem.value:NumberConfirmedBackOrdered::NUMBER(38,10) AS NumberConfirmedBackOrdered
        ,LineItem.value:NumberConfirmedRejected::NUMBER(38,10) AS NumberConfirmedRejected
        ,LineItem.value:NumberConfirmedSubstituted::NUMBER(38,10) AS NumberConfirmedSubstituted
        ,LineItem.value:NumberInCollection::INTEGER AS NumberInCollection
        ,LineItem.value:NumberOnReq::INTEGER AS NumberOnReq
        ,LineItem.value:NumberShipped::NUMBER(38,10) AS NumberShipped
        ,LineItem.value:OrderId::STRING AS OrderId
        ,LineItem.value:OrderMethodCategory::STRING AS OrderMethodCategory
        ,LineItem.value:OrderedDate::TIMESTAMP_NTZ AS OrderedDate
        ,LineItem.value:OriginalPrice:Amount::NUMBER(38,10) AS OriginalPriceAmount
        ,LineItem.value:OriginalPrice:AmountInReportingCurrency::NUMBER(38,10) AS OriginalPriceAmountInReportingCurrency
        ,LineItem.value:OriginalPrice:ApproxAmountInBaseCurrency::NUMBER(38,10) AS OriginalPriceApproxAmountInBaseCurrency
        ,LineItem.value:OriginalPrice:ConversionDate::TIMESTAMP_NTZ AS OriginalPriceConversionDate
        ,LineItem.value:OriginalPrice:Currency:UniqueName::STRING AS OriginalPriceCurrencyCode
        ,LineItem.value:PaymentTerms:UniqueName::STRING AS PaymentTermsCode
        ,LineItem.value:Quantity::NUMBER(38,10) AS Quantity
        ,LineItem.value:Requisition:UniqueName::STRING AS RequisitionCode
        ,LineItem.value:ServiceAmountApproved:Amount::NUMBER(38,10) AS ServiceAmountApprovedAmount
        ,LineItem.value:ServiceAmountApproved:AmountInReportingCurrency::NUMBER(38,10) AS ServiceAmountApprovedAmountInReportingCurrency
        ,LineItem.value:ServiceAmountApproved:ApproxAmountInBaseCurrency::NUMBER(38,10) AS ServiceAmountApprovedApproxAmountInBaseCurrency
        ,LineItem.value:ServiceAmountApproved:ConversionDate::TIMESTAMP_NTZ AS ServiceAmountApprovedConversionDate
        ,LineItem.value:ServiceAmountApproved:Currency:UniqueName::STRING AS ServiceAmountApprovedCurrencyCode
        ,LineItem.value:ServiceAmountUnderApproval:Amount::NUMBER(38,10) AS ServiceAmountUnderApprovalAmount
        ,LineItem.value:ServiceAmountUnderApproval:AmountInReportingCurrency::NUMBER(38,10) AS ServiceAmountUnderApprovalAmountInReportingCurrency
        ,LineItem.value:ServiceAmountUnderApproval:ApproxAmountInBaseCurrency::NUMBER(38,10) AS ServiceAmountUnderApprovalApproxAmountInBaseCurrency
        ,LineItem.value:ServiceAmountUnderApproval:ConversionDate::TIMESTAMP_NTZ AS ServiceAmountUnderApprovalConversionDate
        ,LineItem.value:ServiceAmountUnderApproval:Currency:UniqueName::STRING AS ServiceAmountUnderApprovalCurrencyCode
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
        ,LineItem.value:"ServiceDetails.RequiresServiceEntry"::STRING AS ServiceDetailsRequiresServiceEntry
        ,LineItem.value:"ServiceDetails.ServiceEndDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceEndDate
        ,LineItem.value:"ServiceDetails.ServiceLine"::STRING AS ServiceDetailsServiceLine
        ,LineItem.value:"ServiceDetails.ServiceStartDate"::TIMESTAMP_NTZ AS ServiceDetailsServiceStartDate
        ,LineItem.value:ShipTo:City::STRING AS ShipToCity
        ,LineItem.value:ShipTo:Country:UniqueName::STRING AS ShipToCountryCode
        ,LineItem.value:ShipTo:FaxNumber::STRING AS ShipToFax
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
        ,LineItem.value:TaxAmount:Amount::NUMBER(38,10) AS TaxAmountAmount
        ,LineItem.value:TaxAmount:AmountInReportingCurrency::NUMBER(38,10) AS TaxAmountAmountInReportingCurrency
        ,LineItem.value:TaxAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxAmountApproxAmountInBaseCurrency
        ,LineItem.value:TaxAmount:ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,LineItem.value:TaxAmount:Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,LineItem.value:TaxCode:UniqueName::STRING AS TaxCodeCode
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
        ,LineItem.value:"TaxDetail.IsDeductible"::STRING AS TaxDetailIsDeductible
        ,LineItem.value:"TaxDetail.IsTriangularTransaction"::STRING AS TaxDetailIsTriangularTransaction
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
        ,LineItem.value:"TaxDetail.TriangularTransaction":LawReference::STRING AS TaxDetailTriangularTransactionLawReference
        ,LineItem.value:VATAmount:Amount::NUMBER(38,10) AS VATAmountAmount
        ,LineItem.value:VATAmount:AmountInReportingCurrency::NUMBER(38,10) AS VATAmountAmountInReportingCurrency
        ,LineItem.value:VATAmount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS VATAmountApproxAmountInBaseCurrency
        ,LineItem.value:VATAmount:ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,LineItem.value:VATAmount:Currency:UniqueName::STRING AS VATAmountCurrencyCode
        FROM source_data_FULL LZData
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
        source_data.PurchaseOrderIDKEY AS PurchaseOrderIdKey,
        source_data.PurchaseOrderVERSIONKEY AS PurchaseOrderVersionKey,
        source_data.NUMBERINCOLLECTION AS PurchaseOrderLineItemKey,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTAMOUNTINREPORTINGCURRENCY AS AmountAmountInReportingCurrency,
        source_data.AMOUNTAPPROXAMOUNTINBASECURRENCY AS AmountApproxAmountInBaseCurrency,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.BASEPRICEAMOUNT AS BasePriceAmount,
        source_data.BASEPRICEAMOUNTINREPORTINGCURRENCY AS BasePriceAmountInReportingCurrency,
        source_data.BASEPRICEAPPROXAMOUNTINBASECURRENCY AS BasePriceApproxAmountInBaseCurrency,
        source_data.BASEPRICECONVERSIONDATE AS BasePriceConversionDate,
        source_data.BASEPRICECURRENCYCODE AS BasePriceCurrencyCode,
        source_data.BILLINGADDRESSCITY AS BillingAddressCity,
        source_data.BILLINGADDRESSCOUNTRYCODE AS BillingAddressCountryCode,
        source_data.BILLINGADDRESSFAX AS BillingAddressFax,
        source_data.BILLINGADDRESSLINES AS BillingAddressLines,
        source_data.BILLINGADDRESSNAME AS BillingAddressName,
        source_data.BILLINGADDRESSPHONE AS BillingAddressPhone,
        source_data.BILLINGADDRESSPOSTALCODE AS BillingAddressPostalCode,
        source_data.BILLINGADDRESSSTATE AS BillingAddressState,
        source_data.BILLINGADDRESSCODE AS BillingAddressCode,
        source_data.BOUGHTFROMPREFERREDSUPPLIER AS BoughtFromPreferredSupplier,
        source_data.CARRIER AS Carrier,
        source_data.CARRIERMETHOD AS CarrierMethod,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeAmountAmountInReportingCurrency,
        source_data.CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeAmountApproxAmountInBaseCurrency,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CLOSED AS Closed,
        source_data.COMMODITYCODECODE AS CommodityCodeCode,
        source_data.DELIVERTO AS DeliverTo,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODENAME AS DescriptionCommonCommodityCodeName,
        source_data.DESCRIPTIONCOMMONCOMMODITYCODECODE AS DescriptionCommonCommodityCodeCode,
        source_data.DESCRIPTIONDESCRIPTION AS DescriptionDescription,
        source_data.DESCRIPTIONEXTENDEDDESCRIPTION AS DescriptionExtendedDescription,
        source_data.DESCRIPTIONMANNAME AS DescriptionManName,
        source_data.DESCRIPTIONMANPARTNUMBER AS DescriptionManPartNumber,
        source_data.DESCRIPTIONPRICEAMOUNT AS DescriptionPriceAmount,
        source_data.DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY AS DescriptionPriceAmountInReportingCurrency,
        source_data.DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY AS DescriptionPriceApproxAmountInBaseCurrency,
        source_data.DESCRIPTIONPRICECONVERSIONDATE AS DescriptionPriceConversionDate,
        source_data.DESCRIPTIONPRICECURRENCYCODE AS DescriptionPriceCurrencyCode,
        source_data.DESCRIPTIONSUPPLIERPARTAUXILIARYID AS DescriptionSupplierPartAuxiliaryId,
        source_data.DESCRIPTIONSUPPLIERPARTNUMBER AS DescriptionSupplierPartNumber,
        source_data.DESCRIPTIONUNITOFMEASURECODE AS DescriptionUnitOfMeasureCode,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY AS DiscountAmountAmountInReportingCurrency,
        source_data.DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY AS DiscountAmountApproxAmountInBaseCurrency,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DUEON AS DueOn,
        source_data.ENDDATE AS EndDate,
        source_data.ERSALLOWED AS ERSAllowed,
        source_data.ISADHOC AS IsAdHoc,
        source_data.ISPRICEMODIFIEDBYUSER AS IsPriceModifiedByUser,
        source_data.ISRECURRING AS IsRecurring,
        source_data.ITEMMASTERIDBUYERPARTNUMBER AS ItemMasterIdBuyerPartNumber,
        source_data.ITEMMASTERIDFACILITY AS ItemMasterIdFacility,
        source_data.LINECONFIRMATIONSTATUS AS LineConfirmationStatus,
        source_data.LINETYPECODE AS LineTypeCode,
        source_data.MASTERAGREEMENTCODE AS MasterAgreementCode,
        source_data.NEEDBY AS NeedBy,
        source_data.NUMBERCONFIRMEDACCEPTED AS NumberConfirmedAccepted,
        source_data.NUMBERCONFIRMEDACCEPTEDWITHCHANGES AS NumberConfirmedAcceptedWithChanges,
        source_data.NUMBERCONFIRMEDBACKORDERED AS NumberConfirmedBackOrdered,
        source_data.NUMBERCONFIRMEDREJECTED AS NumberConfirmedRejected,
        source_data.NUMBERCONFIRMEDSUBSTITUTED AS NumberConfirmedSubstituted,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.NUMBERONREQ AS NumberOnReq,
        source_data.NUMBERSHIPPED AS NumberShipped,
        source_data.ORDERID AS OrderId,
        source_data.ORDERMETHODCATEGORY AS OrderMethodCategory,
        source_data.ORDEREDDATE AS OrderedDate,
        source_data.ORIGINALPRICEAMOUNT AS OriginalPriceAmount,
        source_data.ORIGINALPRICEAMOUNTINREPORTINGCURRENCY AS OriginalPriceAmountInReportingCurrency,
        source_data.ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY AS OriginalPriceApproxAmountInBaseCurrency,
        source_data.ORIGINALPRICECONVERSIONDATE AS OriginalPriceConversionDate,
        source_data.ORIGINALPRICECURRENCYCODE AS OriginalPriceCurrencyCode,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.QUANTITY AS Quantity,
        source_data.REQUISITIONCODE AS RequisitionCode,
        source_data.SERVICEAMOUNTAPPROVEDAMOUNT AS ServiceAmountApprovedAmount,
        source_data.SERVICEAMOUNTAPPROVEDAMOUNTINREPORTINGCURRENCY AS ServiceAmountApprovedAmountInReportingCurrency,
        source_data.SERVICEAMOUNTAPPROVEDAPPROXAMOUNTINBASECURRENCY AS ServiceAmountApprovedApproxAmountInBaseCurrency,
        source_data.SERVICEAMOUNTAPPROVEDCONVERSIONDATE AS ServiceAmountApprovedConversionDate,
        source_data.SERVICEAMOUNTAPPROVEDCURRENCYCODE AS ServiceAmountApprovedCurrencyCode,
        source_data.SERVICEAMOUNTUNDERAPPROVALAMOUNT AS ServiceAmountUnderApprovalAmount,
        source_data.SERVICEAMOUNTUNDERAPPROVALAMOUNTINREPORTINGCURRENCY AS ServiceAmountUnderApprovalAmountInReportingCurrency,
        source_data.SERVICEAMOUNTUNDERAPPROVALAPPROXAMOUNTINBASECURRENCY AS ServiceAmountUnderApprovalApproxAmountInBaseCurrency,
        source_data.SERVICEAMOUNTUNDERAPPROVALCONVERSIONDATE AS ServiceAmountUnderApprovalConversionDate,
        source_data.SERVICEAMOUNTUNDERAPPROVALCURRENCYCODE AS ServiceAmountUnderApprovalCurrencyCode,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAMOUNT AS ServiceDetailsExpectedAmountAmount,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY AS ServiceDetailsExpectedAmountAmountInReportingCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY AS ServiceDetailsExpectedAmountApproxAmountInBaseCurrency,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE AS ServiceDetailsExpectedAmountConversionDate,
        source_data.SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE AS ServiceDetailsExpectedAmountCurrencyCode,
        source_data.SERVICEDETAILSMAXAMOUNTAMOUNT AS ServiceDetailsMaxAmountAmount,
        source_data.SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY AS ServiceDetailsMaxAmountAmountInReportingCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS ServiceDetailsMaxAmountApproxAmountInBaseCurrency,
        source_data.SERVICEDETAILSMAXAMOUNTCONVERSIONDATE AS ServiceDetailsMaxAmountConversionDate,
        source_data.SERVICEDETAILSMAXAMOUNTCURRENCYCODE AS ServiceDetailsMaxAmountCurrencyCode,
        source_data.SERVICEDETAILSREQUIRESSERVICEENTRY AS ServiceDetailsRequiresServiceEntry,
        source_data.SERVICEDETAILSSERVICEENDDATE AS ServiceDetailsServiceEndDate,
        source_data.SERVICEDETAILSSERVICELINE AS ServiceDetailsServiceLine,
        source_data.SERVICEDETAILSSERVICESTARTDATE AS ServiceDetailsServiceStartDate,
        source_data.SHIPTOCITY AS ShipToCity,
        source_data.SHIPTOCOUNTRYCODE AS ShipToCountryCode,
        source_data.SHIPTOFAX AS ShipToFax,
        source_data.SHIPTOLINES AS ShipToLines,
        source_data.SHIPTONAME AS ShipToName,
        source_data.SHIPTOPHONE AS ShipToPhone,
        source_data.SHIPTOPOSTALCODE AS ShipToPostalCode,
        source_data.SHIPTOSTATE AS ShipToState,
        source_data.SHIPTOCODE AS ShipToCode,
        source_data.STARTDATE AS StartDate,
        source_data.SUPPLIERNAME AS SupplierName,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxAmountAmountInReportingCurrency,
        source_data.TAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxAmountApproxAmountInBaseCurrency,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXCODECODE AS TaxCodeCode,
        source_data.TAXDETAILABATEMENTPERCENT AS TaxDetailAbatementPercent,
        source_data.TAXDETAILALTERNATETAXAMOUNTAMOUNT AS TaxDetailAlternateTaxAmountAmount,
        source_data.TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailAlternateTaxAmountAmountInReportingCurrency,
        source_data.TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailAlternateTaxAmountApproxAmountInBaseCurrency,
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
        source_data.TAXDETAILTAXAMOUNTAMOUNT AS TaxDetailTaxAmountAmount,
        source_data.TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailTaxAmountAmountInReportingCurrency,
        source_data.TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailTaxAmountApproxAmountInBaseCurrency,
        source_data.TAXDETAILTAXAMOUNTCONVERSIONDATE AS TaxDetailTaxAmountConversionDate,
        source_data.TAXDETAILTAXAMOUNTCURRENCYCODE AS TaxDetailTaxAmountCurrencyCode,
        source_data.TAXDETAILTAXABLEAMOUNTAMOUNT AS TaxDetailTaxableAmountAmount,
        source_data.TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxDetailTaxableAmountAmountInReportingCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxDetailTaxableAmountApproxAmountInBaseCurrency,
        source_data.TAXDETAILTAXABLEAMOUNTCONVERSIONDATE AS TaxDetailTaxableAmountConversionDate,
        source_data.TAXDETAILTAXABLEAMOUNTCURRENCYCODE AS TaxDetailTaxableAmountCurrencyCode,
        source_data.TAXDETAILTAXLOCATION AS TaxDetailTaxLocation,
        source_data.TAXDETAILTAXPOINTDATE AS TaxDetailTaxPointDate,
        source_data.TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE AS TaxDetailTriangularTransactionLawReference,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTAMOUNTINREPORTINGCURRENCY AS VATAmountAmountInReportingCurrency,
        source_data.VATAMOUNTAPPROXAMOUNTINBASECURRENCY AS VATAmountApproxAmountInBaseCurrency,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
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
        cast(PurchaseOrderIDKEY as VARCHAR(16777216)) as PurchaseOrderIDKEY,
        cast(PurchaseOrderVERSIONKEY as NUMBER(38,0)) as PurchaseOrderVERSIONKEY,
        cast(PurchaseOrderLINEITEMKEY as NUMBER(38,0)) as PurchaseOrderLINEITEMKEY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
        cast(BASEPRICEAMOUNT as NUMBER(38,10)) as BASEPRICEAMOUNT,
        cast(BASEPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as BASEPRICEAMOUNTINREPORTINGCURRENCY,
        cast(BASEPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as BASEPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(BASEPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as BASEPRICECONVERSIONDATE,
        cast(BASEPRICECURRENCYCODE as VARCHAR(16777216)) as BASEPRICECURRENCYCODE,
        cast(BILLINGADDRESSCITY as VARCHAR(16777216)) as BILLINGADDRESSCITY,
        cast(BILLINGADDRESSCOUNTRYCODE as VARCHAR(16777216)) as BILLINGADDRESSCOUNTRYCODE,
        cast(BILLINGADDRESSFAX as VARCHAR(16777216)) as BILLINGADDRESSFAX,
        cast(BILLINGADDRESSLINES as VARCHAR(16777216)) as BILLINGADDRESSLINES,
        cast(BILLINGADDRESSNAME as VARCHAR(16777216)) as BILLINGADDRESSNAME,
        cast(BILLINGADDRESSPHONE as VARCHAR(16777216)) as BILLINGADDRESSPHONE,
        cast(BILLINGADDRESSPOSTALCODE as VARCHAR(16777216)) as BILLINGADDRESSPOSTALCODE,
        cast(BILLINGADDRESSSTATE as VARCHAR(16777216)) as BILLINGADDRESSSTATE,
        cast(BILLINGADDRESSCODE as VARCHAR(16777216)) as BILLINGADDRESSCODE,
        cast(BOUGHTFROMPREFERREDSUPPLIER as VARCHAR(16777216)) as BOUGHTFROMPREFERREDSUPPLIER,
        cast(CARRIER as VARCHAR(16777216)) as CARRIER,
        cast(CARRIERMETHOD as VARCHAR(16777216)) as CARRIERMETHOD,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CLOSED as VARCHAR(16777216)) as CLOSED,
        cast(COMMODITYCODECODE as VARCHAR(16777216)) as COMMODITYCODECODE,
        cast(DELIVERTO as VARCHAR(16777216)) as DELIVERTO,
        cast(DESCRIPTIONCOMMONCOMMODITYCODENAME as VARCHAR(16777216)) as DESCRIPTIONCOMMONCOMMODITYCODENAME,
        cast(DESCRIPTIONCOMMONCOMMODITYCODECODE as VARCHAR(16777216)) as DESCRIPTIONCOMMONCOMMODITYCODECODE,
        cast(DESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONDESCRIPTION,
        cast(DESCRIPTIONEXTENDEDDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONEXTENDEDDESCRIPTION,
        cast(DESCRIPTIONMANNAME as VARCHAR(16777216)) as DESCRIPTIONMANNAME,
        cast(DESCRIPTIONMANPARTNUMBER as VARCHAR(16777216)) as DESCRIPTIONMANPARTNUMBER,
        cast(DESCRIPTIONPRICEAMOUNT as NUMBER(38,10)) as DESCRIPTIONPRICEAMOUNT,
        cast(DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEAMOUNTINREPORTINGCURRENCY,
        cast(DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as DESCRIPTIONPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(DESCRIPTIONPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as DESCRIPTIONPRICECONVERSIONDATE,
        cast(DESCRIPTIONPRICECURRENCYCODE as VARCHAR(16777216)) as DESCRIPTIONPRICECURRENCYCODE,
        cast(DESCRIPTIONSUPPLIERPARTAUXILIARYID as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTAUXILIARYID,
        cast(DESCRIPTIONSUPPLIERPARTNUMBER as VARCHAR(16777216)) as DESCRIPTIONSUPPLIERPARTNUMBER,
        cast(DESCRIPTIONUNITOFMEASURECODE as VARCHAR(16777216)) as DESCRIPTIONUNITOFMEASURECODE,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777216)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DUEON as TIMESTAMP_NTZ(9)) as DUEON,
        cast(ENDDATE as TIMESTAMP_NTZ(9)) as ENDDATE,
        cast(ERSALLOWED as VARCHAR(16777216)) as ERSALLOWED,
        cast(ISADHOC as VARCHAR(16777216)) as ISADHOC,
        cast(ISPRICEMODIFIEDBYUSER as VARCHAR(16777216)) as ISPRICEMODIFIEDBYUSER,
        cast(ISRECURRING as VARCHAR(16777216)) as ISRECURRING,
        cast(ITEMMASTERIDBUYERPARTNUMBER as VARCHAR(16777216)) as ITEMMASTERIDBUYERPARTNUMBER,
        cast(ITEMMASTERIDFACILITY as VARCHAR(16777216)) as ITEMMASTERIDFACILITY,
        cast(LINECONFIRMATIONSTATUS as VARCHAR(16777216)) as LINECONFIRMATIONSTATUS,
        cast(LINETYPECODE as VARCHAR(16777216)) as LINETYPECODE,
        cast(MASTERAGREEMENTCODE as VARCHAR(16777216)) as MASTERAGREEMENTCODE,
        cast(NEEDBY as TIMESTAMP_NTZ(9)) as NEEDBY,
        cast(NUMBERCONFIRMEDACCEPTED as NUMBER(38,10)) as NUMBERCONFIRMEDACCEPTED,
        cast(NUMBERCONFIRMEDACCEPTEDWITHCHANGES as NUMBER(38,10)) as NUMBERCONFIRMEDACCEPTEDWITHCHANGES,
        cast(NUMBERCONFIRMEDBACKORDERED as NUMBER(38,10)) as NUMBERCONFIRMEDBACKORDERED,
        cast(NUMBERCONFIRMEDREJECTED as NUMBER(38,10)) as NUMBERCONFIRMEDREJECTED,
        cast(NUMBERCONFIRMEDSUBSTITUTED as NUMBER(38,10)) as NUMBERCONFIRMEDSUBSTITUTED,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(NUMBERONREQ as NUMBER(38,0)) as NUMBERONREQ,
        cast(NUMBERSHIPPED as NUMBER(38,10)) as NUMBERSHIPPED,
        cast(ORDERID as VARCHAR(16777216)) as ORDERID,
        cast(ORDERMETHODCATEGORY as VARCHAR(16777216)) as ORDERMETHODCATEGORY,
        cast(ORDEREDDATE as TIMESTAMP_NTZ(9)) as ORDEREDDATE,
        cast(ORIGINALPRICEAMOUNT as NUMBER(38,10)) as ORIGINALPRICEAMOUNT,
        cast(ORIGINALPRICEAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as ORIGINALPRICEAMOUNTINREPORTINGCURRENCY,
        cast(ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as ORIGINALPRICEAPPROXAMOUNTINBASECURRENCY,
        cast(ORIGINALPRICECONVERSIONDATE as TIMESTAMP_NTZ(9)) as ORIGINALPRICECONVERSIONDATE,
        cast(ORIGINALPRICECURRENCYCODE as VARCHAR(16777216)) as ORIGINALPRICECURRENCYCODE,
        cast(PAYMENTTERMSCODE as VARCHAR(16777216)) as PAYMENTTERMSCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(REQUISITIONCODE as VARCHAR(16777216)) as REQUISITIONCODE,
        cast(SERVICEAMOUNTAPPROVEDAMOUNT as NUMBER(38,10)) as SERVICEAMOUNTAPPROVEDAMOUNT,
        cast(SERVICEAMOUNTAPPROVEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEAMOUNTAPPROVEDAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEAMOUNTAPPROVEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as SERVICEAMOUNTAPPROVEDAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEAMOUNTAPPROVEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEAMOUNTAPPROVEDCONVERSIONDATE,
        cast(SERVICEAMOUNTAPPROVEDCURRENCYCODE as VARCHAR(16777216)) as SERVICEAMOUNTAPPROVEDCURRENCYCODE,
        cast(SERVICEAMOUNTUNDERAPPROVALAMOUNT as NUMBER(38,10)) as SERVICEAMOUNTUNDERAPPROVALAMOUNT,
        cast(SERVICEAMOUNTUNDERAPPROVALAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEAMOUNTUNDERAPPROVALAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEAMOUNTUNDERAPPROVALAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as SERVICEAMOUNTUNDERAPPROVALAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEAMOUNTUNDERAPPROVALCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEAMOUNTUNDERAPPROVALCONVERSIONDATE,
        cast(SERVICEAMOUNTUNDERAPPROVALCURRENCYCODE as VARCHAR(16777216)) as SERVICEAMOUNTUNDERAPPROVALCURRENCYCODE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAMOUNT as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTAMOUNT,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as SERVICEDETAILSEXPECTEDAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSEXPECTEDAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE as VARCHAR(16777216)) as SERVICEDETAILSEXPECTEDAMOUNTCURRENCYCODE,
        cast(SERVICEDETAILSMAXAMOUNTAMOUNT as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTAMOUNT,
        cast(SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as SERVICEDETAILSMAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(SERVICEDETAILSMAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSMAXAMOUNTCONVERSIONDATE,
        cast(SERVICEDETAILSMAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as SERVICEDETAILSMAXAMOUNTCURRENCYCODE,
        cast(SERVICEDETAILSREQUIRESSERVICEENTRY as VARCHAR(16777216)) as SERVICEDETAILSREQUIRESSERVICEENTRY,
        cast(SERVICEDETAILSSERVICEENDDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICEENDDATE,
        cast(SERVICEDETAILSSERVICELINE as VARCHAR(16777216)) as SERVICEDETAILSSERVICELINE,
        cast(SERVICEDETAILSSERVICESTARTDATE as TIMESTAMP_NTZ(9)) as SERVICEDETAILSSERVICESTARTDATE,
        cast(SHIPTOCITY as VARCHAR(16777216)) as SHIPTOCITY,
        cast(SHIPTOCOUNTRYCODE as VARCHAR(16777216)) as SHIPTOCOUNTRYCODE,
        cast(SHIPTOFAX as VARCHAR(16777216)) as SHIPTOFAX,
        cast(SHIPTOLINES as VARCHAR(16777216)) as SHIPTOLINES,
        cast(SHIPTONAME as VARCHAR(16777216)) as SHIPTONAME,
        cast(SHIPTOPHONE as VARCHAR(16777216)) as SHIPTOPHONE,
        cast(SHIPTOPOSTALCODE as VARCHAR(16777216)) as SHIPTOPOSTALCODE,
        cast(SHIPTOSTATE as VARCHAR(16777216)) as SHIPTOSTATE,
        cast(SHIPTOCODE as VARCHAR(16777216)) as SHIPTOCODE,
        cast(STARTDATE as TIMESTAMP_NTZ(9)) as STARTDATE,
        cast(SUPPLIERNAME as VARCHAR(16777216)) as SUPPLIERNAME,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777216)) as SUPPLIERLOCATIONCODE,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXCODECODE as VARCHAR(16777216)) as TAXCODECODE,
        cast(TAXDETAILABATEMENTPERCENT as NUMBER(38,10)) as TAXDETAILABATEMENTPERCENT,
        cast(TAXDETAILALTERNATETAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTAMOUNT,
        cast(TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TAXDETAILALTERNATETAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILALTERNATETAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILALTERNATETAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILCATEGORY as VARCHAR(16777216)) as TAXDETAILCATEGORY,
        cast(TAXDETAILCOMPONENTCODE as VARCHAR(16777216)) as TAXDETAILCOMPONENTCODE,
        cast(TAXDETAILDESCRIPTION as VARCHAR(16777216)) as TAXDETAILDESCRIPTION,
        cast(TAXDETAILEXEMPTDETAIL as VARCHAR(16777216)) as TAXDETAILEXEMPTDETAIL,
        cast(TAXDETAILFORMULASTRING as VARCHAR(16777216)) as TAXDETAILFORMULASTRING,
        cast(TAXDETAILISDEDUCTIBLE as VARCHAR(16777216)) as TAXDETAILISDEDUCTIBLE,
        cast(TAXDETAILISTRIANGULARTRANSACTION as VARCHAR(16777216)) as TAXDETAILISTRIANGULARTRANSACTION,
        cast(TAXDETAILPAYMENTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILPAYMENTDATE,
        cast(TAXDETAILPERUNIT as NUMBER(38,10)) as TAXDETAILPERUNIT,
        cast(TAXDETAILPERCENT as NUMBER(38,10)) as TAXDETAILPERCENT,
        cast(TAXDETAILPURPOSE as VARCHAR(16777216)) as TAXDETAILPURPOSE,
        cast(TAXDETAILTAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILTAXAMOUNTAMOUNT,
        cast(TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILTAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TAXDETAILTAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILTAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILTAXAMOUNTCURRENCYCODE,
        cast(TAXDETAILTAXABLEAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTAMOUNT,
        cast(TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TAXDETAILTAXABLEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXDETAILTAXABLEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXABLEAMOUNTCONVERSIONDATE,
        cast(TAXDETAILTAXABLEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILTAXABLEAMOUNTCURRENCYCODE,
        cast(TAXDETAILTAXLOCATION as VARCHAR(16777216)) as TAXDETAILTAXLOCATION,
        cast(TAXDETAILTAXPOINTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILTAXPOINTDATE,
        cast(TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE as VARCHAR(16777216)) as TAXDETAILTRIANGULARTRANSACTIONLAWREFERENCE,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(VATAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as VATAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data