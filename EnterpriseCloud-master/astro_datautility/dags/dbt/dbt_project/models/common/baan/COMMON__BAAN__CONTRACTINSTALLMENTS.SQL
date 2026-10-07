{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='CONTRACTINSTALLMENTS',
    unique_key = []
) }}

with source_data as
(
    SELECT
        Qry_ContractInstallments.COMPANY,
        Qry_ContractInstallments.CONFIGURATION,
        Qry_ContractInstallments.CONTRACT_AMT,
        Qry_ContractInstallments.CONTRACT_DESCRIPTION,
        Qry_ContractInstallments.CONTRACT_NUMBER,
        Qry_ContractInstallments.CUSTOMER_PO_LINE,
        Qry_ContractInstallments.DISCOUNT,
        Qry_ContractInstallments.DISCOUNT_AMOUNT,
        Qry_ContractInstallments.FORECAST_COST_PERCENTAGE,
        Qry_ContractInstallments.GROSS_AMOUNT,
        Qry_ContractInstallments.INSTALLMENT_AMOUNT,
        Qry_ContractInstallments.INSTALLMENT_NUMBER,
        Qry_ContractInstallments.INVOICE_DATE,
        Qry_ContractInstallments.INVOICE_NUMBER,
        Qry_ContractInstallments.NET_INSTALLMENT_AMOUNT,
        Qry_ContractInstallments.NUMBER_OF_PERIODS,
        Qry_ContractInstallments.PLANNED_INVOICE_DATE,
        Qry_ContractInstallments.STATUS,
        Qry_ContractInstallments.TAX_AMOUNT,
        Qry_ContractInstallments.TRANSACTION_TYPE,
        Qry_ContractInstallments.WARRANTY_CREDIT
        FROM
        (
        SELECT DISTINCT
            a.service_percent_contract AS Contract_Number,
            NULL AS gross_amount,--TEA_CONT_INST_GROSS_CONT_AMT (a.service_percent_contract) AS gross_amount, 
            e.configuration AS Configuration, 
            e.salesamount AS Contract_Amt, 
            a.description AS Contract_Description,
            a.installmentamount AS Installment_Amount,
            a.installmentstatusdescription AS Status,
            a.invoicenumber AS Invoice_Number,
            a.invoicedate AS Invoice_Date,
            a.installmentnumber AS Installment_Number,
            a.discountpercentage AS Discount,
            a.discountamount AS Discount_Amount,
            a.netinstallmentamount AS Net_Installment_Amount,
            a.warrantycredit AS Warranty_Credit,
            a.forecastcostpercentage AS Forecast_Cost_Percentage,
            a.numberofperiodsforfinancialspreading AS Number_of_Periods,
            a.transactiontype AS Transaction_Type,
            a.financialcompany AS Company,
            a.taxamount AS Tax_Amount,
            a.plannedinvoicedate AS Planned_Invoice_Date,
            a.customerpoline AS Customer_PO_Line
        FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACT_CONFIGURATIONLINES') }} c
            INNER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMS') }} e
            ON     c.contractterms = e.termid
                AND c.configuration = e.configuration
                AND e.typeoflinedescription = 'Contract Total'
                AND (c.servicecontract, e.termid) IN
        (SELECT d1.servicecontract, MAX (d1.termid) 
        FROM {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_TERMIDLOGGING') }} d1
            LEFT OUTER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTCHANGES') }} d2
            ON     d1.servicecontract = d2.servicecontract_csco
                AND d1.termid = d2.contractterms
        WHERE     d1.applicationid = 15
            AND d2.statusofchangedescription IN (NULL, 'Closed')
            AND COALESCE (d2.changeeffectivetime, CURRENT_TIMESTAMP()) <= CURRENT_TIMESTAMP()
        GROUP BY d1.servicecontract)
            INNER JOIN {{ ref('ODS__BAAN__BAANSERVICECONTRACTMANAGEMENT_CONTRACTINSTALLMENTS') }} a
            ON     c.servicecontract = a.service_percent_contract
                AND c.configuration = a.configuration
        ORDER BY a.service_percent_contract, e.configuration, a.installmentnumber
        ) Qry_ContractInstallments
),

transform_data as
(
    SELECT
        source_data.COMPANY,
        source_data.CONFIGURATION,
        source_data.CONTRACT_AMT,
        source_data.CONTRACT_DESCRIPTION,
        source_data.CONTRACT_NUMBER,
        source_data.CUSTOMER_PO_LINE,
        source_data.DISCOUNT,
        source_data.DISCOUNT_AMOUNT,
        source_data.FORECAST_COST_PERCENTAGE,
        source_data.GROSS_AMOUNT,
        source_data.INSTALLMENT_AMOUNT,
        source_data.INSTALLMENT_NUMBER,
        source_data.INVOICE_DATE,
        source_data.INVOICE_NUMBER,
        source_data.NET_INSTALLMENT_AMOUNT,
        source_data.NUMBER_OF_PERIODS,
        source_data.PLANNED_INVOICE_DATE,
        source_data.STATUS,
        source_data.TAX_AMOUNT,
        source_data.TRANSACTION_TYPE,
        source_data.WARRANTY_CREDIT,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(CONTRACT_NUMBER as VARCHAR(16777216)) as CONTRACT_NUMBER,
        cast(GROSS_AMOUNT as VARCHAR(16777216)) as GROSS_AMOUNT,
        cast(CONFIGURATION as VARCHAR(16777216)) as CONFIGURATION,
        cast(CONTRACT_AMT as NUMBER(15,2)) as CONTRACT_AMT,
        cast(CONTRACT_DESCRIPTION as VARCHAR(16777216)) as CONTRACT_DESCRIPTION,
        cast(INSTALLMENT_AMOUNT as NUMBER(15,2)) as INSTALLMENT_AMOUNT,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(INVOICE_NUMBER as NUMBER(38,0)) as INVOICE_NUMBER,
        cast(INVOICE_DATE as DATE) as INVOICE_DATE,
        cast(INSTALLMENT_NUMBER as NUMBER(38,0)) as INSTALLMENT_NUMBER,
        cast(DISCOUNT as NUMBER(15,2)) as DISCOUNT,
        cast(DISCOUNT_AMOUNT as NUMBER(15,2)) as DISCOUNT_AMOUNT,
        cast(NET_INSTALLMENT_AMOUNT as NUMBER(15,2)) as NET_INSTALLMENT_AMOUNT,
        cast(WARRANTY_CREDIT as NUMBER(15,2)) as WARRANTY_CREDIT,
        cast(FORECAST_COST_PERCENTAGE as NUMBER(15,2)) as FORECAST_COST_PERCENTAGE,
        cast(NUMBER_OF_PERIODS as NUMBER(38,0)) as NUMBER_OF_PERIODS,
        cast(TRANSACTION_TYPE as VARCHAR(16777216)) as TRANSACTION_TYPE,
        cast(COMPANY as NUMBER(38,0)) as COMPANY,
        cast(TAX_AMOUNT as NUMBER(15,2)) as TAX_AMOUNT,
        cast(PLANNED_INVOICE_DATE as DATE) as PLANNED_INVOICE_DATE,
        cast(CUSTOMER_PO_LINE as VARCHAR(16777216)) as CUSTOMER_PO_LINE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data