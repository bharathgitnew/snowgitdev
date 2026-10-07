{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICERECONCILIATIONHEADER',
    unique_key = ['RealmName',
    'InvoiceReconciliationIDKey',
    'InvoiceReconciliationVersionKey']
) }}


with source_data as
(
    SELECT
        JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:Active::BOOLEAN AS Active
        ,parse_json(JsonField:AmountBilled):Amount::NUMBER(38,10) AS AmountBilledAmount
        ,parse_json(JsonField:AmountBilled):BaseCurrency::NUMBER(38,10) AS AmountBilledBaseCurrency
        ,parse_json(JsonField:AmountBilled):ConversionDate::TIMESTAMP_NTZ AS AmountBilledConversionDate
        ,parse_json(JsonField:AmountBilled):Currency:UniqueName::STRING AS AmountBilledCurrencyCode
        ,parse_json(JsonField:AmountBilled):ReportingCurrency::NUMBER(38,10) AS AmountBilledReportingCurrency
        ,parse_json(JsonField:AmountCleared):Amount::NUMBER(38,10) AS AmountClearedAmount
        ,parse_json(JsonField:AmountCleared):BaseCurrency::NUMBER(38,10) AS AmountClearedBaseCurrency
        ,parse_json(JsonField:AmountCleared):ConversionDate::TIMESTAMP_NTZ AS AmountClearedConversionDate
        ,parse_json(JsonField:AmountCleared):Currency:UniqueName::STRING AS AmountClearedCurrencyCode
        ,parse_json(JsonField:AmountCleared):ReportingCurrency::NUMBER(38,10) AS AmountClearedReportingCurrency
        ,JsonField:ApprovalRequestsVersion::INTEGER AS ApprovalRequestsVersion
        ,JsonField:ApprovedDate::TIMESTAMP_NTZ AS ApprovedDate
        ,JsonField:ApprovedState::INTEGER AS ApprovedState
        ,parse_json(JsonField:ChangedBy):UniqueName::STRING AS ChangedByCode
        ,parse_json(JsonField:ChargeAmount):Amount::NUMBER(38,10) AS ChargeAmountAmount
        ,parse_json(JsonField:ChargeAmount):BaseCurrency::NUMBER(38,10) AS ChargeAmountBaseCurrency
        ,parse_json(JsonField:ChargeAmount):ConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,parse_json(JsonField:ChargeAmount):Currency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,parse_json(JsonField:ChargeAmount):ReportingCurrency::NUMBER(38,10) AS ChargeAmountReportingCurrency
        ,JsonField:CreateDate::TIMESTAMP_NTZ AS CreateDate
        ,parse_json(JsonField:DiscountAmount):Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,parse_json(JsonField:DiscountAmount):BaseCurrency::NUMBER(38,10) AS DiscountAmountBaseCurrency
        ,parse_json(JsonField:DiscountAmount):ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,parse_json(JsonField:DiscountAmount):Currency:UniqueName::STRING AS DiscountAmountCurrencyCode
        ,parse_json(JsonField:DiscountAmount):ReportingCurrency::NUMBER(38,10) AS DiscountAmountReportingCurrency
        ,JsonField:EligibleForDynamicDiscount::BOOLEAN AS EligibleForDynamicDiscount
        ,JsonField:ExternalStatus::STRING AS ExternalStatus
        ,JsonField:HoldTillDate::TIMESTAMP_NTZ AS HoldTillDate
        ,JsonField:InitialUniqueName::STRING AS InitialUniqueName
        ,parse_json(JsonField:Invoice):UniqueName::STRING AS InvoiceCode
        ,JsonField:InvoiceDate::TIMESTAMP_NTZ AS InvoiceDate
        ,JsonField:IsAccruedOnIR::BOOLEAN AS IsAccruedOnIR
        ,JsonField:LastModified::TIMESTAMP_NTZ AS LastModified
        ,parse_json(JsonField:MaxDiscountApplicable):AmountAmount::NUMBER(38,10) AS MaxDiscountApplicableAmountAmount
        ,parse_json(JsonField:MaxDiscountApplicable):AmountBaseCurrency::NUMBER(38,10) AS MaxDiscountApplicableAmountBaseCurrency
        ,parse_json(JsonField:MaxDiscountApplicable):AmountConversionDate::TIMESTAMP_NTZ AS MaxDiscountApplicableAmountConversionDate
        ,parse_json(JsonField:MaxDiscountApplicable):AmountCurrency:UniqueName::STRING AS MaxDiscountApplicableAmountCurrencyCode
        ,parse_json(JsonField:MaxDiscountApplicable):AmountReportingCurrency::NUMBER(38,10) AS MaxDiscountApplicableAmountReportingCurrency
        ,JsonField:Name::STRING AS Name
        ,JsonField:NextVersion::STRING AS NextVersion
        ,JsonField:NumberBilled::NUMBER(38,10) AS NumberBilled
        ,JsonField:NumberCleared::NUMBER(38,10) AS NumberCleared
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Reason::STRING AS PaidAmountAdjustmentAmountReason
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Amount:Amount::NUMBER(38,10) AS PaidAmountAdjustmentAmountAmount
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Amount:BaseCurrency::NUMBER(38,10) AS PaidAmountAdjustmentAmountAmountInBaseCurrency
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Amount:ConversionDate::TIMESTAMP_NTZ AS PaidAmountAdjustmentAmountConversionDate
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Amount:Currency:UniqueName::STRING AS PaidAmountAdjustmentAmountCurrencyCode
        ,parse_json(JsonField:PaidAmounts):AdjustmentAmount:Amount:ReportingCurrency::NUMBER(38,10) AS PaidAmountAdjustmentAmountAmountInReportingCurrency
        ,parse_json(JsonField:PaidAmounts):GrossAmount:Amount::NUMBER(38,10) AS PaidAmountGrossAmountAmount
        ,parse_json(JsonField:PaidAmounts):GrossAmount:BaseCurrency::NUMBER(38,10) AS PaidAmountGrossAmountAmountInBaseCurrency
        ,parse_json(JsonField:PaidAmounts):GrossAmount:ConversionDate::TIMESTAMP_NTZ AS PaidAmountGrossAmountConversionDate
        ,parse_json(JsonField:PaidAmounts):GrossAmount:Currency:UniqueName::STRING AS PaidAmountGrossAmountCurrencyCode
        ,parse_json(JsonField:PaidAmounts):GrossAmount:ReportingCurrency::NUMBER(38,10) AS PaidAmountGrossAmountAmountInReportingCurrency
        ,parse_json(JsonField:PaidAmounts):DiscountAmount:Amount::NUMBER(38,10) AS PaidAmountDiscountAmountAmount
        ,parse_json(JsonField:PaidAmounts):Discountmount:BaseCurrency::NUMBER(38,10) AS PaidAmountDiscountAmountAmountInBaseCurrency
        ,parse_json(JsonField:PaidAmounts):DiscountAmount:ConversionDate::TIMESTAMP_NTZ AS PaidAmountDiscountAmountConversionDate
        ,parse_json(JsonField:PaidAmounts):DiscountAmount:Currency:UniqueName::STRING AS PaidAmountDiscountAmountCurrencyCode
        ,parse_json(JsonField:PaidAmounts):DiscountAmount:ReportingCurrency::NUMBER(38,10) AS PaidAmountDiscountAmountAmountInReportingCurrency
        ,parse_json(JsonField:PaidAmounts):NetAmount:Amount::NUMBER(38,10) AS PaidAmountNetAmountAmount
        ,parse_json(JsonField:PaidAmounts):NetAmount:BaseCurrency::NUMBER(38,10) AS PaidAmountNetAmountAmountInBaseCurrency
        ,parse_json(JsonField:PaidAmounts):NetAmount:ConversionDate::TIMESTAMP_NTZ AS PaidAmountNetAmountConversionDate
        ,parse_json(JsonField:PaidAmounts):NetAmount:Currency:UniqueName::STRING AS PaidAmountNetAmountCurrencyCode
        ,parse_json(JsonField:PaidAmounts):NetAmount:ReportingCurrency::NUMBER(38,10) AS PaidAmountNetAmountAmountInReportingCurrency
        ,JsonField:PaidDate::TIMESTAMP_NTZ AS PaidDate
        ,JsonField:PayloadID::STRING AS PayloadId
        ,JsonField:PaymentModel::INTEGER AS PaymentModel
        ,parse_json(JsonField:Preparer):UniqueName::STRING AS PreparerCode
        ,JsonField:PreviousApprovalRequestsVersion::INTEGER AS PreviousApprovalRequestsVersion
        ,JsonField:PreviousVersion::VARIANT AS PreviousVersion
        ,JsonField:ProcessedState::INTEGER AS ProcessedState
        ,parse_json(JsonField:ProcurementUnit):UniqueName::STRING AS ProcurementUnitCode
        ,JsonField:ProjectID::STRING AS ProjectId
        ,JsonField:ProjectTitle::STRING AS ProjectTitle
        ,parse_json(JsonField:PurchaseOrg):UniqueName::STRING AS PurchaseOrgCode
        ,JsonField:RejectedDate::TIMESTAMP_NTZ AS RejectedDate
        ,parse_json(JsonField:RemittanceLocation):UniqueName::STRING AS RemittanceLocationCode
        ,parse_json(JsonField:Requester):UniqueName::STRING AS RequesterCode
        ,JsonField:ResubmitDate::TIMESTAMP_NTZ AS ResubmitDate
        ,JsonField:ScheduledPaymentDate::TIMESTAMP_NTZ AS ScheduledPaymentDate
        ,parse_json(JsonField:ServiceLocation):City::STRING AS ServiceLocationCity
        ,parse_json(JsonField:ServiceLocation):Country:UniqueName::STRING AS ServiceLocationCountryCode
        ,parse_json(JsonField:ServiceLocation):Fax::STRING AS ServiceLocationFax
        ,parse_json(JsonField:ServiceLocation):Lines::STRING AS ServiceLocationLines
        ,parse_json(JsonField:ServiceLocation):Name::STRING AS ServiceLocationName
        ,parse_json(JsonField:ServiceLocation):Phone::STRING AS ServiceLocationPhone
        ,parse_json(JsonField:ServiceLocation):PostalCode::STRING AS ServiceLocationPostalCode
        ,parse_json(JsonField:ServiceLocation):State::STRING AS ServiceLocationState
        ,parse_json(JsonField:ServiceLocation):UniqueName::STRING AS ServiceLocationCode
        ,parse_json(JsonField:ServicePeriod):FromDate::TIMESTAMP_NTZ AS ServicePeriodFromDate
        ,parse_json(JsonField:ServicePeriod):Period::STRING AS ServicePeriodPeriod
        ,parse_json(JsonField:ServicePeriod):ToDate::TIMESTAMP_NTZ AS ServicePeriodToDate
        ,JsonField:SourcingStatusString::STRING AS SourcingStatusString
        ,JsonField:StatusString::STRING AS StatusString
        ,JsonField:SubmitDate::TIMESTAMP_NTZ AS SubmitDate
        ,parse_json(JsonField:Supplier):Name::STRING AS SupplierName
        ,parse_json(JsonField:Supplier):UniqueName::STRING AS SupplierCode
        ,parse_json(JsonField:SupplierLocation):UniqueName::STRING AS SupplierLocationCode
        ,parse_json(JsonField:TaxAccrualAmount):Amount::NUMBER(38,10) AS TaxAccrualAmountAmount
        ,parse_json(JsonField:TaxAccrualAmount):BaseCurrency::NUMBER(38,10) AS TaxAccrualAmountBaseCurrency
        ,parse_json(JsonField:TaxAccrualAmount):ConversionDate::TIMESTAMP_NTZ AS TaxAccrualAmountConversionDate
        ,parse_json(JsonField:TaxAccrualAmount):Currency:UniqueName::STRING AS TaxAccrualAmountCurrencyCode
        ,parse_json(JsonField:TaxAccrualAmount):ReportingCurrency::NUMBER(38,10) AS TaxAccrualAmountReportingCurrency
        ,parse_json(JsonField:TaxAmount):Amount::NUMBER(38,10) AS TaxAmountAmount
        ,parse_json(JsonField:TaxAmount):BaseCurrency::NUMBER(38,10) AS TaxAmountBaseCurrency
        ,parse_json(JsonField:TaxAmount):ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,parse_json(JsonField:TaxAmount):Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,parse_json(JsonField:TaxAmount):ReportingCurrency::NUMBER(38,10) AS TaxAmountReportingCurrency
        ,parse_json(JsonField:TaxDetails):AbatementPercent::NUMBER(38,10) AS TaxDetailsAbatementPercent
        ,JsonField:"TaxDetails.AlternateTaxAmount":Amount::NUMBER(38,10) AS TaxDetailsAlternateTaxAmountAmount
        ,JsonField:"TaxDetails.AlternateTaxAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailsAlternateTaxAmountBaseCurrency
        ,JsonField:"TaxDetails.AlternateTaxAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailsAlternateTaxAmountConversionDate
        ,JsonField:"TaxDetails.AlternateTaxAmount":Currency:UniqueName::STRING AS TaxDetailsAlternateTaxAmountCurrencyCode
        ,JsonField:"TaxDetails.AlternateTaxAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailsAlternateTaxAmountReportingCurrency
        ,parse_json(JsonField:TaxDetails):Category::STRING AS TaxDetailsCategory
        ,parse_json(JsonField:TaxDetails):Component:UniqueName::STRING AS TaxDetailsComponentCode
        ,parse_json(JsonField:TaxDetails):Description::STRING AS TaxDetailsDescription
        ,parse_json(JsonField:TaxDetails):ExemptDetail::STRING AS TaxDetailsExemptDetail
        ,parse_json(JsonField:TaxDetails):FormulaString::STRING AS TaxDetailsFormulaString
        ,parse_json(JsonField:TaxDetails):IsDeductible::BOOLEAN AS TaxDetailsIsDeductible
        ,parse_json(JsonField:TaxDetails):IsTriangularTransaction::BOOLEAN AS TaxDetailsIsTriangularTransaction
        ,parse_json(JsonField:TaxDetails):PaymentDate::TIMESTAMP_NTZ AS TaxDetailsPaymentDate
        ,parse_json(JsonField:TaxDetails):PerUnit::NUMBER(38,10) AS TaxDetailsPerUnit
        ,parse_json(JsonField:TaxDetails):Percent::NUMBER(38,10) AS TaxDetailsPercent
        ,parse_json(JsonField:TaxDetails):Purpose::STRING AS TaxDetailsPurpose
        ,JsonField:"TaxDetails.TaxAmount":Amount::NUMBER(38,10) AS TaxDetailsTaxAmountAmount
        ,JsonField:"TaxDetails.TaxAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailsTaxAmountBaseCurrency
        ,JsonField:"TaxDetails.TaxAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailsTaxAmountConversionDate
        ,JsonField:"TaxDetails.TaxAmount":Currency:UniqueName::STRING AS TaxDetailsTaxAmountCurrencyCode
        ,JsonField:"TaxDetails.TaxAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailsTaxAmountReportingCurrency
        ,parse_json(JsonField:TaxDetails):TaxLocation::STRING AS TaxDetailsTaxLocation
        ,parse_json(JsonField:TaxDetails):TaxPointDate::TIMESTAMP_NTZ AS TaxDetailsTaxPointDate
        ,JsonField:"TaxDetails.TaxableAmount":Amount::NUMBER(38,10) AS TaxDetailsTaxableAmountAmount
        ,JsonField:"TaxDetails.TaxableAmount":BaseCurrency::NUMBER(38,10) AS TaxDetailsTaxableAmountBaseCurrency
        ,JsonField:"TaxDetails.TaxableAmount":ConversionDate::TIMESTAMP_NTZ AS TaxDetailsTaxableAmountConversionDate
        ,JsonField:"TaxDetails.TaxableAmount":Currency:UniqueName::STRING AS TaxDetailsTaxableAmountCurrencyCode
        ,JsonField:"TaxDetails.TaxableAmount":ReportingCurrency::NUMBER(38,10) AS TaxDetailsTaxableAmountReportingCurrency
        ,parse_json(JsonField:TaxDetails):TriangularTransactionLawReference::STRING AS TaxDetailsTriangularTransactionLawReference
        ,JsonField:TimeCreated::TIMESTAMP_NTZ AS TimeCreated
        ,JsonField:TimeUpdated::TIMESTAMP_NTZ AS TimeUpdated
        ,parse_json(JsonField:TotalInvoiced):Amount::NUMBER(38,10) AS TotalInvoicedAmount
        ,parse_json(JsonField:TotalInvoiced):BaseCurrency::NUMBER(38,10) AS TotalInvoicedBaseCurrency
        ,parse_json(JsonField:TotalInvoiced):ConversionDate::TIMESTAMP_NTZ AS TotalInvoicedConversionDate
        ,parse_json(JsonField:TotalInvoiced):Currency:UniqueName::STRING AS TotalInvoicedCurrencyCode
        ,parse_json(JsonField:TotalInvoiced):ReportingCurrency::NUMBER(38,10) AS TotalInvoicedReportingCurrency
        ,parse_json(JsonField:TotalWithholding):TaxAmount::NUMBER(38,10) AS TotalWithholdingTaxAmount
        ,parse_json(JsonField:TotalWithholding):TaxBaseCurrency::NUMBER(38,10) AS TotalWithholdingTaxBaseCurrency
        ,parse_json(JsonField:TotalWithholding):TaxConversionDate::TIMESTAMP_NTZ AS TotalWithholdingTaxConversionDate
        ,parse_json(JsonField:TotalWithholding):TaxCurrency:UniqueName::STRING AS TotalWithholdingTaxCurrencyCode
        ,parse_json(JsonField:TotalWithholding):TaxReportingCurrency::NUMBER(38,10) AS TotalWithholdingTaxReportingCurrency
        ,JsonField:Type::STRING AS Type
        ,JsonField:UniqueName::STRING AS UniqueName
        ,parse_json(JsonField:VATAmount):Amount::NUMBER(38,10) AS VATAmountAmount
        ,parse_json(JsonField:VATAmount):BaseCurrency::NUMBER(38,10) AS VATAmountBaseCurrency
        ,parse_json(JsonField:VATAmount):ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,parse_json(JsonField:VATAmount):Currency:UniqueName::STRING AS VATAmountCurrencyCode
        ,parse_json(JsonField:VATAmount):ReportingCurrency::NUMBER(38,10) AS VATAmountReportingCurrency
        ,JsonField:VersionNumber::INTEGER AS VersionNumber
        ,JsonField:cus_BPO::BOOLEAN AS CustomField_BPO
        ,JsonField:cus_BuyerName::STRING AS CustomField_BuyerName
        ,JsonField:cus_ContactDetails::STRING AS CustomField_ContactDetails
        ,JsonField:cus_DINNumber::STRING AS CustomField_DINNumber
        ,JsonField:cus_EndDate::TIMESTAMP_NTZ AS CustomField_EndDate
        ,JsonField:cus_IsBaanSpecific::BOOLEAN AS CustomField_IsBaanSpecific
        ,JsonField:cus_IsBPO::BOOLEAN AS CustomField_IsBPO
        ,JsonField:cus_StartDate::TIMESTAMP_NTZ AS CustomField_StartDate
        ,JsonField:cus_UPSNumber::STRING AS CustomField_UPSNumber
        FROM {{ source("ARIBA", "INVOICERECONCILIATION") }} LZData
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.UNIQUENAME AS InvoiceReconciliationIDKey,
        source_data.VERSIONNUMBER AS InvoiceReconciliationVersionKey,
        source_data.ACTIVE AS Active,
        source_data.AMOUNTBILLEDAMOUNT AS AmountBilledAmount,
        source_data.AMOUNTBILLEDBASECURRENCY AS AmountBilledBaseCurrency,
        source_data.AMOUNTBILLEDCONVERSIONDATE AS AmountBilledConversionDate,
        source_data.AMOUNTBILLEDCURRENCYCODE AS AmountBilledCurrencyCode,
        source_data.AMOUNTBILLEDREPORTINGCURRENCY AS AmountBilledReportingCurrency,
        source_data.AMOUNTCLEAREDAMOUNT AS AmountClearedAmount,
        source_data.AMOUNTCLEAREDBASECURRENCY AS AmountClearedBaseCurrency,
        source_data.AMOUNTCLEAREDCONVERSIONDATE AS AmountClearedConversionDate,
        source_data.AMOUNTCLEAREDCURRENCYCODE AS AmountClearedCurrencyCode,
        source_data.AMOUNTCLEAREDREPORTINGCURRENCY AS AmountClearedReportingCurrency,
        source_data.APPROVALREQUESTSVERSION AS ApprovalRequestsVersion,
        source_data.APPROVEDDATE AS ApprovedDate,
        source_data.APPROVEDSTATE AS ApprovedState,
        source_data.CHANGEDBYCODE AS ChangedByCode,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTBASECURRENCY AS ChargeAmountBaseCurrency,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CHARGEAMOUNTREPORTINGCURRENCY AS ChargeAmountReportingCurrency,
        source_data.CREATEDATE AS CreateDate,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTBASECURRENCY AS DiscountAmountBaseCurrency,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DISCOUNTAMOUNTREPORTINGCURRENCY AS DiscountAmountReportingCurrency,
        source_data.ELIGIBLEFORDYNAMICDISCOUNT AS EligibleForDynamicDiscount,
        source_data.EXTERNALSTATUS AS ExternalStatus,
        source_data.HOLDTILLDATE AS HoldTillDate,
        source_data.INITIALUNIQUENAME AS InitialUniqueName,
        source_data.INVOICEDATE AS InvoiceDate,
        source_data.INVOICECODE AS InvoiceCode,
        source_data.ISACCRUEDONIR AS IsAccruedOnIR,
        source_data.LASTMODIFIED AS LastModified,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNTAMOUNT AS MaxDiscountApplicableAmountAmount,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNTBASECURRENCY AS MaxDiscountApplicableAmountBaseCurrency,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNTCONVERSIONDATE AS MaxDiscountApplicableAmountConversionDate,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNTCURRENCYCODE AS MaxDiscountApplicableAmountCurrencyCode,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNTREPORTINGCURRENCY AS MaxDiscountApplicableAmountReportingCurrency,
        source_data.NAME AS Name,
        source_data.NEXTVERSION AS NextVersion,
        source_data.NUMBERBILLED AS NumberBilled,
        source_data.NUMBERCLEARED AS NumberCleared,
        source_data.TYPE AS ObjectType,
        source_data.PAIDDATE AS PaidDate,
        source_data.PAYLOADID AS PayloadId,
        source_data.PAYMENTMODEL AS PaymentModel,
        source_data.PREPARERCODE AS PreparerCode,
        source_data.PREVIOUSAPPROVALREQUESTSVERSION AS PreviousApprovalRequestsVersion,
        source_data.PREVIOUSVERSION AS PreviousVersion,
        source_data.PROCESSEDSTATE AS ProcessedState,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.PROJECTID AS ProjectId,
        source_data.PROJECTTITLE AS ProjectTitle,
        source_data.REJECTEDDATE AS RejectedDate,
        source_data.REMITTANCELOCATIONCODE AS RemittanceLocationCode,
        source_data.REQUESTERCODE AS RequesterCode,
        source_data.RESUBMITDATE AS ResubmitDate,
        source_data.SCHEDULEDPAYMENTDATE AS ScheduledPaymentDate,
        source_data.SERVICELOCATIONCITY AS ServiceLocationCity,
        source_data.SERVICELOCATIONCOUNTRYCODE AS ServiceLocationCountryCode,
        source_data.SERVICELOCATIONFAX AS ServiceLocationFax,
        source_data.SERVICELOCATIONLINES AS ServiceLocationLines,
        source_data.SERVICELOCATIONNAME AS ServiceLocationName,
        source_data.SERVICELOCATIONPHONE AS ServiceLocationPhone,
        source_data.SERVICELOCATIONPOSTALCODE AS ServiceLocationPostalCode,
        source_data.SERVICELOCATIONSTATE AS ServiceLocationState,
        source_data.SERVICELOCATIONCODE AS ServiceLocationCode,
        source_data.SERVICEPERIODFROMDATE AS ServicePeriodFromDate,
        source_data.SERVICEPERIODPERIOD AS ServicePeriodPeriod,
        source_data.SERVICEPERIODTODATE AS ServicePeriodToDate,
        source_data.SOURCINGSTATUSSTRING AS SourcingStatusString,
        source_data.STATUSSTRING AS StatusString,
        source_data.SUBMITDATE AS SubmitDate,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.SUPPLIERNAME AS SupplierName,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.TAXACCRUALAMOUNTAMOUNT AS TaxAccrualAmountAmount,
        source_data.TAXACCRUALAMOUNTBASECURRENCY AS TaxAccrualAmountBaseCurrency,
        source_data.TAXACCRUALAMOUNTCONVERSIONDATE AS TaxAccrualAmountConversionDate,
        source_data.TAXACCRUALAMOUNTCURRENCYCODE AS TaxAccrualAmountCurrencyCode,
        source_data.TAXACCRUALAMOUNTREPORTINGCURRENCY AS TaxAccrualAmountReportingCurrency,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTBASECURRENCY AS TaxAmountBaseCurrency,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXAMOUNTREPORTINGCURRENCY AS TaxAmountReportingCurrency,
        source_data.TAXDETAILSABATEMENTPERCENT AS TaxDetailsAbatementPercent,
        source_data.TAXDETAILSCATEGORY AS TaxDetailsCategory,
        source_data.TAXDETAILSCOMPONENTCODE AS TaxDetailsComponentCode,
        source_data.TAXDETAILSDESCRIPTION AS TaxDetailsDescription,
        source_data.TAXDETAILSEXEMPTDETAIL AS TaxDetailsExemptDetail,
        source_data.TAXDETAILSFORMULASTRING AS TaxDetailsFormulaString,
        source_data.TAXDETAILSISDEDUCTIBLE AS TaxDetailsIsDeductible,
        source_data.TAXDETAILSISTRIANGULARTRANSACTION AS TaxDetailsIsTriangularTransaction,
        source_data.TAXDETAILSPAYMENTDATE AS TaxDetailsPaymentDate,
        source_data.TAXDETAILSPERUNIT AS TaxDetailsPerUnit,
        source_data.TAXDETAILSPERCENT AS TaxDetailsPercent,
        source_data.TAXDETAILSPURPOSE AS TaxDetailsPurpose,
        source_data.TAXDETAILSTAXLOCATION AS TaxDetailsTaxLocation,
        source_data.TAXDETAILSTAXPOINTDATE AS TaxDetailsTaxPointDate,
        source_data.TAXDETAILSTAXABLEAMOUNTAMOUNT AS TaxDetailsTaxableAmountAmount,
        source_data.TAXDETAILSTAXABLEAMOUNTBASECURRENCY AS TaxDetailsTaxableAmountBaseCurrency,
        source_data.TAXDETAILSTAXABLEAMOUNTCONVERSIONDATE AS TaxDetailsTaxableAmountConversionDate,
        source_data.TAXDETAILSTAXABLEAMOUNTCURRENCYCODE AS TaxDetailsTaxableAmountCurrencyCode,
        source_data.TAXDETAILSTAXABLEAMOUNTREPORTINGCURRENCY AS TaxDetailsTaxableAmountReportingCurrency,
        source_data.TAXDETAILSTRIANGULARTRANSACTIONLAWREFERENCE AS TaxDetailsTriangularTransactionLawReference,
        source_data.TIMECREATED AS TimeCreated,
        source_data.TIMEUPDATED AS TimeUpdated,
        source_data.TOTALINVOICEDAMOUNT AS TotalInvoicedAmount,
        source_data.TOTALINVOICEDBASECURRENCY AS TotalInvoicedBaseCurrency,
        source_data.TOTALINVOICEDCONVERSIONDATE AS TotalInvoicedConversionDate,
        source_data.TOTALINVOICEDCURRENCYCODE AS TotalInvoicedCurrencyCode,
        source_data.TOTALINVOICEDREPORTINGCURRENCY AS TotalInvoicedReportingCurrency,
        source_data.TOTALWITHHOLDINGTAXAMOUNT AS TotalWithholdingTaxAmount,
        source_data.TOTALWITHHOLDINGTAXBASECURRENCY AS TotalWithholdingTaxBaseCurrency,
        source_data.TOTALWITHHOLDINGTAXCONVERSIONDATE AS TotalWithholdingTaxConversionDate,
        source_data.TOTALWITHHOLDINGTAXCURRENCYCODE AS TotalWithholdingTaxCurrencyCode,
        source_data.TOTALWITHHOLDINGTAXREPORTINGCURRENCY AS TotalWithholdingTaxReportingCurrency,
        source_data.UNIQUENAME AS UniqueName,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTBASECURRENCY AS VATAmountBaseCurrency,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.VATAMOUNTREPORTINGCURRENCY AS VATAmountReportingCurrency,
        source_data.VERSIONNUMBER AS VersionNumber,
        source_data.CUSTOMFIELD_BPO AS CustomField_BPO,
        source_data.CUSTOMFIELD_BUYERNAME AS CustomField_BuyerName,
        source_data.CUSTOMFIELD_CONTACTDETAILS AS CustomField_ContactDetails,
        source_data.CUSTOMFIELD_DINNUMBER AS CustomField_DINNumber,
        source_data.CUSTOMFIELD_ENDDATE AS CustomField_EndDate,
        source_data.CUSTOMFIELD_ISBAANSPECIFIC AS CustomField_IsBaanSpecific,
        source_data.CUSTOMFIELD_ISBPO AS CustomField_IsBPO,
        source_data.CUSTOMFIELD_STARTDATE AS CustomField_StartDate,
        source_data.CUSTOMFIELD_UPSNUMBER AS CustomField_UPSNumber,
        source_data.PAIDAMOUNTADJUSTMENTAMOUNTREASON as PAIDAMOUNTADJUSTMENTAMOUNTREASON,
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
        cast(ACTIVE as BOOLEAN) as ACTIVE,
        cast(AMOUNTBILLEDAMOUNT as NUMBER(38,10)) as AMOUNTBILLEDAMOUNT,
        cast(AMOUNTBILLEDBASECURRENCY as NUMBER(38,10)) as AMOUNTBILLEDBASECURRENCY,
        cast(AMOUNTBILLEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTBILLEDCONVERSIONDATE,
        cast(AMOUNTBILLEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTBILLEDCURRENCYCODE,
        cast(AMOUNTBILLEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTBILLEDREPORTINGCURRENCY,
        cast(AMOUNTCLEAREDAMOUNT as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNT,
        cast(AMOUNTCLEAREDBASECURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDBASECURRENCY,
        cast(AMOUNTCLEAREDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCLEAREDCONVERSIONDATE,
        cast(AMOUNTCLEAREDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCLEAREDCURRENCYCODE,
        cast(AMOUNTCLEAREDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDREPORTINGCURRENCY,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as NUMBER(38,0)) as APPROVEDSTATE,
        cast(CHANGEDBYCODE as VARCHAR(16777216)) as CHANGEDBYCODE,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTBASECURRENCY,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTREPORTINGCURRENCY,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTBASECURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTBASECURRENCY,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777216)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DISCOUNTAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTREPORTINGCURRENCY,
        cast(ELIGIBLEFORDYNAMICDISCOUNT as BOOLEAN) as ELIGIBLEFORDYNAMICDISCOUNT,
        cast(EXTERNALSTATUS as VARCHAR(16777216)) as EXTERNALSTATUS,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALUNIQUENAME as VARCHAR(16777216)) as INITIALUNIQUENAME,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICECODE as VARCHAR(16777216)) as INVOICECODE,
        cast(ISACCRUEDONIR as BOOLEAN) as ISACCRUEDONIR,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(MAXDISCOUNTAPPLICABLEAMOUNTAMOUNT as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEAMOUNTAMOUNT,
        cast(MAXDISCOUNTAPPLICABLEAMOUNTBASECURRENCY as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEAMOUNTBASECURRENCY,
        cast(MAXDISCOUNTAPPLICABLEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as MAXDISCOUNTAPPLICABLEAMOUNTCONVERSIONDATE,
        cast(MAXDISCOUNTAPPLICABLEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as MAXDISCOUNTAPPLICABLEAMOUNTCURRENCYCODE,
        cast(MAXDISCOUNTAPPLICABLEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEAMOUNTREPORTINGCURRENCY,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NEXTVERSION as VARCHAR(16777216)) as NEXTVERSION,
        cast(NUMBERBILLED as NUMBER(38,0)) as NUMBERBILLED,
        cast(NUMBERCLEARED as NUMBER(38,0)) as NUMBERCLEARED,
        cast(OBJECTTYPE as VARCHAR(16777216)) as OBJECTTYPE,
        cast(PAIDDATE as TIMESTAMP_NTZ(9)) as PAIDDATE,
        cast(PAYLOADID as VARCHAR(16777216)) as PAYLOADID,
        cast(PAYMENTMODEL as NUMBER(38,0)) as PAYMENTMODEL,
        cast(PREPARERCODE as VARCHAR(16777216)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as NUMBER(38,0)) as PREVIOUSVERSION,
        cast(PROCESSEDSTATE as NUMBER(38,0)) as PROCESSEDSTATE,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(PROJECTID as VARCHAR(16777216)) as PROJECTID,
        cast(PROJECTTITLE as VARCHAR(16777216)) as PROJECTTITLE,
        cast(REJECTEDDATE as TIMESTAMP_NTZ(9)) as REJECTEDDATE,
        cast(REMITTANCELOCATIONCODE as VARCHAR(16777216)) as REMITTANCELOCATIONCODE,
        cast(REQUESTERCODE as VARCHAR(16777216)) as REQUESTERCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(SCHEDULEDPAYMENTDATE as TIMESTAMP_NTZ(9)) as SCHEDULEDPAYMENTDATE,
        cast(SERVICELOCATIONCITY as VARCHAR(16777216)) as SERVICELOCATIONCITY,
        cast(SERVICELOCATIONCOUNTRYCODE as VARCHAR(16777216)) as SERVICELOCATIONCOUNTRYCODE,
        cast(SERVICELOCATIONFAX as VARCHAR(16777216)) as SERVICELOCATIONFAX,
        cast(SERVICELOCATIONLINES as VARCHAR(16777216)) as SERVICELOCATIONLINES,
        cast(SERVICELOCATIONNAME as VARCHAR(16777216)) as SERVICELOCATIONNAME,
        cast(SERVICELOCATIONPHONE as VARCHAR(16777216)) as SERVICELOCATIONPHONE,
        cast(SERVICELOCATIONPOSTALCODE as VARCHAR(16777216)) as SERVICELOCATIONPOSTALCODE,
        cast(SERVICELOCATIONSTATE as VARCHAR(16777216)) as SERVICELOCATIONSTATE,
        cast(SERVICELOCATIONCODE as VARCHAR(16777216)) as SERVICELOCATIONCODE,
        cast(SERVICEPERIODFROMDATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODFROMDATE,
        cast(SERVICEPERIODPERIOD as VARCHAR(16777216)) as SERVICEPERIODPERIOD,
        cast(SERVICEPERIODTODATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODTODATE,
        cast(SOURCINGSTATUSSTRING as VARCHAR(16777216)) as SOURCINGSTATUSSTRING,
        cast(STATUSSTRING as VARCHAR(16777216)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(SUPPLIERNAME as VARCHAR(16777216)) as SUPPLIERNAME,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777216)) as SUPPLIERLOCATIONCODE,
        cast(TAXACCRUALAMOUNTAMOUNT as NUMBER(38,10)) as TAXACCRUALAMOUNTAMOUNT,
        cast(TAXACCRUALAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXACCRUALAMOUNTBASECURRENCY,
        cast(TAXACCRUALAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXACCRUALAMOUNTCONVERSIONDATE,
        cast(TAXACCRUALAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXACCRUALAMOUNTCURRENCYCODE,
        cast(TAXACCRUALAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXACCRUALAMOUNTREPORTINGCURRENCY,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTBASECURRENCY,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILSABATEMENTPERCENT as NUMBER(38,10)) as TAXDETAILSABATEMENTPERCENT,
        cast(TAXDETAILSCATEGORY as VARCHAR(16777216)) as TAXDETAILSCATEGORY,
        cast(TAXDETAILSCOMPONENTCODE as VARCHAR(16777216)) as TAXDETAILSCOMPONENTCODE,
        cast(TAXDETAILSDESCRIPTION as VARCHAR(16777216)) as TAXDETAILSDESCRIPTION,
        cast(TAXDETAILSEXEMPTDETAIL as VARCHAR(16777216)) as TAXDETAILSEXEMPTDETAIL,
        cast(TAXDETAILSFORMULASTRING as VARCHAR(16777216)) as TAXDETAILSFORMULASTRING,
        cast(TAXDETAILSISDEDUCTIBLE as BOOLEAN) as TAXDETAILSISDEDUCTIBLE,
        cast(TAXDETAILSISTRIANGULARTRANSACTION as BOOLEAN) as TAXDETAILSISTRIANGULARTRANSACTION,
        cast(TAXDETAILSPAYMENTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILSPAYMENTDATE,
        cast(TAXDETAILSPERUNIT as NUMBER(38,10)) as TAXDETAILSPERUNIT,
        cast(TAXDETAILSPERCENT as NUMBER(38,10)) as TAXDETAILSPERCENT,
        cast(TAXDETAILSPURPOSE as VARCHAR(16777216)) as TAXDETAILSPURPOSE,
        cast(TAXDETAILSTAXLOCATION as VARCHAR(16777216)) as TAXDETAILSTAXLOCATION,
        cast(TAXDETAILSTAXPOINTDATE as TIMESTAMP_NTZ(9)) as TAXDETAILSTAXPOINTDATE,
        cast(TAXDETAILSTAXABLEAMOUNTAMOUNT as NUMBER(38,10)) as TAXDETAILSTAXABLEAMOUNTAMOUNT,
        cast(TAXDETAILSTAXABLEAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXDETAILSTAXABLEAMOUNTBASECURRENCY,
        cast(TAXDETAILSTAXABLEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILSTAXABLEAMOUNTCONVERSIONDATE,
        cast(TAXDETAILSTAXABLEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILSTAXABLEAMOUNTCURRENCYCODE,
        cast(TAXDETAILSTAXABLEAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILSTAXABLEAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILSTRIANGULARTRANSACTIONLAWREFERENCE as VARCHAR(16777216)) as TAXDETAILSTRIANGULARTRANSACTIONLAWREFERENCE,
        cast(TIMECREATED as TIMESTAMP_NTZ(9)) as TIMECREATED,
        cast(TIMEUPDATED as TIMESTAMP_NTZ(9)) as TIMEUPDATED,
        cast(TOTALINVOICEDAMOUNT as NUMBER(38,10)) as TOTALINVOICEDAMOUNT,
        cast(TOTALINVOICEDBASECURRENCY as NUMBER(38,10)) as TOTALINVOICEDBASECURRENCY,
        cast(TOTALINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALINVOICEDCONVERSIONDATE,
        cast(TOTALINVOICEDCURRENCYCODE as VARCHAR(16777216)) as TOTALINVOICEDCURRENCYCODE,
        cast(TOTALINVOICEDREPORTINGCURRENCY as NUMBER(38,10)) as TOTALINVOICEDREPORTINGCURRENCY,
        cast(TOTALWITHHOLDINGTAXAMOUNT as NUMBER(38,10)) as TOTALWITHHOLDINGTAXAMOUNT,
        cast(TOTALWITHHOLDINGTAXBASECURRENCY as NUMBER(38,10)) as TOTALWITHHOLDINGTAXBASECURRENCY,
        cast(TOTALWITHHOLDINGTAXCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALWITHHOLDINGTAXCONVERSIONDATE,
        cast(TOTALWITHHOLDINGTAXCURRENCYCODE as VARCHAR(16777216)) as TOTALWITHHOLDINGTAXCURRENCYCODE,
        cast(TOTALWITHHOLDINGTAXREPORTINGCURRENCY as NUMBER(38,10)) as TOTALWITHHOLDINGTAXREPORTINGCURRENCY,
        cast(UNIQUENAME as VARCHAR(16777216)) as UNIQUENAME,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTBASECURRENCY as NUMBER(38,10)) as VATAMOUNTBASECURRENCY,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(VATAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTREPORTINGCURRENCY,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(CUSTOMFIELD_BPO as BOOLEAN) as CUSTOMFIELD_BPO,
        cast(CUSTOMFIELD_BUYERNAME as VARCHAR(16777126)) as CUSTOMFIELD_BUYERNAME,
        cast(CUSTOMFIELD_CONTACTDETAILS as VARCHAR(16777126)) as CUSTOMFIELD_CONTACTDETAILS,
        cast(CUSTOMFIELD_DINNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_DINNUMBER,
        cast(CUSTOMFIELD_ENDDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_ENDDATE,
        cast(CUSTOMFIELD_ISBAANSPECIFIC as BOOLEAN) as CUSTOMFIELD_ISBAANSPECIFIC,
        cast(CUSTOMFIELD_ISBPO as BOOLEAN) as CUSTOMFIELD_ISBPO,
        cast(CUSTOMFIELD_STARTDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_STARTDATE,
        cast(CUSTOMFIELD_UPSNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_UPSNUMBER,

        cast(null as VARCHAR(16777216)) as PAIDAMOUNTADJUSTMENTAMOUNTREASON,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTADJUSTMENTAMOUNTAMOUNT,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTADJUSTMENTAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTADJUSTMENTAMOUNTAMOUNTINBASECURRENCY,
        cast(null as TIMESTAMP_NTZ(9)) as PAIDAMOUNTADJUSTMENTAMOUNTCONVERSIONDATE,
        cast(null as VARCHAR(16777216)) as PAIDAMOUNTADJUSTMENTAMOUNTCURRENCYCODE,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTGROSSAMOUNTAMOUNT,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTGROSSAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTGROSSAMOUNTAMOUNTINBASECURRENCY,
        cast(null as TIMESTAMP_NTZ(9)) as PAIDAMOUNTGROSSAMOUNTCONVERSIONDATE,
        cast(null as VARCHAR(16777216)) as PAIDAMOUNTGROSSAMOUNTCURRENCYCODE,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTDISCOUNTAMOUNTAMOUNT,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTDISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTDISCOUNTAMOUNTAMOUNTINBASECURRENCY,
        cast(null as TIMESTAMP_NTZ(9)) as PAIDAMOUNTDISCOUNTAMOUNTCONVERSIONDATE,
        cast(null as VARCHAR(16777216)) as PAIDAMOUNTDISCOUNTAMOUNTCURRENCYCODE,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTNETAMOUNTAMOUNT,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTNETAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(null as NUMBER(38,10)) as PAIDAMOUNTNETAMOUNTAMOUNTINBASECURRENCY,
        cast(null as TIMESTAMP_NTZ(9)) as PAIDAMOUNTNETAMOUNTCONVERSIONDATE,
        cast(null as VARCHAR(16777216)) as PAIDAMOUNTNETAMOUNTCURRENCYCODE,

        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data