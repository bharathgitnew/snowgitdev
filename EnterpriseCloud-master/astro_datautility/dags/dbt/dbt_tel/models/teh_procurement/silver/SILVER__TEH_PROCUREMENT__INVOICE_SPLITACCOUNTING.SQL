/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Ariba\Invoice_SplitAccounting__Ariba_Invoice.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\ariba\Invoice_SplitAccounting.SQL
-materialized incremental
-alias Invoice_SplitAccounting
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema ARIBA
-sourceDatabase LZ_DEV
-useDistinct yes
model file generated on: 1/10/2022 2:27:25 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='Invoice_SplitAccounting',
    unique_key = ['RealmName',
    'InvoiceIdKey',
    'InvoiceVersionKey',
    'InvoiceLineItemKey',
    'InvoiceSplitAccountingKey']
) }}


with source_data as
(
    SELECT
        LASTUPDATED
        ,REALMNAME
        ,INVOICEIDKEY
        ,INVOICEVERSIONKEY
        ,INVOICELINEITEMKEY
        ,INVOICESPLITACCOUNTINGKEY
        ,AMOUNTAMOUNT
        ,AMOUNTBASECURRENCY
        ,AMOUNTCONVERSIONDATE
        ,AMOUNTCURRENCYCODE
        ,AMOUNTREPORTINGCURRENCY
        ,ASSETCOMPANYCODE
        ,ASSETSUBNUMBER
        ,ASSETCODE
        ,ASSETNAME
        ,COMPANYCODECODE
        ,COSTCENTERCOMPANYCODECODE
        ,COSTCENTERCODE
        ,COSTCENTERPROCUREMENTUNIT
        ,COSTCENTERDESCRIPTION
        ,ERPSPLITVALUE
        ,GENERALLEDGERDESCRIPTION
        ,GENERALLEDGERDESCRIPTION2
        ,GENERALLEDGERCODE
        ,GENERALLEDGERCOMPANYCODECODE
        ,GENERALLEDGERFIELDSTATUSGROUP
        ,GENERALLEDGEREXTERNALID
        ,INTERNALORDERDESCRIPTION
        ,INTERNALORDERCODE
        ,NUMBERINCOLLECTION
        ,POLINENUMBER
        ,PONUMBER
        ,PERCENTAGE
        ,PROCUREMENTUNITCODE
        ,QUANTITY
        ,TYPECODE
        ,WBSELEMENTCOMPANYCODECODELIST
        ,WBSELEMENTDESCRIPTION
        ,WBSELEMENTPROJECTNUMBER
        ,WBSELEMENT
        ,CUSTOMFIELD_OFFICE
        ,CUSTOMFIELD_FYNUMBER
        ,CUSTOMFIELD_RECOMPANYCODE
        ,CUSTOMFIELD_SEGMENT
        ,CUSTOMFIELD_PROJECT
        ,ISHISTORICAL
        FROM {{ ref('BRONZE__TEH_PROCUREMENT__ARIBA_INVOICESPLITACCOUNTING') }}
)
,transform_data as
(
    SELECT
        source_data.LASTUPDATED AS LastUpdated,
        source_data.REALMNAME AS RealmName,
        source_data.INVOICEIDKEY AS InvoiceIdKey,
        source_data.INVOICEVERSIONKEY AS InvoiceVersionKey,
        source_data.INVOICELINEITEMKEY AS InvoiceLineItemKey,
        source_data.AMOUNTAMOUNT AS AmountAmount,
        source_data.AMOUNTBASECURRENCY AS AmountBaseCurrency,
        source_data.AMOUNTCONVERSIONDATE AS AmountConversionDate,
        source_data.AMOUNTCURRENCYCODE AS AmountCurrencyCode,
        source_data.AMOUNTREPORTINGCURRENCY AS AmountReportingCurrency,
        source_data.ASSETCOMPANYCODE AS AssetCompanyCode,
        source_data.ASSETSUBNUMBER AS AssetSubNumber,
        source_data.ASSETCODE AS AssetCode,
        source_data.ASSETNAME AS AssetName,
        source_data.COMPANYCODECODE AS CompanyCodeCode,
        source_data.COSTCENTERCOMPANYCODECODE AS CostCenterCompanyCodeCode,
        source_data.COSTCENTERCODE AS CostCenterCode,
        source_data.COSTCENTERPROCUREMENTUNIT AS CostCenterProcurementUnit,
        source_data.COSTCENTERDESCRIPTION AS CostCenterDescription,
        source_data.ERPSPLITVALUE AS ERPSplitValue,
        source_data.GENERALLEDGERDESCRIPTION AS GeneralLedgerDescription,
        source_data.GENERALLEDGERDESCRIPTION2 AS GeneralLedgerDescription2,
        source_data.GENERALLEDGERCODE AS GeneralLedgerCode,
        source_data.GENERALLEDGERCOMPANYCODECODE AS GeneralLedgerCompanyCodeCode,
        source_data.GENERALLEDGERFIELDSTATUSGROUP AS GeneralLedgerFieldStatusGroup,
        source_data.GENERALLEDGEREXTERNALID AS GeneralLedgerExternalId,
        source_data.INTERNALORDERDESCRIPTION AS InternalOrderDescription,
        source_data.INTERNALORDERCODE AS InternalOrderCode,
        source_data.NUMBERINCOLLECTION AS NumberInCollection,
        source_data.POLINENUMBER AS POLineNumber,
        source_data.PONUMBER AS PONumber,
        source_data.PERCENTAGE AS Percentage,
        source_data.PROCUREMENTUNITCODE AS ProcurementUnitCode,
        source_data.QUANTITY AS Quantity,
        source_data.TYPECODE AS TypeCode,
        source_data.WBSELEMENTCOMPANYCODECODELIST AS WBSElementCompanyCodeCodeList,
        source_data.WBSELEMENTDESCRIPTION AS WBSElementDescription,
        source_data.WBSELEMENTPROJECTNUMBER AS WBSElementProjectNumber,
        source_data.WBSELEMENT AS WBSElement,
        source_data.CUSTOMFIELD_OFFICE AS CustomField_Office,
        source_data.CUSTOMFIELD_FYNUMBER AS CustomField_FYNumber,
        source_data.CUSTOMFIELD_RECOMPANYCODE AS CustomField_RECompanyCode,
        source_data.CUSTOMFIELD_SEGMENT AS CustomField_Segment,
        source_data.CUSTOMFIELD_PROJECT AS CustomField_Project,
        source_data.ISHISTORICAL AS ISHISTORICAL,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as
(
    select
        cast(LASTUPDATED as TIMESTAMP_NTZ(9)) as LASTUPDATED,
        cast(REALMNAME as VARCHAR(16777126)) as REALMNAME,
        cast(INVOICEIDKEY as VARCHAR(16777126)) as INVOICEIDKEY,
        cast(INVOICEVERSIONKEY as NUMBER(38,0)) as INVOICEVERSIONKEY,
        cast(INVOICELINEITEMKEY as NUMBER(38,0)) as INVOICELINEITEMKEY,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as INVOICESPLITACCOUNTINGKEY,
        cast(AMOUNTAMOUNT as NUMBER(38,10)) as AMOUNTAMOUNT,
        cast(AMOUNTBASECURRENCY as NUMBER(38,10)) as AMOUNTBASECURRENCY,
        cast(AMOUNTCONVERSIONDATE as TIMESTAMP_NTZ(9)) as AMOUNTCONVERSIONDATE,
        cast(AMOUNTCURRENCYCODE as VARCHAR(16777126)) as AMOUNTCURRENCYCODE,
        cast(AMOUNTREPORTINGCURRENCY as NUMBER(38,10)) as AMOUNTREPORTINGCURRENCY,
        cast(ASSETCOMPANYCODE as VARCHAR(16777126)) as ASSETCOMPANYCODE,
        cast(ASSETSUBNUMBER as VARCHAR(16777126)) as ASSETSUBNUMBER,
        cast(ASSETCODE as VARCHAR(16777126)) as ASSETCODE,
        cast(ASSETNAME as VARCHAR(16777126)) as ASSETNAME,
        cast(COMPANYCODECODE as VARCHAR(16777126)) as COMPANYCODECODE,
        cast(COSTCENTERCOMPANYCODECODE as VARCHAR(16777126)) as COSTCENTERCOMPANYCODECODE,
        cast(COSTCENTERCODE as VARCHAR(16777126)) as COSTCENTERCODE,
        cast(COSTCENTERPROCUREMENTUNIT as VARCHAR(16777126)) as COSTCENTERPROCUREMENTUNIT,
        cast(COSTCENTERDESCRIPTION as VARCHAR(16777126)) as COSTCENTERDESCRIPTION,
        cast(ERPSPLITVALUE as VARCHAR(16777126)) as ERPSPLITVALUE,
        cast(GENERALLEDGERDESCRIPTION as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION,
        cast(GENERALLEDGERDESCRIPTION2 as VARCHAR(16777126)) as GENERALLEDGERDESCRIPTION2,
        cast(GENERALLEDGERCODE as VARCHAR(16777126)) as GENERALLEDGERCODE,
        cast(GENERALLEDGERCOMPANYCODECODE as VARCHAR(16777126)) as GENERALLEDGERCOMPANYCODECODE,
        cast(GENERALLEDGERFIELDSTATUSGROUP as VARCHAR(16777126)) as GENERALLEDGERFIELDSTATUSGROUP,
        cast(GENERALLEDGEREXTERNALID as VARCHAR(16777126)) as GENERALLEDGEREXTERNALID,
        cast(INTERNALORDERDESCRIPTION as VARCHAR(16777126)) as INTERNALORDERDESCRIPTION,
        cast(INTERNALORDERCODE as VARCHAR(16777126)) as INTERNALORDERCODE,
        cast(NUMBERINCOLLECTION as NUMBER(38,0)) as NUMBERINCOLLECTION,
        cast(POLINENUMBER as VARCHAR(16777126)) as POLINENUMBER,
        cast(PONUMBER as VARCHAR(16777126)) as PONUMBER,
        cast(PERCENTAGE as NUMBER(38,10)) as PERCENTAGE,
        cast(PROCUREMENTUNITCODE as VARCHAR(16777126)) as PROCUREMENTUNITCODE,
        cast(QUANTITY as NUMBER(38,10)) as QUANTITY,
        cast(TYPECODE as VARCHAR(16777126)) as TYPECODE,
        cast(WBSELEMENTCOMPANYCODECODELIST as VARCHAR(16777126)) as WBSELEMENTCOMPANYCODECODELIST,
        cast(WBSELEMENTDESCRIPTION as VARCHAR(16777126)) as WBSELEMENTDESCRIPTION,
        cast(WBSELEMENTPROJECTNUMBER as VARCHAR(16777126)) as WBSELEMENTPROJECTNUMBER,
        cast(WBSELEMENT as VARCHAR(16777126)) as WBSELEMENT,
        cast(CUSTOMFIELD_OFFICE as VARCHAR(16777126)) as CUSTOMFIELD_OFFICE,
        cast(CUSTOMFIELD_FYNUMBER as VARCHAR(16777126)) as CUSTOMFIELD_FYNUMBER,
        cast(CUSTOMFIELD_RECOMPANYCODE as VARCHAR(16777126)) as CUSTOMFIELD_RECOMPANYCODE,
        cast(CUSTOMFIELD_SEGMENT as VARCHAR(16777126)) as CUSTOMFIELD_SEGMENT,
        cast(CUSTOMFIELD_PROJECT as VARCHAR(16777126)) as CUSTOMFIELD_PROJECT,
        cast(ISHISTORICAL as VARCHAR(16777216)) as ISHISTORICAL,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select distinct * from type_data