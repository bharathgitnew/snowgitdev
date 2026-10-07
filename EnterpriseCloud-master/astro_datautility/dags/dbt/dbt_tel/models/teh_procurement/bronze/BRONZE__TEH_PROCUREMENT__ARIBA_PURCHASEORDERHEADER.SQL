{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_PURCHASEORDERHEADER',
    unique_key = ['RealmName',
    'PurchaseOrderIdKey',
    'PurchaseOrderVersionKey']
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
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:Active::Boolean AS Active
        ,JsonField:AdvancedShipNoticeState::INTEGER AS AdvancedShipNoticeState
        ,parse_json(JsonField:AmountAccepted):Amount::NUMBER(38,10) AS AmountAcceptedAmount
        ,parse_json(JsonField:AmountAccepted):AmountInReportingCurrency::NUMBER(38,10) AS AmountAcceptedAmountInReportingCurrency
        ,parse_json(JsonField:AmountAccepted):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountAcceptedApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountAccepted):ConversionDate::TIMESTAMP_NTZ AS AmountAcceptedConversionDate
        ,parse_json(JsonField:AmountAccepted):Currency:UniqueName::STRING AS AmountAcceptedCurrencyCode
        ,parse_json(JsonField:AmountBilled):Amount::NUMBER(38,10) AS AmountBilledAmount
        ,parse_json(JsonField:AmountBilled):AmountInReportingCurrency::NUMBER(38,10) AS AmountBilledAmountInReportingCurrency
        ,parse_json(JsonField:AmountBilled):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountBilledApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountBilled):ConversionDate::TIMESTAMP_NTZ AS AmountBilledConversionDate
        ,parse_json(JsonField:AmountBilled):Currency:UniqueName::STRING AS AmountBilledCurrencyCode
        ,parse_json(JsonField:AmountCleared):Amount::NUMBER(38,10) AS AmountClearedAmount
        ,parse_json(JsonField:AmountCleared):AmountInReportingCurrency::NUMBER(38,10) AS AmountClearedAmountInReportingCurrency
        ,parse_json(JsonField:AmountCleared):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountClearedApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountCleared):ConversionDate::TIMESTAMP_NTZ AS AmountClearedConversionDate
        ,parse_json(JsonField:AmountCleared):Currency:UniqueName::STRING AS AmountClearedCurrencyCode
        ,parse_json(JsonField:AmountInvoiced):Amount::NUMBER(38,10) AS AmountInvoicedAmount
        ,parse_json(JsonField:AmountInvoiced):AmountInReportingCurrency::NUMBER(38,10) AS AmountInvoicedAmountInReportingCurrency
        ,parse_json(JsonField:AmountInvoiced):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountInvoicedApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountInvoiced):ConversionDate::TIMESTAMP_NTZ AS AmountInvoicedConversionDate
        ,parse_json(JsonField:AmountInvoiced):Currency:UniqueName::STRING AS AmountInvoicedCurrencyCode
        ,parse_json(JsonField:AmountReconciled):Amount::NUMBER(38,10) AS AmountReconciledAmount
        ,parse_json(JsonField:AmountReconciled):AmountInReportingCurrency::NUMBER(38,10) AS AmountReconciledAmountInReportingCurrency
        ,parse_json(JsonField:AmountReconciled):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountReconciledApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountReconciled):ConversionDate::TIMESTAMP_NTZ AS AmountReconciledConversionDate
        ,parse_json(JsonField:AmountReconciled):Currency:UniqueName::STRING AS AmountReconciledCurrencyCode
        ,parse_json(JsonField:AmountRejected):Amount::NUMBER(38,10) AS AmountRejectedAmount
        ,parse_json(JsonField:AmountRejected):AmountInReportingCurrency::NUMBER(38,10) AS AmountRejectedAmountInReportingCurrency
        ,parse_json(JsonField:AmountRejected):ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountRejectedApproxAmountInBaseCurrency
        ,parse_json(JsonField:AmountRejected):ConversionDate::TIMESTAMP_NTZ AS AmountRejectedConversionDate
        ,parse_json(JsonField:AmountRejected):Currency:UniqueName::STRING AS AmountRejectedCurrencyCode
        ,JsonField:ApprovalRequestsVersion::INTEGER AS ApprovalRequestsVersion
        ,JsonField:ApprovedDate::TIMESTAMP_NTZ AS ApprovedDate
        ,JsonField:ApprovedState::INTEGER AS ApprovedState
        --JsonField:Attachments:Attachments
        ,parse_json(JsonField:ChangedBy):UniqueName::STRING AS ChangedByCode
        ,parse_json(JsonField:ChargeAmount):Amount::NUMBER(38,10) AS ChargeAmountAmount
        ,parse_json(JsonField:ChargeAmount):AmountInReportingCurrency::NUMBER(38,10) AS ChargeAmountAmountInReportingCurrency
        ,parse_json(JsonField:ChargeAmount):ApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeAmountApproxAmountInBaseCurrency
        ,parse_json(JsonField:ChargeAmount):ConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,parse_json(JsonField:ChargeAmount):Currency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,JsonField:Closed::INTEGER AS Closed
        ,parse_json(JsonField:CompanyCode):UniqueName::STRING AS CompanyCode
        ,parse_json(JsonField:Conditions):TAndCVersion::INTEGER AS ConditionsVersion
        ,parse_json(JsonField:Conditions):UniqueName::STRING AS ConditionsCode
        ,JsonField:CreateDate::TIMESTAMP_NTZ AS CreateDate
        ,JsonField:ExpirationDate::TIMESTAMP_NTZ AS ExpirationDate
        ,JsonField:HoldTillDate::TIMESTAMP_NTZ AS HoldTillDate
        ,JsonField:InitialUniqueName::STRING AS InitialUniqueName
        ,JsonField:InvoicedDate::TIMESTAMP_NTZ AS InvoicedDate
        ,JsonField:InvoicedState::INTEGER AS InvoicedState
        ,JsonField:IsBlanketOrder::Boolean AS IsBlanketOrder
        ,JsonField:IsFromExternalReq::Boolean AS IsFromExternalReq
        ,JsonField:IsServiceOrder::Boolean AS IsServiceOrder
        ,JsonField:LastModified::TIMESTAMP_NTZ AS LastModifiedDate
        --MasterAgreement
        ,JsonField:ManuallyOrdered::Boolean AS ManuallyOrdered
        --NextVersion
        ,JsonField:Name::STRING AS Name
        ,JsonField:NumberBilled::NUMBER(18,2) AS NumberBilled
        ,JsonField:NumberCleared::NUMBER(18,2) AS NumberCleared
        ,JsonField:NumberReceivableLineItems::INTEGER AS NumberReceivableLineItems
        ,JsonField:NumberReceivableOrders::INTEGER AS NumberReceivableOrders
        ,JsonField:OrderConfirmationState::INTEGER AS OrderConfirmationState
        ,JsonField:OrderConfirmationStatusString::STRING AS OrderConfirmationStatusString
        ,JsonField:OrderID::STRING AS OrderID
        ,JsonField:OrderMethodCategory::STRING AS OrderMethodCategory
        ,JsonField:OrderStatusPunchOutDisabled::Boolean AS OrderStatusPunchOutDisabled
        ,JsonField:OrderedDate::TIMESTAMP_NTZ AS OrderedDate
        ,JsonField:OrderedState::INTEGER AS OrderedState
        ,JsonField:OriginatingSystemReferenceID::STRING AS OriginatingSystemReferenceID
        ,parse_json(JsonField:PaymentTerms):UniqueName::STRING AS PaymentTermsCode
        ,JsonField:PreOrdered::Boolean AS PreOrdered
        -- ,parse_json(JsonField:Preparer):PasswordAdapter::STRING AS PreparerPasswordAdapter
        ,parse_json(JsonField:Preparer):UniqueName::STRING AS PreparerCode
        ,JsonField:PreviousApprovalRequestsVersion::INTEGER AS PreviousApprovalRequestsVersion
        ,JsonField:PreviousVersion::STRING AS PreviousVersion
        ,JsonField:ReceivedDate::TIMESTAMP_NTZ AS ReceivedDate
        ,JsonField:ReceivedState::INTEGER AS ReceivedState
        ,JsonField:RejectionReason::STRING AS RejectionReason
        ,parse_json(JsonField:ReportingCurrency):UniqueName::STRING AS ReportingCurrencyCode
        -- ,parse_json(JsonField:Requester):PasswordAdapter::STRING AS RequesterPasswordAdapter
        ,parse_json(JsonField:Requester):UniqueName::STRING AS RequesterCode
        ,parse_json(JsonField:Requisition):UniqueName::STRING AS RequisitionCode
        ,JsonField:ResubmitDate::TIMESTAMP_NTZ AS ResubmitDate
        ,JsonField:StatusString::STRING AS StatusString
        ,JsonField:SubmitDate::TIMESTAMP_NTZ AS SubmitDate
        ,parse_json(JsonField:Supplier):Name::STRING AS Supplier
        ,parse_json(JsonField:Supplier):UniqueName::STRING AS SupplierCode
        ,parse_json(JsonField:SupplierLocation):UniqueName::STRING AS SupplierLocationCode
        -- ,JsonField:TermsAndConditionsCode::STRING AS TermsAndConditionsCode
        -- ,JsonField:TermsAndConditionsName::INTEGER AS TermsAndConditionsName
        ,parse_json(JsonField:TotalCost):Amount::NUMBER(38,10) AS TotalCostAmount
        ,parse_json(JsonField:TotalCost):AmountInReportingCurrency::NUMBER(38,10) AS TotalCostAmountInReportingCurrency
        ,parse_json(JsonField:TotalCost):ApproxAmountInBaseCurrency::NUMBER(38,10) AS TotalCostApproxAmountInBaseCurrency
        ,parse_json(JsonField:TotalCost):ConversionDate::TIMESTAMP_NTZ AS TotalCostConversionDate
        ,parse_json(JsonField:TotalCost):Currency:UniqueName::STRING AS TotalCostCurrencyCode
        ,JsonField:Type::STRING AS TypeOfObject
        ,JsonField:UniqueName::STRING AS UniqueName
        ,JsonField:UsePOLineNumberForIntegration::BOOLEAN AS UsePOLineNumberForIntegration
        ,JsonField:Version::INTEGER AS Version
        ,JsonField:VersionNumber::NUMBER(38,10) AS VersionNumber
        ,JsonField:cus_BPO::BOOLEAN AS CustomField_BPO
        ,JsonField:cus_BuyerDetails::STRING AS CustomField_BuyerDetails
        ,JsonField:cus_BuyerName::STRING AS CustomField_BuyerName
        ,JsonField:cus_CompanyName::STRING AS CustomField_CompanyName
        ,JsonField:cus_EndDate::TIMESTAMP_NTZ AS CustomField_EndDate
        ,JsonField:cus_IsBPO::BOOLEAN AS CustomField_IsBPO
        ,JsonField:cus_IsBaanSpecific::BOOLEAN AS CustomField_IsBaanSpecific
        ,JsonField:cus_StartDate::TIMESTAMP_NTZ AS CustomField_StartDate
        ,JsonField:cus_UPSNumber::STRING AS CustomField_UPSNumber
        FROM source_data_FULL LZData
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
        source_data.UNIQUENAME AS PurchaseOrderIdKey,
        source_data.VERSION AS PurchaseOrderVersionKey,
        source_data.ACTIVE AS Active,
        source_data.ADVANCEDSHIPNOTICESTATE AS AdvancedShipNoticeState,
        source_data.AMOUNTACCEPTEDAMOUNT AS AmountAcceptedAmount,
        source_data.AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY AS AmountAcceptedAmountInReportingCurrency,
        source_data.AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY AS AmountAcceptedApproxAmountInBaseCurrency,
        source_data.AMOUNTACCEPTEDCONVERSIONDATE AS AmountAcceptedConversionDate,
        source_data.AMOUNTACCEPTEDCURRENCYCODE AS AmountAcceptedCurrencyCode,
        source_data.AMOUNTBILLEDAMOUNT AS AmountBilledAmount,
        source_data.AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY AS AmountBilledAmountInReportingCurrency,
        source_data.AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY AS AmountBilledApproxAmountInBaseCurrency,
        source_data.AMOUNTBILLEDCONVERSIONDATE AS AmountBilledConversionDate,
        source_data.AMOUNTBILLEDCURRENCYCODE AS AmountBilledCurrencyCode,
        source_data.AMOUNTCLEAREDAMOUNT AS AmountClearedAmount,
        source_data.AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY AS AmountClearedAmountInReportingCurrency,
        source_data.AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY AS AmountClearedApproxAmountInBaseCurrency,
        source_data.AMOUNTCLEAREDCONVERSIONDATE AS AmountClearedConversionDate,
        source_data.AMOUNTCLEAREDCURRENCYCODE AS AmountClearedCurrencyCode,
        source_data.AMOUNTINVOICEDAMOUNT AS AmountInvoicedAmount,
        source_data.AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY AS AmountInvoicedAmountInReportingCurrency,
        source_data.AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY AS AmountInvoicedApproxAmountInBaseCurrency,
        source_data.AMOUNTINVOICEDCONVERSIONDATE AS AmountInvoicedConversionDate,
        source_data.AMOUNTINVOICEDCURRENCYCODE AS AmountInvoicedCurrencyCode,
        source_data.AMOUNTRECONCILEDAMOUNT AS AmountReconciledAmount,
        source_data.AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY AS AmountReconciledAmountInReportingCurrency,
        source_data.AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY AS AmountReconciledApproxAmountInBaseCurrency,
        source_data.AMOUNTRECONCILEDCONVERSIONDATE AS AmountReconciledConversionDate,
        source_data.AMOUNTRECONCILEDCURRENCYCODE AS AmountReconciledCurrencyCode,
        source_data.AMOUNTREJECTEDAMOUNT AS AmountRejectedAmount,
        source_data.AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY AS AmountRejectedAmountInReportingCurrency,
        source_data.AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY AS AmountRejectedApproxAmountInBaseCurrency,
        source_data.AMOUNTREJECTEDCONVERSIONDATE AS AmountRejectedConversionDate,
        source_data.AMOUNTREJECTEDCURRENCYCODE AS AmountRejectedCurrencyCode,
        source_data.APPROVALREQUESTSVERSION AS ApprovalRequestsVersion,
        source_data.APPROVEDDATE AS ApprovedDate,
        source_data.APPROVEDSTATE AS ApprovedState,
        source_data.CHANGEDBYCODE AS ChangedByCode,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeAmountAmountInReportingCurrency,
        source_data.CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeAmountApproxAmountInBaseCurrency,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CLOSED AS Closed,
        source_data.COMPANYCODE AS CompanyCode,
        source_data.CONDITIONSVERSION AS ConditionsVersion,
        source_data.CONDITIONSCODE AS ConditionsCode,
        source_data.CREATEDATE AS CreateDate,
        source_data.EXPIRATIONDATE AS ExpirationDate,
        source_data.HOLDTILLDATE AS HoldTillDate,
        source_data.INITIALUNIQUENAME AS InitialUniqueName,
        source_data.INVOICEDDATE AS InvoicedDate,
        source_data.INVOICEDSTATE AS InvoicedState,
        source_data.ISBLANKETORDER AS IsBlanketOrder,
        source_data.ISFROMEXTERNALREQ AS IsFromExternalReq,
        source_data.ISSERVICEORDER AS IsServiceOrder,
        source_data.LASTMODIFIEDDATE AS LastModifiedDate,
        source_data.MANUALLYORDERED AS ManuallyOrdered,
        source_data.NAME AS Name,
        source_data.NUMBERBILLED AS NumberBilled,
        source_data.NUMBERCLEARED AS NumberCleared,
        source_data.NUMBERRECEIVABLELINEITEMS AS NumberReceivableLineItems,
        source_data.NUMBERRECEIVABLEORDERS AS NumberReceivableOrders,
        source_data.ORDERCONFIRMATIONSTATE AS OrderConfirmationState,
        source_data.ORDERCONFIRMATIONSTATUSSTRING AS OrderConfirmationStatusString,
        source_data.ORDERID AS OrderId,
        source_data.ORDERMETHODCATEGORY AS OrderMethodCategory,
        source_data.ORDERSTATUSPUNCHOUTDISABLED AS OrderStatusPunchOutDisabled,
        source_data.ORDEREDDATE AS OrderedDate,
        source_data.ORDEREDSTATE AS OrderedState,
        source_data.ORIGINATINGSYSTEMREFERENCEID AS OriginatingSystemReferenceId,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.PREORDERED AS PreOrdered,
        source_data.PREPARERCODE AS PreparerCode,
        source_data.PREVIOUSAPPROVALREQUESTSVERSION AS PreviousApprovalRequestsVersion,
        source_data.PREVIOUSVERSION AS PreviousVersion,
        source_data.RECEIVEDDATE AS ReceivedDate,
        source_data.RECEIVEDSTATE AS ReceivedState,
        source_data.REJECTIONREASON AS RejectionReason,
        source_data.REPORTINGCURRENCYCODE AS ReportingCurrencyCode,
        source_data.REQUESTERCODE AS RequesterCode,
        source_data.REQUISITIONCODE AS RequisitionCode,
        source_data.RESUBMITDATE AS ResubmitDate,
        source_data.STATUSSTRING AS StatusString,
        source_data.SUBMITDATE AS SubmitDate,
        source_data.SUPPLIER AS Supplier,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.SUPPLIERLOCATIONCODE AS SupplierLocationCode,
        source_data.TOTALCOSTAMOUNT AS TotalCostAmount,
        source_data.TOTALCOSTAMOUNTINREPORTINGCURRENCY AS TotalCostAmountInReportingCurrency,
        source_data.TOTALCOSTAPPROXAMOUNTINBASECURRENCY AS TotalCostApproxAmountInBaseCurrency,
        source_data.TOTALCOSTCONVERSIONDATE AS TotalCostConversionDate,
        source_data.TOTALCOSTCURRENCYCODE AS TotalCostCurrencyCode,
        source_data.TYPEOFOBJECT AS TypeofObject,
        source_data.UNIQUENAME AS UniqueName,
        source_data.USEPOLINENUMBERFORINTEGRATION AS UsePOLineNumberForIntegration,
        source_data.VERSION AS Version,
        source_data.VERSIONNUMBER AS VersionNumber,
        source_data.CUSTOMFIELD_BPO AS CustomField_BPO,
        source_data.CUSTOMFIELD_BUYERDETAILS AS CustomField_BuyerDetails,
        source_data.CUSTOMFIELD_BUYERNAME AS CustomField_BuyerName,
        source_data.CUSTOMFIELD_COMPANYNAME AS CustomField_CompanyName,
        source_data.CUSTOMFIELD_ENDDATE AS CustomField_EndDate,
        source_data.CUSTOMFIELD_ISBPO AS CustomField_IsBPO,
        source_data.CUSTOMFIELD_ISBAANSPECIFIC AS CustomField_IsBaanSpecific,
        source_data.CUSTOMFIELD_STARTDATE AS CustomField_StartDate,
        source_data.CUSTOMFIELD_UPSNUMBER AS CustomField_UPSNumber,
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
        cast(ACTIVE as BOOLEAN) as ACTIVE,
        cast(ADVANCEDSHIPNOTICESTATE as NUMBER(38,0)) as ADVANCEDSHIPNOTICESTATE,
        cast(AMOUNTACCEPTEDAMOUNT as NUMBER(38,10)) as AMOUNTACCEPTEDAMOUNT,
        cast(AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTACCEPTEDCONVERSIONDATE,
        cast(AMOUNTACCEPTEDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTACCEPTEDCURRENCYCODE,
        cast(AMOUNTBILLEDAMOUNT as NUMBER(38,10)) as AMOUNTBILLEDAMOUNT,
        cast(AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTBILLEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTBILLEDCONVERSIONDATE,
        cast(AMOUNTBILLEDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTBILLEDCURRENCYCODE,
        cast(AMOUNTCLEAREDAMOUNT as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNT,
        cast(AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTCLEAREDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCLEAREDCONVERSIONDATE,
        cast(AMOUNTCLEAREDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTCLEAREDCURRENCYCODE,
        cast(AMOUNTINVOICEDAMOUNT as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNT,
        cast(AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTINVOICEDCONVERSIONDATE,
        cast(AMOUNTINVOICEDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTINVOICEDCURRENCYCODE,
        cast(AMOUNTRECONCILEDAMOUNT as NUMBER(38,10)) as AMOUNTRECONCILEDAMOUNT,
        cast(AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTRECONCILEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTRECONCILEDCONVERSIONDATE,
        cast(AMOUNTRECONCILEDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTRECONCILEDCURRENCYCODE,
        cast(AMOUNTREJECTEDAMOUNT as NUMBER(38,10)) as AMOUNTREJECTEDAMOUNT,
        cast(AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTREJECTEDCONVERSIONDATE,
        cast(AMOUNTREJECTEDCURRENCYCODE as VARCHAR(16777126)) as AMOUNTREJECTEDCURRENCYCODE,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as NUMBER(38,0)) as APPROVEDSTATE,
        cast(CHANGEDBYCODE as VARCHAR(16777126)) as CHANGEDBYCODE,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777126)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CLOSED as NUMBER(38,0)) as CLOSED,
        cast(COMPANYCODE as VARCHAR(16777126)) as COMPANYCODE,
        cast(CONDITIONSVERSION as NUMBER(38,0)) as CONDITIONSVERSION,
        cast(CONDITIONSCODE as VARCHAR(16777126)) as CONDITIONSCODE,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALUNIQUENAME as VARCHAR(16777126)) as INITIALUNIQUENAME,
        cast(INVOICEDDATE as TIMESTAMP_NTZ(9)) as INVOICEDDATE,
        cast(INVOICEDSTATE as NUMBER(38,0)) as INVOICEDSTATE,
        cast(ISBLANKETORDER as BOOLEAN) as ISBLANKETORDER,
        cast(ISFROMEXTERNALREQ as BOOLEAN) as ISFROMEXTERNALREQ,
        cast(ISSERVICEORDER as BOOLEAN) as ISSERVICEORDER,
        cast(LASTMODIFIEDDATE as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATE,
        cast(MANUALLYORDERED as BOOLEAN) as MANUALLYORDERED,
        cast(NAME as VARCHAR(16777126)) as NAME,
        cast(NUMBERBILLED as NUMBER(38,10)) as NUMBERBILLED,
        cast(NUMBERCLEARED as NUMBER(38,10)) as NUMBERCLEARED,
        cast(NUMBERRECEIVABLELINEITEMS as NUMBER(38,0)) as NUMBERRECEIVABLELINEITEMS,
        cast(NUMBERRECEIVABLEORDERS as NUMBER(38,0)) as NUMBERRECEIVABLEORDERS,
        cast(ORDERCONFIRMATIONSTATE as NUMBER(38,0)) as ORDERCONFIRMATIONSTATE,
        cast(ORDERCONFIRMATIONSTATUSSTRING as VARCHAR(16777126)) as ORDERCONFIRMATIONSTATUSSTRING,
        cast(ORDERID as VARCHAR(16777126)) as ORDERID,
        cast(ORDERMETHODCATEGORY as VARCHAR(16777126)) as ORDERMETHODCATEGORY,
        cast(ORDERSTATUSPUNCHOUTDISABLED as BOOLEAN) as ORDERSTATUSPUNCHOUTDISABLED,
        cast(ORDEREDDATE as TIMESTAMP_NTZ(9)) as ORDEREDDATE,
        cast(ORDEREDSTATE as NUMBER(38,0)) as ORDEREDSTATE,
        cast(ORIGINATINGSYSTEMREFERENCEID as VARCHAR(16777126)) as ORIGINATINGSYSTEMREFERENCEID,
        cast(PAYMENTTERMSCODE as VARCHAR(16777126)) as PAYMENTTERMSCODE,
        cast(PREORDERED as BOOLEAN) as PREORDERED,
        cast(PREPARERCODE as VARCHAR(16777126)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as VARCHAR(16777126)) as PREVIOUSVERSION,
        cast(RECEIVEDDATE as TIMESTAMP_NTZ(9)) as RECEIVEDDATE,
        cast(RECEIVEDSTATE as NUMBER(38,0)) as RECEIVEDSTATE,
        cast(REJECTIONREASON as VARCHAR(16777126)) as REJECTIONREASON,
        cast(REPORTINGCURRENCYCODE as VARCHAR(16777126)) as REPORTINGCURRENCYCODE,
        cast(REQUESTERCODE as VARCHAR(16777126)) as REQUESTERCODE,
        cast(REQUISITIONCODE as VARCHAR(16777126)) as REQUISITIONCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(STATUSSTRING as VARCHAR(16777126)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(SUPPLIER as VARCHAR(16777126)) as SUPPLIER,
        cast(SUPPLIERCODE as VARCHAR(16777126)) as SUPPLIERCODE,
        cast(SUPPLIERLOCATIONCODE as VARCHAR(16777126)) as SUPPLIERLOCATIONCODE,
        cast(TOTALCOSTAMOUNT as NUMBER(38,10)) as TOTALCOSTAMOUNT,
        cast(TOTALCOSTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TOTALCOSTAMOUNTINREPORTINGCURRENCY,
        cast(TOTALCOSTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TOTALCOSTAPPROXAMOUNTINBASECURRENCY,
        cast(TOTALCOSTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALCOSTCONVERSIONDATE,
        cast(TOTALCOSTCURRENCYCODE as VARCHAR(16777126)) as TOTALCOSTCURRENCYCODE,
        cast(TYPEOFOBJECT as VARCHAR(16777126)) as TYPEOFOBJECT,
        cast(UNIQUENAME as VARCHAR(16777126)) as UNIQUENAME,
        cast(USEPOLINENUMBERFORINTEGRATION as BOOLEAN) as USEPOLINENUMBERFORINTEGRATION,
        cast(VERSION as NUMBER(38,0)) as VERSION,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(CUSTOMFIELD_BPO as BOOLEAN) as CUSTOMFIELD_BPO,
        cast(CUSTOMFIELD_BUYERDETAILS as VARCHAR(16777126)) as CUSTOMFIELD_BUYERDETAILS,
        cast(CUSTOMFIELD_BUYERNAME as VARCHAR(16777126)) as CUSTOMFIELD_BUYERNAME,
        cast(CUSTOMFIELD_COMPANYNAME as VARCHAR(16777126)) as CUSTOMFIELD_COMPANYNAME,
        cast(CUSTOMFIELD_ENDDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_ENDDATE,
        cast(CUSTOMFIELD_ISBPO as BOOLEAN) as CUSTOMFIELD_ISBPO,
        cast(CUSTOMFIELD_ISBAANSPECIFIC as BOOLEAN) as CUSTOMFIELD_ISBAANSPECIFIC,
        cast(CUSTOMFIELD_STARTDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_STARTDATE,
        cast(CUSTOMFIELD_UPSNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_UPSNUMBER,
        cast(PurchaseOrderIDKEY as VARCHAR(16777216)) as PurchaseOrderIDKEY,
        cast(PurchaseOrderVERSIONKEY as NUMBER(38,0)) as PurchaseOrderVERSIONKEY,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data