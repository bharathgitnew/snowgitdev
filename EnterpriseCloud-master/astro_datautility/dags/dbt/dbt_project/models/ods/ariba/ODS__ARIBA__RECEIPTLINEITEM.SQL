
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='ReceiptLineItem',
    unique_key = ['RealmName',
    'ReceiptIDKey',
    'ReceiptVersionKey',
    'ReceiptLineItemKey']
) }}


with source_data as
(
    SELECT
         JsonField:TimeUpdated::TIMESTAMP_NTZ AS LastUpdated
        ,regexp_substr(_FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1) AS RealmName
        ,JsonField:UniqueName::STRING AS ReceiptIDKey
        ,JsonField:VersionNumber::INTEGER AS ReceiptVersionKey
        ,ReceiptItem.value:AmountAccepted:Amount::NUMBER(38,10) AS AmountAcceptedAmount
        ,ReceiptItem.value:AmountAccepted:AmountInReportingCurrency::NUMBER(38,10) AS AmountAcceptedReportingCurrency
        ,ReceiptItem.value:AmountAccepted:AmountInBaseCurrency::NUMBER(38,10) AS AmountAcceptedBaseCurrency
        ,ReceiptItem.value:AmountAccepted:ConversionDate::TIMESTAMP_NTZ AS AmountAcceptedConversionDate
        ,ReceiptItem.value:AmountAccepted:Currency:UniqueName::STRING AS AmountAcceptedCurrencyCode
        ,ReceiptItem.value:AmountInvoiced:Amount::NUMBER(38,10) AS AmountInvoicedAmount
        ,ReceiptItem.value:AmountInvoiced:AmountInReportingCurrency::NUMBER(38,10) AS AmountInvoicedReportingCurrency
        ,ReceiptItem.value:AmountInvoiced:AmountInBaseCurrency::NUMBER(38,10) AS AmountInvoicedBaseCurrency
        ,ReceiptItem.value:AmountInvoiced:ConversionDate::TIMESTAMP_NTZ AS AmountInvoicedConversionDate
        ,ReceiptItem.value:AmountInvoiced:Currency:UniqueName::STRING AS AmountInvoicedCurrencyCode
        ,ReceiptItem.value:AmountPreviouslyAccepted:Amount::NUMBER(38,10) AS AmountPreviouslyAcceptedAmount
        ,ReceiptItem.value:AmountPreviouslyAccepted:AmountInReportingCurrency::NUMBER(38,10) AS AmountPreviouslyAcceptedReportingCurrency
        ,ReceiptItem.value:AmountPreviouslyAccepted:AmountInBaseCurrency::NUMBER(38,10) AS AmountPreviouslyAcceptedBaseCurrency
        ,ReceiptItem.value:AmountPreviouslyAccepted:ConversionDate::TIMESTAMP_NTZ AS AmountPreviouslyAcceptedConversionDate
        ,ReceiptItem.value:AmountPreviouslyAccepted:Currency:UniqueName::STRING AS AmountPreviouslyAcceptedCurrencyCode
        ,ReceiptItem.value:AmountPreviouslyRejected:Amount::NUMBER(38,10) AS AmountPreviouslyRejectedAmount
        ,ReceiptItem.value:AmountPreviouslyRejected:AmountInReportingCurrency::NUMBER(38,10) AS AmountPreviouslyRejectedReportingCurrency
        ,ReceiptItem.value:AmountPreviouslyRejected:AmountInBaseCurrency::NUMBER(38,10) AS AmountPreviouslyRejectedBaseCurrency
        ,ReceiptItem.value:AmountPreviouslyRejected:ConversionDate::TIMESTAMP_NTZ AS AmountPreviouslyRejectedConversionDate
        ,ReceiptItem.value:AmountPreviouslyRejected:Currency:UniqueName::STRING AS AmountPreviouslyRejectedCurrencyCode
        ,ReceiptItem.value:AmountReconciled:Amount::NUMBER(38,10) AS AmountReconciledAmount
        ,ReceiptItem.value:AmountReconciled:AmountInReportingCurrency::NUMBER(38,10) AS AmountReconciledReportingCurrency
        ,ReceiptItem.value:AmountReconciled:AmountInBaseCurrency::NUMBER(38,10) AS AmountReconciledBaseCurrency
        ,ReceiptItem.value:AmountReconciled:ConversionDate::TIMESTAMP_NTZ AS AmountReconciledConversionDate
        ,ReceiptItem.value:AmountReconciled:Currency:UniqueName::STRING AS AmountReconciledCurrencyCode
        ,ReceiptItem.value:AmountRejected:Amount::NUMBER(38,10) AS AmountRejectedAmount
        ,ReceiptItem.value:AmountRejected:AmountInReportingCurrency::NUMBER(38,10) AS AmountRejectedReportingCurrency
        ,ReceiptItem.value:AmountRejected:ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountRejectedBaseCurrency
        ,ReceiptItem.value:AmountRejected:ConversionDate::TIMESTAMP_NTZ AS AmountRejectedConversionDate
        ,ReceiptItem.value:AmountRejected:Currency:UniqueName::STRING AS AmountRejectedCurrencyCode
        ,ReceiptItem.value:AssetData:AssetData:SerialNumber::STRING AS AssetDataAssetDataSerialNumber
        ,ReceiptItem.value:AssetData:AssetData:Location::STRING AS AssetDataAssetDataLocation
        ,ReceiptItem.value:AssetData:AssetData:TagNumber::STRING AS AssetDataAssetDataTagNumber
        ,ReceiptItem.value:AssetData:AssetData:UnitNumber::INTEGER AS AssetDataAssetDataUnitNumber
        ,ReceiptItem.value:AssetDataNeeded::INTEGER AS AssetDataNeeded
        ,ReceiptItem.value:Comment::STRING AS Comment
        ,ReceiptItem.value:Date::TIMESTAMP_NTZ AS Date
        ,ReceiptItem.value:ERPPOLineNumber::STRING AS ERPPOLineNumber
        ,ReceiptItem.value:ERPPONumber::STRING AS ERPPONumber
        ,ReceiptItem.value:ERPReceiptLineNumber::STRING AS ERPReceiptLineNumber
        ,ReceiptItem.value:GrossAmountAccepted:Amount::NUMBER(38,10) AS GrossAmountAcceptedAmount
        ,ReceiptItem.value:GrossAmountAccepted:AmountInReportingCurrency::NUMBER(38,10) AS GrossAmountAcceptedReportingCurrency
        ,ReceiptItem.value:GrossAmountAccepted:ApproxAmountInBaseCurrency::NUMBER(38,10) AS GrossAmountAcceptedBaseCurrency
        ,ReceiptItem.value:GrossAmountAccepted:ConversionDate::TIMESTAMP_NTZ AS GrossAmountAcceptedConversionDate
        ,ReceiptItem.value:GrossAmountAccepted:Currency:UniqueName::STRING AS GrossAmountAcceptedCurrencyCode
        ,ReceiptItem.value:GrossAmountPreviouslyAccepted:Amount::NUMBER(38,10) AS GrossAmountPreviouslyAcceptedAmount
        ,ReceiptItem.value:GrossAmountPreviouslyAccepted:AmountInReportingCurrency::NUMBER(38,10) AS GrossAmountPreviouslyAcceptedReportingCurrency
        ,ReceiptItem.value:GrossAmountPreviouslyAccepted:ApproxAmountInBaseCurrency::NUMBER(38,10) AS GrossAmountPreviouslyAcceptedBaseCurrency
        ,ReceiptItem.value:GrossAmountPreviouslyAccepted:ConversionDate::TIMESTAMP_NTZ AS GrossAmountPreviouslyAcceptedConversionDate
        ,ReceiptItem.value:GrossAmountPreviouslyAccepted:Currency:UniqueName::STRING AS GrossAmountPreviouslyAcceptedCurrencyCode
        ,ReceiptItem.value:GrossAmountPreviouslyRejected:Amount::NUMBER(38,10) AS GrossAmountPreviouslyRejectedAmount
        ,ReceiptItem.value:GrossAmountPreviouslyRejected:AmountInReportingCurrency::NUMBER(38,10) AS GrossAmountPreviouslyRejectedReportingCurrency
        ,ReceiptItem.value:GrossAmountPreviouslyRejected:ApproxAmountInBaseCurrency::NUMBER(38,10) AS GrossAmountPreviouslyRejectedBaseCurrency
        ,ReceiptItem.value:GrossAmountPreviouslyRejected:ConversionDate::TIMESTAMP_NTZ AS GrossAmountPreviouslyRejectedConversionDate
        ,ReceiptItem.value:GrossAmountPreviouslyRejected:Currency:UniqueName::STRING AS GrossAmountPreviouslyRejectedCurrencyCode
        ,ReceiptItem.value:GrossAmountRejected:Amount::NUMBER(38,10) AS GrossAmountRejectedAmount
        ,ReceiptItem.value:GrossAmountRejected:AmountInReportingCurrency::NUMBER(38,10) AS GrossAmountRejectedReportingCurrency
        ,ReceiptItem.value:GrossAmountRejected:ApproxAmountInBaseCurrency::NUMBER(38,10) AS GrossAmountRejectedBaseCurrency
        ,ReceiptItem.value:GrossAmountRejected:ConversionDate::TIMESTAMP_NTZ AS GrossAmountRejectedConversionDate
        ,ReceiptItem.value:GrossAmountRejected:Currency:UniqueName::STRING AS GrossAmountRejectedCurrencyCode
        ,ReceiptItem.value:IsMilestone::BOOLEAN AS IsMilestone
        ,ReceiptItem.value:IsMilestoneComplete::BOOLEAN AS IsMilestoneComplete
        ,ReceiptItem.value:"LineItem.Description.Description"::STRING AS LineItemDescriptionDescription
        ,ReceiptItem.value:"LineItem.Description.UnitOfMeasure":UniqueName::STRING AS LineItemDescriptionUnitOfMeasureCode
        ,ReceiptItem.value:"LineItem.NumberInCollection"::INTEGER AS LineItemNumberInCollection
        ,ReceiptItem.value:MilestoneCompletionDate::TIMESTAMP_NTZ AS MilestoneCompletionDate
        ,ReceiptItem.value:NotifyPurchasingAgent::BOOLEAN AS NotifyPurchasingAgent
        ,ReceiptItem.value:NumberAccepted::NUMBER(38,10) AS NumberAccepted
        ,ReceiptItem.value:NumberInCollection::INTEGER AS NumberInCollection
        ,ReceiptItem.value:NumberInvoiced::NUMBER(38,10) AS NumberInvoiced
        ,ReceiptItem.value:NumberPreviouslyAccepted::NUMBER(38,10) AS NumberPreviouslyAccepted
        ,ReceiptItem.value:NumberPreviouslyRejected::NUMBER(38,10) AS NumberPreviouslyRejected
        ,ReceiptItem.value:NumberReconciled::NUMBER(38,10) AS NumberReconciled
        ,ReceiptItem.value:NumberRejected::NUMBER(38,10) AS NumberRejected
        ,ReceiptItem.value:PushStatus::INTEGER AS PushStatus
        ,ReceiptItem.value:ReceiptId::STRING AS ReceiptId
        ,ReceiptItem.value:ReceivingType::INTEGER AS ReceivingType
        ,ReceiptItem.value:ReturnBy:UniqueName::STRING AS ReturnBy
        ,ReceiptItem.value:UnitOfMeasure:UniqueName::STRING AS UnitOfMeasureCode
        ,ReceiptItem.value:cus_RecRefDoc::STRING AS CustomField_RecRefDoc
        FROM {{ source("ARIBA", "RECEIPT") }} LZData
        , LATERAL FLATTEN (input => parse_json(JsonField:ReceiptItems)) ReceiptItem
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY
                                regexp_substr(LZData._FileName, '\\.([^\\.]+)\\.', 1, 1, 'e', 1)
                                ,LZData.JSonField:UniqueName::STRING
                                ,LZData.JSonField:Version::INTEGER
                                ,ReceiptItem.value:NumberInCollection::INTEGER
                            ORDER BY JsonField:TimeUpdated::TIMESTAMP_NTZ DESC) )= 1
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.RECEIPTIDKEY AS ReceiptIDKey,
        source_data.RECEIPTVERSIONKEY AS ReceiptVersionKey,
        source_data.NUMBERINCOLLECTION AS ReceiptLineItemKey,
        source_data.AMOUNTACCEPTEDREPORTINGCURRENCY AS AmountAcceptedReportingCurrency,
        source_data.AMOUNTACCEPTEDBASECURRENCY AS AmountAcceptedBaseCurrency,
        source_data.AMOUNTACCEPTEDAMOUNT AS AmountAcceptedAmount,
        source_data.AMOUNTACCEPTEDCONVERSIONDATE AS AmountAcceptedConversionDate,
        source_data.AMOUNTACCEPTEDCURRENCYCODE AS AmountAcceptedCurrencyCode,
        source_data.AMOUNTINVOICEDREPORTINGCURRENCY AS AmountInvoicedReportingCurrency,
        source_data.AMOUNTINVOICEDBASECURRENCY AS AmountInvoicedBaseCurrency,
        source_data.AMOUNTINVOICEDAMOUNT AS AmountInvoicedAmount,
        source_data.AMOUNTINVOICEDCONVERSIONDATE AS AmountInvoicedConversionDate,
        source_data.AMOUNTINVOICEDCURRENCYCODE AS AmountInvoicedCurrencyCode,
        source_data.AMOUNTPREVIOUSLYACCEPTEDREPORTINGCURRENCY AS AmountPreviouslyAcceptedReportingCurrency,
        source_data.AMOUNTPREVIOUSLYACCEPTEDBASECURRENCY AS AmountPreviouslyAcceptedBaseCurrency,
        source_data.AMOUNTPREVIOUSLYACCEPTEDAMOUNT AS AmountPreviouslyAcceptedAmount,
        source_data.AMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE AS AmountPreviouslyAcceptedConversionDate,
        source_data.AMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE AS AmountPreviouslyAcceptedCurrencyCode,
        source_data.AMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY AS AmountPreviouslyRejectedReportingCurrency,
        source_data.AMOUNTPREVIOUSLYREJECTEDBASECURRENCY AS AmountPreviouslyRejectedBaseCurrency,
        source_data.AMOUNTPREVIOUSLYREJECTEDAMOUNT AS AmountPreviouslyRejectedAmount,
        source_data.AMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE AS AmountPreviouslyRejectedConversionDate,
        source_data.AMOUNTPREVIOUSLYREJECTEDCURRENCYCODE AS AmountPreviouslyRejectedCurrencyCode,
        source_data.AMOUNTRECONCILEDREPORTINGCURRENCY AS AmountReconciledReportingCurrency,
        source_data.AMOUNTRECONCILEDBASECURRENCY AS AmountReconciledBaseCurrency,
        source_data.AMOUNTRECONCILEDAMOUNT AS AmountReconciledAmount,
        source_data.AMOUNTRECONCILEDCONVERSIONDATE AS AmountReconciledConversionDate,
        source_data.AMOUNTRECONCILEDCURRENCYCODE AS AmountReconciledCurrencyCode,
        source_data.AMOUNTREJECTEDREPORTINGCURRENCY AS AmountRejectedReportingCurrency,
        source_data.AMOUNTREJECTEDBASECURRENCY AS AmountRejectedBaseCurrency,
        source_data.AMOUNTREJECTEDAMOUNT AS AmountRejectedAmount,
        source_data.AMOUNTREJECTEDCONVERSIONDATE AS AmountRejectedConversionDate,
        source_data.AMOUNTREJECTEDCURRENCYCODE AS AmountRejectedCurrencyCode,
        source_data.ASSETDATAASSETDATASERIALNUMBER AS AssetDataSerialNumber,
        source_data.ASSETDATAASSETDATALOCATION AS AssetDataLocation,
        source_data.ASSETDATAASSETDATATAGNUMBER AS AssetDataTagNumber,
        source_data.ASSETDATAASSETDATAUNITNUMBER AS AssetDataUnitNumber,
        source_data.ASSETDATANEEDED AS AssetDataNeeded,
        source_data.COMMENT AS Comment,
        source_data.DATE AS Date,
        source_data.LINEITEMDESCRIPTIONDESCRIPTION AS DescriptionDescription,
        source_data.LINEITEMDESCRIPTIONUNITOFMEASURECODE AS DescriptionUnitOfMeasureUniqueName,
        source_data.ERPPOLINENUMBER AS ERPPOLineNumber,
        source_data.ERPPONUMBER AS ERPPONumber,
        source_data.ERPRECEIPTLINENUMBER AS ERPReceiptLineNumber,
        source_data.GROSSAMOUNTACCEPTEDREPORTINGCURRENCY AS GrossAmountAcceptedReportingCurrency,
        source_data.GROSSAMOUNTACCEPTEDBASECURRENCY AS GrossAmountAcceptedBaseCurrency,
        source_data.GROSSAMOUNTACCEPTEDAMOUNT AS GrossAmountAcceptedAmount,
        source_data.GROSSAMOUNTACCEPTEDCONVERSIONDATE AS GrossAmountAcceptedConversionDate,
        source_data.GROSSAMOUNTACCEPTEDCURRENCYCODE AS GrossAmountAcceptedCurrencyCode,
        source_data.GROSSAMOUNTPREVIOUSLYACCEPTEDBASECURRENCY AS GrossAmountPreviouslyAcceptedBaseCurrency,
        source_data.GROSSAMOUNTPREVIOUSLYACCEPTEDAMOUNT AS GrossAmountPreviouslyAcceptedAmount,
        source_data.GROSSAMOUNTPREVIOUSLYACCEPTEDREPORTINGCURRENCY AS GrossAmountPreviouslyReportingCurrency,
        source_data.GROSSAMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE AS GrossAmountPreviouslyAcceptedConversionDate,
        source_data.GROSSAMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE AS GrossAmountPreviouslyAcceptedCurrencyCode,
        source_data.GROSSAMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY AS GrossAmountPreviouslyRejectedReportingCurrency,
        source_data.GROSSAMOUNTPREVIOUSLYREJECTEDBASECURRENCY AS GrossAmountPreviouslyRejectedBaseCurrency,
        source_data.GROSSAMOUNTPREVIOUSLYREJECTEDAMOUNT AS GrossAmountPreviouslyRejectedAmount,
        source_data.GROSSAMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE AS GrossAmountPreviouslyRejectedConversionDate,
        source_data.GROSSAMOUNTPREVIOUSLYREJECTEDCURRENCYCODE AS GrossAmountPreviouslyRejectedCurrencyCode,
        source_data.GROSSAMOUNTREJECTEDREPORTINGCURRENCY AS GrossAmountRejectedReportingCurrency,
        source_data.GROSSAMOUNTREJECTEDBASECURRENCY AS GrossAmountRejectedBaseCurrency,
        source_data.GROSSAMOUNTREJECTEDAMOUNT AS GrossAmountRejectedAmount,
        source_data.GROSSAMOUNTREJECTEDCONVERSIONDATE AS GrossAmountRejectedConversionDate,
        source_data.GROSSAMOUNTREJECTEDCURRENCYCODE AS GrossAmountRejectedCurrencyCode,
        source_data.ISMILESTONE AS IsMilestone,
        source_data.ISMILESTONECOMPLETE AS IsMilestoneComplete,
        source_data.MILESTONECOMPLETIONDATE AS MilestoneCompletionDate,
        source_data.NOTIFYPURCHASINGAGENT AS NotifyPurchasingAgent,
        source_data.NUMBERACCEPTED AS NumberAccepted,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.NUMBERINVOICED AS NumberInvoiced,
        source_data.NUMBERPREVIOUSLYACCEPTED AS NumberPreviouslyAccepted,
        source_data.NUMBERPREVIOUSLYREJECTED AS NumberPreviouslyRejected,
        source_data.NUMBERRECONCILED AS NumberReconciled,
        source_data.NUMBERREJECTED AS NumberRejected,
        source_data.PUSHSTATUS AS PushStatus,
        source_data.RECEIVINGTYPE AS ReceivingType,
        source_data.RETURNBY AS ReturnBy,
        source_data.CUSTOMFIELD_RECREFDOC AS CustomField_RecRefDoc,
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
        cast(RECEIPTIDKEY as VARCHAR(16777216)) as RECEIPTIDKEY,
        cast(RECEIPTVERSIONKEY as NUMBER(38,0)) as RECEIPTVERSIONKEY,
        cast(RECEIPTLINEITEMKEY as NUMBER(38,0)) as RECEIPTLINEITEMKEY,
        cast(AMOUNTACCEPTEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDREPORTINGCURRENCY,
        cast(AMOUNTACCEPTEDBASECURRENCY as NUMBER(38,10)) as AMOUNTACCEPTEDBASECURRENCY,
        cast(AMOUNTACCEPTEDAMOUNT as NUMBER(38,10)) as AMOUNTACCEPTEDAMOUNT,
        cast(AMOUNTACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTACCEPTEDCONVERSIONDATE,
        cast(AMOUNTACCEPTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTACCEPTEDCURRENCYCODE,
        cast(AMOUNTINVOICEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDREPORTINGCURRENCY,
        cast(AMOUNTINVOICEDBASECURRENCY as NUMBER(38,10)) as AMOUNTINVOICEDBASECURRENCY,
        cast(AMOUNTINVOICEDAMOUNT as NUMBER(38,10)) as AMOUNTINVOICEDAMOUNT,
        cast(AMOUNTINVOICEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTINVOICEDCONVERSIONDATE,
        cast(AMOUNTINVOICEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTINVOICEDCURRENCYCODE,
        cast(AMOUNTPREVIOUSLYACCEPTEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTPREVIOUSLYACCEPTEDREPORTINGCURRENCY,
        cast(AMOUNTPREVIOUSLYACCEPTEDBASECURRENCY as NUMBER(38,10)) as AMOUNTPREVIOUSLYACCEPTEDBASECURRENCY,
        cast(AMOUNTPREVIOUSLYACCEPTEDAMOUNT as NUMBER(38,10)) as AMOUNTPREVIOUSLYACCEPTEDAMOUNT,
        cast(AMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE,
        cast(AMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE,
        cast(AMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY,
        cast(AMOUNTPREVIOUSLYREJECTEDBASECURRENCY as NUMBER(38,10)) as AMOUNTPREVIOUSLYREJECTEDBASECURRENCY,
        cast(AMOUNTPREVIOUSLYREJECTEDAMOUNT as NUMBER(38,10)) as AMOUNTPREVIOUSLYREJECTEDAMOUNT,
        cast(AMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE,
        cast(AMOUNTPREVIOUSLYREJECTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTPREVIOUSLYREJECTEDCURRENCYCODE,
        cast(AMOUNTRECONCILEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDREPORTINGCURRENCY,
        cast(AMOUNTRECONCILEDBASECURRENCY as NUMBER(38,10)) as AMOUNTRECONCILEDBASECURRENCY,
        cast(AMOUNTRECONCILEDAMOUNT as NUMBER(38,10)) as AMOUNTRECONCILEDAMOUNT,
        cast(AMOUNTRECONCILEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTRECONCILEDCONVERSIONDATE,
        cast(AMOUNTRECONCILEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTRECONCILEDCURRENCYCODE,
        cast(AMOUNTREJECTEDREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDREPORTINGCURRENCY,
        cast(AMOUNTREJECTEDBASECURRENCY as NUMBER(38,10)) as AMOUNTREJECTEDBASECURRENCY,
        cast(AMOUNTREJECTEDAMOUNT as NUMBER(38,10)) as AMOUNTREJECTEDAMOUNT,
        cast(AMOUNTREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTREJECTEDCONVERSIONDATE,
        cast(AMOUNTREJECTEDCURRENCYCODE as VARCHAR(16777216)) as AMOUNTREJECTEDCURRENCYCODE,
        cast(ASSETDATASERIALNUMBER as VARCHAR(16777216)) as ASSETDATASERIALNUMBER,
        cast(ASSETDATALOCATION as VARCHAR(16777216)) as ASSETDATALOCATION,
        cast(ASSETDATATAGNUMBER as VARCHAR(16777216)) as ASSETDATATAGNUMBER,
        cast(ASSETDATAUNITNUMBER as NUMBER(38,0)) as ASSETDATAUNITNUMBER,
        cast(ASSETDATANEEDED as NUMBER(38,0)) as ASSETDATANEEDED,
        cast(COMMENT as VARCHAR(16777216)) as COMMENT,
        cast(DATE as TIMESTAMP_NTZ(9)) as DATE,
        cast(DESCRIPTIONDESCRIPTION as VARCHAR(16777216)) as DESCRIPTIONDESCRIPTION,
        cast(DESCRIPTIONUNITOFMEASUREUNIQUENAME as VARCHAR(16777216)) as DESCRIPTIONUNITOFMEASUREUNIQUENAME,
        cast(ERPPOLINENUMBER as VARCHAR(16777216)) as ERPPOLINENUMBER,
        cast(ERPPONUMBER as VARCHAR(16777216)) as ERPPONUMBER,
        cast(ERPRECEIPTLINENUMBER as VARCHAR(16777216)) as ERPRECEIPTLINENUMBER,
        cast(GROSSAMOUNTACCEPTEDREPORTINGCURRENCY as NUMBER(38,10)) as GROSSAMOUNTACCEPTEDREPORTINGCURRENCY,
        cast(GROSSAMOUNTACCEPTEDBASECURRENCY as NUMBER(38,10)) as GROSSAMOUNTACCEPTEDBASECURRENCY,
        cast(GROSSAMOUNTACCEPTEDAMOUNT as NUMBER(38,10)) as GROSSAMOUNTACCEPTEDAMOUNT,
        cast(GROSSAMOUNTACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as GROSSAMOUNTACCEPTEDCONVERSIONDATE,
        cast(GROSSAMOUNTACCEPTEDCURRENCYCODE as VARCHAR(16777216)) as GROSSAMOUNTACCEPTEDCURRENCYCODE,
        cast(GROSSAMOUNTPREVIOUSLYREPORTINGCURRENCY as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYREPORTINGCURRENCY,
        cast(GROSSAMOUNTPREVIOUSLYACCEPTEDBASECURRENCY as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYACCEPTEDBASECURRENCY,
        cast(GROSSAMOUNTPREVIOUSLYACCEPTEDAMOUNT as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYACCEPTEDAMOUNT,
        cast(GROSSAMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as GROSSAMOUNTPREVIOUSLYACCEPTEDCONVERSIONDATE,
        cast(GROSSAMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE as VARCHAR(16777216)) as GROSSAMOUNTPREVIOUSLYACCEPTEDCURRENCYCODE,
        cast(GROSSAMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYREJECTEDREPORTINGCURRENCY,
        cast(GROSSAMOUNTPREVIOUSLYREJECTEDBASECURRENCY as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYREJECTEDBASECURRENCY,
        cast(GROSSAMOUNTPREVIOUSLYREJECTEDAMOUNT as NUMBER(38,10)) as GROSSAMOUNTPREVIOUSLYREJECTEDAMOUNT,
        cast(GROSSAMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as GROSSAMOUNTPREVIOUSLYREJECTEDCONVERSIONDATE,
        cast(GROSSAMOUNTPREVIOUSLYREJECTEDCURRENCYCODE as VARCHAR(16777216)) as GROSSAMOUNTPREVIOUSLYREJECTEDCURRENCYCODE,
        cast(GROSSAMOUNTREJECTEDREPORTINGCURRENCY as NUMBER(38,10)) as GROSSAMOUNTREJECTEDREPORTINGCURRENCY,
        cast(GROSSAMOUNTREJECTEDBASECURRENCY as NUMBER(38,10)) as GROSSAMOUNTREJECTEDBASECURRENCY,
        cast(GROSSAMOUNTREJECTEDAMOUNT as NUMBER(38,10)) as GROSSAMOUNTREJECTEDAMOUNT,
        cast(GROSSAMOUNTREJECTEDCONVERSIONDATE as TIMESTAMP_NTZ(9)) as GROSSAMOUNTREJECTEDCONVERSIONDATE,
        cast(GROSSAMOUNTREJECTEDCURRENCYCODE as VARCHAR(16777216)) as GROSSAMOUNTREJECTEDCURRENCYCODE,
        cast(ISMILESTONE as BOOLEAN) as ISMILESTONE,
        cast(ISMILESTONECOMPLETE as BOOLEAN) as ISMILESTONECOMPLETE,
        cast(MILESTONECOMPLETIONDATE as TIMESTAMP_NTZ(9)) as MILESTONECOMPLETIONDATE,
        cast(NOTIFYPURCHASINGAGENT as BOOLEAN) as NOTIFYPURCHASINGAGENT,
        cast(NUMBERACCEPTED as NUMBER(38,10)) as NUMBERACCEPTED,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(NUMBERINVOICED as NUMBER(38,10)) as NUMBERINVOICED,
        cast(NUMBERPREVIOUSLYACCEPTED as NUMBER(38,10)) as NUMBERPREVIOUSLYACCEPTED,
        cast(NUMBERPREVIOUSLYREJECTED as NUMBER(38,10)) as NUMBERPREVIOUSLYREJECTED,
        cast(NUMBERRECONCILED as NUMBER(38,10)) as NUMBERRECONCILED,
        cast(NUMBERREJECTED as NUMBER(38,10)) as NUMBERREJECTED,
        cast(PUSHSTATUS as NUMBER(38,0)) as PUSHSTATUS,
        cast(RECEIVINGTYPE as NUMBER(38,0)) as RECEIVINGTYPE,
        cast(RETURNBY as VARCHAR(16777216)) as RETURNBY,
        cast(CUSTOMFIELD_RECREFDOC as VARCHAR(16777216)) as CUSTOMFIELD_RECREFDOC,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data