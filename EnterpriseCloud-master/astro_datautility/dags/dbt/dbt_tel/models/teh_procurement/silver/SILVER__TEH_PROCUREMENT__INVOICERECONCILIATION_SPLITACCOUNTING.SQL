/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Repository\EnterpriseCloud\Snowflake\ODS_2_Common-Ariba\InvoiceReconciliation_SplitAccounting.SQL
-newFile C:\Repository\EnterpriseCloud\dbt\ods_to_common\models\ariba\InvoiceReconciliation_SplitAccounting.SQL
-materialized incremental
-alias InvoiceReconciliation_SplitAccounting
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema ARIBA
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/4/2022 1:10:08 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='InvoiceReconciliation_SplitAccounting',
    unique_key= ['REALMNAME',
    'INVOICERECONCILIATIONIDKEY',
    'INVOICERECONCILIATIONVERSIONKEY',
    'INVOICERECONCILIATIONLINEITEMKEY',
    'INVOICERECONCILIATIONSPLITACCOUNTINGKEY']
) }}

with source_data as
(
    SELECT
        InvoiceReconciliationSplitAccounting.LastUpdated AS LASTUPDATED,
        InvoiceReconciliationSplitAccounting.RealmName AS REALMNAME,
        InvoiceReconciliationSplitAccounting.InvoiceReconciliationIDKey AS INVOICERECONCILIATIONIDKEY,
        InvoiceReconciliationSplitAccounting.InvoiceReconciliationVersionKey AS INVOICERECONCILIATIONVERSIONKEY,
        InvoiceReconciliationSplitAccounting.InvoiceReconciliationLineItemKey AS INVOICERECONCILIATIONLINEITEMKEY,
        InvoiceReconciliationSplitAccounting.InvoiceReconciliationSplitAccountingKey AS INVOICERECONCILIATIONSPLITACCOUNTINGKEY,
        InvoiceReconciliationSplitAccounting.AmountReportingCurrency AS AMOUNTREPORTINGCURRENCY,
        InvoiceReconciliationSplitAccounting.AmountBaseCurrency AS AMOUNTBASECURRENCY,
        InvoiceReconciliationSplitAccounting.AmountAmount AS AMOUNTAMOUNT,
        InvoiceReconciliationSplitAccounting.AmountConversionDate AS AMOUNTCONVERSIONDATE,
        InvoiceReconciliationSplitAccounting.AmountCurrencyCode AS AMOUNTCURRENCYCODE,
        InvoiceReconciliationSplitAccounting.AssetCompanyCodeCode AS ASSETCOMPANYCODECODE,
        InvoiceReconciliationSplitAccounting.AssetSubNumber AS ASSETSUBNUMBER,
        InvoiceReconciliationSplitAccounting.AssetCode AS ASSETCODE,
        InvoiceReconciliationSplitAccounting.AssetName AS ASSETNAME,
        InvoiceReconciliationSplitAccounting.CompanyCodeCode AS COMPANYCODECODE,
        InvoiceReconciliationSplitAccounting.CostCenterCompanyCodeCode AS COSTCENTERCOMPANYCODECODE,
        InvoiceReconciliationSplitAccounting.CostCenterCode AS COSTCENTERCODE,
        InvoiceReconciliationSplitAccounting.CostCenterProcurementUnitCode AS COSTCENTERPROCUREMENTUNITCODE,
        InvoiceReconciliationSplitAccounting.CostCenterDescription AS COSTCENTERDESCRIPTION,
        InvoiceReconciliationSplitAccounting.ERPSplitValue AS ERPSPLITVALUE,
        InvoiceReconciliationSplitAccounting.GeneralLedgerCode AS GENERALLEDGERCODE,
        InvoiceReconciliationSplitAccounting.GeneralLedgerCompanyCodeCode AS GENERALLEDGERCOMPANYCODECODE,
        InvoiceReconciliationSplitAccounting.GeneralLedgerDescription AS GENERALLEDGERDESCRIPTION,
        InvoiceReconciliationSplitAccounting.GeneralLedgerDescription2 AS GENERALLEDGERDESCRIPTION2,
        InvoiceReconciliationSplitAccounting.GeneralLedgerExternalId AS GENERALLEDGEREXTERNALID,
        InvoiceReconciliationSplitAccounting.GeneralLedgerFieldStatusGroup AS GENERALLEDGERFIELDSTATUSGROUP,
        InvoiceReconciliationSplitAccounting.InternalOrderDescription AS INTERNALORDERDESCRIPTION,
        InvoiceReconciliationSplitAccounting.InternalOrderCode AS INTERNALORDERCODE,
        InvoiceReconciliationSplitAccounting.NumberInCollection AS NUMBERINCOLLECTION,
        InvoiceReconciliationSplitAccounting.Percentage AS PERCENTAGE,
        InvoiceReconciliationSplitAccounting.POLineNumber AS POLINENUMBER,
        InvoiceReconciliationSplitAccounting.PONumber AS PONUMBER,
        InvoiceReconciliationSplitAccounting.ProcurementUnitCode AS PROCUREMENTUNITCODE,
        InvoiceReconciliationSplitAccounting.Quantity AS QUANTITY,
        InvoiceReconciliationSplitAccounting.TypeCode AS TYPECODE,
        InvoiceReconciliationSplitAccounting.CustomField_FYNumber AS CUSTOMFIELD_FYNUMBER,
        InvoiceReconciliationSplitAccounting.CustomField_Office AS CUSTOMFIELD_OFFICE,
        InvoiceReconciliationSplitAccounting.CustomField_Project AS CUSTOMFIELD_PROJECT,
        InvoiceReconciliationSplitAccounting.CustomField_RECompanyCode AS CUSTOMFIELD_RECOMPANYCODE,
        InvoiceReconciliationSplitAccounting.CustomField_Segment AS CUSTOMFIELD_SEGMENT,
        InvoiceReconciliationSplitAccounting.IsHistorical AS ISHISTORICAL
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICERECONCILIATIONSPLITACCOUNTING') }} InvoiceReconciliationSplitAccounting
{%- if is_tel_incremental() %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY REALMNAME,INVOICERECONCILIATIONIDKEY,INVOICERECONCILIATIONVERSIONKEY,INVOICERECONCILIATIONLINEITEMKEY,INVOICERECONCILIATIONSPLITACCOUNTINGKEY
                           ORDER BY LASTUPDATED)=1
{%- endif %} 
    )
,transform_data as
(
    SELECT
        LASTUPDATED,
        REALMNAME,
        INVOICERECONCILIATIONIDKEY,
        INVOICERECONCILIATIONVERSIONKEY,
        INVOICERECONCILIATIONLINEITEMKEY,
        INVOICERECONCILIATIONSPLITACCOUNTINGKEY,
        AMOUNTREPORTINGCURRENCY,
        AMOUNTBASECURRENCY,
        AMOUNTAMOUNT,
        AMOUNTCONVERSIONDATE,
        AMOUNTCURRENCYCODE,
        ASSETCOMPANYCODECODE,
        ASSETSUBNUMBER,
        ASSETCODE,
        ASSETNAME,
        COMPANYCODECODE,
        COSTCENTERCOMPANYCODECODE,
        COSTCENTERCODE,
        COSTCENTERPROCUREMENTUNITCODE,
        COSTCENTERDESCRIPTION,
        ERPSPLITVALUE,
        GENERALLEDGERCODE,
        GENERALLEDGERCOMPANYCODECODE,
        GENERALLEDGERDESCRIPTION,
        GENERALLEDGERDESCRIPTION2,
        GENERALLEDGEREXTERNALID,
        GENERALLEDGERFIELDSTATUSGROUP,
        INTERNALORDERDESCRIPTION,
        INTERNALORDERCODE,
        NUMBERINCOLLECTION,
        PERCENTAGE,
        POLINENUMBER,
        PONUMBER,
        PROCUREMENTUNITCODE,
        QUANTITY,
        TYPECODE,
        CUSTOMFIELD_FYNUMBER,
        CUSTOMFIELD_OFFICE,
        CUSTOMFIELD_PROJECT,
        CUSTOMFIELD_RECOMPANYCODE,
        CUSTOMFIELD_SEGMENT,
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
        cast(INVOICERECONCILIATIONIDKEY as VARCHAR(16777216)) as INVOICERECONCILIATIONIDKEY,
        cast(INVOICERECONCILIATIONVERSIONKEY as NUMBER(38,0)) as INVOICERECONCILIATIONVERSIONKEY,
        cast(INVOICERECONCILIATIONLINEITEMKEY as NUMBER(38,0)) as INVOICERECONCILIATIONLINEITEMKEY,
        cast(INVOICERECONCILIATIONSPLITACCOUNTINGKEY as NUMBER(38,0)) as INVOICERECONCILIATIONSPLITACCOUNTINGKEY,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777216)) as AMOUNTCURRENCYCODE,
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
        cast(GENERALLEDGERCODE as VARCHAR(16777216)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777216)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777216)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777216)) as GENERALLEDGEREXTERNALID,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777216)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777216)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777216)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as VARCHAR(16777216)) as NUMBERINCOLLECTION,
        cast(PERCENTAGE as NUMBER(38,10)) as PERCENTAGE,
        cast(POLINENUMBER as VARCHAR(16777216)) as POLINENUMBER,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777216)) as PROCUREMENTUNITCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(TYPECODE as VARCHAR(16777216)) as TYPECODE,
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