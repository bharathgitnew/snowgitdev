{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='Ariba_Indirect_Purchase_Order_Information',
    transient=false
) }}

WITH
    -- Source Data Tables

  PurchaseOrderHeader AS
(
    SELECT
          PurchaseOrderIdKey
         ,PurchaseOrderVersionKey
         ,InitialUniqueName AS PurchaseOrderNumber
         ,IsBlanketOrder
         ,CompanyCode CompanyId
         ,Closed
         ,CreateDate AS OrderedDate
    FROM {{ ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_HEADER') }}
    WHERE RealmName = 'tel-S4'
    AND IsCurrentVersion = 'Yes'
)
, PurchaseOrderLineItem AS
(
    SELECT
         PurchaseOrderIdKey
        ,PurchaseOrderVersionKey
        ,PurchaseOrderLineItemKey
        ,NumberInCollection AS PurchaseOrderLineNumber
        ,RequisitionCode AS RequisitionNumber
        ,Quantity AS OrderQuantity
        ,DescriptionDescription AS LineDescription
        ,ServiceDetailsServiceStartDate As StartDate
        ,ServiceDetailsServiceEndDate As EndDate
        ,CASE
            WHEN ServiceDetailsServiceStartDate IS NULL THEN 'No'
            ELSE 'Yes'
         END AS IsBPOLine
        ,SupplierCode As SupplierNumber
        ,SupplierName As SupplierName
        ,SupplierLocationCode As SupplierLocation
        ,AmountAmount AS LineAmount
        ,Quantity * DescriptionPriceAmount AS TotalAmount -- Was Custom Field * Quantity
        ,DescriptionPriceCurrencyCode As Currency
        ,DescriptionPriceAmount AS UnitPrice -- Unit Price???
    FROM {{ ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_LINEITEM') }}
    WHERE RealmName = 'tel-S4'
    AND IsHistorical = 'No'
)
, PurchaseOrderSplitAccounting AS
(
    SELECT
         PurchaseOrderIdKey
        ,PurchaseOrderVersionKey
        ,PurchaseOrderLineItemKey
        ,NumberInCollection AS PurchaseOrderSplitAccountingNumber
        ,GeneralLedgerCode
        ,GeneralLedgerDescription
        ,CostCenterCode AS DepartmentCode
        ,CostCenterDescription AS DepartmentName
        ,AssetCode AS AssetCode
        ,AssetName AS AssetName
    FROM {{ ref('SILVER__TEH_PROCUREMENT__PURCHASEORDER_SPLITACCOUNTING') }}
    WHERE RealmName = 'tel-S4'
    AND IsHistorical = 'No'
)
, RequisitionHeader AS
(
    SELECT
         RequisitionIdKey RequisitionNumber
        ,RequisitionVersionKey RequisitionVersionNumber
        ,Name AS Title
        ,PreparerCode AS PreparerEmail
        ,RequesterCode AS RequesterEMail
    FROM {{ ref('SILVER__TEH_PROCUREMENT__REQUISITION_HEADER') }}
    WHERE RealmName = 'tel-S4'
    AND IsCurrentVersion = 'Yes'
)
, RequisitionLineItem AS
(
    SELECT
         RequisitionIdKey RequisitionNumber
        ,RequisitionVersionKey RequisitionVersionNumber
        ,RequisitionLineItemKey RequisitionLineNumber
        ,CommodityExportMapEntryCommodityCodeName AS ERPCommodity
        ,SupplierLocationCode AS ERPSupplierNumber
        ,SupplierCode AS CommonSupplierID
    FROM {{ ref('SILVER__TEH_PROCUREMENT__REQUISITION_LINEITEM') }}
    WHERE RealmName = 'tel-S4'
)
, InvoiceHeader AS
(
    SELECT
         InvoiceIdKey
        ,InvoiceVersionKey
    FROM {{ ref('SILVER__TEH_PROCUREMENT__INVOICE_HEADER') }}
    WHERE RealmName = 'tel-S4'
    AND ApprovedDate IS NOT NULL
)
, InvoiceLineItem AS
(
    SELECT
         InvoiceIdKey
        ,InvoiceVersionKey
        ,OrderCode AS PurchaseOrderNumber
        ,OrderLineItemNumberInCollection AS PurchaseOrderLineNumber
        ,AmountAmount As Amount
    FROM {{ ref('SILVER__TEH_PROCUREMENT__INVOICE_LINEITEM') }}
    WHERE RealmName = 'tel-S4'
)
, ReceiptLineItem AS
(
    SELECT
         ERPPONumber PurchaseOrderNumber
        ,NULLIF(ERPPOLineNumber,'') AS PurchaseOrderLineNumber
        ,AmountAcceptedAmount
        ,AmountReconciledAmount
        ,NumberReconciled
    FROM {{ ref('SILVER__TEH_PROCUREMENT__RECEIPT_LINEITEM') }}
    WHERE RealmName = 'tel-S4'
)

    -- Combinations

, PurchaseOrder AS
(
  SELECT
         Header.PurchaseOrderNumber
        ,Header.IsBlanketOrder
        ,Header.CompanyId
        ,Header.Closed
        ,Header.OrderedDate
        ,LineItem.PurchaseOrderLineNumber
        ,LineItem.StartDate
        ,LineItem.EndDate
        ,LineItem.IsBPOLine
        ,LineItem.SupplierName
        ,LineItem.SupplierNumber
        ,LineItem.SupplierLocation
        ,LineItem.RequisitionNumber
        ,LineItem.OrderQuantity
        ,LineItem.LineDescription
        ,LineItem.LineAmount
        ,LineItem.TotalAmount
        ,LineItem.UnitPrice
        ,LineItem.Currency
        ,SplitAccounting.PurchaseOrderSplitAccountingNumber
        ,SplitAccounting.GeneralLedgerCode
        ,SplitAccounting.GeneralLedgerDescription
        ,SplitAccounting.DepartmentCode
        ,SplitAccounting.DepartmentName
        ,SplitAccounting.AssetCode
        ,SplitAccounting.AssetName
  FROM PurchaseOrderHeader Header
  JOIN PurchaseOrderLineItem LineItem
  ON LineItem.PurchaseOrderIdKey = Header.PurchaseOrderIdKey
  AND LineItem.PurchaseOrderVersionKey = Header.PurchaseOrderVersionKey
  LEFT OUTER JOIN PurchaseOrderSplitAccounting SplitAccounting
  ON SplitAccounting.PurchaseOrderIdKey = LineItem.PurchaseOrderIdKey
    AND SplitAccounting.PurchaseOrderVersionKey = LineItem.PurchaseOrderVersionKey
    AND SplitAccounting.PurchaseOrderLineItemKey = LineItem.PurchaseOrderLineItemKey
)
, Requisition AS
(
    SELECT
         Header.RequisitionNumber
        ,Lineitem.RequisitionLineNumber
        ,Header.Title
        ,Header.PreparerEmail
        ,Header.RequesterEMail
        ,Lineitem.ERPCommodity
        ,Lineitem.ERPSupplierNumber
        ,Lineitem.CommonSupplierID
    FROM RequisitionHeader Header
    LEFT OUTER JOIN RequisitionLineItem Lineitem
    ON Lineitem.RequisitionNumber = Header.RequisitionNumber
    AND Lineitem.RequisitionVersionNumber = Header.RequisitionVersionNumber
)
, Invoice AS
(
    SELECT
         Header.InvoiceIdKey
        ,Header.InvoiceVersionKey
        ,LineItem.PurchaseOrderNumber
        ,LineItem.PurchaseOrderLineNumber
        ,LineItem.Amount
    FROM InvoiceHeader Header
    JOIN InvoiceLineItem LineItem
    ON Lineitem.InvoiceIdKey = Header.InvoiceIdKey
    AND Lineitem.InvoiceVersionKey = Header.InvoiceVersionKey
)

    -- Aggregates

,InvoiceTotal_By_PurchaseOrder AS
(
    SELECT
         PurchaseOrderNumber
        ,SUM(Amount) As TotalAmount
    FROM Invoice
    GROUP BY ALL
)
,InvoiceTotal_BY_PurchaseOrderLineNumber AS
(
    SELECT
         PurchaseOrderNumber
        ,PurchaseOrderLineNumber
        ,SUM(Amount) As TotalAmount
    FROM Invoice
    GROUP BY ALL
)
,ReceiptTotal_By_PurchaseOrderLineNumber AS
(
    SELECT
         PurchaseOrderNumber
        ,PurchaseOrderLineNumber
        ,SUM(AmountAcceptedAmount) AS AmountAccepted
        ,SUM(AmountReconciledAmount) AS AmountReconciled
        ,SUM(NumberReconciled) as NumberReconciled
    FROM ReceiptLineItem
    GROUP BY ALL
)

    -- Report

, Transform_Data AS
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID
		,SHA2('hash_me') AS _ROW_HASH
        ,PurchaseOrder.IsBPOLine
        ,PurchaseOrder.PurchaseOrderNumber PurchaseOrderId
        ,PurchaseOrder.PurchaseOrderLineNumber
        ,PurchaseOrder.RequisitionNumber RequisitionId
        ,PurchaseOrder.SupplierNumber
        ,PurchaseOrder.SupplierName
        ,PurchaseOrder.SupplierLocation
        ,PurchaseOrder.Closed AS ClosedOrderStatus
        ,Requisition.Title
        ,PurchaseOrder.CompanyId
        ,PurchaseOrder.DepartmentCode AS CostCenterCode
        ,PurchaseOrder.DepartmentName AS CostCenterName
        ,PurchaseOrder.AssetCode
        ,PurchaseOrder.AssetName
        ,Requisition.RequesterEMail
        ,Requisition.PreparerEmail
        ,PurchaseOrder.LineDescription
        ,PurchaseOrder.GeneralLedgerCode
        ,PurchaseOrder.GeneralLedgerDescription
        ,Requisition.ERPCommodity
        ,TO_VARCHAR(PurchaseOrder.StartDate,'yyyy/mm/dd' ) AS StartDate
        ,TO_VARCHAR(PurchaseOrder.EndDate,'yyyy/mm/dd' ) AS EndDate
        ,TO_VARCHAR(PurchaseOrder.OrderedDate,'yyyy/mm/dd' ) AS OrderedDate
        ,PurchaseOrder.OrderQuantity
        ,PurchaseOrder.UnitPrice
        ,PurchaseOrder.TotalAmount
        ,PurchaseOrder.Currency
        ,ReceiptTotals.AmountAccepted
        ,IFNULL(ReceiptTotals.NumberReconciled,0) AS ReconciledQuantity
        ,IFNULL(CASE
                    WHEN PurchaseOrder.IsBPOLine='Yes' THEN ReceiptTotals.AmountAccepted
                    ELSE ReceiptTotals.AmountReconciled
                END
            ,0) AS ReconciledAmount
        ,IFNULL(PurchaseOrder.LineAmount,0) - IFNULL(CASE
                                                        WHEN PurchaseOrder.IsBPOLine='Yes' THEN ReceiptTotals.AmountAccepted
                                                        ELSE ReceiptTotals.AmountReconciled
                                                    END
                                                    ,0) AS AmountLeftToReconcile
        ,PurchaseOrder.LineAmount - IFNULL(ReceiptTotals.AmountAccepted,0) AS AmountLeftToInvoice
        ,IFNULL(InvoicePurchaseOrderLineItemTotal.TotalAmount,0) AS InvoiceLineAmount
        ,IFNULL(InvoicePurchaseOrderTotal.TotalAmount,0) InvoicePurchaseOrderTotalAmount
    FROM PurchaseOrder
    JOIN Requisition
      ON Requisition.RequisitionNumber = PurchaseOrder.RequisitionNumber
      AND Requisition.RequisitionLineNumber = PurchaseOrder.PurchaseOrderLineNumber
    LEFT OUTER JOIN ReceiptTotal_By_PurchaseOrderLineNumber ReceiptTotals
      ON ReceiptTotals.PurchaseOrderNumber = PurchaseOrder.PurchaseOrderNumber
      AND ReceiptTotals.PurchaseOrderLineNumber = PurchaseOrder.PurchaseOrderLineNumber
    LEFT OUTER JOIN InvoiceTotal_By_PurchaseOrder InvoicePurchaseOrderTotal
      ON InvoicePurchaseOrderTotal.PurchaseOrderNumber = PurchaseOrder.PurchaseOrderNumber
    LEFT OUTER JOIN InvoiceTotal_BY_PurchaseOrderLineNumber InvoicePurchaseOrderLineItemTotal
      ON InvoicePurchaseOrderLineItemTotal.PurchaseOrderNumber = PurchaseOrder.PurchaseOrderNumber
      AND InvoicePurchaseOrderLineItemTotal.PurchaseOrderLineNumber = PurchaseOrder.PurchaseOrderLineNumber
),

type_data as (
    SELECT 
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
 	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    CAST(ISBPOLINE AS VARCHAR(3)) AS ISBPOLINE,
	CAST(PURCHASEORDERID AS VARCHAR(16777216)) AS PURCHASEORDERID,
	CAST(PURCHASEORDERLINENUMBER AS NUMBER(38,0)) AS PURCHASEORDERLINENUMBER,
	CAST(REQUISITIONID AS VARCHAR(16777216)) AS REQUISITIONID,
	CAST(SUPPLIERNUMBER AS VARCHAR(16777216)) AS SUPPLIERNUMBER,
	CAST(SUPPLIERNAME AS VARCHAR(16777216)) AS SUPPLIERNAME,
	CAST(SUPPLIERLOCATION AS VARCHAR(16777216)) AS SUPPLIERLOCATION,
	CAST(CLOSEDORDERSTATUS AS VARCHAR(16777216)) AS CLOSEDORDERSTATUS,
	CAST(TITLE AS VARCHAR(16777216)) AS TITLE,
	CAST(COMPANYID AS VARCHAR(16777216)) AS COMPANYID,
	CAST(COSTCENTERCODE AS VARCHAR(16777216)) AS COSTCENTERCODE,
	CAST(COSTCENTERNAME AS VARCHAR(16777216)) AS COSTCENTERNAME,
	CAST(ASSETCODE AS VARCHAR(16777216)) AS ASSETCODE,
	CAST(ASSETNAME AS VARCHAR(16777216)) AS ASSETNAME,
	CAST(REQUESTEREMAIL AS VARCHAR(16777216)) AS REQUESTEREMAIL,
	CAST(PREPAREREMAIL AS VARCHAR(16777216)) AS PREPAREREMAIL,
	CAST(LINEDESCRIPTION AS VARCHAR(16777216)) AS LINEDESCRIPTION,
	CAST(GENERALLEDGERCODE AS VARCHAR(16777216)) AS GENERALLEDGERCODE,
	CAST(GENERALLEDGERDESCRIPTION AS VARCHAR(16777216)) AS GENERALLEDGERDESCRIPTION,
	CAST(ERPCOMMODITY AS VARCHAR(16777216)) AS ERPCOMMODITY,
	CAST(STARTDATE AS VARCHAR(16777216)) AS STARTDATE,
	CAST(ENDDATE AS VARCHAR(16777216)) AS ENDDATE,
	CAST(ORDEREDDATE AS VARCHAR(16777216)) AS ORDEREDDATE,
	CAST(ORDERQUANTITY AS NUMBER(38,10)) AS ORDERQUANTITY,
	CAST(UNITPRICE AS NUMBER(38,10)) AS UNITPRICE,
	CAST(TOTALAMOUNT AS NUMBER(38,12)) AS TOTALAMOUNT,
	CAST(CURRENCY AS VARCHAR(16777216)) AS CURRENCY,
	CAST(AMOUNTACCEPTED AS NUMBER(38,10)) AS AMOUNTACCEPTED,
	CAST(RECONCILEDQUANTITY AS NUMBER(38,10)) AS RECONCILEDQUANTITY,
	CAST(RECONCILEDAMOUNT AS NUMBER(38,10)) AS RECONCILEDAMOUNT,
	CAST(AMOUNTLEFTTORECONCILE AS NUMBER(38,10)) AS AMOUNTLEFTTORECONCILE,
	CAST(AMOUNTLEFTTOINVOICE AS NUMBER(38,10)) AS AMOUNTLEFTTOINVOICE,
	CAST(INVOICELINEAMOUNT AS NUMBER(38,10)) AS INVOICELINEAMOUNT,
	CAST(INVOICEPURCHASEORDERTOTALAMOUNT AS NUMBER(38,10)) AS INVOICEPURCHASEORDERTOTALAMOUNT
    FROM Transform_Data
)


SELECT * FROM type_data