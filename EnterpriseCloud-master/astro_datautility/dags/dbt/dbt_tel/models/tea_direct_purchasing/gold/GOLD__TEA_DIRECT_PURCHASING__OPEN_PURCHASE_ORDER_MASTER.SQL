{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='OPEN_PURCHASE_ORDER_MASTER',
        transient=false
) }}

with PO_ORDER_MASTER as (
SELECT 
    EMPLOYEE_NUMBER,
    PO_TYPE,
    BU,
    VENDOR,
    VENDOR_NAME,
    COLLECTIVE_NUMBER,
    PO_NUMBER,
    LINE_ITEM,
    CONFIRMATION_SEQ,
    PRIORITY,
    PO_DATE,
    PART_NUMBER,
    DESCRIPTION,
    PURCHASE_QTY,
    OPEN_QTY,
    QTY_RECEIVED,
    SLOC,
    CONFIRMED_QTY,
    REQUESTED_DELIVERY_DATE,
    CONFIRMED_DEL_DATE,
    TEL_UPDATE,
    SO_NUMBER,
    TEA_IBDO,
    DO_ITEM_NUMBER,
    SHIP_DATE,
    HAWB,
    MAWB,
    OUR_REFERENCE,
    CUSTOMER,
    CUSTOMER_REFERENCE,
    END_USER,
    NET_PRICE,
    LINE_TOTAL,
    CURRENCY,
    LEAD_TIME,
    LT_DELIVERY_DATE,
    LOCAL_ABC,
    CUSTOMER_SPECIFIC_ABC,
    TEA_OH,
    THREE_MONTH_USAGE,
    AVG_MONTHLY_USAGE,
    AVG_DAILY_USAGE,
    THREE_MONTH_DOI,
    SHIPPED,
    STATUS,
    INTEL,
    FAKENORMAL,
    HTS,
    PURCHASE_REQUISITION_NUMBER,
    RECEIPT_DATE,
    RESPONSE_TIME,
    INVOICE_QTY,
    INVOICE_AMT,
    PIR,
    DELIVERY_SCHEDULE_LINE_COUNTER,
    CONFIRMED_CUSTOMS_CLEARANCE_DATE,
    DELIVERY_COMPLETED_INDICATOR
FROM {{ ref('GOLD__TEA_DIRECT_PURCHASING__PURCHASE_ORDER_MASTER') }} 
where   PURCHASING_ORGANIZATION_EKORG between '3100' and '3400' and
        left(PO_NUMBER, 2) not in ('PO', 'EP') and
        PO_TYPE not in ('ZP25', 'ZP26','ZP27') and
        CONFIRMED_QTY > 0 and
        OPEN_QTY > 0 and
        SUPPLIER_CONFIRMATION_DELETION_INDICATOR != 'X' and
        EKPO_DELETION_INDICATOR_IN_PURCHASING_DOCUMENT != 'L'
),
received_quantities as ( 
select distinct 
        PO_NUMBER,
        LINE_ITEM,
        QTY_RECEIVED
    from PO_ORDER_MASTER
),
--Get all the confirmed Quanities 
Unique_record as (
select distinct 
        EKKO_PURCHASING_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS,
        PURCHASE_ORDER_QUANTITY,
        QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        ROW_NUMBER() over (partition by EKKO_PURCHASING_DOCUMENT_NUMBER,ITEM_NUMBER_OF_PURCHASING_DOCUMENT order by
                           EKKO_PURCHASING_DOCUMENT_NUMBER,ITEM_NUMBER_OF_PURCHASING_DOCUMENT,SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS ) as check_cnt
        from {{ ref('SILVER__TEA_DIRECT_PURCHASING__PURCHASE_ORDER_SUPPLIER_CONFIRMATION') }} 
         where confirmation_category = 'AB'
),
Non_confirmed as (
select distinct PO_NUMBER,
                LINE_item 
            from PO_ORDER_MASTER as posc
  left join Unique_record as ekes_ab
           on  ekes_ab.EKKO_PURCHASING_DOCUMENT_NUMBER =  posc.PO_NUMBER
         and ekes_ab.ITEM_NUMBER_OF_PURCHASING_DOCUMENT =  posc.LINE_item
  where ekes_ab.EKKO_PURCHASING_DOCUMENT_NUMBER is null
),
--Derive the pending Quanities  
Pending_quantity as (
    select distinct 
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER,
        posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT,
        posc.SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS,
        posc.PURCHASE_ORDER_QUANTITY,
        zeroifnull(GR.QTY_RECEIVED) as GR,
        posc.PURCHASE_ORDER_QUANTITY - GR as TOTAL_OPEN,
        posc.QUANTITY_AS_PER_SUPPLIER_CONFIRMATION,
        SUM( posc.QUANTITY_AS_PER_SUPPLIER_CONFIRMATION ) OVER ( PARTITION BY 
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER,posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT     ORDER BY
         posc.EKKO_PURCHASING_DOCUMENT_NUMBER,posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT,posc.SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS
         ASC ROWS BETWEEN UNBOUNDED PRECEDING  AND CURRENT ROW ) as TOTAL_NEED_QTY,
      sum( posc.QUANTITY_AS_PER_SUPPLIER_CONFIRMATION) OVER ( PARTITION BY 
        posc.EKKO_PURCHASING_DOCUMENT_NUMBER,posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT ) as OVERALL_NEED_QTY,
  case when OVERALL_NEED_QTY = posc.PURCHASE_ORDER_QUANTITY 
--When the Total Commited Quanities = total Purchase Quanities 
      then 
-- Check the Comitted Quanities are above Goods Received 
     (case when TOTAL_NEED_QTY < GR then  
--Assign the Purchase Quanities 
      ( case when   TOTAL_NEED_QTY  > posc.PURCHASE_ORDER_QUANTITY then posc.PURCHASE_ORDER_QUANTITY else 0 end ) 
-- For the incompleted Comitted Quanities derive the OPEN Item           
    else( case when TOTAL_NEED_QTY - GR > QUANTITY_AS_PER_SUPPLIER_CONFIRMATION then QUANTITY_AS_PER_SUPPLIER_CONFIRMATION
                      else TOTAL_NEED_QTY - GR end )   end) 
    -- else TOTAL_OPEN end as open_qty
    when OVERALL_NEED_QTY <> posc.PURCHASE_ORDER_QUANTITY and check_cnt = 1 then TOTAL_OPEN end as open_qty
  from Unique_record as posc
  left join  received_quantities  as gr on 
          GR.PO_NUMBER = posc.EKKO_PURCHASING_DOCUMENT_NUMBER and  GR.LINE_ITEM = posc.ITEM_NUMBER_OF_PURCHASING_DOCUMENT
),
source_data as (
select 
    posc.EMPLOYEE_NUMBER,
    posc.PO_TYPE,
    posc.BU,
    posc.VENDOR,
    posc.VENDOR_NAME,
    posc.COLLECTIVE_NUMBER,
    posc.PO_NUMBER,
    posc.LINE_ITEM,
    posc.CONFIRMATION_SEQ,
    posc.PRIORITY,
    posc.PO_DATE,
    posc.PART_NUMBER,
    posc.DESCRIPTION,
    posc.PURCHASE_QTY,
    posc.OPEN_QTY,
    posc.QTY_RECEIVED,
    posc.SLOC,
    posc.CONFIRMED_QTY,
    CASE when ekes_ab.EKKO_PURCHASING_DOCUMENT_NUMBER is null and Nposc.PO_NUMBER is null then 0
    when  ekes_ab.EKKO_PURCHASING_DOCUMENT_NUMBER is null and Nposc.PO_NUMBER is not null  then POSC.OPEN_QTY
    else zeroifnull(ekes_ab.open_qty) end AS OPEN_ITEM,
    posc.REQUESTED_DELIVERY_DATE,
    posc.CONFIRMED_DEL_DATE,
    posc.TEL_UPDATE,
    posc.SO_NUMBER,
    posc.TEA_IBDO,
    posc.DO_ITEM_NUMBER,
    posc.SHIP_DATE,
    posc.HAWB,
    posc.MAWB,
    posc.OUR_REFERENCE,
    posc.CUSTOMER,
    posc.CUSTOMER_REFERENCE,
    posc.END_USER,
    posc.NET_PRICE,
    posc.LINE_TOTAL,
    posc.CURRENCY,
    posc.LEAD_TIME,
    posc.LT_DELIVERY_DATE,
    posc.LOCAL_ABC,
    posc.CUSTOMER_SPECIFIC_ABC,
    posc.TEA_OH,
    posc.THREE_MONTH_USAGE,
    posc.AVG_MONTHLY_USAGE,
    posc.AVG_DAILY_USAGE,
    posc.THREE_MONTH_DOI,
    posc.SHIPPED,
    posc.STATUS,
    posc.INTEL,
    posc.FAKENORMAL,
    posc.HTS,
    posc.PURCHASE_REQUISITION_NUMBER,
    posc.RECEIPT_DATE,
    posc.RESPONSE_TIME,
    posc.INVOICE_QTY,
    posc.INVOICE_AMT,
    posc.PIR,
    posc.DELIVERY_SCHEDULE_LINE_COUNTER,
    posc.CONFIRMED_CUSTOMS_CLEARANCE_DATE,
    posc.DELIVERY_COMPLETED_INDICATOR
from PO_ORDER_MASTER as posc
left join Non_confirmed as Nposc 
on   Nposc.PO_NUMBER = posc.PO_NUMBER
 and  Nposc.LINE_item = posc.LINE_item
left join Pending_quantity as ekes_ab
         on  ekes_ab.EKKO_PURCHASING_DOCUMENT_NUMBER =  posc.PO_NUMBER
         and ekes_ab.ITEM_NUMBER_OF_PURCHASING_DOCUMENT =  posc.LINE_item
         and ekes_ab.SEQUENTIAL_NUMBER_OF_SUPPLIER_CONFIRMATION_ETENS =  posc.CONFIRMATION_SEQ        
  ),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        EMPLOYEE_NUMBER,
        PO_TYPE,
        BU,
        VENDOR,
        VENDOR_NAME,
        COLLECTIVE_NUMBER,
        PO_NUMBER,
        LINE_ITEM,
        CONFIRMATION_SEQ,
        PRIORITY,
        PO_DATE,
        PART_NUMBER,
        DESCRIPTION,
        PURCHASE_QTY,
        OPEN_QTY,
        QTY_RECEIVED,
        SLOC,
        CONFIRMED_QTY,
        OPEN_ITEM,
        REQUESTED_DELIVERY_DATE,
        CONFIRMED_DEL_DATE,
        TEL_UPDATE,
        SO_NUMBER,
        TEA_IBDO,
        DO_ITEM_NUMBER,
        SHIP_DATE,
        HAWB,
        MAWB,
        OUR_REFERENCE,
        CUSTOMER,
        CUSTOMER_REFERENCE,
        END_USER,
        NET_PRICE,
        LINE_TOTAL,
        CURRENCY,
        LEAD_TIME,
        LT_DELIVERY_DATE,
        LOCAL_ABC,
        CUSTOMER_SPECIFIC_ABC,
        TEA_OH,
        THREE_MONTH_USAGE,
        AVG_MONTHLY_USAGE,
        AVG_DAILY_USAGE,
        THREE_MONTH_DOI,
        SHIPPED,
        STATUS,
        INTEL,
        FAKENORMAL,
        HTS,
        PURCHASE_REQUISITION_NUMBER,
        RECEIPT_DATE,
        RESPONSE_TIME,
        INVOICE_QTY,
        INVOICE_AMT,
        PIR,
        DELIVERY_SCHEDULE_LINE_COUNTER,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        DELIVERY_COMPLETED_INDICATOR
    FROM source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        EMPLOYEE_NUMBER,
        PO_TYPE,
        BU,
        VENDOR,
        VENDOR_NAME,
        COLLECTIVE_NUMBER,
        PO_NUMBER,
        LINE_ITEM,
        CONFIRMATION_SEQ,
        PRIORITY,
        PO_DATE,
        PART_NUMBER,
        DESCRIPTION,
        PURCHASE_QTY,
        cast(OPEN_QTY as VARCHAR(16777216)) as OPEN_QTY,
        cast(QTY_RECEIVED as VARCHAR(16777216)) as QTY_RECEIVED,
        SLOC,
        CONFIRMED_QTY,
        OPEN_ITEM,
        REQUESTED_DELIVERY_DATE,
        CONFIRMED_DEL_DATE,
        TEL_UPDATE,
        SO_NUMBER,
        TEA_IBDO,
        DO_ITEM_NUMBER,
        SHIP_DATE,
        HAWB,
        MAWB,
        OUR_REFERENCE,
        CUSTOMER,
        CUSTOMER_REFERENCE,
        END_USER,
        NET_PRICE,
        LINE_TOTAL,
        CURRENCY,
        cast(LEAD_TIME as VARCHAR(16777216)) as LEAD_TIME,
        LT_DELIVERY_DATE,
        LOCAL_ABC,
        CUSTOMER_SPECIFIC_ABC,
        cast(TEA_OH as VARCHAR(16777216)) as TEA_OH,
        cast(THREE_MONTH_USAGE as VARCHAR(16777216)) as THREE_MONTH_USAGE,
        cast(AVG_MONTHLY_USAGE as VARCHAR(16777216)) as AVG_MONTHLY_USAGE,
        cast(AVG_DAILY_USAGE as VARCHAR(16777216)) as AVG_DAILY_USAGE,
        cast(THREE_MONTH_DOI as VARCHAR(16777216)) as THREE_MONTH_DOI,
        SHIPPED,
        STATUS,
        INTEL,
        FAKENORMAL,
        HTS,
        PURCHASE_REQUISITION_NUMBER,
        RECEIPT_DATE,
        cast(RESPONSE_TIME as VARCHAR(16777216)) as RESPONSE_TIME,
        cast(INVOICE_QTY as VARCHAR(16777216)) as INVOICE_QTY,
        cast(INVOICE_AMT as VARCHAR(16777216)) as INVOICE_AMT,
        PIR,
        DELIVERY_SCHEDULE_LINE_COUNTER,
        CONFIRMED_CUSTOMS_CLEARANCE_DATE,
        DELIVERY_COMPLETED_INDICATOR
    from transform_data
)

select * from type_data