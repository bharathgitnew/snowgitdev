{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='BaanV_TEA_Sales_Orders',
      transient=false
) }}


with source_data as
(       
SELECT DISTINCT
          b.SALESORDER AS Sales_Order_No,
          b.POSITIONNUMBER AS Position_No,
          b.SEQUENCENUMBER AS Sequence_No,
          b.ORDER_LINETYPEDESCRIPTION as Order_Line_Type,
          b.INVOICENUMBERRETURN AS Invoice_No,
          c.LINESTATUSDESCRIPTION AS Status,
          b.WAREHOUSE AS Warehouse,
          b.CURRENTACTIVITY AS Current_Activity_Session,
        --   j.t$desc AS Current_Activity,
          a.INVOICETOBP AS InvoiceTo_BPID,
          h.NAME AS InvoiceTo_BP,
          b.SOLDTOBUSINESSPARTNER AS SoldTo_BPID,
          e.NAME AS SoldTo_BP,
          b.ITEM AS Item,
          f.DESCRIPTION AS Item_Description,
          a.SALESORDERTYPE AS Order_Type,
          b.COSTCOMPONENT AS Cost_Price_Component,
          b.SALESPRICEUNIT AS Unit_of_Measure,
          b.ORDER_EDQUANTITY AS Ordered_Qty,
          b.DELIVEREDQUANTITY AS Delivered_Qty,
          b.BACKORDERQUANTITY AS Back_Order_Qty,
          b.ORDER_DATE AS Order_Date,
          b.ORDER_DATE Order_DT,
          b.CUSTREQDELDATE AS Customer_Request_Date,
          b.CUSTREQDELDATE AS Customer_Request_DT,
          b.PLANNEDDELIVERYDATE AS Plan_Delivery_Date,
          b.PLANNEDDELIVERYDATE AS Plan_Delivery_DT,
          b.DELIVERYDATE AS Delivery_Date, 
          b.DELIVERYDATE AS Delivery_DT,
          b.INVOICEDATE AS Invoice_Date,
          b.INVOICEDATE AS Invoice_DT,
          b.COMMITDATE AS Original_Commit_Date,
          b.COMMITDATE AS Original_Commit_DT,
          b.COSTAMOUNTOFODSSOLD1 AS Standard_Cost_Price,
          b.PRICE AS Price,
          b.PRICESOURCEDESCRIPTION AS Price_Source,
          b.AMOUNT_OAMT AS Order_Amount,
          g.AMOUNTININVOICECURRENCY AS Invoice_Amount,
          b.LINEDISCOUNT1 AS Discount_Percent,
          b.CUSTOMERORDERNUMBER AS Customer_PO_No,
          a.REFERENCEA AS ReferenceA,
          a.REFERENCEB AS ReferenceB,
          a.INSIDESALESREP AS Sales_Rep,
          b.DIRECTDELIVERYDESCRIPTION AS Direct_Delivery,
          d.PURCHASEORDER AS Purchase_Order_No,
          a.AREA AS Area,
          b.TRANSACTIONTYPE AS Transaction_Type,
          k.INVOICESTATUSDESCRIPTION AS Invoice_Status,
          c.LINESTATUSDESCRIPTION AS Warehouse_Status,
          b.CANCELLEDDESCRIPTION AS Cancelled,
          m.TRANSACTIONDATE AS Cancelled_Date,
          b.ORDER_PRIORITY_PRIO_UDESCRIPTION AS Order_Priority,
          b.TAXCODE AS Tax_Code,
          b.CUSTOMERORDERPOSITION AS Customer_Order_Position,
          b.ROUTE AS Route,
          a.ORDER_CURRENCY AS Currency,
          b.CHANNELS AS Channel,
          b.SERIALNO AS Serial_No,
          a.INVOICINGBYINSTALLMENTSDESCRIPTION AS Invoice_By_Installment              
     FROM {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERS') }} a      -- SO Header
          INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES') }} b                                -- SO Lines
                                   ON a.SALESORDER = b.SALESORDER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES') }}  c   -- Warehousing Outbound Order Lines
             ON     b.SALESORDER = c.ORDER_
                AND b.POSITIONNUMBER = c.POSITIONNUMBER
                AND b.SEQUENCENUMBER = c.SEQUENCENUMBER
                -- AND c.t$oorg = 1
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA') }} d                -- Linked SO Line Data
             ON     b.SALESORDER = d.SALESORDER
                AND b.POSITIONNUMBER = d.POSITIONNUMBER_PONO
                AND b.SEQUENCENUMBER = d.SEQUENCENUMBER_SQNB
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }} e                         -- General BP
                                        ON b.SOLDTOBUSINESSPARTNER = e.BUSINESSPARTNER
          INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONITEMBASEDATA_GENERALITEMDATA') }}  f                     -- General Item Master
                                   ON b.ITEM = f.ITEM
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES') }} g -- Sales {\&} Warehouse Order Invoice Lines
             ON     b.SALESORDER = g.SALESWAREHOUSEORDER
                AND b.POSITIONNUMBER = g.LINENUMBER
                AND b.SEQUENCENUMBER = g.SEQUENCENUMBER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }} h                         -- General BP
                                        ON a.INVOICETOBP = h.BUSINESSPARTNER
        --   LEFT OUTER JOIN TTTADV300000 j
        --      /* Display Forms */
        --      ON     SUBSTR (b.CURRENTACTIVITY, 1, 2) = j.t$cpac
        --         AND SUBSTR (b.CURRENTACTIVITY, 3, 3) = j.t$cmod
        --         AND SUBSTR (b.CURRENTACTIVITY, 6, 8) = SUBSTR (j.t$cfrm, 1, 8)
        --         AND j.t$clan = 2
        --         AND j.t$vers = 'B50U'
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS') }} k
             /* Invoice - Source Relations */
             ON b.TRANSACTIONTYPE = k.SALESINVOICETRANSACTIONTYPE AND b.INVOICENUMBERRETURN = k.SALESINVOICEDOCUMENTNUMBER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY') }} m
             ON     b.SALESORDER = m.SALESORDER
                AND b.POSITIONNUMBER = m.POSITIONNUMBER_PONO
                AND b.SEQUENCENUMBER = m.SEQUENCENUMBER_SQNB
                AND m.RECORDTYPE1_3ID = 2
    WHERE b.ORDER_LINETYPEID <> 1                        /* Order Line Status: Header */
                       AND SUBSTR (a.SALESOFFICE, 1, 3) <> 'TEH'
   UNION
   SELECT DISTINCT
          b.SALESORDER AS Sales_Order_No,
          b.POSITIONNUMBER AS Position_No,
          b.SEQUENCENUMBER AS Sequence_No,
          b.ORDER_LINETYPEDESCRIPTION as Order_Line_Type,
          b.INVOICENUMBERRETURN AS Invoice_No,
          c.LINESTATUSDESCRIPTION AS Status,
          b.WAREHOUSE AS Warehouse,
          b.CURRENTACTIVITY AS Current_Activity_Session,
        --   j.t$desc AS Current_Activity,
          a.INVOICETOBP AS InvoiceTo_BPID,
          h.NAME AS InvoiceTo_BP,
          b.SOLDTOBUSINESSPARTNER AS SoldTo_BPID,
          e.NAME AS SoldTo_BP,
          b.ITEM AS Item,
          f.DESCRIPTION AS Item_Description,
          a.SALESORDERTYPE AS Order_Type,
          b.COSTCOMPONENT AS Cost_Price_Component,
          b.SALESPRICEUNIT AS Unit_of_Measure,
          b.ORDER_EDQUANTITY AS Ordered_Qty,
          b.DELIVEREDQUANTITY AS Delivered_Qty,
          b.BACKORDERQUANTITY AS Back_Order_Qty,
          b.ORDER_DATE AS Order_Date,
          b.ORDER_DATE Order_DT,
          b.CUSTREQDELDATE AS Customer_Request_Date,
          b.CUSTREQDELDATE AS Customer_Request_DT,
          b.PLANNEDDELIVERYDATE AS Plan_Delivery_Date,
          b.PLANNEDDELIVERYDATE AS Plan_Delivery_DT,
          b.DELIVERYDATE AS Delivery_Date, 
          b.DELIVERYDATE AS Delivery_DT,
          b.INVOICEDATE AS Invoice_Date,
          b.INVOICEDATE AS Invoice_DT,
          b.COMMITDATE AS Original_Commit_Date,
          b.COMMITDATE AS Original_Commit_DT,
          b.COSTAMOUNTOFODSSOLD1 AS Standard_Cost_Price,
          b.PRICE AS Price,
          b.PRICESOURCEDESCRIPTION AS Price_Source,
          b.AMOUNT_OAMT AS Order_Amount,
          g.AMOUNTININVOICECURRENCY AS Invoice_Amount,
          b.LINEDISCOUNT1 AS Discount_Percent,
          b.CUSTOMERORDERNUMBER AS Customer_PO_No,
          a.REFERENCEA AS ReferenceA,
          a.REFERENCEB AS ReferenceB,
          a.INSIDESALESREP AS Sales_Rep,
          b.DIRECTDELIVERYDESCRIPTION AS Direct_Delivery,
          d.PURCHASEORDER AS Purchase_Order_No,
          a.AREA AS Area,
          b.TRANSACTIONTYPE AS Transaction_Type,
          k.INVOICESTATUSDESCRIPTION AS Invoice_Status,
          c.LINESTATUSDESCRIPTION AS Warehouse_Status,
          b.CANCELLEDDESCRIPTION AS Cancelled,
          m.TRANSACTIONDATE AS Cancelled_Date,
          b.ORDER_PRIORITY_PRIO_UDESCRIPTION AS Order_Priority,
          b.TAXCODE AS Tax_Code,
          b.CUSTOMERORDERPOSITION AS Customer_Order_Position,
          b.ROUTE AS Route,
          a.ORDER_CURRENCY AS Currency,
          b.CHANNELS AS Channel,
          b.SERIALNO AS Serial_No,
          a.INVOICINGBYINSTALLMENTSDESCRIPTION AS Invoice_By_Installment   
     FROM {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERS') }} a                                          -- SO Header
          INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINES') }} b                                -- SO Lines
                                   ON a.SALESORDER = b.SALESORDER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDORDERLINES') }} c   -- Warehousing Outbound Order Lines
             ON     b.SALESORDER = c.ORDER_
                AND b.POSITIONNUMBER = c.POSITIONNUMBER
                AND b.SEQUENCENUMBER = c.SEQUENCENUMBER
                -- AND c.t$oorg = 1
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_LINKEDORDERLINEDATA') }} d                -- Linked SO Line Data
             ON     b.SALESORDER = d.SALESORDER
                AND b.POSITIONNUMBER = d.POSITIONNUMBER_PONO
                AND b.SEQUENCENUMBER = d.SEQUENCENUMBER_SQNB
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}  e                         -- General BP
                                        ON b.SOLDTOBUSINESSPARTNER = e.BUSINESSPARTNER
          INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONITEMBASEDATA_GENERALITEMDATA') }} f                     -- General Item Master
                                   ON b.ITEM = f.ITEM
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCENTRALINVOICINGSALESINVOICING_SALESANDWAREHOUSEORDERINVOICELINES') }} g -- Sales {\&} Warehouse Order Invoice Lines
             ON     b.SALESORDER = g.SALESWAREHOUSEORDER
                AND b.POSITIONNUMBER = g.LINENUMBER
                AND b.SEQUENCENUMBER = g.SEQUENCENUMBER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCOMMONCOMMONDATA_BUSINESSPARTNERS') }}  h                         -- General BP
                                        ON a.INVOICETOBP = h.BUSINESSPARTNER
        --   LEFT OUTER JOIN TTTADV300000 j
        --      /* Display Forms */
        --      ON     SUBSTR (b.CURRENTACTIVITY, 1, 2) = j.t$cpac
        --         AND SUBSTR (b.CURRENTACTIVITY, 3, 3) = j.t$cmod
        --         AND SUBSTR (b.CURRENTACTIVITY, 6, 8) = SUBSTR (j.t$cfrm, 1, 8)
        --         AND j.t$clan = 2
        --         AND j.t$vers = 'B50U'
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANCENTRALINVOICINGSALESINVOICING_INVOICE_SOURCERELATIONS') }} k
             /* Invoice - Source Relations */
             ON b.TRANSACTIONTYPE = k.SALESINVOICETRANSACTIONTYPE AND b.INVOICENUMBERRETURN = k.SALESINVOICEDOCUMENTNUMBER
          LEFT OUTER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__BAAN_BAANDISTRIBUTIONSALESCONTROL_SALESORDERLINEHISTORY') }} m
             ON     b.SALESORDER = m.SALESORDER
                AND b.POSITIONNUMBER = m.POSITIONNUMBER_PONO
                AND b.SEQUENCENUMBER = m.SEQUENCENUMBER_SQNB
                AND m.RECORDTYPE1_3ID = 2
    WHERE b.ORDER_LINETYPEID <> 1                        /* Order Line Status: Header */
                       AND SUBSTR (a.SALESOFFICE, 1, 3) = 'TEH'
    )

,transform_data as(
    SELECT
        SALES_ORDER_NO,
        POSITION_NO,
        SEQUENCE_NO,
        ORDER_LINE_TYPE,
        INVOICE_NO,
        STATUS,
        WAREHOUSE,
        CURRENT_ACTIVITY_SESSION,
        INVOICETO_BPID,
        INVOICETO_BP,
        SOLDTO_BPID,
        SOLDTO_BP,
        ITEM,
        ITEM_DESCRIPTION,
        ORDER_TYPE,
        COST_PRICE_COMPONENT,
        UNIT_OF_MEASURE,
        ORDERED_QTY,
        DELIVERED_QTY,
        BACK_ORDER_QTY,
        ORDER_DATE,
        ORDER_DT,
        CUSTOMER_REQUEST_DATE,
        CUSTOMER_REQUEST_DT,
        PLAN_DELIVERY_DATE,
        PLAN_DELIVERY_DT,
        DELIVERY_DATE,
        DELIVERY_DT,
        INVOICE_DATE,
        INVOICE_DT,
        ORIGINAL_COMMIT_DATE,
        ORIGINAL_COMMIT_DT,
        STANDARD_COST_PRICE,
        PRICE,
        PRICE_SOURCE,
        ORDER_AMOUNT,
        INVOICE_AMOUNT,
        DISCOUNT_PERCENT,
        CUSTOMER_PO_NO,
        REFERENCEA,
        REFERENCEB,
        SALES_REP,
        DIRECT_DELIVERY,
        PURCHASE_ORDER_NO,
        AREA,
        TRANSACTION_TYPE,
        INVOICE_STATUS,
        WAREHOUSE_STATUS,
        CANCELLED,
        CANCELLED_DATE,
        ORDER_PRIORITY,
        TAX_CODE,
        CUSTOMER_ORDER_POSITION,
        ROUTE,
        CURRENCY,
        CHANNEL,
        SERIAL_NO,
        INVOICE_BY_INSTALLMENT,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data
)
,type_data as 
(
    select
        cast(SALES_ORDER_NO as VARCHAR(16777216)) as SALES_ORDER_NO,
        cast(POSITION_NO as NUMBER(38,0)) as POSITION_NO,
        cast(SEQUENCE_NO as NUMBER(38,0)) as SEQUENCE_NO,
        cast(ORDER_LINE_TYPE as VARCHAR(16777216)) as ORDER_LINE_TYPE,
        cast(INVOICE_NO as NUMBER(38,0)) as INVOICE_NO,
        cast(STATUS as VARCHAR(16777216)) as STATUS,
        cast(WAREHOUSE as VARCHAR(16777216)) as WAREHOUSE,
        cast(CURRENT_ACTIVITY_SESSION as VARCHAR(16777216)) as CURRENT_ACTIVITY_SESSION,
        cast(INVOICETO_BPID as VARCHAR(16777216)) as INVOICETO_BPID,
        cast(INVOICETO_BP as VARCHAR(16777216)) as INVOICETO_BP,
        cast(SOLDTO_BPID as VARCHAR(16777216)) as SOLDTO_BPID,
        cast(SOLDTO_BP as VARCHAR(16777216)) as SOLDTO_BP,
        cast(ITEM as VARCHAR(16777216)) as ITEM,
        cast(ITEM_DESCRIPTION as VARCHAR(16777216)) as ITEM_DESCRIPTION,
        cast(ORDER_TYPE as VARCHAR(16777216)) as ORDER_TYPE,
        cast(COST_PRICE_COMPONENT as VARCHAR(16777216)) as COST_PRICE_COMPONENT,
        cast(UNIT_OF_MEASURE as VARCHAR(16777216)) as UNIT_OF_MEASURE,
        cast(ORDERED_QTY as NUMBER(15,2)) as ORDERED_QTY,
        cast(DELIVERED_QTY as NUMBER(15,2)) as DELIVERED_QTY,
        cast(BACK_ORDER_QTY as NUMBER(15,2)) as BACK_ORDER_QTY,
        cast(ORDER_DATE as TIMESTAMP_NTZ(9)) as ORDER_DATE,
        cast(ORDER_DT as TIMESTAMP_NTZ(9)) as ORDER_DT,
        cast(CUSTOMER_REQUEST_DATE as TIMESTAMP_NTZ(9)) as CUSTOMER_REQUEST_DATE,
        cast(CUSTOMER_REQUEST_DT as TIMESTAMP_NTZ(9)) as CUSTOMER_REQUEST_DT,
        cast(PLAN_DELIVERY_DATE as TIMESTAMP_NTZ(9)) as PLAN_DELIVERY_DATE,
        cast(PLAN_DELIVERY_DT as TIMESTAMP_NTZ(9)) as PLAN_DELIVERY_DT,
        cast(DELIVERY_DATE as TIMESTAMP_NTZ(9)) as DELIVERY_DATE,
        cast(DELIVERY_DT as TIMESTAMP_NTZ(9)) as DELIVERY_DT,
        cast(INVOICE_DATE as TIMESTAMP_NTZ(9)) as INVOICE_DATE,
        cast(INVOICE_DT as TIMESTAMP_NTZ(9)) as INVOICE_DT,
        cast(ORIGINAL_COMMIT_DATE as TIMESTAMP_NTZ(9)) as ORIGINAL_COMMIT_DATE,
        cast(ORIGINAL_COMMIT_DT as TIMESTAMP_NTZ(9)) as ORIGINAL_COMMIT_DT,
        cast(STANDARD_COST_PRICE as NUMBER(15,2)) as STANDARD_COST_PRICE,
        cast(PRICE as NUMBER(15,2)) as PRICE,
        cast(PRICE_SOURCE as VARCHAR(16777216)) as PRICE_SOURCE,
        cast(ORDER_AMOUNT as NUMBER(15,2)) as ORDER_AMOUNT,
        cast(INVOICE_AMOUNT as NUMBER(15,2)) as INVOICE_AMOUNT,
        cast(DISCOUNT_PERCENT as NUMBER(15,2)) as DISCOUNT_PERCENT,
        cast(CUSTOMER_PO_NO as VARCHAR(16777216)) as CUSTOMER_PO_NO,
        cast(REFERENCEA as VARCHAR(16777216)) as REFERENCEA,
        cast(REFERENCEB as VARCHAR(16777216)) as REFERENCEB,
        cast(SALES_REP as VARCHAR(16777216)) as SALES_REP,
        cast(DIRECT_DELIVERY as VARCHAR(16777216)) as DIRECT_DELIVERY,
        cast(PURCHASE_ORDER_NO as VARCHAR(16777216)) as PURCHASE_ORDER_NO,
        cast(AREA as VARCHAR(16777216)) as AREA,
        cast(TRANSACTION_TYPE as VARCHAR(16777216)) as TRANSACTION_TYPE,
        cast(INVOICE_STATUS as VARCHAR(16777216)) as INVOICE_STATUS,
        cast(WAREHOUSE_STATUS as VARCHAR(16777216)) as WAREHOUSE_STATUS,
        cast(CANCELLED as VARCHAR(16777216)) as CANCELLED,
        cast(CANCELLED_DATE as TIMESTAMP_NTZ(9)) as CANCELLED_DATE,
        cast(ORDER_PRIORITY as VARCHAR(16777216)) as ORDER_PRIORITY,
        cast(TAX_CODE as VARCHAR(16777216)) as TAX_CODE,
        cast(CUSTOMER_ORDER_POSITION as VARCHAR(16777216)) as CUSTOMER_ORDER_POSITION,
        cast(ROUTE as VARCHAR(16777216)) as ROUTE,
        cast(CURRENCY as VARCHAR(16777216)) as CURRENCY,
        cast(CHANNEL as VARCHAR(16777216)) as CHANNEL,
        cast(SERIAL_NO as VARCHAR(16777216)) as SERIAL_NO,
        cast(INVOICE_BY_INSTALLMENT as VARCHAR(16777216)) as INVOICE_BY_INSTALLMENT,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data