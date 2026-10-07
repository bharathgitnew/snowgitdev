{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='CONTRACTDETAIL',
    unique_key = [],
    enabled=true
) }}

with source_data as
(
    SELECT
    CoverageTerms.SALESAMOUNT,
    ServiceContracts.BACKFILLID,
    CASE ServiceContracts.BACKFILLID
    WHEN 0 THEN 'Not Assigned'
    WHEN 1 THEN 'No Backfill'
    WHEN 2 THEN 'Limited Backfill'
    WHEN 3 THEN 'Full Backfill'
    WHEN 4 THEN 'Not Applicable'
    ELSE 'Unknown:'||TO_CHAR(ServiceContracts.BACKFILLID)
    END AS BackFill,
    BaanBundleContractTerms.CONTRACTTERM1
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM2,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM3,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM4,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM5,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM6,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM7,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM8,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM9,'')
    ||IFNULL(','||BaanBundleContractTerms.CONTRACTTERM10,'') AS BundleTermsDescription,
    ServiceContracts.CANCELDATE,
    ContractChanges.CHANGEEFFECTIVETIME,
    Terms.CONFIGURATION,
    BaanBundleContractTerms.FLEXSUPPORTHOURS,
    ServiceContracts.SERVICECONTRACT,
    ServiceContracts.CONTRACTTYPE,
    ContractTypes.DESCRIPTION AS ContractTypeDescription,
    CoverageTerms.CEILINGAMOUNT,
    CoverageTerms.COSTCOVERINGMETHODDESCRIPTION,
    CoverageTerms.DISCOUNT,
    Terms.COSTTYPEDESCRIPTION,
    LaborTerms.TOTALCOVEREDTIME,
    ServiceContracts.CURRENCY,
    ServiceContracts.REFERENCEA,
    ServiceContracts.DESCRIPTION,
    ServiceContracts.CONTRACTEFFECTIVEDATE,
    ServiceContracts.CONTRACTEXPIRYDATE,
    CASE
    WHEN Terms.CONFIGURATION IS NULL
        THEN 'COALESCE([FST_Departmental].[dbo].[FST_Customer_Group_Mapping].[FST Customer Group], ''Regional'') From [Contract.InvoiceToCustomerId]'
        ELSE 'COALESCE([FST_Departmental].[dbo].[FST_Customer_Group_Mapping].[FST Customer Group], ''Regional'') From [Configuration.InvoiceToCustomerId]'
    END AS FSTCustomerGroup,    
    CASE WHEN Contract_FLX_TransitionHrs.Contract_Number IS NULL THEN 'No' ELSE 'Yes' END AS IsFlexContract,
    ServiceContracts.INVOICE_TOBUSINESSPARTNER,
    CASE WHEN BaanBundleContractTerms.FLEXSUPPORTHOURS > 0 THEN 'Yes' ELSE 'No' END AS HasFlexTransitionHours,
    'No'  AS IsTopContract,
    ServiceContracts.LATEPAYMENTSURCHARGE,
    ServiceContracts.REFERENCEB,
    ServiceContracts.PROCEDUREFORCONTRACTRENEWALDESCRIPTION,
    ServiceContracts.SALESREP,
    ServiceContracts.SALESPRICELIST,
    ServiceContracts.SEARCHARGUMENT,
    ServiceContracts.SERVICEOFFICE,
    Terms.SERVICETYPE,
    ServiceContracts.CONTRACTSTATUSDESCRIPTION,
    ServiceContracts.TAXCODE,
    TermLogging.MAXTERMID,
    CASE
    WHEN IFNULL( TermLogging.MAXTERMID , 0) =  ServiceContracts.CONTRACTTERMS THEN 'CONTRACT TERM'
    ELSE 'COVERAGE TERM'
    END TermIdType,
    ServiceContracts.TERMSOFPAYMENT
    FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS_CURRENT') }} ServiceContracts
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES') }} ContractTypes ON ContractTypes.CONTRACTTYPE =  ServiceContracts.CONTRACTTYPE
    LEFT OUTER JOIN (
    SELECT
    TermLog.ServiceContract
    ,MAX(TermLog.TermID) MaxTermId
    FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING') }} TermLog
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES') }} ContractChanges
    ON ContractChanges.ServiceContract_CSCO = TermLog.ServiceContract
    AND ContractChanges.ContractTerms = TermLog.TermID
    WHERE TermLog.ApplicationDescription = 'Contract'
    AND IFNULL(ContractChanges.StatusOfChangeDescription,'Empty') IN ('Empty','Closed')
    GROUP BY TermLog.ServiceContract


    ) TermLogging ON TermLogging.SERVICECONTRACT =  ServiceContracts.SERVICECONTRACT
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMS') }} Terms ON Terms.TERMID =  TermLogging.MAXTERMID
    AND Terms.TYPEOFLINEDESCRIPTION  = 'Term Part'
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_COVERAGETERMS') }} CoverageTerms ON CoverageTerms.TERMID  =  Terms.TERMID
    AND CoverageTerms.CONFIGURATION =  Terms.CONFIGURATION
    AND CoverageTerms.SERVICETYPE = Terms.SERVICETYPE
    AND CoverageTerms.COSTTYPEID =  Terms.COSTTYPEID
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES') }} ContractChanges ON ContractChanges.SERVICECONTRACT_CSCO =  TermLogging.SERVICECONTRACT
    AND ContractChanges.CONTRACTTERMS  =  TermLogging.MAXTERMID
    LEFT OUTER JOIN (
    SELECT
    TermId
    ,Configuration
    ,ServiceType
    ,CostTypeDescription
    ,CoverageTermNumber
    ,SUM(CoveredTime) TotalCoveredTime
    FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_LABORTERMS') }}
    GROUP BY
    TermId
    ,Configuration
    ,ServiceType
    ,CostTypeDescription
    ,CoverageTermNumber
    ) LaborTerms ON LaborTerms.TERMID = CoverageTerms.TERMID
    AND LaborTerms.CONFIGURATION = CoverageTerms.CONFIGURATION
    AND LaborTerms.SERVICETYPE = CoverageTerms.SERVICETYPE
    AND LaborTerms.COSTTYPEDESCRIPTION = CoverageTerms.COSTTYPEDESCRIPTION
    AND LaborTerms.COVERAGETERMNUMBER =  CoverageTerms.COVERAGETERMNUMBER
    LEFT OUTER JOIN {{ ref('ODS__MDM__CONTRACTBUNDLETERMS') }} ContractBundleTerms ON ContractBundleTerms.ContractNumber =  ServiceContracts.SERVICECONTRACT
    LEFT OUTER JOIN {{ ref('ODS__MDM__CONTRACT_FLX_TRANSITIONHRS') }} Contract_FLX_TransitionHrs ON Contract_FLX_TransitionHrs.Contract_Number = ServiceContracts.SERVICECONTRACT
    LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_BUNDLECONTRACTTERMS') }} BaanBundleContractTerms ON BaanBundleContractTerms.SERVICECONTRACT =  ServiceContracts.SERVICECONTRACT
    WHERE ServiceContracts.CONTRACTSTATUSDESCRIPTION  = 'Free'
    OR
    (
        ServiceContracts.CONTRACTSTATUSDESCRIPTION <> 'Free'
        AND Terms.TERMID = CoverageTerms.TERMID
    )

),


base_contractdetail as
(
    SELECT
        source_data.SALESAMOUNT AS Amount,
        source_data.BackFill AS BackFill,
        source_data.BACKFILLID,
        source_data.BundleTermsDescription AS BundleTermsDescription,
        source_data.CANCELDATE AS CancelledDate,
        source_data.CHANGEEFFECTIVETIME AS ChangeEffectiveDate,
        source_data.CONFIGURATION AS ConfigurationId,
        source_data.FLEXSUPPORTHOURS AS ContractFlexHours,
        source_data.SERVICECONTRACT AS ContractNumber,
        source_data.CONTRACTTYPE AS ContractType,
        source_data.ContractTypeDescription AS ContractTypeDescription,
        source_data.CEILINGAMOUNT AS CostCoverageCeiling,
        source_data.COSTCOVERINGMETHODDESCRIPTION AS CostCoverageMethod,
        source_data.DISCOUNT AS CostCoverateDiscountPercentage,
        source_data.COSTTYPEDESCRIPTION AS CostType,
        source_data.TOTALCOVEREDTIME AS CoveredTime,
        source_data.CURRENCY AS Currency,
        source_data.REFERENCEA AS CustomerPONumber,
        source_data.DESCRIPTION AS Description,
        source_data.CONTRACTEFFECTIVEDATE AS EffectiveDate,
        source_data.CONTRACTEXPIRYDATE AS ExpirationDate,
        source_data.FSTCustomerGroup AS FSTCustomerGroup,
        source_data.HasFlexTransitionHours AS HasFlexTransitionHours,
        source_data.INVOICE_TOBUSINESSPARTNER AS InvoiceToCustomerId,
        source_data.IsFlexContract AS  IsFlexContract,
        source_data.IsTopContract AS IsTopContract,
        source_data.LATEPAYMENTSURCHARGE AS LatePaymentSurcharge,
        source_data.REFERENCEB AS ReferenceB,
        source_data.PROCEDUREFORCONTRACTRENEWALDESCRIPTION AS RenewalType,
        source_data.SALESREP AS SalesEmployeeId,
        source_data.SALESPRICELIST AS SalesPriceList,
        source_data.SEARCHARGUMENT AS SearchArgument,
        source_data.SERVICEOFFICE AS ServiceCenter,
        source_data.SERVICETYPE AS ServiceType,
        source_data.CONTRACTSTATUSDESCRIPTION AS Status,
        source_data.TAXCODE AS TaxCode,
        source_data.MAXTERMID AS TermId,
        source_data.TermIdType AS TermIdType,
        source_data.TERMSOFPAYMENT AS TermsOfPayment
        FROM source_data
),


update_bulist as
(

    select
         QRY_Contract_BUList.ContractNumber,
         QRY_Contract_BUList.BUCOUNT as ContractBUCount,
         QRY_Contract_BUList.BULIST as ContractBUList,
        CASE
            WHEN QRY_Contract_BUList.BUCOUNT > 1 THEN 'Multi-BU'
            ELSE QRY_Contract_BUList.BULIST
        END as ContractBUListShort
        FROM
        (
        SELECT
            ContractDetail.ContractNumber,
            Count(DISTINCT BUCodeMapping.BUCodeTEA) BUCount,
            LISTAGG(DISTINCT BUCodeMapping.BUCodeTEA,',') BUList
        FROM base_contractdetail as ContractDetail
        JOIN {{ ref('COMMON__BAAN__CONFIGURATION') }} as Configuration
        ON Configuration.ConfigurationId = ContractDetail.ConfigurationId
        JOIN {{ ref('COMMON__BAAN__BUCODEMAPPING') }} BUCodeMapping
        ON BUCodeMapping.BUCodeByConfiguration =  Configuration.BU
        GROUP BY ContractDetail.ContractNumber
        ) QRY_Contract_BUList

),

update_configurationlist as
(

    select
        QRY_Contract_ConfigurationList.ContractNumber,
        QRY_Contract_ConfigurationList.CONFIGURATIONCOUNT as ContractConfigurationCount,
        QRY_Contract_ConfigurationList.CONFIGURATIONLIST as ContractConfigurationList,
        CASE
        WHEN  QRY_Contract_ConfigurationList.CONFIGURATIONCOUNT > 1 THEN 'Multi-Configuration'
        ELSE  QRY_Contract_ConfigurationList.CONFIGURATIONLIST
        END as ContractConfigurationListShort
        FROM
        (
        SELECT
            ContractDetail.ContractNumber,
            Count(DISTINCT ContractDetail.ConfigurationId) ConfigurationCount,
            LISTAGG(DISTINCT ContractDetail.ConfigurationId,',') ConfigurationList
        FROM base_contractdetail as ContractDetail
        GROUP BY ContractDetail.ContractNumber
        ) QRY_Contract_ConfigurationList


),

update_fablist as
(
    select
        QRY_Contract_FabList.ContractNumber,
        QRY_Contract_FabList.FABCOUNT as ContractFabCount,
        QRY_Contract_FabList.FABLIST as ContractFabList,
        CASE
        WHEN  QRY_Contract_FabList.FABCOUNT > 1 THEN 'Multi-Fab'
        ELSE  QRY_Contract_FabList.FABLIST
        END as ContractFabListShort
        FROM
        (
        SELECT
            ContractNumber,
            Count(DISTINCT Configuration.FABId) FabCount,
            LISTAGG(DISTINCT Configuration.FABId,',') FabList
        FROM base_contractdetail as ContractDetail
        JOIN {{ ref('COMMON__BAAN__CONFIGURATION') }} as Configuration
        ON Configuration.ConfigurationId = ContractDetail.ConfigurationId
        GROUP BY ContractDetail.ContractNumber
        ) QRY_Contract_FabList


),

update_serviceorderlist as
(

    select
        QRY_ContractDetail_ServiceOrderList_Flex.ContractNumber,
        QRY_ContractDetail_ServiceOrderList_Flex.FLEXSERVICEORDERLIST as ContractServiceOrderList_Flex,
        QRY_ContractDetail_ServiceOrderList_Flex.FLEXSERVICEORDERCOUNT as ContractServiceOrderList_FlexCOUNT,
        CASE WHEN Position('-R' IN QRY_ContractDetail_ServiceOrderList_Flex.FLEXSERVICEORDERLIST ) > 0 THEN 'Yes' ELSE 'No' END as IsContractServiceOrder_Flex_Open
        FROM
        (
        SELECT
            SourceData.ContractNumber ContractNumber
            ,COUNT(DISTINCT ServiceOrders.Service_Order_No) ServiceOrderCount
            ,LISTAGG(DISTINCT ServiceOrders.Service_Order_No||'-'||LEFT(ServiceOrders.Order_Status_Desc,1),',') ServiceOrderList
            ,COUNT(DISTINCT FlexOrders.Service_Order_No) FlexServiceOrderCount
            ,LISTAGG(DISTINCT FlexOrders.Service_Order_No||'-'||LEFT(FlexOrders.Order_Status_Desc,1),',') FlexServiceOrderList
        FROM base_contractdetail SourceData
        LEFT OUTER JOIN {{ ref('COMMON__BAAN__SERVICEORDER_DISTINCT') }} ServiceOrders
        ON ServiceOrders.Contract_No = SourceData.ContractNumber
        LEFT OUTER JOIN {{ ref('COMMON__BAAN__SERVICEORDER_DISTINCT') }} FlexOrders
        ON FlexOrders.Contract_No = SourceData.ContractNumber
        AND FlexOrders.Service_Order_No ilike 'FLX%'
        AND FlexOrders.Contract_Effective_Date > '2015-01-01'
        GROUP BY SourceData.ContractNumber

        ) QRY_ContractDetail_ServiceOrderList_Flex


),

update_topcontract as
(

    select
        distinct
        ContractNumber,
        ConfigurationId,
        MaxDate,
        'Yes' as IsTopContract
        FROM
        (
        SELECT
        ContractNumber
        ,ConfigurationId
        ,MAX(ChangeEffectiveDate) AS MaxDate
        FROM base_contractdetail as ContractDetail
        GROUP BY
        ContractNumber
        ,ConfigurationId
        ) QRY_TopContracts

),


transform_data as
(
    select
        base_contractdetail.Amount,
        base_contractdetail.BACKFILLID,
        base_contractdetail.BackFill,
        base_contractdetail.BundleTermsDescription,
        base_contractdetail.CancelledDate,
        base_contractdetail.ChangeEffectiveDate,
        base_contractdetail.ConfigurationId,
        base_contractdetail.ContractFlexHours,
        base_contractdetail.ContractNumber,
        base_contractdetail.ContractType,
        base_contractdetail.ContractTypeDescription,
        base_contractdetail.CostCoverageCeiling,
        base_contractdetail.CostCoverageMethod,
        base_contractdetail.CostCoverateDiscountPercentage,
        base_contractdetail.CostType,
        base_contractdetail.CoveredTime,
        base_contractdetail.Currency,
        base_contractdetail.CustomerPONumber,
        base_contractdetail.Description,
        base_contractdetail.EffectiveDate,
        base_contractdetail.ExpirationDate,
        base_contractdetail.FSTCustomerGroup,
        base_contractdetail.HasFlexTransitionHours,
        base_contractdetail.InvoiceToCustomerId,
        base_contractdetail.IsFlexContract,
        case when update_topcontract.IsTopContract = 'Yes' then update_topcontract.IsTopContract else base_contractdetail.IsTopContract end as IsTopContract,
        base_contractdetail.LatePaymentSurcharge,
        base_contractdetail.ReferenceB,
        base_contractdetail.RenewalType,
        base_contractdetail.SalesEmployeeId,
        base_contractdetail.SalesPriceList,
        base_contractdetail.SearchArgument,
        base_contractdetail.ServiceCenter,
        base_contractdetail.ServiceType,
        base_contractdetail.Status,
        base_contractdetail.TaxCode,
        base_contractdetail.TermId,
        base_contractdetail.TermIdType,
        base_contractdetail.TermsOfPayment,
        update_bulist.ContractBUCount,
        update_bulist.ContractBUList,
        update_bulist.ContractBUListShort,
        update_configurationlist.ContractConfigurationCount,
        update_configurationlist.ContractConfigurationList,
        update_configurationlist.ContractConfigurationListShort,
        update_fablist.ContractFabCount,
        update_fablist.ContractFabList,
        update_fablist.ContractFabListShort,
        update_serviceorderlist.ContractServiceOrderList_Flex,
        update_serviceorderlist.ContractServiceOrderList_FlexCOUNT,
        update_serviceorderlist.IsContractServiceOrder_Flex_Open,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    from base_contractdetail
    join update_bulist
    on base_contractdetail.ContractNumber = update_bulist.ContractNumber
    join update_configurationlist
    on base_contractdetail.ContractNumber = update_configurationlist.ContractNumber
    join update_fablist
    on base_contractdetail.ContractNumber = update_fablist.ContractNumber
    join update_serviceorderlist
    on base_contractdetail.ContractNumber = update_serviceorderlist.ContractNumber
    join update_topcontract
    on base_contractdetail.ContractNumber = update_topcontract.ContractNumber
    and base_contractdetail.ConfigurationId =   update_topcontract.ConfigurationId
    and IFNULL(base_contractdetail.ChangeEffectiveDate,'9999-12-31') =  IFNULL(update_topcontract.MaxDate,'9999-12-31')

)

,type_data as
(
    select
        cast(CONTRACTNUMBER as VARCHAR(16777216)) as CONTRACTNUMBER,
        cast(DESCRIPTION as VARCHAR(16777216)) as DESCRIPTION,
        cast(SEARCHARGUMENT as VARCHAR(16777216)) as SEARCHARGUMENT,
        cast(INVOICETOCUSTOMERID as VARCHAR(16777216)) as INVOICETOCUSTOMERID,
        cast(CONFIGURATIONID as VARCHAR(16777216)) as CONFIGURATIONID,
        cast(FSTCUSTOMERGROUP as VARCHAR(16777216)) as FSTCUSTOMERGROUP,
        cast(CUSTOMERPONUMBER as VARCHAR(16777216)) as CUSTOMERPONUMBER,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(EFFECTIVEDATE as TIMESTAMP_NTZ(9)) as EFFECTIVEDATE,
        cast(EXPIRATIONDATE as TIMESTAMP_NTZ(9)) as EXPIRATIONDATE,
        cast(SERVICETYPE as VARCHAR(16777216)) as SERVICETYPE,
        cast(COSTTYPE as VARCHAR(16777216)) as COSTTYPE,
        cast(AMOUNT as NUMBER(38,10)) as AMOUNT,
        cast(CONTRACTTYPE as VARCHAR(16777216)) as CONTRACTTYPE,
        cast(CONTRACTTYPEDESCRIPTION as VARCHAR(16777216)) as CONTRACTTYPEDESCRIPTION,
        cast(RENEWALTYPE as VARCHAR(16777216)) as RENEWALTYPE,
        cast(CURRENCY as VARCHAR(16777216)) as CURRENCY,
        cast(SALESPRICELIST as VARCHAR(16777216)) as SALESPRICELIST,
        cast(TERMSOFPAYMENT as VARCHAR(16777216)) as TERMSOFPAYMENT,
        cast(LATEPAYMENTSURCHARGE as VARCHAR(16777216)) as LATEPAYMENTSURCHARGE,
        cast(TAXCODE as VARCHAR(16777216)) as TAXCODE,
        cast(REFERENCEB as VARCHAR(16777216)) as REFERENCEB,
        cast(COVEREDTIME as NUMBER(38,10)) as COVEREDTIME,
        cast(TERMID as NUMBER(38,0)) as TERMID,
        cast(TERMIDTYPE as VARCHAR(16777216)) as TERMIDTYPE,
        cast(COSTCOVERAGEMETHOD as VARCHAR(16777216)) as COSTCOVERAGEMETHOD,
        cast(COSTCOVERAGECEILING as NUMBER(38,10)) as COSTCOVERAGECEILING,
        cast(COSTCOVERATEDISCOUNTPERCENTAGE as NUMBER(38,10)) as COSTCOVERATEDISCOUNTPERCENTAGE,
        cast(CHANGEEFFECTIVEDATE as TIMESTAMP_NTZ(9)) as CHANGEEFFECTIVEDATE,
        cast(SALESEMPLOYEEID as VARCHAR(16777216)) as SALESEMPLOYEEID,
        cast(SERVICECENTER as VARCHAR(16777216)) as SERVICECENTER,
        cast(BACKFILLID as NUMBER(38,0)) as BACKFILLID,
        cast(BACKFILL as VARCHAR(16777216)) as BACKFILL,
        cast(CANCELLEDDATE as TIMESTAMP_NTZ(9)) as CANCELLEDDATE,
        cast(ISTOPCONTRACT as VARCHAR(16777216)) as ISTOPCONTRACT,
        cast(CONTRACTCONFIGURATIONCOUNT as NUMBER(38,0)) as CONTRACTCONFIGURATIONCOUNT,
        cast(CONTRACTCONFIGURATIONLIST as VARCHAR(16777216)) as CONTRACTCONFIGURATIONLIST,
        cast(CONTRACTCONFIGURATIONLISTSHORT as VARCHAR(16777216)) as CONTRACTCONFIGURATIONLISTSHORT,
        cast(CONTRACTBUCOUNT as NUMBER(38,0)) as CONTRACTBUCOUNT,
        cast(CONTRACTBULIST as VARCHAR(16777216)) as CONTRACTBULIST,
        cast(CONTRACTBULISTSHORT as VARCHAR(16777216)) as CONTRACTBULISTSHORT,
        cast(CONTRACTFABCOUNT as NUMBER(38,0)) as CONTRACTFABCOUNT,
        cast(CONTRACTFABLIST as VARCHAR(16777216)) as CONTRACTFABLIST,
        cast(CONTRACTFABLISTSHORT as VARCHAR(16777216)) as CONTRACTFABLISTSHORT,
        cast(BUNDLETERMSDESCRIPTION as VARCHAR(16777216)) as BUNDLETERMSDESCRIPTION,
        cast(HASFLEXTRANSITIONHOURS as VARCHAR(16777216)) as HASFLEXTRANSITIONHOURS,
        cast(CONTRACTSERVICEORDERLIST_FLEX as VARCHAR(16777216)) as CONTRACTSERVICEORDERLIST_FLEX,
        cast(ISCONTRACTSERVICEORDER_FLEX_OPEN as VARCHAR(16777216)) as ISCONTRACTSERVICEORDER_FLEX_OPEN,
        cast(CONTRACTSERVICEORDERLIST_FLEXCOUNT as NUMBER(38,0)) as CONTRACTSERVICEORDERLIST_FLEXCOUNT,
        cast(CONTRACTFLEXHOURS as NUMBER(38,0)) as CONTRACTFLEXHOURS,
        cast(ISFLEXCONTRACT as VARCHAR(16777216)) as ISFLEXCONTRACT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data