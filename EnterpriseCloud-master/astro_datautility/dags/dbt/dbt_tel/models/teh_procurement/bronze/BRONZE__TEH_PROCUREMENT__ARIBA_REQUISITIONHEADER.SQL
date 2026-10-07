{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_REQUISITIONHEADER',
    unique_key = ['RealmName',
    'RequisitionIDKey',
    'RequisitionVersionKey']
) }}


with source_data as
(
    SELECT
        regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:Active::BOOLEAN AS Active
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
        ,JsonField:AreOrdersStuck::BOOLEAN AS AreOrdersStuck
        ,parse_json(JsonField:BlanketOrder):UniqueName::STRING AS BlanketOrderCode
        ,JsonField:BlanketOrderId::STRING AS BlanketOrderId
        ,JsonField:BudgetCheckStatus::INTEGER AS BudgetCheckStatus
        ,JsonField:BudgetCheckStatusMessage::STRING AS BudgetCheckStatusMessage
        ,JsonField:BudgetRefId::STRING AS BudgetRefId
        ,parse_json(JsonField:ChangedBy):UniqueName::STRING AS ChangedByCode
        ,parse_json(JsonField:ChargeAmount):Amount::NUMBER(38,10) AS ChargeAmountAmount
        ,parse_json(JsonField:ChargeAmount):AmountInReportingCurrency::NUMBER(38,10) AS ChargeAmountAmountInReportingCurrency
        ,parse_json(JsonField:ChargeAmount):ApproxAmountInBaseCurrency::NUMBER(38,10) AS ChargeAmountApproxAmountInBaseCurrency
        ,parse_json(JsonField:ChargeAmount):ConversionDate::TIMESTAMP_NTZ AS ChargeAmountConversionDate
        ,parse_json(JsonField:ChargeAmount):Currency:UniqueName::STRING AS ChargeAmountCurrencyCode
        ,parse_json(JsonField:CollaborationState):CancelReason:UniqueName::STRING AS CollaborationStateCancelReasonCode
        ,parse_json(JsonField:CollaborationState):Mode::INTEGER AS CollaborationStateMode
        ,parse_json(JsonField:CollaborationState):Order:UniqueName::STRING AS CollaborationStateOrderCode
        ,parse_json(JsonField:CollaborationState):Reason:UniqueName::STRING AS CollaborationStateReasonCode
        ,parse_json(JsonField:CollaborationState):State::INTEGER AS CollaborationStateState
        ,parse_json(JsonField:CollaborationState):Supplier:UniqueName::STRING AS CollaborationStateSupplierCode
        ,parse_json(JsonField:CompanyCode):UniqueName::STRING AS CompanyCodeCode
        ,JsonField:CreateDate::TIMESTAMP_NTZ AS CreateDate
        ,parse_json(JsonField:CustomCatalogPurchaseOrg):UniqueName::STRING AS CustomCatalogPurchaseOrgCode
        ,parse_json(JsonField:DiscountAmount):Amount::NUMBER(38,10) AS DiscountAmountAmount
        ,parse_json(JsonField:DiscountAmount):AmountInReportingCurrency::NUMBER(38,10) AS DiscountAmountAmountInReportingCurrency
        ,parse_json(JsonField:DiscountAmount):ApproxAmountInBaseCurrency::NUMBER(38,10) AS DiscountAmountApproxAmountInBaseCurrency
        ,parse_json(JsonField:DiscountAmount):ConversionDate::TIMESTAMP_NTZ AS DiscountAmountConversionDate
        ,parse_json(JsonField:DiscountAmount):CurrencyUniqueName::STRING AS DiscountAmountCurrencyCode
        ,parse_json(JsonField:ERPRequisitionId):UniqueName::STRING AS ERPRequisitionIdCode
        ,JsonField:ExternalReqId::STRING AS ExternalReqId
        ,JsonField:ExternalReqUrl::STRING AS ExternalReqUrl
        ,JsonField:ExternalSourcingId::STRING AS ExternalSourcingId
        ,JsonField:HoldTillDate::TIMESTAMP_NTZ AS HoldTillDate
        ,JsonField:InitialUniqueName::STRING AS InitialUniqueName
        ,JsonField:InvoicedDate::TIMESTAMP_NTZ AS InvoicedDate
        ,JsonField:IsExternalReq::BOOLEAN AS IsExternalReq
        ,JsonField:IsForcast::BOOLEAN AS IsForcast
        ,JsonField:IsServiceOrder::BOOLEAN AS IsServiceOrder
        ,JsonField:IsServiceRequisition::BOOLEAN AS IsServiceRequisition
        ,JsonField:LastCheckDate::TIMESTAMP_NTZ AS LastCheckDate
        ,JsonField:LastModifiedDate::TIMESTAMP_NTZ AS LastModifiedDate
        ,JsonField:Name::STRING AS Name
        ,JsonField:NextVersion::STRING AS NextVersion
        ,JsonField:NumberBilled::NUMBER(38,10) AS NumberBilled
        ,JsonField:NumberCleared::NUMBER(38,10) AS NumberCleared
        ,JsonField:NumberReceivableOrders::INTEGER AS NumberReceivableOrders
        ,JsonField:ObjectType::STRING AS ObjectType
        ,JsonField:OrderedDate::TIMESTAMP_NTZ AS OrderedDate
        ,JsonField:OrderedState::INTEGER AS OrderedState
        ,JsonField:OriginatingSystem::STRING AS OriginatingSystem
        ,JsonField:OriginatingSystemReferenceId::STRING AS OriginatingSystemReferenceId
        ,parse_json(JsonField:PaymentTerms):UniqueName::STRING AS PaymentTermsCode
        ,parse_json(JsonField:PreCollaborationTotalCost):Amount::NUMBER(38,10) AS PreCollaborationTotalCostAmount
        ,parse_json(JsonField:PreCollaborationTotalCost):AmountInReportingCurrency::NUMBER(38,10) AS PreCollaborationTotalCostAmountInReportingCurrency
        ,parse_json(JsonField:PreCollaborationTotalCost):ApproxAmountInBaseCurrency::NUMBER(38,10) AS PreCollaborationTotalCostApproxAmountInBaseCurrency
        ,parse_json(JsonField:PreCollaborationTotalCost):ConversionDate::TIMESTAMP_NTZ AS PreCollaborationTotalCostConversionDate
        ,parse_json(JsonField:PreCollaborationTotalCost):Currency:UniqueName::STRING AS PreCollaborationTotalCostCurrencyCode
        ,parse_json(JsonField:Preparer):UniqueName::STRING AS PreparerCode
        ,JsonField:PreviousApprovalRequestsVersion::INTEGER AS PreviousApprovalRequestsVersion
        ,JsonField:PreviousVersion::STRING AS PreviousVersion
        ,parse_json(JsonField:ProcurementUnit):UniqueName::STRING AS ProcurementUnitCode
        ,JsonField:ProjectId::STRING AS ProjectId
        ,JsonField:ProjectTitle::STRING AS ProjectTitle
        ,parse_json(JsonField:RealTimeBudgetResponse):UniqueName::STRING AS RealTimeBudgetResponseCode
        ,JsonField:ReceivedDate::TIMESTAMP_NTZ AS ReceivedDate
        ,JsonField:ReceivedState::INTEGER AS ReceivedState
        ,parse_json(JsonField:ReportingCurrency):UniqueName::STRING AS ReportingCurrencyCode
        ,parse_json(JsonField:Requester):UniqueName::STRING AS RequesterCode
        ,JsonField:ResubmitDate::TIMESTAMP_NTZ AS ResubmitDate
        ,JsonField:SentDate::TIMESTAMP_NTZ AS SentDate
        ,JsonField:SourcingStatus::INTEGER AS SourcingStatus
        ,JsonField:SourcingStatusMessage::STRING AS SourcingStatusMessage
        ,JsonField:SourcingStatusString::STRING AS SourcingStatusString
        ,JsonField:StatusString::STRING AS StatusString
        ,JsonField:SubmitDate::TIMESTAMP_NTZ AS SubmitDate
        ,parse_json(JsonField:Supplier):UniqueName::STRING AS SupplierCode
        ,parse_json(JsonField:TaxAmount):Amount::NUMBER(38,10) AS TaxAmountAmount
        ,parse_json(JsonField:TaxAmount):AmountInReportingCurrency::NUMBER(38,10) AS TaxAmountAmountInReportingCurrency
        ,parse_json(JsonField:TaxAmount):ApproxAmountInBaseCurrency::NUMBER(38,10) AS TaxAmountApproxAmountInBaseCurrency
        ,parse_json(JsonField:TaxAmount):ConversionDate::TIMESTAMP_NTZ AS TaxAmountConversionDate
        ,parse_json(JsonField:TaxAmount):CurrencyUniqueName::STRING AS TaxAmountCurrencyCode
        ,JsonField:TimeCreated::TIMESTAMP_NTZ AS TimeCreated
        ,JsonField:TimeUpdated::TIMESTAMP_NTZ AS TimeUpdated
        ,parse_json(JsonField:TotalCost):Amount::NUMBER(38,10) AS TotalCostAmount
        ,parse_json(JsonField:TotalCost):AmountInReportingCurrency::NUMBER(38,10) AS TotalCostAmountInReportingCurrency
        ,parse_json(JsonField:TotalCost):ApproxAmountInBaseCurrency::NUMBER(38,10) AS TotalCostApproxAmountInBaseCurrency
        ,parse_json(JsonField:TotalCost):ConversionDate::TIMESTAMP_NTZ AS TotalCostConversionDate
        ,parse_json(JsonField:TotalCost):Currency:UniqueName::STRING AS TotalCostCurrencyCode
        ,JsonField:UniqueName::STRING AS UniqueName
        ,parse_json(JsonField:VATAmount):Amount::NUMBER(38,10) AS VATAmountAmount
        ,parse_json(JsonField:VATAmount):AmountInReportingCurrency::NUMBER(38,10) AS VATAmountAmountInReportingCurrency
        ,parse_json(JsonField:VATAmount):ApproxAmountInBaseCurrency::NUMBER(38,10) AS VATAmountApproxAmountInBaseCurrency
        ,parse_json(JsonField:VATAmount):ConversionDate::TIMESTAMP_NTZ AS VATAmountConversionDate
        ,parse_json(JsonField:VATAmount):CurrencyUniqueName::STRING AS VATAmountCurrencyCode
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
        FROM {{ source("ARIBA", "REQUISITION") }} LZData
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
        )
,transform_data as
(
    SELECT
        source_data.TIMEUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.UNIQUENAME AS RequisitionIDKey,
        source_data.VERSION AS RequisitionVersionKey,
        source_data.ACTIVE AS Active,
        source_data.AMOUNTACCEPTEDAMOUNT AS AmountAcceptedAmount,
        source_data.AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY AS AmountAcceptedApproxAmountInBaseCurrency,
        source_data.AMOUNTACCEPTEDCONVERSIONDATE AS AmountAcceptedConversionDate,
        source_data.AMOUNTACCEPTEDCURRENCYCODE AS AmountAcceptedCurrencyCode,
        source_data.AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY AS AmountAcceptedAmountInReportingCurrency,
        source_data.AMOUNTBILLEDAMOUNT AS AmountBilledAmount,
        source_data.AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY AS AmountBilledApproxAmountInBaseCurrency,
        source_data.AMOUNTBILLEDCONVERSIONDATE AS AmountBilledConversionDate,
        source_data.AMOUNTBILLEDCURRENCYCODE AS AmountBilledCurrencyCode,
        source_data.AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY AS AmountBilledAmountInReportingCurrency,
        source_data.AMOUNTCLEAREDAMOUNT AS AmountClearedAmount,
        source_data.AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY AS AmountClearedApproxAmountInBaseCurrency,
        source_data.AMOUNTCLEAREDCONVERSIONDATE AS AmountClearedConversionDate,
        source_data.AMOUNTCLEAREDCURRENCYCODE AS AmountClearedCurrencyCode,
        source_data.AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY AS AmountClearedAmountInReportingCurrency,
        source_data.AMOUNTINVOICEDAMOUNT AS AmountInvoicedAmount,
        source_data.AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY AS AmountInvoicedApproxAmountInBaseCurrency,
        source_data.AMOUNTINVOICEDCONVERSIONDATE AS AmountInvoicedConversionDate,
        source_data.AMOUNTINVOICEDCURRENCYCODE AS AmountInvoicedCurrencyCode,
        source_data.AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY AS AmountInvoicedAmountInReportingCurrency,
        source_data.AMOUNTRECONCILEDAMOUNT AS AmountReconciledAmount,
        source_data.AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY AS AmountReconciledApproxAmountInBaseCurrency,
        source_data.AMOUNTRECONCILEDCONVERSIONDATE AS AmountReconciledConversionDate,
        source_data.AMOUNTRECONCILEDCURRENCYCODE AS AmountReconciledCurrencyCode,
        source_data.AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY AS AmountReconciledAmountInReportingCurrency,
        source_data.AMOUNTREJECTEDAMOUNT AS AmountRejectedAmount,
        source_data.AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY AS AmountRejectedApproxAmountInBaseCurrency,
        source_data.AMOUNTREJECTEDCONVERSIONDATE AS AmountRejectedConversionDate,
        source_data.AMOUNTREJECTEDCURRENCYCODE AS AmountRejectedCurrencyCode,
        source_data.AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY AS AmountRejectedAmountInReportingCurrency,
        source_data.APPROVALREQUESTSVERSION AS ApprovalRequestsVersion,
        source_data.APPROVEDDATE AS ApprovedDate,
        source_data.APPROVEDSTATE AS ApprovedState,
        source_data.AREORDERSSTUCK AS AreOrdersStuck,
        source_data.BLANKETORDERID AS BlanketOrderId,
        source_data.BLANKETORDERCODE AS BlanketOrderCode,
        source_data.BUDGETCHECKSTATUS AS BudgetCheckStatus,
        source_data.BUDGETCHECKSTATUSMESSAGE AS BudgetCheckStatusMessage,
        source_data.BUDGETREFID AS BudgetRefId,
        source_data.CHANGEDBYCODE AS ChangedByCode,
        source_data.CHARGEAMOUNTAMOUNT AS ChargeAmountAmount,
        source_data.CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY AS ChargeAmountApproxAmountInBaseCurrency,
        source_data.CHARGEAMOUNTCONVERSIONDATE AS ChargeAmountConversionDate,
        source_data.CHARGEAMOUNTCURRENCYCODE AS ChargeAmountCurrencyCode,
        source_data.CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY AS ChargeAmountAmountInReportingCurrency,
        source_data.COLLABORATIONSTATECANCELREASONCODE AS CollaborationStateCancelReasonCode,
        source_data.COLLABORATIONSTATEMODE AS CollaborationStateMode,
        source_data.COLLABORATIONSTATEORDERCODE AS CollaborationStateOrderCode,
        source_data.COLLABORATIONSTATEREASONCODE AS CollaborationStateReasonCode,
        source_data.COLLABORATIONSTATESTATE AS CollaborationStateState,
        source_data.COLLABORATIONSTATESUPPLIERCODE AS CollaborationStateSupplierCode,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.CREATEDATE AS CreateDate,
        source_data.CUSTOMCATALOGPURCHASEORGCODE AS CustomCatalogPurchaseOrgCode,
        source_data.DISCOUNTAMOUNTAMOUNT AS DiscountAmountAmount,
        source_data.DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY AS DiscountAmountApproxAmountInBaseCurrency,
        source_data.DISCOUNTAMOUNTCONVERSIONDATE AS DiscountAmountConversionDate,
        source_data.DISCOUNTAMOUNTCURRENCYCODE AS DiscountAmountCurrencyCode,
        source_data.DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY AS DiscountAmountAmountInReportingCurrency,
        source_data.ERPREQUISITIONIDCODE AS ERPRequisitionIdCode,
        source_data.EXTERNALREQID AS ExternalReqId,
        source_data.EXTERNALREQURL AS ExternalReqUrl,
        source_data.EXTERNALSOURCINGID AS ExternalSourcingId,
        source_data.HOLDTILLDATE AS HoldTillDate,
        source_data.INITIALUNIQUENAME AS InitialUniqueName,
        source_data.INVOICEDDATE AS InvoicedDate,
        source_data.ISEXTERNALREQ AS IsExternalReq,
        source_data.ISFORCAST AS IsForcast,
        source_data.ISSERVICEORDER AS IsServiceOrder,
        source_data.ISSERVICEREQUISITION AS IsServiceRequisition,
        source_data.LASTCHECKDATE AS LastCheckDate,
        source_data.LASTMODIFIEDDATE AS LastModifiedDate,
        source_data.NAME AS Name,
        source_data.NEXTVERSION AS NextVersion,
        source_data.NUMBERBILLED AS NumberBilled,
        source_data.NUMBERCLEARED AS NumberCleared,
        source_data.NUMBERRECEIVABLEORDERS AS NumberReceivableOrders,
        source_data.OBJECTTYPE AS ObjectType,
        source_data.ORDEREDDATE AS OrderedDate,
        source_data.ORDEREDSTATE AS OrderedState,
        source_data.ORIGINATINGSYSTEM AS OriginatingSystem,
        source_data.ORIGINATINGSYSTEMREFERENCEID AS OriginatingSystemReferenceId,
        source_data.PAYMENTTERMSCODE AS PaymentTermsCode,
        source_data.PRECOLLABORATIONTOTALCOSTAMOUNT AS PreCollaborationTotalCostAmount,
        source_data.PRECOLLABORATIONTOTALCOSTAPPROXAMOUNTINBASECURRENCY AS PreCollaborationTotalCostApproxAmountInBaseCurrency,
        source_data.PRECOLLABORATIONTOTALCOSTCONVERSIONDATE AS PreCollaborationTotalCostConversionDate,
        source_data.PRECOLLABORATIONTOTALCOSTCURRENCYCODE AS PreCollaborationTotalCostCurrencyCode,
        source_data.PRECOLLABORATIONTOTALCOSTAMOUNTINREPORTINGCURRENCY AS PreCollaborationTotalCostAmountInReportingCurrency,
        source_data.PREPARERCODE AS PreparerCode,
        source_data.PREVIOUSAPPROVALREQUESTSVERSION AS PreviousApprovalRequestsVersion,
        source_data.PREVIOUSVERSION AS PreviousVersion,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.PROJECTID AS ProjectId,
        source_data.PROJECTTITLE AS ProjectTitle,
        source_data.REALTIMEBUDGETRESPONSECODE AS RealTimeBudgetResponseCode,
        source_data.RECEIVEDDATE AS ReceivedDate,
        source_data.RECEIVEDSTATE AS ReceivedState,
        source_data.REQUESTERCODE AS RequesterCode,
        source_data.RESUBMITDATE AS ResubmitDate,
        source_data.SENTDATE AS SentDate,
        source_data.SOURCINGSTATUS AS SourcingStatus,
        source_data.SOURCINGSTATUSMESSAGE AS SourcingStatusMessage,
        source_data.SOURCINGSTATUSSTRING AS SourcingStatusString,
        source_data.STATUSSTRING AS StatusString,
        source_data.SUBMITDATE AS SubmitDate,
        source_data.SUPPLIERCODE AS SupplierCode,
        source_data.TAXAMOUNTAMOUNT AS TaxAmountAmount,
        source_data.TAXAMOUNTAPPROXAMOUNTINBASECURRENCY AS TaxAmountApproxAmountInBaseCurrency,
        source_data.TAXAMOUNTCONVERSIONDATE AS TaxAmountConversionDate,
        source_data.TAXAMOUNTCURRENCYCODE AS TaxAmountCurrencyCode,
        source_data.TAXAMOUNTAMOUNTINREPORTINGCURRENCY AS TaxAmountAmountInReportingCurrency,
        source_data.TIMECREATED AS TimeCreated,
        source_data.TIMEUPDATED AS TimeUpdated,
        source_data.TOTALCOSTAMOUNT AS TotalCostAmount,
        source_data.TOTALCOSTAPPROXAMOUNTINBASECURRENCY AS TotalCostApproxAmountInBaseCurrency,
        source_data.TOTALCOSTCONVERSIONDATE AS TotalCostConversionDate,
        source_data.TOTALCOSTCURRENCYCODE AS TotalCostCurrencyCode,
        source_data.TOTALCOSTAMOUNTINREPORTINGCURRENCY AS TotalCostAmountInReportingCurrency,
        source_data.UNIQUENAME AS UniqueName,
        source_data.VATAMOUNTAMOUNT AS VATAmountAmount,
        source_data.VATAMOUNTAPPROXAMOUNTINBASECURRENCY AS VATAmountApproxAmountInBaseCurrency,
        source_data.VATAMOUNTCONVERSIONDATE AS VATAmountConversionDate,
        source_data.VATAMOUNTCURRENCYCODE AS VATAmountCurrencyCode,
        source_data.VATAMOUNTAMOUNTINREPORTINGCURRENCY AS VATAmountAmountInReportingCurrency,
        source_data.VERSIONNUMBER AS VersionNumber,
        source_data.VERSION AS Version,
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
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(REQUISITIONIDKEY as VARCHAR(16777216)) as REQUISITIONIDKEY,
        cast(REQUISITIONVERSIONKEY as NUMBER(38,0)) as REQUISITIONVERSIONKEY,
        cast(ACTIVE as BOOLEAN) as ACTIVE,
        cast(AMOUNTACCEPTEDAMOUNT as NUMBER(38,10)) as AMOUNTACCEPTEDAMOUNT,
        cast(AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTACCEPTEDCONVERSIONDATE,
        cast(AMOUNTACCEPTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTACCEPTEDCURRENCYCODE,
        cast(AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTBILLEDAMOUNT as NUMBER(38,10)) as AMOUNTBILLEDAMOUNT,
        cast(AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTBILLEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTBILLEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTBILLEDCONVERSIONDATE,
        cast(AMOUNTBILLEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTBILLEDCURRENCYCODE,
        cast(AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTBILLEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTCLEAREDAMOUNT as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNT,
        cast(AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTCLEAREDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCLEAREDCONVERSIONDATE,
        cast(AMOUNTCLEAREDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCLEAREDCURRENCYCODE,
        cast(AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTCLEAREDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTINVOICEDAMOUNT as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNT,
        cast(AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTINVOICEDCONVERSIONDATE,
        cast(AMOUNTINVOICEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTINVOICEDCURRENCYCODE,
        cast(AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTRECONCILEDAMOUNT as NUMBER(38,10)) as AMOUNTRECONCILEDAMOUNT,
        cast(AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTRECONCILEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTRECONCILEDCONVERSIONDATE,
        cast(AMOUNTRECONCILEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTRECONCILEDCURRENCYCODE,
        cast(AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTREJECTEDAMOUNT as NUMBER(38,10)) as AMOUNTREJECTEDAMOUNT,
        cast(AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTREJECTEDCONVERSIONDATE,
        cast(AMOUNTREJECTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTREJECTEDCURRENCYCODE,
        cast(AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDAMOUNTINREPORTINGCURRENCY,
        cast(APPROVALREQUESTSVERSION as NUMBER(38,0)) as APPROVALREQUESTSVERSION,
        cast(APPROVEDDATE as TIMESTAMP_NTZ(9)) as APPROVEDDATE,
        cast(APPROVEDSTATE as NUMBER(38,0)) as APPROVEDSTATE,
        cast(AREORDERSSTUCK as BOOLEAN) as AREORDERSSTUCK,
        cast(BLANKETORDERID as VARCHAR(16777216)) as BLANKETORDERID,
        cast(BLANKETORDERCODE as VARCHAR(16777216)) as BLANKETORDERCODE,
        cast(BUDGETCHECKSTATUS as NUMBER(38,0)) as BUDGETCHECKSTATUS,
        cast(BUDGETCHECKSTATUSMESSAGE as VARCHAR(16777216)) as BUDGETCHECKSTATUSMESSAGE,
        cast(BUDGETREFID as VARCHAR(16777216)) as BUDGETREFID,
        cast(CHANGEDBYCODE as VARCHAR(16777216)) as CHANGEDBYCODE,
        cast(CHARGEAMOUNTAMOUNT as NUMBER(38,10)) as CHARGEAMOUNTAMOUNT,
        cast(CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(CHARGEAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as CHARGEAMOUNTCONVERSIONDATE,
        cast(CHARGEAMOUNTCURRENCYCODE as VARCHAR(16777216)) as CHARGEAMOUNTCURRENCYCODE,
        cast(CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as CHARGEAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(COLLABORATIONSTATECANCELREASONCODE as VARCHAR(16777216)) as COLLABORATIONSTATECANCELREASONCODE,
        cast(COLLABORATIONSTATEMODE as NUMBER(38,0)) as COLLABORATIONSTATEMODE,
        cast(COLLABORATIONSTATEORDERCODE as VARCHAR(16777216)) as COLLABORATIONSTATEORDERCODE,
        cast(COLLABORATIONSTATEREASONCODE as VARCHAR(16777216)) as COLLABORATIONSTATEREASONCODE,
        cast(COLLABORATIONSTATESTATE as NUMBER(38,0)) as COLLABORATIONSTATESTATE,
        cast(COLLABORATIONSTATESUPPLIERCODE as VARCHAR(16777216)) as COLLABORATIONSTATESUPPLIERCODE,
        cast(COMPANYCODECODE as VARCHAR(16777216)) as COMPANYCODECODE,
        cast(CREATEDATE as TIMESTAMP_NTZ(9)) as CREATEDATE,
        cast(CUSTOMCATALOGPURCHASEORGCODE as VARCHAR(16777216)) as CUSTOMCATALOGPURCHASEORGCODE,
        cast(DISCOUNTAMOUNTAMOUNT as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNT,
        cast(DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(DISCOUNTAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as DISCOUNTAMOUNTCONVERSIONDATE,
        cast(DISCOUNTAMOUNTCURRENCYCODE as VARCHAR(16777216)) as DISCOUNTAMOUNTCURRENCYCODE,
        cast(DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as DISCOUNTAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(ERPREQUISITIONIDCODE as VARCHAR(16777216)) as ERPREQUISITIONIDCODE,
        cast(EXTERNALREQID as VARCHAR(16777216)) as EXTERNALREQID,
        cast(EXTERNALREQURL as VARCHAR(16777216)) as EXTERNALREQURL,
        cast(EXTERNALSOURCINGID as VARCHAR(16777216)) as EXTERNALSOURCINGID,
        cast(HOLDTILLDATE as TIMESTAMP_NTZ(9)) as HOLDTILLDATE,
        cast(INITIALUNIQUENAME as VARCHAR(16777216)) as INITIALUNIQUENAME,
        cast(INVOICEDDATE as TIMESTAMP_NTZ(9)) as INVOICEDDATE,
        cast(ISEXTERNALREQ as BOOLEAN) as ISEXTERNALREQ,
        cast(ISFORCAST as BOOLEAN) as ISFORCAST,
        cast(ISSERVICEORDER as BOOLEAN) as ISSERVICEORDER,
        cast(ISSERVICEREQUISITION as BOOLEAN) as ISSERVICEREQUISITION,
        cast(LASTCHECKDATE as TIMESTAMP_NTZ(9)) as LASTCHECKDATE,
        cast(LASTMODIFIEDDATE as TIMESTAMP_NTZ(9)) as LASTMODIFIEDDATE,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(NEXTVERSION as VARCHAR(16777216)) as NEXTVERSION,
        cast(NUMBERBILLED as NUMBER(38,10)) as NUMBERBILLED,
        cast(NUMBERCLEARED as NUMBER(38,10)) as NUMBERCLEARED,
        cast(NUMBERRECEIVABLEORDERS as NUMBER(38,0)) as NUMBERRECEIVABLEORDERS,
        cast(OBJECTTYPE as VARCHAR(16777216)) as OBJECTTYPE,
        cast(ORDEREDDATE as TIMESTAMP_NTZ(9)) as ORDEREDDATE,
        cast(ORDEREDSTATE as NUMBER(38,0)) as ORDEREDSTATE,
        cast(ORIGINATINGSYSTEM as VARCHAR(16777216)) as ORIGINATINGSYSTEM,
        cast(ORIGINATINGSYSTEMREFERENCEID as VARCHAR(16777216)) as ORIGINATINGSYSTEMREFERENCEID,
        cast(PAYMENTTERMSCODE as VARCHAR(16777216)) as PAYMENTTERMSCODE,
        cast(PRECOLLABORATIONTOTALCOSTAMOUNT as NUMBER(38,10)) as PRECOLLABORATIONTOTALCOSTAMOUNT,
        cast(PRECOLLABORATIONTOTALCOSTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as PRECOLLABORATIONTOTALCOSTAPPROXAMOUNTINBASECURRENCY,
        cast(PRECOLLABORATIONTOTALCOSTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as PRECOLLABORATIONTOTALCOSTCONVERSIONDATE,
        cast(PRECOLLABORATIONTOTALCOSTCURRENCYCODE as VARCHAR(16777216)) as PRECOLLABORATIONTOTALCOSTCURRENCYCODE,
        cast(PRECOLLABORATIONTOTALCOSTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as PRECOLLABORATIONTOTALCOSTAMOUNTINREPORTINGCURRENCY,
        cast(PREPARERCODE as VARCHAR(16777216)) as PREPARERCODE,
        cast(PREVIOUSAPPROVALREQUESTSVERSION as NUMBER(38,0)) as PREVIOUSAPPROVALREQUESTSVERSION,
        cast(PREVIOUSVERSION as VARCHAR(16777216)) as PREVIOUSVERSION,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(PROJECTID as VARCHAR(16777216)) as PROJECTID,
        cast(PROJECTTITLE as VARCHAR(16777216)) as PROJECTTITLE,
        cast(REALTIMEBUDGETRESPONSECODE as VARCHAR(16777216)) as REALTIMEBUDGETRESPONSECODE,
        cast(RECEIVEDDATE as TIMESTAMP_NTZ(9)) as RECEIVEDDATE,
        cast(RECEIVEDSTATE as NUMBER(38,0)) as RECEIVEDSTATE,
        cast(REQUESTERCODE as VARCHAR(16777216)) as REQUESTERCODE,
        cast(RESUBMITDATE as TIMESTAMP_NTZ(9)) as RESUBMITDATE,
        cast(SENTDATE as TIMESTAMP_NTZ(9)) as SENTDATE,
        cast(SOURCINGSTATUS as NUMBER(38,0)) as SOURCINGSTATUS,
        cast(SOURCINGSTATUSMESSAGE as VARCHAR(16777216)) as SOURCINGSTATUSMESSAGE,
        cast(SOURCINGSTATUSSTRING as VARCHAR(16777216)) as SOURCINGSTATUSSTRING,
        cast(STATUSSTRING as VARCHAR(16777216)) as STATUSSTRING,
        cast(SUBMITDATE as TIMESTAMP_NTZ(9)) as SUBMITDATE,
        cast(SUPPLIERCODE as VARCHAR(16777216)) as SUPPLIERCODE,
        cast(TAXAMOUNTAMOUNT as NUMBER(38,10)) as TAXAMOUNTAMOUNT,
        cast(TAXAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TAXAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(TAXAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TAXAMOUNTCONVERSIONDATE,
        cast(TAXAMOUNTCURRENCYCODE as VARCHAR(16777216)) as TAXAMOUNTCURRENCYCODE,
        cast(TAXAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TAXAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(TIMECREATED as TIMESTAMP_NTZ(9)) as TIMECREATED,
        cast(TIMEUPDATED as TIMESTAMP_NTZ(9)) as TIMEUPDATED,
        cast(TOTALCOSTAMOUNT as NUMBER(38,10)) as TOTALCOSTAMOUNT,
        cast(TOTALCOSTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as TOTALCOSTAPPROXAMOUNTINBASECURRENCY,
        cast(TOTALCOSTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as TOTALCOSTCONVERSIONDATE,
        cast(TOTALCOSTCURRENCYCODE as VARCHAR(16777216)) as TOTALCOSTCURRENCYCODE,
        cast(TOTALCOSTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as TOTALCOSTAMOUNTINREPORTINGCURRENCY,
        cast(VATAMOUNTAMOUNT as NUMBER(38,10)) as VATAMOUNTAMOUNT,
        cast(VATAMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as VATAMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(VATAMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as VATAMOUNTCONVERSIONDATE,
        cast(VATAMOUNTCURRENCYCODE as VARCHAR(16777216)) as VATAMOUNTCURRENCYCODE,
        cast(VATAMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as VATAMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(VERSIONNUMBER as NUMBER(38,0)) as VERSIONNUMBER,
        cast(UNIQUENAME as VARCHAR(16777216)) as UNIQUENAME,
        cast(CUSTOMFIELD_BPO as BOOLEAN) as CUSTOMFIELD_BPO,
        cast(CUSTOMFIELD_BUYERDETAILS as VARCHAR(16777126)) as CUSTOMFIELD_BUYERDETAILS,
        cast(CUSTOMFIELD_BUYERNAME as VARCHAR(16777126)) as CUSTOMFIELD_BUYERNAME,
        cast(CUSTOMFIELD_COMPANYNAME as VARCHAR(16777126)) as CUSTOMFIELD_COMPANYNAME,
        cast(CUSTOMFIELD_ENDDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_ENDDATE,
        cast(CUSTOMFIELD_ISBPO as BOOLEAN) as CUSTOMFIELD_ISBPO,
        cast(CUSTOMFIELD_ISBAANSPECIFIC as BOOLEAN) as CUSTOMFIELD_ISBAANSPECIFIC,
        cast(CUSTOMFIELD_STARTDATE as TIMESTAMP_NTZ(9)) as CUSTOMFIELD_STARTDATE,
        cast(CUSTOMFIELD_UPSNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_UPSNUMBER,
        cast(VERSION as NUMBER(38,0)) as VERSION,
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data