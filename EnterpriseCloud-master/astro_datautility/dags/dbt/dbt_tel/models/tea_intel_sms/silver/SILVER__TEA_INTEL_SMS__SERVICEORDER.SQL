{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SERVICEORDER',
    unique_key = [],
    enabled=true
) }}

WITH Source_ServiceOrder AS
(
    SELECT
        SERVICEORDER,
        SERVICECONTRACT,

        DISPATCHTIME,
        SERVICEORDERCOSTINGSHEET,
        CANCELREASON,
        CANCELDATE,
        CONFIGURATION,
        CURRENCY,
        REFERENCEA,
        EXCLUDEFROMKRONOSDESCRIPTION,
        INVOICE_TOBUSINESSPARTNER,
        NCDRDESCRIPTION,
        ORDER_DATE,
        ORDER_PRIORITYDESCRIPTION,
        ORDER_STATUSID,
        ORDER_STATUSDESCRIPTION,
        ORDER_TEXT,
        REFERENCEB,
        PAIDSERVICETYPEDESCRIPTION,
        PLANNEDFINISHTIME,
        ORDER_DURATION,
        PLANNEDSTARTTIME,
        SALESREPRESENTATIVEINSIDE,
        SERVICECENTER,
        SOLDTOBUSINESSPARTNER,
        TAXCODE,
        SERVICEENGINEER,
        INVOICETEXT
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS') }}

)
, source_MaterialCosts AS
(
    SELECT
        ServiceOrder,
        Activity,
        SalesAmountServiceContract,
        SalesAmountOtherCosts,
        SalesAmountWarranty,
        SalesAmountServiceOrderInvoicing,
        Carrier,
        CommitDate,
        CostComponent,
        CostLineStatusDescription,
        CustomerPOLine,
        ActualCostPrice1,
        WarrantyCoverageDescription,
        CustReqDelDt,
        ActualCumulativeQuantity,
        DeliveryTypeId,
        DeliveryTypeDescription,
        Discount,
        InvoiceAmount,
        InvoiceDate,
        InvoiceNumber,
        Item,
        LineNumber,
        Order_Date,
        PostingDate,
        ReasonCode,
        Route,
        SalesPrice,
        ShipToAddress,
        TotalSalesAmount,
        DeliveredQuantity,
        PLANNEDDELIVERYTIME,
        LastTransactionDateActualCostLine,
        TSMTransLine_Hash_ContNumber,
        TSMTransIDContName,
        WarehouseOrderForTransfer,
        TFGLD011TTYP as TransactionType
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS') }}

)
, source_LaborCosts AS
(
    SELECT
        ServiceOrder,
        Activity,
        SalesAmountServiceContract,
        SalesAmountOtherCosts,
        SalesAmountWarranty,
        SalesAmountServiceOrderInvoicing,
        CostComponent,
        CostLineStatusDescription,
        CustomerPOLine,
        WarrantyCoverageDescription,
        EstimatedLaborRate1,
        InvoiceAmount,
        InvoiceDate,
        InvoiceNumber,
        LineNumber,
        PostingDate,
        TotalSalesAmount,
        LastTransactionDateActualCostLine,
        TransactionType
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERLABORCOSTS') }}

)
, source_OtherCosts AS
(
    SELECT
        ServiceOrder,
        Activity,
        SalesAmountServiceContract,
        SalesAmountOtherCosts,
        SalesAmountWarranty,
        SalesAmountServiceOrderInvoicing,
        CostComponent,
        CostLineStatusDescription,
        CustomerPOLine,
        CostTypeDescription,
        WarrantyCoverageDescription,
        InvoiceAmount,
        InvoiceDate,
        InvoiceNumber,
        LineNumber,
        ActualQuantity,
        PostingDate,
        SalesPrice,
        TotalSalesAmount,
        LastTransactionDateActualCostLine,
        TransactionType
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS') }}

)
, source_ServiceOrderActivities AS
(
    SELECT
        SERVICEORDER,
        CONFIGURATION,
        ACTIVITY,
        ACTIVITYSTATUSID,
        ACTIVITYSTATUSDESCRIPTION,
        CUSTOMERPOLINE,
        DESCRIPTION,
        PLANNEDFINISHTIME,
        PLANNEDSTARTTIME,
        SERVICETYPE,
        OBJECTNUMBER,
        OBJECT
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES') }} ServiceOrderActivities
)
, source_Employee AS
(
    SELECT
         EMPLOYEE,
         NAME
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANCOMMONCOMMONDATA_EMPLOYEES') }}

)
, source_ServiceContract AS
(
    SELECT
        SERVICECONTRACT,
        CONTRACTEFFECTIVEDATE,
        CONTRACTEXPIRYDATE
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICECONTRACTMANAGEMENT_SERVICECONTRACTS') }}

)
, source_ServiceExecutionAssignments AS
(
    SELECT
        ServiceOrder,
        Activity,
        ServiceEngineer
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEEXECUTIONASSIGNMENTS') }}

)
, source_PDSHourlyRate AS
(
    SELECT
        Invoice_To_BPID,
        Paid_Service_Hourly_Rate
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__MDM_PDS_HOURLY_RATE') }}

)
, source_PaidServiceExceptionPricing AS
(
    SELECT
        Service_Order,
        Hourly_Rate
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__MDM_PAID_SERVICE_EXCEPTION_PRICING') }}

)
, source_BusinessPartners AS
(
    SELECT
        BusinessPartner,
        Name
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}

)
, source_BusinessUnit AS
(
    SELECT
        BUCodeByConfiguration,
        BUCodeTEA,
        BUCodeTEL
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANCOMMONCOMMONDATA_BUCODEMAPPING') }}

)
, source_ConfigurationObject AS
(
    SELECT
        Configuration,
        ObjectNumber,
        Object,
        ObjectGroup,
        SerialNumber,
        EmployeeNumber
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICECONFIGURATIONCONTROL_OBJECTS') }}

)
, source_TextManager AS
(
    SELECT
        TextNumber,
        Language,
        NumberOfLines,
        TextLine
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANTOOLSTEXTMANAGER_TEXT') }}

)
, source_CostComponent AS
(
    SELECT
         CostComponent
        ,Description
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANCOMMONSYSTEMTABLES_COSTCOMPONENTS') }}

)
, source_ServiceHoursAccounting AS
(
    SELECT
         ServiceOrder
        ,TSSOC210ACLN
        ,LaborLine
        ,CostTypeDescription
        ,HourlyLaborType
        ,SpentTime
        ,SalesRate
        ,Task
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEHOURSACCOUNTING') }}

)
, source_SourceRelations AS
(
    SELECT
         SalesInvoiceDocumentNumber
        ,SalesInvoiceTransactionType
        ,InvoiceStatusDescription
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS') }}

)
, source_POLink AS
(
    SELECT
         ServiceOrder
        ,Activity
        ,CostLine
        ,PurchaseOrder
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK') }}

)
, source_MaintainReasonForOrderingParts AS
(
    SELECT
        ReasonCode
        ,Description
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANSERVICESERVICEORDERCONTROL_MAINTAINREASONFORORDERINGPARTS') }}

)
, source_inboundOrderLines AS
(
    SELECT
         Order_
        ,PositionNumber
        ,ActualReceiptDate
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_INBOUNDORDERLINES') }}

)
, source_outboundOrderLines AS
(
    SELECT
         Order_
        ,PositionNumber
        ,LineStatusDescription
        ,ActualDeliveryDate
    FROM {{ ref('BRONZE__TEA_INTEL_SMS__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES') }}

)



, transform_ServiceOrder AS
(
    SELECT
        SERVICEORDER as Service_Order_No,
        SERVICECONTRACT as Contract_No,
        LEFT(SERVICEORDER,3) AS Service_Order_Series,

        DISPATCHTIME as ACTUALS_DISPATCH_TIME,
        SERVICEORDERCOSTINGSHEET as BLANK_ORDER_SHEET,
        CANCELREASON as CANCELLED,
        CANCELDATE as CANCELLED_DATE,
        CONFIGURATION as CONFIGURATION,
        CURRENCY as CURRENCY,
        REFERENCEA as CUSTOMER_PO,
        EXCLUDEFROMKRONOSDESCRIPTION as Exclude_From_Kronos,
        INVOICE_TOBUSINESSPARTNER as InvoiceTo_BusinessPartner_Id,
        NCDRDESCRIPTION as NCDR_FLAG,
        ORDER_DATE as ORDER_DT,
        ORDER_PRIORITYDESCRIPTION as ORDER_PRIORITY,
        ORDER_STATUSID as ORDER_STATUS,
        ORDER_STATUSDESCRIPTION as ORDER_STATUS_DESC,
        TRY_TO_NUMBER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REFERENCEB,'N/A',''),'(','-'),')',''),'$',''),',','')) as Customer_PO_Amt,
        PAIDSERVICETYPEDESCRIPTION as PAID_SERVICE_TYPE,
        PLANNEDFINISHTIME as PLANNED_END_TIME,
        ORDER_DURATION as PLANNED_ORDER_DURATION,
        PLANNEDSTARTTIME as PLANNED_START_DT,
        SALESREPRESENTATIVEINSIDE as SALES_REP,
        SERVICECENTER as SERVICE_CENTER,
        SOLDTOBUSINESSPARTNER as SoldTo_BusinessPartner_Id,
        TAXCODE as TAX_CODE,
        SERVICEENGINEER AS ServiceEngineer_Id,
        ORDER_TEXT AS Order_Text_Number,
        INVOICETEXT AS Invoice_Text_Number
    FROM Source_ServiceOrder
)
, transform_ServiceOrderActivities AS
(
    SELECT
        SERVICEORDER as Service_Order_No,
        CONFIGURATION as Configuration,
        ACTIVITY as Activity_Line,
        ACTIVITYSTATUSID as ACTIVITY_STATUS,
        ACTIVITYSTATUSDESCRIPTION as ACTIVITY_STATUS_DESC,
        CUSTOMERPOLINE as CUSTOMER_PO_LINE,
        DESCRIPTION as DESCRIPTION,
        PLANNEDFINISHTIME as PLAN_FINISH_TIME,
        PLANNEDSTARTTIME as PLAN_START_TIME,
        SERVICETYPE as SERVICE_TYPE,
        OBJECTNUMBER as Object_Number,
        OBJECT as OBJECT
    FROM source_ServiceOrderActivities ServiceOrderActivities
)
, transform_Employee AS
(
    SELECT
        Employee AS Employee_Id,
        Name AS Employee_Name
    FROM source_Employee
)
, transform_ServiceContract AS
(
    SELECT
        ServiceContract         AS Contract_No,
        CONTRACTEFFECTIVEDATE   AS CONTRACT_EFFECTIVE_DATE,
        CONTRACTEXPIRYDATE      AS CONTRACT_EXPIRATION_DATE
    FROM source_ServiceContract
)
, transform_ServiceExecutionAssignments AS
(
    SELECT
        ServiceOrder    AS Service_Order_No,
        Activity        AS Activity_Line,
        ServiceEngineer AS Service_Engineer_Id
    FROM source_ServiceExecutionAssignments
)
, transform_BusinessPartners AS
(
    SELECT
        BusinessPartner AS BusinessPartner_Id,
        Name            AS BusinessPartner_Name
    FROM source_BusinessPartners
)
, transform_BusinessUnit AS
(
    SELECT
        BUCodeByConfiguration AS BusinessUnit_Id,
        BUCodeTEA       AS BusinessUnit_TEA,
        BUCodeTEL       AS BusinessUnit_TEL
    FROM source_BusinessUnit
)
, transform_ConfigurationObject AS
(
    SELECT
        Configuration,
        ObjectNumber AS Object_Number,
        Object,
        ObjectGroup AS BusinessUnit_Id,
        SerialNumber as Serial_Number,
        EmployeeNumber AS Employee_Number
    FROM source_ConfigurationObject
)
, transform_TextManager AS
(
    SELECT
        TextNumber AS Text_Number,
        LISTAGG(TextLine) WITHIN GROUP (Order By NumberOfLines) AS Text_Data
    FROM source_TextManager
    WHERE Language = 2
      AND NumberOfLines <= 3
    GROUP BY TextNumber
)
, transform_PDSHourlyRate AS
(
    SELECT
        Invoice_To_BPID AS Business_Partner_Id,
        Paid_Service_Hourly_Rate AS Hourly_Rate
    FROM source_PDSHourlyRate
)
, transform_PaidServiceExceptionPricing AS
(
    SELECT
        Service_Order   AS Service_Order_No,
        Hourly_Rate     AS Hourly_Rate
    FROM source_PaidServiceExceptionPricing
)
, transform_CostComponent AS
(
    SELECT
         CostComponent AS Cost_Component
        ,Description    AS Description
    FROM source_CostComponent
)
, transform_ServiceHoursAccounting AS
(
    SELECT
         ServiceOrder as Service_Order_No
        ,TSSOC210ACLN   As Activity
        ,LaborLine      as Activity_Line
        ,CostTypeDescription    AS Cost_Type_Description
        ,HourlyLaborType    AS Hourly_Labor_Type
        ,SpentTime          AS Spent_Time
        ,SalesRate          AS Sales_Rate
        ,Task               AS Task
    FROM source_ServiceHoursAccounting
)
, transform_SourceRelations AS
(
    SELECT
         SalesInvoiceDocumentNumber AS Sales_Invoice_Document_Number
        ,SalesInvoiceTransactionType AS Sales_Invoice_Transaction_Type
        ,InvoiceStatusDescription AS Invoice_Status_Description
    FROM source_SourceRelations
)
, transform_POLink AS
(
    SELECT
         ServiceOrder AS Service_Order_No
        ,Activity AS Activity
        ,CostLine AS Line_Number
        ,PurchaseOrder AS Purchase_Order
    FROM source_POLink
)
, transform_MaintainReasonForOrderingParts AS
(
    SELECT
         ReasonCode AS Reason_Code
        ,Description
    FROM source_MaintainReasonForOrderingParts
)
, transform_InboundOrderLines AS
(
    SELECT
         Order_ Service_Order_No
        ,PositionNumber AS Position_Number
        ,TO_DATE(ActualReceiptDate) AS Actual_Receipt_Date
        ,ActualReceiptDate     AS Actual_Receipt_Datetime
    FROM source_inboundOrderLines
), transform_InboundOrderLines_Max_Calculation AS
(
    SELECT
         Service_Order_No
        ,Position_Number
        ,MAX(Actual_Receipt_Datetime) AS Max_Actual_Receipt_Datetime
    FROM transform_inboundOrderLines
    GROUP BY Service_Order_No,Position_Number
)
, transform_InboundOrderLines_Latest AS
(
    SELECT
         SourceData.Service_Order_No
        ,SourceData.Position_Number
        ,SourceData.Actual_Receipt_Date
        ,SourceData.Actual_Receipt_Datetime
    FROM transform_InboundOrderLines SourceData
    JOIN transform_InboundOrderLines_Max_Calculation MaxRowData
      ON MaxRowData.Service_Order_No = SourceData.Service_Order_No
     AND MaxRowData.Position_Number = SourceData.Position_Number
     AND MaxRowData.Max_Actual_Receipt_Datetime = SourceData.Actual_Receipt_Datetime
)
, transform_outboundOrderLines AS
(
    SELECT
         Order_ Service_Order_No
        ,PositionNumber AS Position_Number
        ,LineStatusDescription  AS Line_Status_Description
        ,TO_DATE(ActualDeliveryDate) AS Actual_Delivery_Date
        ,ActualDeliveryDate     AS Actual_Delivery_Datetime
    FROM source_outboundOrderLines
), transform_outboundOrderLines_Max_Calculation AS
(
    SELECT
         Service_Order_No
        ,Position_Number
        ,MAX(Actual_Delivery_Datetime) AS Max_Actual_Delievery_Datetime
    FROM transform_outboundOrderLines
    GROUP BY Service_Order_No,Position_Number
)
, transform_OutboundOrderLines_Latest AS
(
    SELECT
         SourceData.Service_Order_No
        ,SourceData.Position_Number
        ,SourceData.Line_Status_Description
        ,SourceData.Actual_Delivery_Date
        ,SourceData.Actual_Delivery_Datetime
    FROM transform_outboundOrderLines       SourceData
    JOIN transform_outboundOrderLines_Max_Calculation MaxRowData
      ON MaxRowData.Service_Order_No = SourceData.Service_Order_No
     AND MaxRowData.Position_Number = SourceData.Position_Number
     AND MaxRowData.Max_Actual_Delievery_Datetime = SourceData.Actual_Delivery_Datetime
)


, transform_MaterialCosts AS
(
    SELECT
        ServiceOrder AS Service_Order_No,
        Activity AS Activity_Line,
        SalesAmountServiceContract AS Sales_Amount_Service_Contract,
        SalesAmountOtherCosts AS Sales_Amount_Other_Costs,
        SalesAmountWarranty AS Sales_Amount_Warranty,
        SalesAmountServiceOrderInvoicing AS Sales_Amount_ServiceOrder_Invoicing,
        Carrier AS Carrier,
        CommitDate AS Commit_Date,
        CostComponent AS Cost_Component,
        CostLineStatusDescription AS Cost_Line_Status_Description,
        CustomerPOLine AS COST_PO_LINE,
        ActualCostPrice1 AS Actual_Cost_Price,
        WarrantyCoverageDescription AS Warranty_Coverage_Description,
        CustReqDelDt AS Customer_Requested_Delivery_Date,
        ActualCumulativeQuantity AS Actual_Cumulative_Quantity,
        DeliveryTypeId AS Delivery_Type_Id,
        DeliveryTypeDescription AS Delivery_Type_Description,
        Discount AS Discount,
        InvoiceAmount AS Invoice_Amount,
        InvoiceDate AS Invoice_Date,
        InvoiceNumber AS Invoice_Number,
        Item AS Item,
        LineNumber AS Line_Number,
        Order_Date AS Order_Date,
        ActualCumulativeQuantity + DeliveredQuantity AS Ordered_Quantity,
        PostingDate AS Posting_Date,
        ReasonCode AS Reason_Code,
        Route AS Route,
        SalesPrice AS Sales_Price,
        ShipToAddress AS ShipTo_Address,
        TotalSalesAmount AS Total_Sales_Amount,
        DeliveredQuantity AS Delivered_Quantity,
        PLANNEDDELIVERYTIME,
        LastTransactionDateActualCostLine AS Last_Transaction_Date_Actual_Cost_Line,
        TSMTransLine_Hash_ContNumber AS TSM_Trans_Line_Hash_Cont_Number,
        TSMTransIDContName AS TSM_Trans_ID_Cont_Name,
        WarehouseOrderForTransfer AS Warehouse_Order_For_Transfer,
        TransactionType AS Transaction_Type
    FROM source_MaterialCosts
)
, transform_LaborCosts AS
(
    SELECT
        ServiceOrder AS Service_Order_No,
        Activity AS Activity_Line,
        SalesAmountServiceContract AS Sales_Amount_Service_Contract,
        SalesAmountOtherCosts AS Sales_Amount_Other_Costs,
        SalesAmountWarranty AS Sales_Amount_Warranty,
        SalesAmountServiceOrderInvoicing AS Sales_Amount_ServiceOrder_Invoicing,
        CostComponent AS Cost_Component,
        CostLineStatusDescription AS Cost_Line_Status_Description,
        CustomerPOLine AS COST_PO_LINE,
        WarrantyCoverageDescription AS Warranty_Coverage_Description,
        EstimatedLaborRate1 AS Estimated_Labor_Rate,
        InvoiceAmount AS Invoice_Amount,
        InvoiceDate AS Invoice_Date,
        InvoiceNumber AS Invoice_Number,
        LineNumber AS Line_Number,
        PostingDate AS Posting_Date,
        TotalSalesAmount AS Total_Sales_Amount,
        LastTransactionDateActualCostLine AS Last_Transaction_Date_Actual_Cost_Line,
        TransactionType as Transaction_Type
    FROM source_LaborCosts
)
, transform_OtherCosts AS
(
    SELECT
        ServiceOrder AS Service_Order_No,
        Activity AS Activity_Line,
        SalesAmountServiceContract AS Sales_Amount_Service_Contract,
        SalesAmountOtherCosts AS Sales_Amount_Other_Costs,
        SalesAmountWarranty AS Sales_Amount_Warranty,
        SalesAmountServiceOrderInvoicing AS Sales_Amount_ServiceOrder_Invoicing,
        CostComponent AS Cost_Component,
        CostLineStatusDescription AS Cost_Line_Status_Description,
        CustomerPOLine AS COST_PO_LINE,
        CostTypeDescription AS Cost_Type_Description,
        WarrantyCoverageDescription AS Warranty_Coverage_Description,
        InvoiceAmount AS Invoice_Amount,
       InvoiceDate AS Invoice_Date,
        InvoiceNumber AS Invoice_Number,
        LineNumber AS Line_Number,
        ActualQuantity AS Actual_Quantity,
        PostingDate AS Posting_Date,
        SalesPrice AS Sales_Price,
        TotalSalesAmount AS Total_Sales_Amount,
        LastTransactionDateActualCostLine AS Last_Transaction_Date_Actual_Cost_Line,
        TransactionType AS Transaction_Type
    FROM source_OtherCosts
)

, transform_CommonFields AS
(
    SELECT
        ServiceOrder.Service_Order_No,
        ServiceOrder.Contract_No,
        ServiceOrder.ACTUALS_DISPATCH_TIME,
        ServiceOrder.BLANK_ORDER_SHEET,
        ServiceOrder.CANCELLED,
        ServiceOrder.CANCELLED_DATE,
        ServiceOrder.CONFIGURATION,
        ServiceOrder.CURRENCY,
        ServiceOrder.CUSTOMER_PO,
        ServiceOrder.EXCLUDE_FROM_KRONOS,
        ServiceOrder.InvoiceTo_BusinessPartner_Id,
        ServiceOrder.NCDR_FLAG,
        ServiceOrder.ORDER_DT,
        ServiceOrder.ORDER_PRIORITY,
        ServiceOrder.ORDER_STATUS,
        ServiceOrder.ORDER_STATUS_DESC,
        ServiceOrder.PAID_SERVICE_TYPE,
        ServiceOrder.PLANNED_END_TIME,
        ServiceOrder.PLANNED_ORDER_DURATION,
        ServiceOrder.Customer_PO_Amt,
        ServiceOrder.PLANNED_START_DT,
        ServiceOrder.SALES_REP,
        ServiceOrder.SERVICE_CENTER,
        ServiceOrder.Service_Order_Series,
        ServiceOrder.SoldTo_BusinessPartner_Id,
        ServiceOrder.TAX_CODE,
        ServiceOrderActivities.Configuration Activities_Configuration,
        ServiceOrderActivities.Activity_Line,
        ServiceOrderActivities.ACTIVITY_STATUS,
        ServiceOrderActivities.ACTIVITY_STATUS_DESC,
        ServiceOrderActivities.CUSTOMER_PO_LINE,
        ServiceOrderActivities.DESCRIPTION,
        ServiceOrderActivities.PLAN_FINISH_TIME,
        ServiceOrderActivities.PLAN_START_TIME,
        ServiceOrderActivities.SERVICE_TYPE,
        Employee.EMPLOYEE_NAME,
        ServiceContract.CONTRACT_EFFECTIVE_DATE,
        ServiceContract.CONTRACT_EXPIRATION_DATE,
        ExecutionAssignment.Service_Engineer_Id,
        InvoiceToBusinessPartner.BusinessPartner_Name AS Invoice_To_BP,
        SoldToBusinessPartner.BusinessPartner_Name AS Sold_To_BP,
        ConfigurationObject.Serial_Number,
        BusinessUnit.BusinessUnit_TEA,
        BusinessUnit.BusinessUnit_TEL,
        OrderText.Text_Data AS Order_Text,
        InvoiceText.Text_Data AS Invoice_Text,
        CASE
            WHEN NULLIF(ServiceOrder.Blank_Order_Sheet,'') IS NOT NULL THEN ServiceOrder.Blank_Order_Sheet
            WHEN OrderText.Text_Data LIKE '%*%' THEN OrderText.Text_Data
        END AS Quote,
        CASE
               WHEN PaidServiceExceptionPricing.Service_Order_No IS NOT NULL THEN PaidServiceExceptionPricing.Hourly_Rate  --Intel Exception Rates for PFP
               WHEN PDSHourlyRate.Hourly_Rate IS NOT NULL THEN PDSHourlyRate.Hourly_Rate  -- Standard Customer Rate
               ELSE 230  --Default Hrly Rate
        END AS Expected_Hourly_Rate,
        ROW_NUMBER() OVER (PARTITION BY ServiceOrder.Service_Order_No ORDER BY ServiceOrderActivities.Activity_Status DESC,ServiceOrderActivities.Activity_Line ASC) SOHeaderRowNumber
    FROM transform_ServiceOrder ServiceOrder
    JOIN transform_ServiceOrderActivities  ServiceOrderActivities
    ON ServiceOrderActivities.Service_Order_No = ServiceOrder.Service_Order_No
    LEFT OUTER JOIN transform_Employee Employee
    ON Employee.Employee_Id = ServiceOrder.ServiceEngineer_Id
    LEFT OUTER JOIN transform_ServiceContract ServiceContract
    ON ServiceContract.Contract_No = ServiceOrder.Contract_No
    LEFT OUTER JOIN transform_ServiceExecutionAssignments ExecutionAssignment
    ON ExecutionAssignment.Service_Order_No = ServiceOrderActivities.Service_Order_No
    AND ExecutionAssignment.Activity_Line = ServiceOrderActivities.Activity_Line
    LEFT OUTER JOIN transform_BusinessPartners InvoiceToBusinessPartner
    ON InvoiceToBusinessPartner.BusinessPartner_Id = ServiceOrder.InvoiceTo_BusinessPartner_Id
    LEFT OUTER JOIN transform_BusinessPartners SoldToBusinessPartner
    ON SoldToBusinessPartner.BusinessPartner_Id = ServiceOrder.SoldTo_BusinessPartner_Id
    LEFT OUTER JOIN transform_ConfigurationObject ConfigurationObject
    ON ConfigurationObject.Configuration = ServiceOrderActivities.Configuration
    AND ConfigurationObject.Object_Number = ServiceOrderActivities.Object_Number
    AND ConfigurationObject.Object = ServiceOrderActivities.Object
    LEFT OUTER JOIN transform_BusinessUnit BusinessUnit
    ON BusinessUnit.BusinessUnit_Id = ConfigurationObject.BusinessUnit_Id
    LEFT OUTER JOIN transform_TextManager OrderText
    ON OrderText.Text_Number = ServiceOrder.Order_Text_Number
    LEFT OUTER JOIN transform_TextManager InvoiceText
    ON InvoiceText.Text_Number = ServiceOrder.Invoice_Text_Number
    LEFT OUTER JOIN transform_PDSHourlyRate PDSHourlyRate
    ON PDSHourlyRate.Business_Partner_Id = ServiceOrder.InvoiceTo_BusinessPartner_Id
    LEFT OUTER JOIN transform_PaidServiceExceptionPricing PaidServiceExceptionPricing
    ON PaidServiceExceptionPricing.Service_Order_No = ServiceOrder.Service_Order_No


)
, transform_BaseServiceOrder AS
(
    SELECT
        'Service Order' AS SourceField
        ,ServiceOrderActivities.Service_Order_No
        ,ServiceOrderActivities.Activity_Line
    FROM transform_serviceOrder ServiceOrder
    LEFT OUTER JOIN transform_ServiceOrderActivities  ServiceOrderActivities
    ON ServiceOrderActivities.Service_Order_No = ServiceOrder.Service_Order_No
    LEFT OUTER JOIN transform_MaterialCosts MaterialCosts
    ON MaterialCosts.Service_Order_No = ServiceOrderActivities.Service_Order_No
      AND MaterialCosts.Activity_Line = ServiceOrderActivities.Activity_Line
    LEFT OUTER JOIN transform_LaborCosts LaborCosts
    ON LaborCosts.Service_Order_No = ServiceOrderActivities.Service_Order_No
      AND LaborCosts.Activity_Line = ServiceOrderActivities.Activity_Line
    LEFT OUTER JOIN transform_OtherCosts OtherCosts
    ON OtherCosts.Service_Order_No = ServiceOrderActivities.Service_Order_No
      AND OtherCosts.Activity_Line = ServiceOrderActivities.Activity_Line
    WHERE MaterialCosts.Service_Order_No IS NULL
    AND LaborCosts.Service_Order_No IS NULL
    AND OtherCosts.Service_Order_No IS NULL
)
, transform_BaseMaterialCosts AS
(
    SELECT
        'Material Costs' AS SourceField,
        MaterialCosts.Service_Order_No,
        MaterialCosts.Activity_Line,

        MaterialCosts.Sales_Amount_Service_Contract,
        MaterialCosts.Sales_Amount_Other_Costs,
        MaterialCosts.Sales_Amount_Warranty,
        MaterialCosts.Sales_Amount_ServiceOrder_Invoicing,
        MaterialCosts.Carrier,
        MaterialCosts.Commit_Date,
        MaterialCosts.Cost_Component,
        MaterialCosts.Cost_Line_Status_Description,
        MaterialCosts.COST_PO_LINE,
        MaterialCosts.Actual_Cost_Price,
        MaterialCosts.Warranty_Coverage_Description,
        MaterialCosts.Customer_Requested_Delivery_Date,
        MaterialCosts.Actual_Cumulative_Quantity,
        OutboundOrderLines.Actual_Delivery_Date  AS Delivery_Date,
        MaterialCosts.Delivery_Type_Description,
        MaterialCosts.Discount,
        CASE WHEN MaterialCosts.Delivery_Type_Id = 25 THEN InboundOrderLines.Actual_Receipt_Date  ELSE OutboundOrderLines.Actual_Delivery_Date END AS Final_Ship_Date,
        MaterialCosts.Invoice_Amount,
        MaterialCosts.Invoice_Date,
        MaterialCosts.Invoice_Number,
        MaterialCosts.Item,
        MaterialCosts.Line_Number,
        MaterialCosts.Order_Date,
        MaterialCosts.Ordered_Quantity,
        MaterialCosts.Posting_Date,
        MaterialCosts.Reason_Code,
        ReasonCodeDesc.Description AS Reason_Code_Description,
        MaterialCosts.Route,
        MaterialCosts.Sales_Price,
        MaterialCosts.ShipTo_Address,
        MaterialCosts.Total_Sales_Amount,
        MaterialCosts.Delivered_Quantity,
        MaterialCosts.PLANNEDDELIVERYTIME,
        MaterialCosts.Last_Transaction_Date_Actual_Cost_Line,
        MaterialCosts.TSM_Trans_Line_Hash_Cont_Number,
        MaterialCosts.TSM_Trans_ID_Cont_Name,
        MaterialCosts.Warehouse_Order_For_Transfer,
        OutboundOrderLines.Line_Status_Description AS Warehouse_Status,
        CostComponent.Description as Cost_Component_Description,
        NULL as Cost_Type,
        NULL as Hourly_Labor_Type,
        NULL as Task,
        NULL as Employee_Number,
        SourceRelations.Invoice_Status_Description AS Invoice_Status,
        SourceRelations.Sales_Invoice_Transaction_Type AS Transaction_Type,
        POLink.Purchase_Order AS TEL_PO_No
    FROM transform_MaterialCosts MaterialCosts
    LEFT OUTER JOIN transform_CostComponent CostComponent
      ON CostComponent.Cost_Component = MaterialCosts.Cost_Component
    LEFT OUTER JOIN transform_MaintainReasonForOrderingParts ReasonCodeDesc
      ON ReasonCodeDesc.Reason_Code = MaterialCosts.Reason_Code
    LEFT OUTER JOIN transform_SourceRelations SourceRelations
      ON SourceRelations.Sales_Invoice_Transaction_Type = MaterialCosts.Transaction_Type
     AND SourceRelations.Sales_Invoice_Document_Number = MaterialCosts.Invoice_Number
    LEFT OUTER JOIN transform_POLink POLink
      ON POLink.Service_Order_No = MaterialCosts.Service_Order_No
     AND POLink.Activity = MaterialCosts.Activity_Line
     AND POLink.Line_Number = MaterialCosts.Line_Number
    LEFT OUTER JOIN transform_OutboundOrderLines_Latest OutboundOrderLines
      ON OutboundOrderLines.Service_Order_No = MaterialCosts.Service_Order_No
     AND OutboundOrderLines.Position_Number = MaterialCosts.Line_Number
    LEFT OUTER JOIN transform_InboundOrderLines_Latest InboundOrderLines
      ON InboundOrderLines.Service_Order_No = MaterialCosts.Service_Order_No
     AND InboundOrderLines.Position_Number = MaterialCosts.Line_Number
)
, transform_BaseLaborCosts AS
(
    SELECT
        'Labor Hours' AS SourceField,
        LaborCosts.Service_Order_No,
        LaborCosts.Activity_Line,

        LaborCosts.Sales_Amount_Service_Contract,
        LaborCosts.Sales_Amount_Other_Costs,
        LaborCosts.Sales_Amount_Warranty,
        LaborCosts.Sales_Amount_ServiceOrder_Invoicing,
        LaborCosts.Cost_Component,
        LaborCosts.Cost_Line_Status_Description,
        LaborCosts.COST_PO_LINE,
        LaborCosts.Warranty_Coverage_Description,
        LaborCosts.Estimated_Labor_Rate,
        LaborCosts.Invoice_Amount,
        LaborCosts.Invoice_Date,
        LaborCosts.Invoice_Number,
        LaborCosts.Line_Number,
        LaborCosts.Posting_Date,
        LaborCosts.Total_Sales_Amount,
        LaborCosts.Last_Transaction_Date_Actual_Cost_Line,
        CostComponent.Description as Cost_Component_Description,
        ServiceHoursAccounting.Cost_Type_Description as Cost_Type,
        ServiceHoursAccounting.Hourly_Labor_Type,
        ServiceHoursAccounting.Spent_Time * ServiceHoursAccounting.Sales_Rate as Sales_Price,
        ServiceHoursAccounting.Task,
        Objects.Employee_Number,
        SourceRelations.Invoice_Status_Description AS Invoice_Status,
        SourceRelations.Sales_Invoice_Transaction_Type AS Transaction_Type,
        POLink.Purchase_Order AS TEL_PO_No
    FROM transform_LaborCosts LaborCosts
    LEFT OUTER JOIN transform_CostComponent CostComponent
      ON CostComponent.Cost_Component = LaborCosts.Cost_Component
    LEFT OUTER JOIN transform_ServiceHoursAccounting ServiceHoursAccounting
      ON ServiceHoursAccounting.Service_Order_No = LaborCosts.Service_Order_No
     AND ServiceHoursAccounting.Activity = LaborCosts.Activity_Line
      AND ServiceHoursAccounting.Activity_Line = LaborCosts.Line_Number
    LEFT OUTER JOIN transform_ServiceOrderActivities Activity
      ON Activity.Service_Order_No = LaborCosts.Service_Order_No
     AND Activity.Activity_Line = LaborCosts.Activity_Line
    LEFT OUTER JOIN transform_ConfigurationObject Objects
      ON Objects.Configuration = Activity.Configuration
     AND Objects.Object_Number = Activity.Object_Number
     AND Objects.Object = Activity.Object
    LEFT OUTER JOIN transform_SourceRelations SourceRelations
      ON SourceRelations.Sales_Invoice_Transaction_Type = LaborCosts.Transaction_Type
     AND SourceRelations.Sales_Invoice_Document_Number = LaborCosts.Invoice_Number
    LEFT OUTER JOIN transform_POLink POLink
      ON POLink.Service_Order_No = LaborCosts.Service_Order_No
     AND POLink.Activity = LaborCosts.Activity_Line
     AND POLink.Line_Number = LaborCosts.Line_Number
)
, transform_BaseOtherCosts AS
(
    SELECT
        'Other Costs' AS SourceField,
        OtherCosts.Service_Order_No,
        OtherCosts.Activity_Line,

        OtherCosts.Sales_Amount_Service_Contract,
        OtherCosts.Sales_Amount_Other_Costs,
        OtherCosts.Sales_Amount_Warranty,
        OtherCosts.Sales_Amount_ServiceOrder_Invoicing,
        OtherCosts.Cost_Component,
        OtherCosts.Cost_Line_Status_Description,
        OtherCosts.COST_PO_LINE,
        OtherCosts.Cost_Type_Description,
        OtherCosts.Warranty_Coverage_Description,
        OtherCosts.Invoice_Amount,
        OtherCosts.Invoice_Date,
        OtherCosts.Invoice_Number,
        OtherCosts.Line_Number,
        OtherCosts.Actual_Quantity,
        OtherCosts.Posting_Date,
        OtherCosts.Sales_Price,
        OtherCosts.Total_Sales_Amount,
        OtherCosts.Last_Transaction_Date_Actual_Cost_Line,
        CostComponent.Description as Cost_Component_Description,
        OtherCosts.Cost_Type_Description as Cost_Type,
        NULL as Hourly_Labor_Type,
        NULL as Task,
        NULL as Employee_Number,
        SourceRelations.Invoice_Status_Description AS Invoice_Status,
        SourceRelations.Sales_Invoice_Transaction_Type AS Transaction_Type,
        POLink.Purchase_Order AS TEL_PO_No
    FROM transform_OtherCosts OtherCosts
    LEFT OUTER JOIN transform_CostComponent CostComponent
      ON CostComponent.Cost_Component = OtherCosts.Cost_Component
    LEFT OUTER JOIN transform_SourceRelations SourceRelations
      ON SourceRelations.Sales_Invoice_Transaction_Type = OtherCosts.Transaction_Type
     AND SourceRelations.Sales_Invoice_Document_Number = OtherCosts.Invoice_Number
    LEFT OUTER JOIN transform_POLink POLink
      ON POLink.Service_Order_No = OtherCosts.Service_Order_No
     AND POLink.Activity = OtherCosts.Activity_Line
     AND POLink.Line_Number = OtherCosts.Line_Number
)
, transform_UnitedCosts AS
(
    SELECT
         SourceField
        ,Service_Order_No
        ,Activity_Line
        ,NULL AS Sales_Amount_Service_Contract
        ,NULL AS Sales_Amount_Other_Costs
        ,NULL AS Sales_Amount_Warranty
        ,NULL AS Sales_Amount_ServiceOrder_Invoicing
        ,NULL AS Carrier
        ,NULL AS Commit_Date
        ,NULL AS Cost_Component
        ,NULL AS Cost_Line_Status_Description
        ,NULL AS COST_PO_LINE
        ,NULL AS Cost_Type_Description
        ,NULL AS Actual_Quantity
        ,NULL AS Actual_Cost_Price
        ,NULL AS Warranty_Coverage_Description
        ,NULL AS Customer_Requested_Delivery_Date
        ,NULL AS Actual_Cumulative_Quantity
        ,NULL AS Delivery_Date
        ,NULL AS Delivery_Type_Description
        ,NULL AS Discount
        ,NULL AS Estimated_Labor_Rate
        ,NULL AS Final_Ship_Date
        ,NULL AS Invoice_Amount
        ,NULL AS Invoice_Date
        ,NULL AS Invoice_Number
        ,NULL AS Item
        ,NULL AS Line_Number
        ,NULL AS Order_Date
        ,NULL AS Ordered_Quantity
        ,NULL AS Posting_Date
        ,NULL AS Reason_Code
        ,NULL AS Reason_Code_Description
        ,NULL AS Route
        ,NULL AS Sales_Price
        ,NULL AS ShipTo_Address
        ,NULL AS Total_Sales_Amount
        ,NULL AS Delivered_Quantity
        ,NULL AS PLANNEDDELIVERYTIME
        ,NULL AS Last_Transaction_Date_Actual_Cost_Line
        ,NULL AS TSM_Trans_Line_Hash_Cont_Number
        ,NULL AS TSM_Trans_ID_Cont_Name
        ,NULL AS Warehouse_Order_For_Transfer
        ,NULL AS Warehouse_Status
        ,NULL AS Cost_Component_Description
        ,NULL AS Cost_Type
        ,NULL AS Hourly_Labor_Type
        ,NULL AS Task
        ,NULL AS Employee_Number
        ,NULL AS Invoice_Status
        ,NULL AS Transaction_Type
        ,NULL AS TEL_PO_No
    FROM transform_BaseServiceOrder
  UNION ALL
    SELECT
         SourceField
        ,Service_Order_No
        ,Activity_Line
        ,Sales_Amount_Service_Contract
        ,Sales_Amount_Other_Costs
        ,Sales_Amount_Warranty
        ,Sales_Amount_ServiceOrder_Invoicing
        ,Carrier
        ,NULL AS Commit_Date
        ,Cost_Component
        ,Cost_Line_Status_Description
        ,COST_PO_LINE
        ,NULL AS Cost_Type_Description
        ,NULL AS Actual_Quantity
        ,Actual_Cost_Price
        ,Warranty_Coverage_Description
        ,Customer_Requested_Delivery_Date
        ,Actual_Cumulative_Quantity
        ,Delivery_Date
        ,Delivery_Type_Description
        ,Discount
        ,NULL AS Estimated_Labor_Rate
        ,Final_Ship_Date AS Final_Ship_Date
        ,Invoice_Amount
        ,Invoice_Date
        ,Invoice_Number
        ,Item
        ,Line_Number
        ,Order_Date
        ,Ordered_Quantity
        ,Posting_Date
        ,Reason_Code
        ,Reason_Code_Description
        ,Route
        ,Sales_Price
        ,ShipTo_Address
        ,Total_Sales_Amount
        ,Delivered_Quantity
        ,PLANNEDDELIVERYTIME
        ,Last_Transaction_Date_Actual_Cost_Line
        ,TSM_Trans_Line_Hash_Cont_Number
        ,TSM_Trans_ID_Cont_Name
        ,Warehouse_Order_For_Transfer
        ,Warehouse_Status
        ,Cost_Component_Description
        ,Cost_Type
        ,Hourly_Labor_Type
        ,Task
        ,Employee_Number
        ,Invoice_Status
        ,Transaction_Type
        ,TEL_PO_No
    FROM transform_BaseMaterialCosts
  UNION ALL
    SELECT
         SourceField
        ,Service_Order_No
        ,Activity_Line
        ,Sales_Amount_Service_Contract
        ,Sales_Amount_Other_Costs
        ,Sales_Amount_Warranty
        ,Sales_Amount_ServiceOrder_Invoicing
        ,NULL AS Carrier
        ,NULL AS Commit_Date
        ,Cost_Component
        ,Cost_Line_Status_Description
        ,COST_PO_LINE
        ,NULL AS Cost_Type_Description
        ,NULL AS Actual_Quantity
        ,NULL AS Actual_Cost_Price
        ,Warranty_Coverage_Description
        ,NULL AS Customer_Requested_Delivery_Date
        ,NULL AS Actual_Cumulative_Quantity
        ,NULL AS Delivery_Date
        ,NULL AS Delivery_Type_Description
        ,NULL AS Discount
        ,Estimated_Labor_Rate
        ,NULL AS Final_Ship_Date
        ,Invoice_Amount
        ,Invoice_Date
        ,Invoice_Number
        ,NULL AS Item
        ,Line_Number
        ,NULL AS Order_Date
        ,NULL AS Ordered_Quantity
        ,Posting_Date
        ,NULL AS Reason_Code
        ,NULL AS Reason_Code_Description
        ,NULL AS Route
        ,Sales_Price
        ,NULL AS ShipTo_Address
        ,Total_Sales_Amount
        ,NULL AS Delivered_Quantity
        ,NULL AS PLANNEDDELIVERYTIME
        ,Last_Transaction_Date_Actual_Cost_Line
        ,NULL AS TSM_Trans_Line_Hash_Cont_Number
        ,NULL AS TSM_Trans_ID_Cont_Name
        ,NULL AS Warehouse_Order_For_Transfer
        ,NULL AS Warehouse_Status
        ,Cost_Component_Description
        ,Cost_Type
        ,Hourly_Labor_Type
        ,Task
        ,Employee_Number
        ,Invoice_Status
        ,Transaction_Type
        ,TEL_PO_No
    FROM transform_BaseLaborCosts
  UNION ALL
    SELECT
         SourceField
        ,Service_Order_No
        ,Activity_Line
        ,Sales_Amount_Service_Contract
        ,Sales_Amount_Other_Costs
        ,Sales_Amount_Warranty
        ,Sales_Amount_ServiceOrder_Invoicing
        ,NULL AS Carrier
        ,NULL AS Commit_Date
        ,Cost_Component
        ,Cost_Line_Status_Description
        ,COST_PO_LINE
        ,Cost_Type_Description
        ,Actual_Quantity
        ,NULL AS Actual_Cost_Price
        ,Warranty_Coverage_Description
        ,NULL AS Customer_Requested_Delivery_Date
        ,NULL AS Actual_Cumulative_Quantity
        ,NULL AS Delivery_Date
        ,NULL AS Delivery_Type_Description
        ,NULL AS Discount
        ,NULL AS Estimated_Labor_Rate
        ,NULL AS Final_Ship_Date
        ,Invoice_Amount
        ,Invoice_Date
        ,Invoice_Number
        ,NULL AS Item
        ,Line_Number
        ,NULL AS Order_Date
        ,NULL AS Ordered_Quantity
        ,Posting_Date
        ,NULL AS Reason_Code
        ,NULL AS Reason_Code_Description
        ,NULL AS Route
        ,Sales_Price
        ,NULL AS ShipTo_Address
        ,Total_Sales_Amount
        ,NULL AS Delivered_Quantity
        ,NULL AS PLANNEDDELIVERYTIME
        ,Last_Transaction_Date_Actual_Cost_Line
        ,NULL AS TSM_Trans_Line_Hash_Cont_Number
        ,NULL AS TSM_Trans_ID_Cont_Name
        ,NULL AS Warehouse_Order_For_Transfer
        ,NULL AS Warehouse_Status
        ,Cost_Component_Description
        ,Cost_Type
        ,NULL AS Hourly_Labor_Type
        ,NULL AS Task
        ,NULL AS Employee_Number
        ,Invoice_Status
        ,Transaction_Type
        ,TEL_PO_No
    FROM transform_BaseOtherCosts
)
, transform_CombinedCommonAndSpecific AS
(
  SELECT
         United.Service_Order_No
        ,United.Activity_Line
        ,Common.Order_DT AS Order_DT
        ,Common.Service_Type AS Service_Type
        ,Common.Description AS Description
        ,Common.Configuration AS Configuration
        ,Common.Activities_Configuration AS Activity_Configuration
        ,Common.Serial_Number AS Serial_Number
        ,Common.BusinessUnit_TEA AS TEL_BU
        ,Common.BusinessUnit_TEA AS TEA_BU
        ,Common.Order_Status AS Order_Status
        ,Common.Order_Status_Desc
        ,Common.Activity_Status AS Activity_Status
        ,Common.Activity_Status_Desc AS ACTIVITY_STATUS_DESC
        ,Common.Paid_Service_Type AS Paid_Service_Type
        ,Common.InvoiceTo_BusinessPartner_Id AS Invoice_To_BPID
        ,Common.Invoice_To_BP AS Invoice_To_BP
        ,Common.SoldTo_BusinessPartner_Id AS Sold_To_BPID
        ,Common.Sold_To_BP AS Sold_To_BP
        ,Common.Customer_PO AS Customer_PO
        ,Common.Customer_PO_Line AS CUSTOMER_PO_LINE        
  --      ,United.Customer_PO_Line AS Customer_PO_Line
        ,Common.Customer_PO_Amt AS Customer_PO_Amt
        ,Common.Sales_Rep AS Sales_Rep
        ,Common.Contract_No AS Contract_No
        ,Common.Contract_Effective_Date AS Contract_Effective_Date
        ,Common.Contract_Expiration_Date AS Contract_Expiration_Date
        ,Common.Service_Engineer_Id AS Employee
        ,Common.Employee_Name AS Employee_Name
        ,Common.Blank_Order_Sheet AS Blank_Order_Sheet
        ,Common.Service_Center AS Service_Center
        ,Common.Planned_Start_DT AS Planned_Start_DT
        ,United.SourceField AS Source
        ,United.Line_Number AS Line_Number
        ,United.Cost_Component AS Cost_Component
        ,United.Cost_Component_Description AS Cost_Component_Desc
        ,United.Cost_Type AS Cost_Type
        ,United.Delivery_Type_Description AS Delivery_Type
        ,United.Warehouse_Order_For_Transfer AS Warehouse
        ,United.TSM_Trans_ID_Cont_Name AS TSM_Trans_Id
        ,United.TSM_Trans_Line_Hash_Cont_Number AS TSM_Line
        ,United.Order_Date AS Material_Order_Date
        ,United.Commit_Date AS Commit_Date
        ,United.Customer_Requested_Delivery_Date AS Customer_Req_Date
 --       ,Common.Planned_Delivery_Time AS Planned_Ship_Date
         ,United.PLANNEDDELIVERYTIME AS Planned_Ship_Date
        ,United.ShipTo_Address AS Ship_To_Address_Code
        ,United.Item AS Item
        ,United.Actual_Cost_Price AS Cost_Price
        ,United.Ordered_Quantity AS Ordered_Qty
        ,United.Actual_Cumulative_Quantity AS Delivered_Qty
        ,United.Delivered_Quantity AS To_Be_Del_Qty
        ,United.Delivery_Date AS Delivery_Date
        ,United.Sales_Price AS Sales_Price
        ,United.Total_Sales_Amount AS Total_Sales_Amt
        ,United.Warranty_Coverage_Description AS Covered_By_Warranty
        ,United.Sales_Amount_Service_Contract AS Amt_Covered_By_Contract
        ,United.Sales_Amount_Warranty AS Amt_Covered_By_Warranty
        ,United.Sales_Amount_Other_Costs AS Amt_Covered_By_Other
        ,United.Sales_Amount_ServiceOrder_Invoicing AS Amt_To_Be_Invoiced
        ,United.Invoice_Amount AS Invoice_Amount
        ,United.Transaction_Type AS Transaction_Type
        ,United.Invoice_Number AS Invoice_Number
        ,United.Invoice_Date AS Invoice_Date
        ,United.Employee_Number AS Employee_Number
        ,United.Hourly_Labor_Type AS Hourly_Labor_Type
        ,United.Task AS Task
        ,United.Cost_Line_Status_Description AS Cost_Line_Status
        ,United.COST_PO_LINE AS COST_PO_LINE
        ,United.Invoice_Status AS Invoice_Status
        ,United.Warehouse_Status AS Warehouse_Status
        ,United.Carrier AS Carrier
        ,United.Route AS Route
        ,Common.Tax_Code AS Tax_Code
        ,United.Last_Transaction_Date_Actual_Cost_Line AS Transaction_Date
        ,United.Posting_Date AS Posting_Date
        ,Common.Cancelled AS Cancelled
        ,Common.Cancelled_Date AS Cancelled_Date
        ,United.Final_Ship_Date AS Final_Ship_Date
        ,Common.NCDR_Flag AS NCDR_Flag
        ,Common.Order_Priority AS Order_Priority
        ,United.TEL_PO_No AS TEL_PO_No
        ,Common.Invoice_Text AS Invoice_Text
        ,United.Reason_Code AS Reason_Code
        ,United.Reason_Code_Description AS Reason_Code_Desc
        ,United.Estimated_Labor_Rate AS Estimated_Labor
        ,Common.Currency AS Currency
        ,Common.Planned_End_Time AS Planned_End_Time
        ,Common.Planned_Order_Duration AS Planned_Order_Duration
        ,Common.Actuals_Dispatch_Time AS Actuals_Dispatch_Time
        ,Common.Order_Text AS Order_Text
        ,United.Discount AS Discount_Rate
        ,Common.Exclude_From_Kronos AS Exclude_From_Kronos
        ,Common.Plan_Start_Time AS Plan_Start_Time
        ,Common.Plan_Finish_Time AS Plan_Finish_Time
        ,CASE WHEN Common.SOHeaderRowNumber = 1 THEN 'Yes' ELSE 'No' END AS IsReportingHeader
        ,Common.Expected_Hourly_Rate AS ExpectedHourlyRate
        ,Common.Quote AS Quote
        ,Common.Service_Order_Series AS SO_Series
        ,'{{ invocation_id }}' AS _Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash         
  FROM transform_UnitedCosts United
  JOIN transform_CommonFields Common
  ON Common.Service_Order_No = United.Service_Order_No
  AND Common.Activity_Line = United.Activity_Line
)

,	type_data as 
(
    select
		cast(_AUDIT_LOG_ID as VARCHAR(36)) as   _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(LINE_NUMBER as VARCHAR(16777216)) as  LINE_NUMBER,
		cast(SERVICE_ORDER_NO as VARCHAR(9)) as  SERVICE_ORDER_NO,
		cast(ACTIVITY_LINE as NUMBER(38,0)) as  ACTIVITY_LINE,
		cast(ORDER_DT as TIMESTAMP_NTZ(9)) as  ORDER_DT,
		cast(SERVICE_TYPE as VARCHAR(9)) as  SERVICE_TYPE,
		cast(DESCRIPTION as VARCHAR(16777216)) as  DESCRIPTION,
		cast(CONFIGURATION as VARCHAR(16777216)) as  CONFIGURATION,
		cast(ACTIVITY_CONFIGURATION as VARCHAR(16777216)) as  ACTIVITY_CONFIGURATION,
		cast(SERIAL_NUMBER as VARCHAR(16777216)) as  SERIAL_NUMBER,
		cast(TEL_BU as VARCHAR(16777216)) as  TEL_BU,
		cast(TEA_BU as VARCHAR(16777216)) as  TEA_BU,
		cast(ORDER_STATUS as NUMBER(38,0)) as  ORDER_STATUS,
		cast(ORDER_STATUS_DESC as VARCHAR(16777216)) as  ORDER_STATUS_DESC,
		cast(ACTIVITY_STATUS as NUMBER(38,0)) as  ACTIVITY_STATUS,
		cast(ACTIVITY_STATUS_DESC as VARCHAR(16777216)) as  ACTIVITY_STATUS_DESC,
		cast(PAID_SERVICE_TYPE as VARCHAR(16777216)) as  PAID_SERVICE_TYPE,
		cast(INVOICE_TO_BPID as VARCHAR(16777216)) as  INVOICE_TO_BPID,
		cast(INVOICE_TO_BP as VARCHAR(16777216)) as  INVOICE_TO_BP,
		cast(SOLD_TO_BPID as VARCHAR(16777216)) as  SOLD_TO_BPID,
		cast(SOLD_TO_BP as VARCHAR(16777216)) as  SOLD_TO_BP,
		cast(CUSTOMER_PO as VARCHAR(16777216)) as  CUSTOMER_PO,
		cast(CUSTOMER_PO_LINE as VARCHAR(16777216)) as  CUSTOMER_PO_LINE,
		cast(CUSTOMER_PO_AMT as VARCHAR(16777216)) as  CUSTOMER_PO_AMT,
		cast(SALES_REP as VARCHAR(16777216)) as  SALES_REP,
		cast(CONTRACT_NO as VARCHAR(16777216)) as  CONTRACT_NO,
		cast(CONTRACT_EFFECTIVE_DATE as TIMESTAMP_NTZ(9)) as  CONTRACT_EFFECTIVE_DATE,
		cast(CONTRACT_EXPIRATION_DATE as TIMESTAMP_NTZ(9)) as  CONTRACT_EXPIRATION_DATE,
		cast(EMPLOYEE as VARCHAR(16777216)) as  EMPLOYEE,
		cast(EMPLOYEE_NAME as VARCHAR(16777216)) as  EMPLOYEE_NAME,
		cast(BLANK_ORDER_SHEET as VARCHAR(16777216)) as  BLANK_ORDER_SHEET,
		cast(SERVICE_CENTER as VARCHAR(16777216)) as  SERVICE_CENTER,
		cast(PLANNED_START_DT as TIMESTAMP_NTZ(9)) as  PLANNED_START_DT,
		cast(SOURCE as VARCHAR(16777216)) as  SOURCE,
		cast(COST_COMPONENT as VARCHAR(16777216)) as  COST_COMPONENT,
		cast(COST_COMPONENT_DESC as VARCHAR(16777216)) as  COST_COMPONENT_DESC,
		cast(COST_TYPE as VARCHAR(16777216)) as  COST_TYPE,
		cast(DELIVERY_TYPE as VARCHAR(16777216)) as  DELIVERY_TYPE,
		cast(WAREHOUSE as VARCHAR(16777216)) as  WAREHOUSE,
		cast(TSM_TRANS_ID as VARCHAR(16777216)) as  TSM_TRANS_ID,
		cast(TSM_LINE as VARCHAR(16777216)) as  TSM_LINE,
		cast(MATERIAL_ORDER_DATE as DATE) as MATERIAL_ORDER_DATE,
		cast(COMMIT_DATE as DATE) as COMMIT_DATE,
		cast(CUSTOMER_REQ_DATE as DATE) as CUSTOMER_REQ_DATE,
		cast(PLANNED_SHIP_DATE as DATE) as PLANNED_SHIP_DATE,
		cast(SHIP_TO_ADDRESS_CODE as VARCHAR(16777216)) as  SHIP_TO_ADDRESS_CODE,
		cast(ITEM as VARCHAR(16777216)) as  ITEM,
		cast(COST_PRICE as VARCHAR(16777216)) as  COST_PRICE,
		cast(ORDERED_QTY as VARCHAR(16777216)) as  ORDERED_QTY,
		cast(DELIVERED_QTY as VARCHAR(16777216)) as  DELIVERED_QTY,
		cast(TO_BE_DEL_QTY as VARCHAR(16777216)) as  TO_BE_DEL_QTY,
		cast(DELIVERY_DATE as DATE) as DELIVERY_DATE,
		cast(SALES_PRICE as VARCHAR(16777216)) as  SALES_PRICE,
		cast(TOTAL_SALES_AMT as VARCHAR(16777216)) as  TOTAL_SALES_AMT,
		cast(COVERED_BY_WARRANTY as VARCHAR(16777216)) as  COVERED_BY_WARRANTY,
		cast(AMT_COVERED_BY_CONTRACT as VARCHAR(16777216)) as  AMT_COVERED_BY_CONTRACT,
		cast(AMT_COVERED_BY_WARRANTY as VARCHAR(16777216)) as  AMT_COVERED_BY_WARRANTY,
		cast(AMT_COVERED_BY_OTHER as VARCHAR(16777216)) as  AMT_COVERED_BY_OTHER,
		cast(AMT_TO_BE_INVOICED as VARCHAR(16777216)) as  AMT_TO_BE_INVOICED,
		cast(INVOICE_AMOUNT as VARCHAR(16777216)) as  INVOICE_AMOUNT,
		cast(TRANSACTION_TYPE as VARCHAR(16777216)) as  TRANSACTION_TYPE,
		cast(INVOICE_NUMBER as VARCHAR(16777216)) as  INVOICE_NUMBER,
		cast(INVOICE_DATE as VARCHAR(16777216)) as  INVOICE_DATE,
		cast(EMPLOYEE_NUMBER as VARCHAR(16777216)) as  EMPLOYEE_NUMBER,
		cast(HOURLY_LABOR_TYPE as VARCHAR(16777216)) as  HOURLY_LABOR_TYPE,
		cast(TASK as VARCHAR(16777216)) as  TASK,
		cast(COST_LINE_STATUS as VARCHAR(16777216)) as  COST_LINE_STATUS,
		cast(INVOICE_STATUS as VARCHAR(16777216)) as  INVOICE_STATUS,
		cast(WAREHOUSE_STATUS as VARCHAR(16777216)) as  WAREHOUSE_STATUS,
		cast(CARRIER as VARCHAR(16777216)) as  CARRIER,
		cast(ROUTE as VARCHAR(16777216)) as  ROUTE,
		cast(TAX_CODE as VARCHAR(16777216)) as  TAX_CODE,
		cast(TRANSACTION_DATE as VARCHAR(16777216)) as  TRANSACTION_DATE,
		cast(POSTING_DATE as VARCHAR(16777216)) as  POSTING_DATE,
		cast(CANCELLED as VARCHAR(16777216)) as  CANCELLED,
		cast(CANCELLED_DATE as TIMESTAMP_NTZ(9)) as  CANCELLED_DATE,
		cast(FINAL_SHIP_DATE as DATE) as FINAL_SHIP_DATE,
		cast(NCDR_FLAG as VARCHAR(16777216)) as  NCDR_FLAG,
		cast(ORDER_PRIORITY as VARCHAR(16777216)) as  ORDER_PRIORITY,
		cast(TEL_PO_NO as VARCHAR(16777216)) as  TEL_PO_NO,
		cast(INVOICE_TEXT as VARCHAR(16777216)) as  INVOICE_TEXT,
		cast(REASON_CODE as VARCHAR(16777216)) as  REASON_CODE,
		cast(REASON_CODE_DESC as VARCHAR(16777216)) as  REASON_CODE_DESC,
		cast(ESTIMATED_LABOR as VARCHAR(16777216)) as  ESTIMATED_LABOR,
		cast(CURRENCY as VARCHAR(16777216)) as  CURRENCY,
		cast(PLANNED_END_TIME as TIMESTAMP_NTZ(9)) as  PLANNED_END_TIME,
		cast(PLANNED_ORDER_DURATION as NUMBER(38,10)) as  PLANNED_ORDER_DURATION,
		cast(ACTUALS_DISPATCH_TIME as TIMESTAMP_NTZ(9)) as  ACTUALS_DISPATCH_TIME,
		cast(ORDER_TEXT as VARCHAR(16777216)) as  ORDER_TEXT,
		cast(COST_PO_LINE as VARCHAR(16777216)) as  COST_PO_LINE,
		cast(DISCOUNT_RATE as VARCHAR(16777216)) as  DISCOUNT_RATE,
		cast(EXCLUDE_FROM_KRONOS as VARCHAR(16777216)) as  EXCLUDE_FROM_KRONOS,
		cast(PLAN_START_TIME as TIMESTAMP_NTZ(9)) as  PLAN_START_TIME,
		cast(PLAN_FINISH_TIME as TIMESTAMP_NTZ(9)) as  PLAN_FINISH_TIME,
		cast(ISREPORTINGHEADER as VARCHAR(16777216)) as  ISREPORTINGHEADER,
		cast(EXPECTEDHOURLYRATE as NUMBER(38,10)) as  EXPECTEDHOURLYRATE,
		cast(QUOTE as VARCHAR(16777216)) as  QUOTE,
		cast(SO_SERIES as VARCHAR(16777216)) as  SO_SERIES
    from transform_CombinedCommonAndSpecific
)

select * from type_data