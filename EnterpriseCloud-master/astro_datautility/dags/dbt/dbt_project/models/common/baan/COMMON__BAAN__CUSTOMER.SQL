{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='CUSTOMER',
    unique_key = ['CustomerId'],
    enabled=true
) }}

with source_data as
(

    SELECT
        BAAN_BusinessPartners.BUSINESSPARTNER AS CustomerId,
        BAAN_BusinessPartners.NAME AS CustomerName,
        IFNULL ( MDM_Customer.CustomerShortName , BAAN_BusinessPartners.NAME ) AS CustomerShortName,
        BAAN_BusinessPartners.ADDRESSCODE AS AddressId,
        BAAN_BusinessPartners.TAXNUMBER AS TaxId,
        CASE WHEN LEN ( BAAN_BusinessPartners.BUSINESSPARTNER ) = 5 THEN 'Yes' ELSE 'No' END AS IsCustomer,
        CASE WHEN LEN ( BAAN_BusinessPartners.BUSINESSPARTNER ) = 9 THEN 'Yes' ELSE 'No' END AS IsCustomerSite,
        CASE WHEN BAAN_BusinessPartners.NAME ilike 'Intel-%' THEN 'Yes' WHEN BAAN_BusinessPartners.NAME ilike 'Intel %' THEN 'Yes' ELSE 'No' END AS IsIntel,
        'No' AS IsInvoiceTo,
        'No' AS IsShipTo,
        'No' AS IsSoldTo,
        'No' AS IsPayBy,
        CASE WHEN BAAN_BusinessPartners.BUSINESSPARTNERSTATUSDESCRIPTION = 'Active' THEN 'Yes' ELSE 'No' END AS IsActive,
        'No Rule' AS IsInternal,
        CASE WHEN MDM_Customer.CustomerID IS NULL THEN NULL ELSE IFNULL ( MDM_Customer.CustomerGroup , 'Regional' ) END AS GroupName,
        MDM_Customer.CustomerGroupTel AS TELGroupName,
        MDM_Customer.GroupFinancialName AS FinancialGroupName,
        CASE WHEN MDM_Customer.CustomerID IS NULL THEN NULL ELSE IFNULL ( MDM_Customer.SalesCustomerGroup , 'Regional' ) END AS SalesGroupName,
        Customer_Group_Mapping.SalesCustomerGroup AS SalesGroupName_FST,
        MDM_Office.REGION AS Region,
        0 AS ERROR_FLAG,
        CAST('' AS VARCHAR(200)) AS ERROR_REASON,
        CAST('' AS VARCHAR(100)) AS ERROR_CODE,
        CAST(LOCALTIMESTAMP AS TIMESTAMP) AS RECORD_INSERT_TIMESTAMP,
        CAST('INSERT' AS VARCHAR(100)) AS OPERATION_TYPE,
        ROW_NUMBER() OVER (ORDER BY 1) AS SRC_ROW_NUMBER
        FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }} BAAN_BusinessPartners
        LEFT OUTER JOIN {{ ref('ODS__MDM__CUSTOMER') }} MDM_Customer
        ON MDM_Customer.CustomerID = LEFT( BAAN_BusinessPartners.BUSINESSPARTNER ,5)
        LEFT OUTER JOIN {{ ref('ODS__MDM__CUSTOMER_GROUP_MAPPING') }} Customer_Group_Mapping
        ON RIGHT('00000'|| Customer_Group_Mapping.CustomerCode ,5) = LEFT(MDM_Customer.CustomerID ,5)
        LEFT OUTER JOIN {{ ref('COMMON__BAAN__FAB') }} BAAN_FAB
        ON BAAN_FAB.CustomerId =  BAAN_BusinessPartners.BUSINESSPARTNER
        AND BAAN_FAB.IsExpired = 'No'
        LEFT OUTER JOIN {{ ref('ODS__MDM__OFFICE') }} MDM_Office
        ON MDM_Office.OFFICECODE =  BAAN_FAB.ServiceCenterOfficeId

),

update_invoicetobusinesspartner as
(

    Select distinct
    'Yes' IsInvoiceTo,
    INVOICETOBUSINESSPARTNER
    FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS') }} BAANCOMMONCOMMONDATA_INVOICETOBUSINESSPARTNERS

),

update_paybybusinesspartner as
(

    select distinct
    'Yes' as IsPayBy,
    PAYFROMBUSINESSPARTNER
    FROM {{ source('ODS__BAAN','BAANCOMMONCOMMONDATA_PAYBYBUSINESSPARTNERS') }} BAANCOMMONCOMMONDATA_PAYBYBUSINESSPARTNERS


),

update_shiptobusinesspartner as
(

    select distinct
        'Yes' as IsShipTo,
        SHIPTOBUSINESSPARTNER
    FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS') }} BAANCOMMONCOMMONDATA_SHIPTOBUSINESSPARTNERS

),

update_soldtobusinesspartner as
(

    select distinct
         'Yes' as IsSoldTo,
         SOLDTOBUSINESSPARTNER
    FROM {{ ref('ODS__BAAN__BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS') }} BAANCOMMONCOMMONDATA_SOLDTOBUSINESSPARTNERS

),

transform_data as
(
    select distinct
        CustomerId,
        CustomerName,
        CustomerShortName,
        AddressId,
        TaxId,
        IsCustomer,
        IsCustomerSite,
        IsIntel,
        case when update_invoicetobusinesspartner.IsInvoiceTo = 'Yes'
        then update_invoicetobusinesspartner.IsInvoiceTo
        else source_data.IsInvoiceTo
        end as IsInvoiceTo,
        case when update_shiptobusinesspartner.IsShipTo = 'Yes'
        then update_shiptobusinesspartner.IsShipTo
        else source_data.IsShipTo
        end as IsShipTo,
        case when update_soldtobusinesspartner.IsSoldTo = 'Yes'
        then update_soldtobusinesspartner.IsSoldTo
        else source_data.IsSoldTo
        end as IsSoldTo,
        case when update_paybybusinesspartner.IsPayBy = 'Yes'
        then update_paybybusinesspartner.IsPayBy
        else source_data.IsPayBy
        end as IsPayBy,
        IsActive,
        IsInternal,
        GroupName,
        TELGroupName,
        FinancialGroupName,
        SalesGroupName,
        SalesGroupName_FST,
        Region,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
    left join update_invoicetobusinesspartner
    on update_invoicetobusinesspartner.INVOICETOBUSINESSPARTNER = source_data.CustomerId
    left join update_paybybusinesspartner
    on update_paybybusinesspartner.PAYFROMBUSINESSPARTNER = source_data.CustomerId
    left join update_shiptobusinesspartner
    on update_shiptobusinesspartner.SHIPTOBUSINESSPARTNER = source_data.CustomerId
    left join update_soldtobusinesspartner
    on update_soldtobusinesspartner.SOLDTOBUSINESSPARTNER = source_data.CustomerId
)

,type_data as
(
    select
        cast(CUSTOMERID as VARCHAR(16777216)) as CUSTOMERID,
        cast(CUSTOMERNAME as VARCHAR(16777216)) as CUSTOMERNAME,
        cast(CUSTOMERSHORTNAME as VARCHAR(16777216)) as CUSTOMERSHORTNAME,
        cast(ADDRESSID as VARCHAR(16777216)) as ADDRESSID,
        cast(TAXID as VARCHAR(16777216)) as TAXID,
        cast(ISCUSTOMER as VARCHAR(16777216)) as ISCUSTOMER,
        cast(ISCUSTOMERSITE as VARCHAR(16777216)) as ISCUSTOMERSITE,
        cast(ISINTEL as VARCHAR(16777216)) as ISINTEL,
        cast(ISINVOICETO as VARCHAR(16777216)) as ISINVOICETO,
        cast(ISSHIPTO as VARCHAR(16777216)) as ISSHIPTO,
        cast(ISSOLDTO as VARCHAR(16777216)) as ISSOLDTO,
        cast(ISPAYBY as VARCHAR(16777216)) as ISPAYBY,
        cast(ISACTIVE as VARCHAR(16777216)) as ISACTIVE,
        cast(ISINTERNAL as VARCHAR(16777216)) as ISINTERNAL,
        cast(GROUPNAME as VARCHAR(16777216)) as GROUPNAME,
        cast(TELGROUPNAME as VARCHAR(16777216)) as TELGROUPNAME,
        cast(FINANCIALGROUPNAME as VARCHAR(16777216)) as FINANCIALGROUPNAME,
        cast(SALESGROUPNAME as VARCHAR(16777216)) as SALESGROUPNAME,
        cast(REGION as VARCHAR(16777216)) as REGION,
        cast(SALESGROUPNAME_FST as VARCHAR(16777216)) as SALESGROUPNAME_FST,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data