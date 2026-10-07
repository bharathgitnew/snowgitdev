{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ARIBA_PURCHASEORDERSPLITACCOUNTING',
    unique_key = ['RealmName',
    'PurchaseOrderIdKey',
    'PurchaseOrderVersionKey',
    'PurchaseOrderLineItemKey',
    'PurchaseOrderSplitAccountingKey']
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
        ,JsonField:UniqueName::STRING AS PurchaseOrderIdKey
        ,JsonField:Version::INTEGER AS PurchaseOrderVersionKey
        ,LineItem.value:NumberInCollection::INTEGER AS PurchaseOrderLineItemKey
        ,SplitAccounting.value:Amount:Amount::NUMBER(38,10) AS AmountAmount
        ,SplitAccounting.value:Amount:AmountInReportingCurrency::NUMBER(38,10) AS AmountAmountInReportingCurrency
        ,SplitAccounting.value:Amount:ApproxAmountInBaseCurrency::NUMBER(38,10) AS AmountApproxAmountInBaseCurrency
        ,SplitAccounting.value:Amount:ConversionDate::TIMESTAMP_NTZ AS AmountConversionDate
        ,SplitAccounting.value:Amount:Currency:UniqueName::STRING AS AmountCurrencyCode
        ,SplitAccounting.value:Asset:CompanyCode:UniqueName::STRING AS AssetCompanyCodeCode
        ,SplitAccounting.value:Asset:Name::STRING AS AssetName
        ,SplitAccounting.value:Asset:SubNumber::STRING AS AssetSubNumber
        ,SplitAccounting.value:Asset:UniqueName::STRING AS AssetCode
        ,SplitAccounting.value:CompanyCode:UniqueName::STRING AS CompanyCodeCode
        ,SplitAccounting.value:CostCenter:CompanyCode:UniqueName::STRING AS CostCenterCompanyCodeCode
        ,SplitAccounting.value:CostCenter:CostCenterDescription::STRING AS CostCenterCostCenterDescription
        ,SplitAccounting.value:CostCenter:ProcurementUnit:UniqueName::STRING AS CostCenterProcurementUnitCode
        ,SplitAccounting.value:CostCenter:UniqueName::STRING AS CostCenterCode
        ,SplitAccounting.value:GeneralLedger:CompanyCode:UniqueName::STRING AS GeneralLedgerCompanyCodeCode
        ,SplitAccounting.value:GeneralLedger:GeneralLedgerDescription::STRING AS GeneralLedgerDescription
        ,SplitAccounting.value:GeneralLedger:GeneralLedgerDescription2::STRING AS GeneralLedgerDescription2
        ,SplitAccounting.value:GeneralLedger:ExternalId::STRING AS GeneralLedgerExternalId
        ,SplitAccounting.value:GeneralLedger:FieldStatusGroup::STRING AS GeneralLedgerFieldStatusGroup
        ,SplitAccounting.value:GeneralLedger:UniqueName::STRING AS GeneralLedgerCode
        ,SplitAccounting.value:InternalOrder.Description::STRING AS InternalOrderDescription
        ,SplitAccounting.value:InternalOrder:UniqueName::STRING AS InternalOrderCode
        ,SplitAccounting.value:NumberInCollection::INTEGER AS NumberInCollection
        ,SplitAccounting.value:WBSElement:CompanyCodeUniqueNameList::STRING AS WBSElementCompanyCodeCodeList
        ,SplitAccounting.value:WBSElement:Description::STRING AS WBSElementDescription
        ,SplitAccounting.value:WBSElement:ProjectNumber::STRING AS WBSElementProjectNumber
        ,SplitAccounting.value:WBSElement:UniqueName::STRING AS WBSElementCode
        ,SplitAccounting.value:cus_RECompanyCode:UniqueName::STRING AS CustomField_RECompanyCode
        ,SplitAccounting.value:cus_Office:UniqueName::STRING AS CustomField_Office
        ,SplitAccounting.value:cus_Segment:UniqueName::STRING AS CustomField_Segment
        ,SplitAccounting.value:cus_Project:UniqueName::STRING AS CustomField_Project
        ,SplitAccounting.value:cus_FYNumber::STRING AS CustomField_FYNumber
        FROM source_data_FULL LZData
        ,LATERAL FLATTEN (input => parse_json(JSonField:LineItems)) LineItem
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
        source_data.PurchaseOrderIDKEY AS PurchaseOrderIdKey,
        source_data.PurchaseOrderVERSIONKEY AS PurchaseOrderVersionKey,
        source_data.PurchaseOrderLINEITEMKEY AS PurchaseOrderLineItemKey,
        source_data.NUMBERINCOLLECTION AS PurchaseOrderSplitAccountingKey,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTAMOUNTINREPORTINGCURRENCY AS AmountAmountInReportingCurrency,
        source_data.AMOUNTAPPROXAMOUNTINBASECURRENCY AS AmountApproxAmountInBaseCurrency,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.ASSETCOMPANYCODECODE AS AssetCompanyCodeCode,
        source_data.ASSETNAME AS AssetName,
        source_data.ASSETSUBNUMBER AS AssetSubNumber,
        source_data.ASSETCODE AS AssetCode,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.COSTCENTERCOMPANYCODECODE AS CostCenterCompanyCodeCode,
        source_data.COSTCENTERCODE AS CostCenterCode,
        source_data.COSTCENTERPROCUREMENTUNITCODE AS CostCenterProcurementUnitCode,
        source_data.COSTCENTERCOSTCENTERDESCRIPTION AS CostCenterDescription,
        source_data.GENERALLEDGERDESCRIPTION AS GeneralLedgerDescription,
        source_data.GENERALLEDGERDESCRIPTION2 AS GeneralLedgerDescription2,
        source_data.GENERALLEDGERCODE AS GeneralLedgerCode,
        source_data.GENERALLEDGERCOMPANYCODECODE AS GeneralLedgerCompanyCodeCode,
        source_data.GENERALLEDGERFIELDSTATUSGROUP AS GeneralLedgerFieldStatusGroup,
        source_data.GENERALLEDGEREXTERNALID AS GeneralLedgerExternalId,
        source_data.INTERNALORDERDESCRIPTION AS InternalOrderDescription,
        source_data.INTERNALORDERCODE AS InternalOrderCode,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.WBSELEMENTCOMPANYCODECODELIST AS WBSElementCompanyCodeCodeList,
        source_data.WBSELEMENTDESCRIPTION AS WBSElementDescription,
        source_data.WBSELEMENTPROJECTNUMBER AS WBSElementProjectNumber,
        source_data.WBSELEMENTCODE AS WBSElementCode,
        source_data.CUSTOMFIELD_RECOMPANYCODE AS CustomField_RECompanyCode,
        source_data.CUSTOMFIELD_OFFICE AS CustomField_Office,
        source_data.CUSTOMFIELD_SEGMENT AS CustomField_Segment,
        source_data.CUSTOMFIELD_PROJECT AS CustomField_Project,
        source_data.CUSTOMFIELD_FYNUMBER AS CustomField_FYNumber,
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
        cast(PurchaseOrderIDKEY as VARCHAR(16777126)) as PurchaseOrderIDKEY,
        cast(PurchaseOrderVERSIONKEY as NUMBER(38,0)) as PurchaseOrderVERSIONKEY,
        cast(PurchaseOrderLINEITEMKEY as NUMBER(38,0)) as PurchaseOrderLINEITEMKEY,
        cast(ASSETCOMPANYCODECODE as VARCHAR(16777126)) as ASSETCOMPANYCODECODE,
        cast(ASSETNAME as VARCHAR(16777126)) as ASSETNAME,
        cast(ASSETSUBNUMBER as VARCHAR(16777126)) as ASSETSUBNUMBER,
        cast(ASSETCODE as VARCHAR(16777126)) as ASSETCODE,
        cast(COMPANYCODECODE as VARCHAR(16777126)) as COMPANYCODECODE,
        cast(COSTCENTERCOMPANYCODECODE as VARCHAR(16777126)) as COSTCENTERCOMPANYCODECODE,
        cast(COSTCENTERCODE as VARCHAR(16777126)) as COSTCENTERCODE,
        cast(COSTCENTERPROCUREMENTUNITCODE as VARCHAR(16777126)) as COSTCENTERPROCUREMENTUNITCODE,
        cast(COSTCENTERDESCRIPTION as VARCHAR(16777126)) as COSTCENTERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGERCODE as VARCHAR(16777126)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777126)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777126)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777126)) as GENERALLEDGEREXTERNALID,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777126)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777126)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as VARCHAR(16777126)) as NUMBERINCOLLECTION,
        cast(WBSELEMENTCOMPANYCODECODELIST as VARCHAR(16777126)) as WBSELEMENTCOMPANYCODECODELIST,
        cast(WBSELEMENTDESCRIPTION as VARCHAR(16777126)) as WBSELEMENTDESCRIPTION,
        cast(WBSELEMENTPROJECTNUMBER as VARCHAR(16777126)) as WBSELEMENTPROJECTNUMBER,
        cast(WBSELEMENTCODE as VARCHAR(16777126)) as WBSELEMENTCODE,
        cast(CUSTOMFIELD_RECOMPANYCODE as VARCHAR(16777126)) as CUSTOMFIELD_RECOMPANYCODE,
        cast(CUSTOMFIELD_OFFICE as VARCHAR(16777126)) as CUSTOMFIELD_OFFICE,
        cast(CUSTOMFIELD_SEGMENT as VARCHAR(16777126)) as CUSTOMFIELD_SEGMENT,
        cast(CUSTOMFIELD_PROJECT as VARCHAR(16777126)) as CUSTOMFIELD_PROJECT,
        cast(CUSTOMFIELD_FYNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_FYNUMBER,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTAMOUNTINREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTAMOUNTINREPORTINGCURRENCY,
        cast(AMOUNTAPPROXAMOUNTINBASECURRENCY as NUMBER(38,10)) as AMOUNTAPPROXAMOUNTINBASECURRENCY,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
        cast(PurchaseOrderSPLITACCOUNTINGKEY as NUMBER(38,0)) as PurchaseOrderSPLITACCOUNTINGKEY,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data