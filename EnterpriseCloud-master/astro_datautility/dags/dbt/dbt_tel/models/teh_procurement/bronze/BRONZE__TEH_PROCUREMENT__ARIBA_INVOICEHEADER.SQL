{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_INVOICEHEADER',
    unique_key = ['RealmName',
    'InvoiceIdKey',
    'InvoiceVersionKey']
) }}


with source_data as
(
    SELECT
        JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:AccountReceivableId::STRING AS AccountReceivableId
        ,JsonField:Active::BOOLEAN AS Active
        ,JsonField:ApprovalRequestsVersion::INTEGER AS ApprovalRequestsVersion
        ,JsonField:ApprovedDate::TIMESTAMP_NTZ AS ApprovedDate
        ,JsonField:ApprovedState::INTEGER AS ApprovedState
        ,JsonField:Category::INTEGER AS Category
        ,parse_json(JsonField:ChangedBy):UniqueName::STRING AS ChangedByCode
        ,parse_json(JsonField:CompanyCode):UniqueName::STRING AS CompanyCodeCode
        ,JsonField:CreateDate::TIMESTAMP_NTZ AS CreateDate
        ,JsonField:HeaderLevel::BOOLEAN AS HeaderLevel
        ,JsonField:HoldTillDate::TIMESTAMP_NTZ AS HoldTillDate
        ,JsonField:InitialUniqueName::STRING AS InitialUniqueName
        ,JsonField:InvoiceDate::TIMESTAMP_NTZ AS InvoiceDate
        ,JsonField:InvoiceNumber::STRING AS InvoiceNumber
        ,JsonField:InvoiceOrigin::STRING AS InvoiceOrigin
        ,JsonField:InvoiceOriginType::INTEGER AS InvoiceOriginType
        ,JsonField:InvoicePurpose::STRING AS InvoicePurpose
        ,JsonField:InvoiceSourceDocument::STRING AS InvoiceSourceDocument
        ,JsonField:InvoiceState::INTEGER AS InvoiceState
        ,JsonField:InvoiceStatusString::STRING AS InvoiceStatusString
        ,JsonField:InvoiceSubmissionMethod::STRING AS InvoiceSubmissionMethod
        ,parse_json(JsonField:InvoiceToCredit):UniqueName::STRING AS InvoiceToCreditCode
        ,JsonField:IsNonPO::BOOLEAN AS IsNonPO
        ,JsonField:IsTaxInLine::BOOLEAN AS IsTaxInLine
        ,JsonField:LastModified::TIMESTAMP_NTZ AS LastModified
        ,parse_json(JsonField:MasterAgreement):UniqueName::STRING AS MasterAgreementCode
        ,parse_json(JsonField:MaxDiscountApplicable):Amount::NUMBER(38,10) AS MaxDiscountApplicableAmount
        ,parse_json(JsonField:MaxDiscountApplicable):BaseCurrency::NUMBER(38,10) AS MaxDiscountApplicableBaseCurrency
        ,parse_json(JsonField:MaxDiscountApplicable):ConversionDate::TIMESTAMP_NTZ AS MaxDiscountApplicableConversionDate
        ,parse_json(JsonField:MaxDiscountApplicable):Currency:UniqueName::STRING AS MaxDiscountApplicableCurrencyCode
        ,parse_json(JsonField:MaxDiscountApplicable):ReportingCurrency::NUMBER(38,10) AS MaxDiscountApplicableReportingCurrency
        ,JsonField:Name::STRING AS Name
        ,JsonField:NextVersion::STRING AS NextVersion
        ,JsonField:ObjectType::STRING AS ObjectType
        ,parse_json(JsonField:Order):UniqueName::STRING AS OrderCode
        ,parse_json(JsonField:PaymentTerms):UniqueName::STRING AS PaymentTermsCode
        ,parse_json(JsonField:Preparer):UniqueName::STRING AS PreparerCode
        ,JsonField:PreviousApprovalRequestsVersion::INTEGER AS PreviousApprovalRequestsVersion
        ,JsonField:PreviousVersion::STRING AS PreviousVersion
        ,parse_json(JsonField:PurchaseOrg):UniqueName::STRING AS PurchaseOrgCode
        ,JsonField:ReconciledDate::TIMESTAMP_NTZ AS ReconciledDate
        ,parse_json(JsonField:RemitToAddress):City::STRING AS RemitToAddressCity
        ,parse_json(JsonField:RemitToAddress):Country:UniqueName::STRING AS RemitToAddressCountryCode
        ,parse_json(JsonField:RemitToAddress):Fax::STRING AS RemitToAddressFax
        ,parse_json(JsonField:RemitToAddress):Lines::STRING AS RemitToAddressLines
        ,parse_json(JsonField:RemitToAddress):Name::STRING AS RemitToAddressName
        ,parse_json(JsonField:RemitToAddress):Phone::STRING AS RemitToAddressPhone
        ,parse_json(JsonField:RemitToAddress):PostalCode::STRING AS RemitToAddressPostalCode
        ,parse_json(JsonField:RemitToAddress):State::STRING AS RemitToAddressState
        ,parse_json(JsonField:RemitToAddress):UniqueName::STRING AS RemitToAddressCode
        ,JsonField:RemitToId::STRING AS RemitToId
        ,parse_json(JsonField:Requester):UniqueName::STRING AS RequesterCode
        ,JsonField:ResubmitDate::TIMESTAMP_NTZ AS ResubmitDate
        ,JsonField:ScheduledPaymentDate::TIMESTAMP_NTZ AS ScheduledPaymentDate
        ,parse_json(JsonField:ServiceLocation):City::STRING AS ServiceLocationCity
        ,parse_json(JsonField:ServiceLocation):CountryUniqueName::STRING AS ServiceLocationCountryCode
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
        ,JsonField:Signed::BOOLEAN AS Signed
        ,parse_json(JsonField:SoldTo):City::STRING AS SoldToCity
        ,parse_json(JsonField:SoldTo):Country:UniqueName::STRING AS SoldToCountryCode
        ,parse_json(JsonField:SoldTo):Fax::STRING AS SoldToFax
        ,parse_json(JsonField:SoldTo):Lines::STRING AS SoldToLines
        ,parse_json(JsonField:SoldTo):Name::STRING AS SoldToName
        ,parse_json(JsonField:SoldTo):Phone::STRING AS SoldToPhone
        ,parse_json(JsonField:SoldTo):PostalCode::STRING AS SoldToPostalCode
        ,parse_json(JsonField:SoldTo):State::STRING AS SoldToState
        ,parse_json(JsonField:SoldTo):UniqueName::STRING AS SoldToCode
        ,JsonField:StatusString::STRING AS StatusString
        ,JsonField:SubmitDate::TIMESTAMP_NTZ AS SubmitDate
        ,parse_json(JsonField:Supplier):Name::STRING AS SupplierName
        ,parse_json(JsonField:Supplier):UniqueName::STRING AS SupplierCode
        ,parse_json(JsonField:SupplierLocation):UniqueName::STRING AS SupplierLocationCode
        ,JsonField:TaxExchangeRate::NUMBER(38,10) AS TaxExchangeRate
        ,JsonField:TimeCreated::TIMESTAMP_NTZ AS TimeCreated
        ,JsonField:TimeUpdated::TIMESTAMP_NTZ AS TimeUpdated
        ,parse_json(JsonField:TaxAmount):Amount::NUMBER(38,10) AS TaxAmountAmount
        ,parse_json(JsonField:TaxAmount):BaseCurrency::NUMBER(38,10) AS TaxAmountBaseCurrency
        ,parse_json(JsonField:TaxAmount):ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,parse_json(JsonField:TaxAmount):Currency:UniqueName::STRING AS TaxAmountCurrencyCode
        ,parse_json(JsonField:TaxAmount):ReportingCurrency::NUMBER(38,10) AS TaxAmountReportingCurrency
        ,parse_json(JsonField:TaxDetails):Amount::NUMBER(38,10) AS TaxDetailsAmount
        ,parse_json(JsonField:TaxDetails):BaseCurrency::NUMBER(38,10) AS TaxDetailsBaseCurrency
        ,parse_json(JsonField:TaxDetails):ConversionDate::TIMESTAMP_NTZ AS TaxDetailsConversionDate
        ,parse_json(JsonField:TaxDetails):Currency:UniqueName::STRING AS TaxDetailsCurrencyCode
        ,parse_json(JsonField:TaxDetails):ReportingCurrency::NUMBER(38,10) AS TaxDetailsReportingCurrency
        ,parse_json(JsonField:TotalCost):Amount::NUMBER(38,10) AS TotalCostAmount
        ,parse_json(JsonField:TotalCost):BaseCurrency::NUMBER(38,10) AS TotalCostBaseCurrency
        ,parse_json(JsonField:TotalCost):ConversionDate::TIMESTAMP_NTZ AS TotalCostConversionDate
        ,parse_json(JsonField:TotalCost):Currency:UniqueName::STRING AS TotalCostCurrencyCode
        ,parse_json(JsonField:TotalCost):ReportingCurrency::NUMBER(38,10) AS TotalCostReportingCurrency
        ,parse_json(JsonField:TotalInvoiced):Amount::NUMBER(38,10) AS TotalInvoicedAmount
        ,parse_json(JsonField:TotalInvoiced):BaseCurrency::NUMBER(38,10) AS TotalInvoicedBaseCurrency
        ,parse_json(JsonField:TotalInvoiced):ConversionDate::TIMESTAMP_NTZ AS TotalInvoicedConversionDate
        ,parse_json(JsonField:TotalInvoiced):Currency:UniqueName::STRING AS TotalInvoicedCurrencyCode
        ,parse_json(JsonField:TotalInvoiced):ReportingCurrency::NUMBER(38,10) AS TotalInvoicedReportingCurrency
        ,parse_json(JsonField:TotalInvoicedLessTax):Amount::NUMBER(38,10) AS TotalInvoicedLessTaxAmount
        ,parse_json(JsonField:TotalInvoicedLessTax):BaseCurrency::NUMBER(38,10) AS TotalInvoicedLessTaxBaseCurrency
        ,parse_json(JsonField:TotalInvoicedLessTax):ConversionDate::TIMESTAMP_NTZ AS TotalInvoicedLessTaxConversionDate
        ,parse_json(JsonField:TotalInvoicedLessTax):Currency:UniqueName::STRING AS TotalInvoicedLessTaxCurrencyCode
        ,parse_json(JsonField:TotalInvoicedLessTax):ReportingCurrency::NUMBER(38,10) AS TotalInvoicedLessTaxReportingCurrency
        ,parse_json(JsonField:TotalTax):Amount::NUMBER(38,10) AS TotalTaxAmount
        ,parse_json(JsonField:TotalTax):BaseCurrency::NUMBER(38,10) AS TotalTaxBaseCurrency
        ,parse_json(JsonField:TotalTax):ConversionDate::TIMESTAMP_NTZ AS TotalTaxConversionDate
        ,parse_json(JsonField:TotalTax):Currency:UniqueName::STRING AS TotalTaxCurrencyCode
        ,JsonField:TotalTaxReportingCurrency::NUMBER(38,10) AS TotalTaxReportingCurrency
        ,parse_json(JsonField:TotalWithholdingTax):Amount::NUMBER(38,10) AS TotalWithholdingTaxAmount
        ,parse_json(JsonField:TotalWithholdingTax):BaseCurrency::NUMBER(38,10) AS TotalWithholdingTaxBaseCurrency
        ,parse_json(JsonField:TotalWithholdingTax):ConversionDate::TIMESTAMP_NTZ AS TotalWithholdingTaxConversionDate
        ,parse_json(JsonField:TotalWithholdingTax):Currency:UniqueName::STRING AS TotalWithholdingTaxCurrencyCode
        ,parse_json(JsonField:TotalWithholdingTax):ReportingCurrency::NUMBER(38,10) AS TotalWithholdingTaxReportingCurrency
        ,JsonField:UpperCaseInvoiceNumber::STRING AS UpperCaseInvoiceNumber
        ,JsonField:UniqueName::STRING AS UniqueName
        ,parse_json(JsonField:VATAmount):Amount::NUMBER(38,10) AS VATAmountAmount
        ,parse_json(JsonField:VATAmount):BaseCurrency::NUMBER(38,10) AS VATAmountBaseCurrency
        ,parse_json(JsonField:VATAmount):ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,parse_json(JsonField:VATAmount):Currency:UniqueName::STRING AS VATAmountCurrencyCode
        ,parse_json(JsonField:VATAmount):ReportingCurrency::NUMBER(38,10) AS VATAmountReportingCurrency
        ,JsonField:VersionNumber::NUMBER(38,10) AS VersionNumber
        ,JsonField:cus_BPO::BOOLEAN AS CustomField_BPO
        ,JsonField:CompanyCode.cus_BuyerName::STRING AS CustomField_CompanyCodeBuyerName
        ,JsonField:CompanyCode.cus_ContactDetails::STRING AS CustomField_CompanyCodeContactDetails
        ,JsonField:CompanyCode.cus_UPSNumber::STRING AS CustomField_CompanyCodeUPSNumber
        ,JsonField:cus_DINNumber::STRING AS CustomField_DINNumber
        ,JsonField:cus_EndDate::STRING AS CustomField_EndDate
        ,JsonField:cus_IsBaanSpecific::BOOLEAN AS CustomField_IsBaanSpecific
        ,JsonField:cus_IsBPO::BOOLEAN AS CustomField_IsBPO
        ,JsonField:cus_StartDate::STRING AS CustomField_StartDate
        FROM {{ source("ARIBA", "INVOICE") }} LZData
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
        source_data.UNIQUENAME AS InvoiceIdKey,
        source_data.VERSIONNUMBER AS InvoiceVersionKey,
        source_data.ACCOUNTRECEIVABLEID AS AccountReceivableId,
        source_data.ACTIVE AS Active,
        source_data.APPROVALREQUESTSVERSION AS ApprovalRequestsVersion,
        source_data.APPROVEDDATE AS ApprovedDate,
        source_data.APPROVEDSTATE AS ApprovedState,
        source_data.CATEGORY AS Category,
        source_data.CHANGEDBYCODE AS ChangedByCode,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.CREATEDATE AS CreateDate,
        source_data.HEADERLEVEL AS HeaderLevel,
        source_data.HOLDTILLDATE AS HoldTillDate,
        source_data.INITIALUNIQUENAME AS InitialUniqueName,
        source_data.INVOICEDATE AS InvoiceDate,
        source_data.INVOICENUMBER AS InvoiceNumber,
        source_data.INVOICEORIGIN AS InvoiceOrigin,
        source_data.INVOICEORIGINTYPE AS InvoiceOriginType,
        source_data.INVOICEPURPOSE AS InvoicePurpose,
        source_data.INVOICESOURCEDOCUMENT AS InvoiceSourceDocument,
        source_data.INVOICESTATE AS InvoiceState,
        source_data.INVOICESTATUSSTRING AS InvoiceStatusString,
        source_data.INVOICESUBMISSIONMETHOD AS InvoiceSubmissionMethod,
        source_data.INVOICETOCREDITCODE AS InvoiceToCreditCode,
        source_data.ISNONPO AS IsNonPO,
        source_data.ISTAXINLINE AS IsTaxInLine,
        source_data.LASTMODIFIED AS LastModified,
        source_data.MASTERAGREEMENTCODE AS MasterAgreementCode,
        source_data.MAXDISCOUNTAPPLICABLEAMOUNT AS MaxDiscountApplicableAmount,
        source_data.MAXDISCOUNTAPPLICABLEBASECURRENCY AS MaxDiscountApplicableBaseCurrency,
        source_data.MAXDISCOUNTAPPLICABLECONVERSIONDATE AS MaxDiscountApplicableConversionDate,
        source_data.MAXDISCOUNTAPPLICABLECURRENCYCODE AS MaxDiscountApplicableCurrencyCode,
        source_data.MAXDISCOUNTAPPLICABLEREPORTINGCURRENCY AS MaxDiscountApplicableReportingCurrency,
        source_data.NAME AS Name,
        source_data.NEXTVERSION AS NextVersion,
        source_data.OBJECTTYPE AS ObjectType,
        source_data.ORDERCODE AS OrderCode,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.PREPARERCODE AS PreparerCode,
        source_data.PREVIOUSAPPROVALREQUESTSVERSION AS PreviousApprovalRequestsVersion,
        source_data.PREVIOUSVERSION AS PreviousVersion,
        source_data.PURCHASEORGCODE AS PurchaseOrgCode,
        source_data.RECONCILEDDATE AS ReconciledDate,
        source_data.REMITTOADDRESSCITY AS RemitToAddressCity,
        source_data.REMITTOADDRESSCOUNTRYCODE AS RemitToAddressCountryCode,
        source_data.REMITTOADDRESSFAX AS RemitToAddressFax,
        source_data.REMITTOADDRESSLINES AS RemitToAddressLines,
        source_data.REMITTOADDRESSNAME AS RemitToAddressName,
        source_data.REMITTOADDRESSPHONE AS RemitToAddressPhone,
        source_data.REMITTOADDRESSPOSTALCODE AS RemitToAddressPostalCode,
        source_data.REMITTOADDRESSSTATE AS RemitToAddressState,
        source_data.REMITTOADDRESSCODE AS RemitToAddressCode,
        source_data.REMITTOID AS RemitToId,
        source_data.REQUESTERCODE AS RequesterCode,
        source_data.RESUBMITDATE AS ResubmitDate,
        source_data.SCHEDULEDPAYMENTDATE AS ScheduledPaymentDate,
        source_data.SERVICELOCATIONCITY AS ServiceLocationCity,
        source_data.SERVICELOCATIONCOUNTRYCODE AS ServiceLocationCountryCode,
        source_data.SERVICELOCATIONFAX AS ServiceLocationFax,
        source_data.SERVICELOCATIONPHONE AS ServiceLocationPhone,
        source_data.SERVICELOCATIONLINES AS ServiceLocationLines,
        source_data.SERVICELOCATIONNAME AS ServiceLocationName,
        source_data.SERVICELOCATIONPOSTALCODE AS ServiceLocationPostalCode,
        source_data.SERVICELOCATIONSTATE AS ServiceLocationState,
        source_data.SERVICELOCATIONCODE AS ServiceLocationCode,
        source_data.SERVICEPERIODFROMDATE AS ServicePeriodFromDate,
        source_data.SERVICEPERIODPERIOD AS ServicePeriodPeriod,
        source_data.SERVICEPERIODTODATE AS ServicePeriodToDate,
        source_data.SIGNED AS Signed,
        source_data.SOLDTOCITY AS SoldToCity,
        source_data.SOLDTOCOUNTRYCODE AS SoldToCountryCode,
        source_data.SOLDTOFAX AS SoldToFax,
        source_data.SOLDTOLINES AS SoldToLines,
        source_data.SOLDTONAME AS SoldToName,
        source_data.SOLDTOPHONE AS SoldToPhone,
        source_data.SOLDTOPOSTALCODE AS SoldToPostalCode,
        source_data.SOLDTOSTATE AS SoldToState,
        source_data.SOLDTOCODE AS SoldToCode,
        source_data.STATUSSTRING AS StatusString,
        source_data.SUBMITDATE AS SubmitDate,
        source_data.SUPPLIERNAME AS SupplierName,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.TAXEXCHANGERATE AS TaxExchangeRate,
        source_data.TIMECREATED AS TimeCreated,
        source_data.TIMEUPDATED AS TimeUpdated,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTBASECURRENCY AS TaxAmountBaseCurrency,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXAMOUNTREPORTINGCURRENCY AS TaxAmountReportingCurrency,
        source_data.TAXDETAILSAMOUNT AS TaxDetailsAmount,
        source_data.TAXDETAILSBASECURRENCY AS TaxDetailsBaseCurrency,
        source_data.TAXDETAILSCONVERSIONDATE AS TaxDetailsConversionDate,
        source_data.TAXDETAILSCURRENCYCODE AS TaxDetailsCurrencyCode,
        source_data.TAXDETAILSREPORTINGCURRENCY AS TaxDetailsReportingCurrency,
        source_data.TOTALCOSTAMOUNT AS TotalCostAmount,
        source_data.TOTALCOSTBASECURRENCY AS TotalCostBaseCurrency,
        source_data.TOTALCOSTCONVERSIONDATE AS TotalCostConversionDate,
        source_data.TOTALCOSTCURRENCYCODE AS TotalCostCurrencyCode,
        source_data.TOTALCOSTREPORTINGCURRENCY AS TotalCostReportingCurrency,
        source_data.TOTALINVOICEDAMOUNT AS TotalInvoicedAmount,
        source_data.TOTALINVOICEDBASECURRENCY AS TotalInvoicedBaseCurrency,
        source_data.TOTALINVOICEDCONVERSIONDATE AS TotalInvoicedConversionDate,
        source_data.TOTALINVOICEDCURRENCYCODE AS TotalInvoicedCurrencyCode,
        source_data.TOTALINVOICEDREPORTINGCURRENCY AS TotalInvoicedReportingCurrency,
        source_data.TOTALINVOICEDLESSTAXAMOUNT AS TotalInvoicedLessTaxAmount,
        source_data.TOTALINVOICEDLESSTAXBASECURRENCY AS TotalInvoicedLessTaxBaseCurrency,
        source_data.TOTALINVOICEDLESSTAXCONVERSIONDATE AS TotalInvoicedLessTaxConversionDate,
        source_data.TOTALINVOICEDLESSTAXCURRENCYCODE AS TotalInvoicedLessTaxCurrencyCode,
        source_data.TOTALINVOICEDLESSTAXREPORTINGCURRENCY AS TotalInvoicedLessTaxReportingCurrency,
        source_data.TOTALTAXAMOUNT AS TotalTaxAmount,
        source_data.TOTALTAXBASECURRENCY AS TotalTaxBaseCurrency,
        source_data.TOTALTAXCONVERSIONDATE AS TotalTaxConversionDate,
        source_data.TOTALTAXCURRENCYCODE AS TotalTaxCurrencyCode,
        source_data.TOTALTAXREPORTINGCURRENCY AS TotalTaxReportingCurrency,
        source_data.TOTALWITHHOLDINGTAXAMOUNT AS TotalWithholdingTaxAmount,
        source_data.TOTALWITHHOLDINGTAXBASECURRENCY AS TotalWithholdingTaxBaseCurrency,
        source_data.TOTALWITHHOLDINGTAXCONVERSIONDATE AS TotalWithholdingTaxConversionDate,
        source_data.TOTALWITHHOLDINGTAXCURRENCYCODE AS TotalWithholdingTaxCurrencyCode,
        source_data.TOTALWITHHOLDINGTAXREPORTINGCURRENCY AS TotalWithholdingTaxReportingCurrency,
        source_data.UPPERCASEINVOICENUMBER AS UpperCaseInvoiceNumber,
        source_data.UNIQUENAME AS UniqueName,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTBASECURRENCY AS VATAmountBaseCurrency,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.VATAMOUNTREPORTINGCURRENCY AS VATAmountReportingCurrency,
        source_data.VERSIONNUMBER AS VersionNumber,
        source_data.CUSTOMFIELD_BPO AS CustomField_BPO,
        source_data.CUSTOMFIELD_COMPANYCODEBUYERNAME AS CustomField_CompanyCodeBuyerName,
        source_data.CUSTOMFIELD_COMPANYCODECONTACTDETAILS AS CustomField_CompanyCodeContactDetails,
        source_data.CUSTOMFIELD_COMPANYCODEUPSNUMBER AS CustomField_CompanyCodeUPSNumber,
        source_data.CUSTOMFIELD_DINNUMBER AS CustomField_DINNumber,
        source_data.CUSTOMFIELD_ENDDATE AS CustomField_EndDate,
        source_data.CUSTOMFIELD_ISBAANSPECIFIC AS CustomField_IsBaanSpecific,
        source_data.CUSTOMFIELD_ISBPO AS CustomField_IsBPO,
        source_data.CUSTOMFIELD_STARTDATE AS CustomField_StartDate,
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
        cast(ACCOUNTRECEIVABLEID as VARCHAR(16777216)) as ACCOUNTRECEIVABLEID,
        cast(ACTIVE as BOOLEAN) as ACTIVE,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as NUMBER(38,0)) as APPROVEDSTATE,
        cast(CATEGORY as NUMBER(38,0)) as CATEGORY,
        cast(CHANGEDBYCODE as VARCHAR(16777216)) as CHANGEDBYCODE,
        cast(COMPANYCODECODE as VARCHAR(16777216)) as COMPANYCODECODE,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(HEADERLEVEL as BOOLEAN) as HEADERLEVEL,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALUNIQUENAME as VARCHAR(16777216)) as INITIALUNIQUENAME,
        cast(INVOICEDATE as TIMESTAMP_NTZ(9)) as INVOICEDATE,
        cast(INVOICENUMBER as VARCHAR(16777216)) as INVOICENUMBER,
        cast(INVOICEORIGIN as VARCHAR(16777216)) as INVOICEORIGIN,
        cast(INVOICEORIGINTYPE as NUMBER(38,0)) as INVOICEORIGINTYPE,
        cast(INVOICEPURPOSE as VARCHAR(16777216)) as INVOICEPURPOSE,
        cast(INVOICESOURCEDOCUMENT as VARCHAR(16777216)) as INVOICESOURCEDOCUMENT,
        cast(INVOICESTATE as NUMBER(38,0)) as INVOICESTATE,
        cast(INVOICESTATUSSTRING as VARCHAR(16777216)) as INVOICESTATUSSTRING,
        cast(INVOICESUBMISSIONMETHOD as VARCHAR(16777216)) as INVOICESUBMISSIONMETHOD,
        cast(INVOICETOCREDITCODE as VARCHAR(16777216)) as INVOICETOCREDITCODE,
        cast(ISNONPO as BOOLEAN) as ISNONPO,
        cast(ISTAXINLINE as BOOLEAN) as ISTAXINLINE,
        cast(LASTMODIFIED as TIMESTAMP_NTZ(9)) as LASTMODIFIED,
        cast(MASTERAGREEMENTCODE as VARCHAR(16777216)) as MASTERAGREEMENTCODE,
        cast(MAXDISCOUNTAPPLICABLEAMOUNT as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEAMOUNT,
        cast(MAXDISCOUNTAPPLICABLEBASECURRENCY as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEBASECURRENCY,
        cast(MAXDISCOUNTAPPLICABLECONVERSIONDATE as TIMESTAMP_NTZ(9)) as MAXDISCOUNTAPPLICABLECONVERSIONDATE,
        cast(MAXDISCOUNTAPPLICABLECURRENCYCODE as VARCHAR(16777216)) as MAXDISCOUNTAPPLICABLECURRENCYCODE,
        cast(MAXDISCOUNTAPPLICABLEREPORTINGCURRENCY as NUMBER(38,10)) as MAXDISCOUNTAPPLICABLEREPORTINGCURRENCY,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NEXTVERSION as VARCHAR(16777216)) as NEXTVERSION,
        cast(OBJECTTYPE as VARCHAR(16777216)) as OBJECTTYPE,
        cast(ORDERCODE as VARCHAR(16777216)) as ORDERCODE,
        cast(PAYMENTTERMSCODE as VARCHAR(16777216)) as PAYMENTTERMSCODE,
        cast(PREPARERCODE as VARCHAR(16777216)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as VARCHAR(16777216)) as PREVIOUSVERSION,
        cast(PURCHASEORGCODE as VARCHAR(16777216)) as PURCHASEORGCODE,
        cast(RECONCILEDDATE as TIMESTAMP_NTZ(9)) as RECONCILEDDATE,
        cast(REMITTOADDRESSCITY as VARCHAR(16777216)) as REMITTOADDRESSCITY,
        cast(REMITTOADDRESSCOUNTRYCODE as VARCHAR(16777216)) as REMITTOADDRESSCOUNTRYCODE,
        cast(REMITTOADDRESSFAX as VARCHAR(16777216)) as REMITTOADDRESSFAX,
        cast(REMITTOADDRESSLINES as VARCHAR(16777216)) as REMITTOADDRESSLINES,
        cast(REMITTOADDRESSNAME as VARCHAR(16777216)) as REMITTOADDRESSNAME,
        cast(REMITTOADDRESSPHONE as VARCHAR(16777216)) as REMITTOADDRESSPHONE,
        cast(REMITTOADDRESSPOSTALCODE as VARCHAR(16777216)) as REMITTOADDRESSPOSTALCODE,
        cast(REMITTOADDRESSSTATE as VARCHAR(16777216)) as REMITTOADDRESSSTATE,
        cast(REMITTOADDRESSCODE as VARCHAR(16777216)) as REMITTOADDRESSCODE,
        cast(REMITTOID as VARCHAR(16777216)) as REMITTOID,
        cast(REQUESTERCODE as VARCHAR(16777216)) as REQUESTERCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(SCHEDULEDPAYMENTDATE as TIMESTAMP_NTZ(9)) as SCHEDULEDPAYMENTDATE,
        cast(SERVICELOCATIONCITY as VARCHAR(16777216)) as SERVICELOCATIONCITY,
        cast(SERVICELOCATIONCOUNTRYCODE as VARCHAR(16777216)) as SERVICELOCATIONCOUNTRYCODE,
        cast(SERVICELOCATIONFAX as VARCHAR(16777216)) as SERVICELOCATIONFAX,
        cast(SERVICELOCATIONPHONE as VARCHAR(16777216)) as SERVICELOCATIONPHONE,
        cast(SERVICELOCATIONLINES as VARCHAR(16777216)) as SERVICELOCATIONLINES,
        cast(SERVICELOCATIONNAME as VARCHAR(16777216)) as SERVICELOCATIONNAME,
        cast(SERVICELOCATIONPOSTALCODE as VARCHAR(16777216)) as SERVICELOCATIONPOSTALCODE,
        cast(SERVICELOCATIONSTATE as VARCHAR(16777216)) as SERVICELOCATIONSTATE,
        cast(SERVICELOCATIONCODE as VARCHAR(16777216)) as SERVICELOCATIONCODE,
        cast(SERVICEPERIODFROMDATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODFROMDATE,
        cast(SERVICEPERIODPERIOD as VARCHAR(16777216)) as SERVICEPERIODPERIOD,
        cast(SERVICEPERIODTODATE as TIMESTAMP_NTZ(9)) as SERVICEPERIODTODATE,
        cast(SIGNED as BOOLEAN) as SIGNED,
        cast(SOLDTOCITY as VARCHAR(16777216)) as SOLDTOCITY,
        cast(SOLDTOCOUNTRYCODE as VARCHAR(16777216)) as SOLDTOCOUNTRYCODE,
        cast(SOLDTOFAX as VARCHAR(16777216)) as SOLDTOFAX,
        cast(SOLDTOLINES as VARCHAR(16777216)) as SOLDTOLINES,
        cast(SOLDTONAME as VARCHAR(16777216)) as SOLDTONAME,
        cast(SOLDTOPHONE as VARCHAR(16777216)) as SOLDTOPHONE,
        cast(SOLDTOPOSTALCODE as VARCHAR(16777216)) as SOLDTOPOSTALCODE,
        cast(SOLDTOSTATE as VARCHAR(16777216)) as SOLDTOSTATE,
        cast(SOLDTOCODE as VARCHAR(16777216)) as SOLDTOCODE,
        cast(STATUSSTRING as VARCHAR(16777216)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(SUPPLIERNAME as VARCHAR(16777216)) as SUPPLIERNAME,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777216)) as SUPPLIERLOCATIONCODE,
        cast(TAXEXCHANGERATE as NUMBER(38,10)) as TAXEXCHANGERATE,
        cast(TIMECREATED as TIMESTAMP_NTZ(9)) as TIMECREATED,
        cast(TIMEUPDATED as TIMESTAMP_NTZ(9)) as TIMEUPDATED,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTBASECURRENCY,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTREPORTINGCURRENCY,
        cast(TAXDETAILSAMOUNT as NUMBER(38,10)) as TAXDETAILSAMOUNT,
        cast(TAXDETAILSBASECURRENCY as NUMBER(38,10)) as TAXDETAILSBASECURRENCY,
        cast(TAXDETAILSCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXDETAILSCONVERSIONDATE,
        cast(TAXDETAILSCURRENCYCODE as VARCHAR(16777216)) as TAXDETAILSCURRENCYCODE,
        cast(TAXDETAILSREPORTINGCURRENCY as NUMBER(38,10)) as TAXDETAILSREPORTINGCURRENCY,
        cast(TOTALCOSTAMOUNT as NUMBER(38,10)) as TOTALCOSTAMOUNT,
        cast(TOTALCOSTBASECURRENCY as NUMBER(38,10)) as TOTALCOSTBASECURRENCY,
        cast(TOTALCOSTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALCOSTCONVERSIONDATE,
        cast(TOTALCOSTCURRENCYCODE as VARCHAR(16777216)) as TOTALCOSTCURRENCYCODE,
        cast(TOTALCOSTREPORTINGCURRENCY as NUMBER(38,10)) as TOTALCOSTREPORTINGCURRENCY,
        cast(TOTALINVOICEDAMOUNT as NUMBER(38,10)) as TOTALINVOICEDAMOUNT,
        cast(TOTALINVOICEDBASECURRENCY as NUMBER(38,10)) as TOTALINVOICEDBASECURRENCY,
        cast(TOTALINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALINVOICEDCONVERSIONDATE,
        cast(TOTALINVOICEDCURRENCYCODE as VARCHAR(16777216)) as TOTALINVOICEDCURRENCYCODE,
        cast(TOTALINVOICEDREPORTINGCURRENCY as NUMBER(38,10)) as TOTALINVOICEDREPORTINGCURRENCY,
        cast(TOTALINVOICEDLESSTAXAMOUNT as NUMBER(38,10)) as TOTALINVOICEDLESSTAXAMOUNT,
        cast(TOTALINVOICEDLESSTAXBASECURRENCY as NUMBER(38,10)) as TOTALINVOICEDLESSTAXBASECURRENCY,
        cast(TOTALINVOICEDLESSTAXCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALINVOICEDLESSTAXCONVERSIONDATE,
        cast(TOTALINVOICEDLESSTAXCURRENCYCODE as VARCHAR(16777216)) as TOTALINVOICEDLESSTAXCURRENCYCODE,
        cast(TOTALINVOICEDLESSTAXREPORTINGCURRENCY as NUMBER(38,10)) as TOTALINVOICEDLESSTAXREPORTINGCURRENCY,
        cast(TOTALTAXAMOUNT as NUMBER(38,10)) as TOTALTAXAMOUNT,
        cast(TOTALTAXBASECURRENCY as NUMBER(38,10)) as TOTALTAXBASECURRENCY,
        cast(TOTALTAXCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALTAXCONVERSIONDATE,
        cast(TOTALTAXCURRENCYCODE as VARCHAR(16777216)) as TOTALTAXCURRENCYCODE,
        cast(TOTALTAXREPORTINGCURRENCY as NUMBER(38,10)) as TOTALTAXREPORTINGCURRENCY,
        cast(TOTALWITHHOLDINGTAXAMOUNT as NUMBER(38,10)) as TOTALWITHHOLDINGTAXAMOUNT,
        cast(TOTALWITHHOLDINGTAXBASECURRENCY as NUMBER(38,10)) as TOTALWITHHOLDINGTAXBASECURRENCY,
        cast(TOTALWITHHOLDINGTAXCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALWITHHOLDINGTAXCONVERSIONDATE,
        cast(TOTALWITHHOLDINGTAXCURRENCYCODE as VARCHAR(16777216)) as TOTALWITHHOLDINGTAXCURRENCYCODE,
        cast(TOTALWITHHOLDINGTAXREPORTINGCURRENCY as NUMBER(38,10)) as TOTALWITHHOLDINGTAXREPORTINGCURRENCY,
        cast(UPPERCASEINVOICENUMBER as VARCHAR(16777216)) as UPPERCASEINVOICENUMBER,
        cast(UNIQUENAME as VARCHAR(16777216)) as UNIQUENAME,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTBASECURRENCY as NUMBER(38,10)) as VATAMOUNTBASECURRENCY,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(VATAMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTREPORTINGCURRENCY,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(CUSTOMFIELD_BPO as BOOLEAN) as CUSTOMFIELD_BPO,
        cast(CUSTOMFIELD_COMPANYCODEBUYERNAME as VARCHAR(16777126)) as CUSTOMFIELD_COMPANYCODEBUYERNAME,
        cast(CUSTOMFIELD_COMPANYCODECONTACTDETAILS as VARCHAR(16777126)) as CUSTOMFIELD_COMPANYCODECONTACTDETAILS,
        cast(CUSTOMFIELD_COMPANYCODEUPSNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_COMPANYCODEUPSNUMBER,
        cast(CUSTOMFIELD_DINNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_DINNUMBER,
        cast(CUSTOMFIELD_ENDDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_ENDDATE,
        cast(CUSTOMFIELD_ISBAANSPECIFIC as BOOLEAN) as CUSTOMFIELD_ISBAANSPECIFIC,
        cast(CUSTOMFIELD_ISBPO as BOOLEAN) as CUSTOMFIELD_ISBPO,
        cast(CUSTOMFIELD_STARTDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_STARTDATE,
        cast(INVOICEIDKEY as VARCHAR(16777216)) as INVOICEIDKEY,
        cast(INVOICEVERSIONKEY as NUMBER(38,10)) as INVOICEVERSIONKEY,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data