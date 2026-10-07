/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\Requisition_SplitAccounting.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\Requisition_SplitAccounting.SQL
-materialized incremental
-alias Requisition_SplitAccounting
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:12 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='Requisition_SplitAccounting',
    unique_key= ['REALMNAME',
    'REQUISITIONIDKEY',
    'REQUISITIONVERSIONKEY',
    'REQUISITIONLINEITEMKEY',
    'REQUISITIONSPLITACCOUNTINGKEY'] 
) }}

with source_data as
(
    SELECT
RequisitionSplitAccounting.LastUpdated AS LASTUPDATED,
RequisitionSplitAccounting.RealmName AS REALMNAME,
RequisitionSplitAccounting.RequisitionIDKey AS REQUISITIONIDKEY,
RequisitionSplitAccounting.RequisitionVersionKey AS REQUISITIONVERSIONKEY,
RequisitionSplitAccounting.RequisitionLineItemKey AS REQUISITIONLINEITEMKEY,
RequisitionSplitAccounting.RequisitionSplitAccountingKey AS REQUISITIONSPLITACCOUNTINGKEY,
RequisitionSplitAccounting.AmountAmount AS AMOUNTAMOUNT,
RequisitionSplitAccounting.AmountBaseCurrency AS AMOUNTBASECURRENCY,
RequisitionSplitAccounting.AmountConversionDate AS AMOUNTCONVERSIONDATE,
RequisitionSplitAccounting.AmountCurrencyCode AS AMOUNTCURRENCYCODE,
RequisitionSplitAccounting.AmountReportingCurrency AS AMOUNTREPORTINGCURRENCY,
RequisitionSplitAccounting.AssetCode AS ASSETCODE,
RequisitionSplitAccounting.AssetCompanyCodeCode AS ASSETCOMPANYCODECODE,
RequisitionSplitAccounting.AssetSubNumber AS ASSETSUBNUMBER,
RequisitionSplitAccounting.AssetName AS ASSETNAME,
RequisitionSplitAccounting.CompanyCodeCode AS COMPANYCODECODE,
RequisitionSplitAccounting.CostCenterCompanyCodeCode AS COSTCENTERCOMPANYCODECODE,
RequisitionSplitAccounting.CostCenterProcurementUnitCode AS COSTCENTERPROCUREMENTUNITCODE,
RequisitionSplitAccounting.CostCenterDescription AS COSTCENTERDESCRIPTION,
RequisitionSplitAccounting.ERPSplitValue AS ERPSPLITVALUE,
RequisitionSplitAccounting.GeneralLedgerDescription AS GENERALLEDGERDESCRIPTION,
RequisitionSplitAccounting.GeneralLedgerDescription2 AS GENERALLEDGERDESCRIPTION2,
RequisitionSplitAccounting.GeneralLedgerCode AS GENERALLEDGERCODE,
RequisitionSplitAccounting.GeneralLedgerCompanyCodeCode AS GENERALLEDGERCOMPANYCODECODE,
RequisitionSplitAccounting.GeneralLedgerFieldStatusGroup AS GENERALLEDGERFIELDSTATUSGROUP,
RequisitionSplitAccounting.GeneralLedgerExternalId AS GENERALLEDGEREXTERNALID,
RequisitionSplitAccounting.InternalOrderDescription AS INTERNALORDERDESCRIPTION,
RequisitionSplitAccounting.InternalOrderCode AS INTERNALORDERCODE,
RequisitionSplitAccounting.Percentage AS PERCENTAGE,
RequisitionSplitAccounting.POLineNumber AS POLINENUMBER,
RequisitionSplitAccounting.PONumber AS PONUMBER,
RequisitionSplitAccounting.ProcurementUnitCode AS PROCUREMENTUNITCODE,
RequisitionSplitAccounting.Quantity AS QUANTITY,
RequisitionSplitAccounting.TypeCode AS TYPECODE,
RequisitionSplitAccounting.WBSElementCompanyCodeCodeList AS WBSELEMENTCOMPANYCODECODELIST,
RequisitionSplitAccounting.WBSElementDescription AS WBSELEMENTDESCRIPTION,
RequisitionSplitAccounting.WBSElementProjectNumber AS WBSELEMENTPROJECTNUMBER,
RequisitionSplitAccounting.WBSElementCode AS WBSELEMENTCODE,
RequisitionSplitAccounting.CustomField_FYNumber AS CUSTOMFIELD_FYNUMBER,
RequisitionSplitAccounting.CustomField_Office AS CUSTOMFIELD_OFFICE,
RequisitionSplitAccounting.CustomField_Project AS CUSTOMFIELD_PROJECT,
RequisitionSplitAccounting.CustomField_RECompanyCode AS CUSTOMFIELD_RECOMPANYCODE,
RequisitionSplitAccounting.CustomField_Segment AS CUSTOMFIELD_SEGMENT,
RequisitionSplitAccounting.NumberInCollection AS NUMBERINCOLLECTION,
RequisitionSplitAccounting.CostCenterCode AS COSTCENTERCODE,
RequisitionSplitAccounting.IsHistorical AS ISHISTORICAL
FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_REQUISITIONSPLITACCOUNTING') }} RequisitionSplitAccounting
)
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        REQUISITIONIDKEY,
        REQUISITIONVERSIONKEY,
        REQUISITIONLINEITEMKEY,
        REQUISITIONSPLITACCOUNTINGKEY,
        AMOUNTAMOUNT,
        AMOUNTBASECURRENCY,
        AMOUNTCONVERSIONDATE,
        AMOUNTCURRENCYCODE,
        AMOUNTREPORTINGCURRENCY,
        ASSETCODE,
        ASSETCOMPANYCODECODE,
        ASSETSUBNUMBER,
        ASSETNAME,
        COMPANYCODECODE,
        COSTCENTERCOMPANYCODECODE,
        COSTCENTERPROCUREMENTUNITCODE,
        COSTCENTERDESCRIPTION,
        ERPSPLITVALUE,
        GENERALLEDGERDESCRIPTION,
        GENERALLEDGERDESCRIPTION2,
        GENERALLEDGERCODE,
        GENERALLEDGERCOMPANYCODECODE,
        GENERALLEDGERFIELDSTATUSGROUP,
        GENERALLEDGEREXTERNALID,
        INTERNALORDERDESCRIPTION,
        INTERNALORDERCODE,
        PERCENTAGE,
        POLINENUMBER,
        PONUMBER,
        PROCUREMENTUNITCODE,
        QUANTITY,
        TYPECODE,
        WBSELEMENTCOMPANYCODECODELIST,
        WBSELEMENTDESCRIPTION,
        WBSELEMENTPROJECTNUMBER,
        WBSELEMENTCODE,
        CUSTOMFIELD_FYNUMBER,
        CUSTOMFIELD_OFFICE,
        CUSTOMFIELD_PROJECT,
        CUSTOMFIELD_RECOMPANYCODE,
        CUSTOMFIELD_SEGMENT,
        NUMBERINCOLLECTION,
        COSTCENTERCODE,
        ISHISTORICAL,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777216)) as REALMNAME,
        cast(REQUISITIONIDKEY as VARCHAR(16777216)) as REQUISITIONIDKEY,
        cast(REQUISITIONVERSIONKEY as NUMBER(38,0)) as REQUISITIONVERSIONKEY,
        cast(REQUISITIONLINEITEMKEY as NUMBER(38,0)) as REQUISITIONLINEITEMKEY,
        cast(REQUISITIONSPLITACCOUNTINGKEY as NUMBER(38,0)) as REQUISITIONSPLITACCOUNTINGKEY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(ASSETCOMPANYCODECODE as VARCHAR(16777216)) as ASSETCOMPANYCODECODE,
        cast(ASSETSUBNUMBER as VARCHAR(16777216)) as ASSETSUBNUMBER,
        cast(ASSETCODE as VARCHAR(16777216)) as ASSETCODE,
        cast(ASSETNAME as VARCHAR(16777216)) as ASSETNAME,
        cast(COMPANYCODECODE as VARCHAR(16777216)) as COMPANYCODECODE,
        cast(COSTCENTERCOMPANYCODECODE as VARCHAR(16777216)) as COSTCENTERCOMPANYCODECODE,
        cast(COSTCENTERCODE as VARCHAR(16777216)) as COSTCENTERCODE,
        cast(COSTCENTERPROCUREMENTUNITCODE as VARCHAR(16777216)) as COSTCENTERPROCUREMENTUNITCODE,
        cast(COSTCENTERDESCRIPTION as VARCHAR(16777216)) as COSTCENTERDESCRIPTION,
        cast(ERPSPLITVALUE as VARCHAR(16777216)) as ERPSPLITVALUE,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGERCODE as VARCHAR(16777216)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777216)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777216)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777216)) as GENERALLEDGEREXTERNALID,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777216)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777216)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(PERCENTAGE as NUMBER(38,10)) as PERCENTAGE,
        cast(POLINENUMBER as VARCHAR(16777216)) as POLINENUMBER,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(TYPECODE as VARCHAR(16777216)) as TYPECODE,
        cast(WBSELEMENTCOMPANYCODECODELIST as VARCHAR(16777216)) as WBSELEMENTCOMPANYCODECODELIST,
        cast(WBSELEMENTDESCRIPTION as VARCHAR(16777216)) as WBSELEMENTDESCRIPTION,
        cast(WBSELEMENTPROJECTNUMBER as VARCHAR(16777216)) as WBSELEMENTPROJECTNUMBER,
        cast(WBSELEMENTCODE as VARCHAR(16777216)) as WBSELEMENTCODE,
        cast(CUSTOMFIELD_FYNUMBER as VARCHAR(16777216)) as CUSTOMFIELD_FYNUMBER,
        cast(CUSTOMFIELD_OFFICE as VARCHAR(16777216)) as CUSTOMFIELD_OFFICE,
        cast(CUSTOMFIELD_PROJECT as VARCHAR(16777216)) as CUSTOMFIELD_PROJECT,
        cast(CUSTOMFIELD_RECOMPANYCODE as VARCHAR(16777216)) as CUSTOMFIELD_RECOMPANYCODE,
        cast(CUSTOMFIELD_SEGMENT as VARCHAR(16777216)) as CUSTOMFIELD_SEGMENT,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data