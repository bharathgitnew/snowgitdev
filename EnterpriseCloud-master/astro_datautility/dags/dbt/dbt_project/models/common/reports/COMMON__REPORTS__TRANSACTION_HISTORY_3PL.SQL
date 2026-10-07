{{ config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        alias='TRANSACTION_HISTORY_3PL',
        transient=false,
        enabled=true
) }}

with MVKE as
(
    select distinct
        MVKE_MATERIAL_NUMBER
        , MATERIAL_GROUP_1
        , MATERIAL_GROUP_2
    from {{ ref('COMMON__SAPH__INVENTORY_SALES_MATERIAL') }}
),

matdoc_data as (
    select
        MATDOC.MOVEMENT_TYPE
        , MATDOC.MATDOC_DOCUMENT_TYPE
        , MATDOC.USER_NAME
        , MATDOC.NUMBER_OF_MATERIAL_DOCUMENT_MBLNR as DOCUMENT_NUMBER
        , MATDOC.ITEM_IN_MATERIAL_DOCUMENT_ZEILE as DOCUMENT_ITEM
        , MATDOC.SALES_ORDER_NUMBER as SO
        , MATDOC.ITEM_NUMBER_IN_SALES_ORDER as SO_LINE
        , MATDOC.PURCHASE_ORDER_NUMBER as PO
        , MATDOC.ITEM_NUMBER_OF_PURCHASING_DOCUMENT as PO_LINE
        , MATDOC.DELIVERY_VBELN_IM as DO_NUMBER
        , MATDOC.delivery_item as DO_LINE
        , MATDOC.BATCH_NUMBER_CHARG_SID as SAP_BATCH_NUMBER
        , MATDOC.MATERIAL_IN_RESPECT_OF_WHICH_STOCK_IS_MANAGED as MATERIAL
        , MATDOC.PLANT_WERKS as PLANT
        , MATDOC.STORAGE_LOCATION_LGORT_SID as STORAGE_LOCATION
        , MATDOC.CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID as CONSIGNMENT_CUSTOMER
        , KNA1.NAME1 as CUSTOMER_NAME
        , case when STORAGE_LOCATION_LGORT_SID = '' then KNA1.NAME1 else STORAGE_LOCATION_LGORT_SID end as SLOC_CUSTOMER_COMBINED
        , MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED as ENTRY_DATE
        , MATDOC.TIME_OF_ENTRY as ENTRY_TIME
        , convert_timezone('Etc/UCT', 'US/Central', to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS')) as CST_TIME_STAMP
        , to_date(convert_timezone('Etc/UCT', 'US/Central', to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS'))) as CST_ENTRY_DATE
        , to_time(convert_timezone('Etc/UCT', 'US/Central', to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS'))) as CST_ENTRY_TIME
        , to_date(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED,'YYYYMMDD') as UTC_ENTRY_DATE
        , to_time(MATDOC.TIME_OF_ENTRY,'HH24MISS') as UTC_ENTRY_TIME
        , to_timestamp(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED||MATDOC.TIME_OF_ENTRY,'YYYYMMDDHH24MISS') as UTC_TIMESTAMP
        , MATDOC.STOCK_QUANTITY as TRANSACTION_QTY
        , MATDOC.AMOUNT_IN_LOCAL_CURRENCY_WITH_SIGN_OF_STOCK_QUANTITY as TRANSACTION_VALUE
        , MVKE.MATERIAL_GROUP_1 as PRODUCT_CODE
        , MATDOC.LOCAL_ABC as LOCAL_ABC
        , MATDOC.SPECIFIC_CUSTOMER_ABC as INTEL_ABC
        , case when MVKE.MATERIAL_GROUP_2 = '0' then 'Non-Consumable' else 'Consumable' end  as CONSUMABLE
        , case when substr(MATDOC.STORAGE_LOCATION_LGORT_SID ,3,1) = '3' then 'Intel' else 'Non-Intel' end as INTEL
        , MATDOC.MATDOC_PROFIT_CENTER as PROFIT_CENTER
        , MATDOC.COST_CENTER
    from {{ ref('COMMON__SAPH__INVENTORY_PLANT_MATERIAL') }} MATDOC
    join MVKE on MVKE.MVKE_MATERIAL_NUMBER = MATDOC.MATERIAL_IN_RESPECT_OF_WHICH_STOCK_IS_MANAGED
    left join ODS.SAPAPI.ZCDV_T_CMTU020_KNA1 KNA1 on KNA1.KUNNR = MATDOC.CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID
    where MATDOC.PLANT in ('3200','3300','3400')
),

ship_conf as
(
	select
    	document_number
        , line_number
        , max(house_airway_bill_number) as HAWB
        , max(tracking_number) as tracking_number
        , max(service_level) as service_level
        , max(shipment_carrier) as FORWARDER
    from {{ ref('COMMON__THREEPL__TPL_SHIPMENT_CONFIRMATION') }}
    group by document_number, line_number
),

tpl_data as
(
	select
    	ship_line.document_number
        , lpad(ship_line.line_number,6,'0') as LINE_NUMBER
        , ship_line.tpl_order_number
        , ship_line.storage_location
        , ship_line.quantity
        , ship_line.tracking_number
        , ship_status.tpl_order_number as ship_status_3PL_order_no
        , ship_status.current_status
        , ship_status.edi_generated_dt
        , ship_status.order_created_dt
        , ship_status.order_accepted_dt
        , ship_status.ready_for_shipment_dt
        , ship_status.order_delivered_dt
        , ship_req.shipment_route
        , ship_req.header_text
        , ship_conf.HAWB
        , ship_conf.tracking_number as ship_conf_tracking_number
        , ship_conf.service_level
        , ship_conf.Forwarder

    from {{ ref('COMMON__THREEPL__TPL_SHIPMENT_LINE_DETAIL') }} ship_line
    join {{ ref('COMMON__THREEPL__TPL_SHIPMENT_STATUS') }}  ship_status on ship_line.document_number = ship_status.document_number and ship_line.line_number = ship_status.line_number
    join {{ ref('COMMON__THREEPL__TPL_SHIP_REQUEST') }} ship_req on ship_line.document_number = ship_req.document_number and ship_line.line_number = ship_req.line_number
    left join ship_conf on ship_line.document_number = ship_conf.document_number and ship_line.line_number = ship_conf.line_number
),

cost_center as (
select
COST_CENTER_CODE,
SEGMENT_CODE as SECURITY_SEGMENT,
DEPARTMENT_CODE as SECURITY_DEPARTMENT,
OFFICE_CODE as SECURITY_OFFICE
from {{ ref('ODS__FILE__COST_CENTER') }}),

profit_center as (
    select
        PROFIT_CENTER_CODE,
        PROFIT_CENTER_NAME,
        SEGMENT_CODE,
        SEGMENT,
        DEPARTMENT_CODE,
        DEPARTMENT,
        OFFICE_CODE,
        OFFICE
    from {{ ref('ODS__FILE__PROFIT_CENTER') }}
),

source_data as
(
	select
    	matdoc.MOVEMENT_TYPE
        , matdoc.MATDOC_DOCUMENT_TYPE
        , matdoc.USER_NAME
        , matdoc.DOCUMENT_NUMBER
        , matdoc.DOCUMENT_ITEM
        , matdoc.SO
        , matdoc.SO_LINE
        , matdoc.PO
        , matdoc.PO_LINE
        , matdoc.DO_NUMBER
        , matdoc.DO_LINE
        , matdoc.SAP_BATCH_NUMBER
        , matdoc.MATERIAL
        , matdoc.PLANT
        , matdoc.STORAGE_LOCATION
        , matdoc.CONSIGNMENT_CUSTOMER
        , matdoc.CUSTOMER_NAME
        , matdoc.SLOC_CUSTOMER_COMBINED
        , matdoc.ENTRY_DATE
        , matdoc.ENTRY_TIME
        , matdoc.CST_TIME_STAMP
        , matdoc.CST_ENTRY_DATE
        , matdoc.CST_ENTRY_TIME
        , matdoc.UTC_ENTRY_DATE
        , matdoc.UTC_ENTRY_TIME
        , matdoc.UTC_TIMESTAMP
        , matdoc.TRANSACTION_QTY
        , matdoc.TRANSACTION_VALUE
        , matdoc.PRODUCT_CODE
        , matdoc.LOCAL_ABC
        , matdoc.INTEL_ABC
        , matdoc.CONSUMABLE
        , matdoc.INTEL
        , tpl.tpl_order_number
        , tpl.storage_location as tpl_storage_location
        , tpl.quantity
        , tpl.tracking_number
        , tpl.ship_status_3PL_order_no
        , tpl.current_status
        , tpl.edi_generated_dt
        , tpl.order_created_dt
        , tpl.order_accepted_dt
        , tpl.ready_for_shipment_dt
        , tpl.order_delivered_dt
        , tpl.shipment_route
        , tpl.header_text
        , tpl.HAWB
        , tpl.ship_conf_tracking_number
        , tpl.service_level
        , tpl.Forwarder
        , matdoc.PROFIT_CENTER
        , matdoc.COST_CENTER
        , '<ALL>' as SECURITY_SEGMENT
        , '<ALL>' as SECURITY_DEPARTMENT
        , '<ALL>' as SECURITY_OFFICE
    	from matdoc_data matdoc
    	left join tpl_data tpl on tpl.document_number = matdoc.DO_NUMBER and tpl.LINE_NUMBER = matdoc.DO_LINE
        left outer join cost_center on matdoc.COST_CENTER=cost_center.COST_CENTER_CODE
        left outer join profit_center on matdoc.PROFIT_CENTER=profit_center.PROFIT_CENTER_CODE
),

transform_data as
(
	select distinct
		MOVEMENT_TYPE
        ,CASE
        	WHEN MOVEMENT_TYPE = '101' THEN 'Goods receipt for purchase order or order'
            WHEN MOVEMENT_TYPE = '601' THEN 'Goods issue for delivery (Shipping)'
            WHEN MOVEMENT_TYPE = '641' THEN 'Goods issue for a stock transport order (Shipping)'
            WHEN MOVEMENT_TYPE = '647' THEN 'Goods issue for a stock transport order in one step (Shipping)'
            WHEN MOVEMENT_TYPE = '631' THEN 'Transfer posting unrestricted use - customer consignment stock (Shipping)'
            WHEN MOVEMENT_TYPE = '161' THEN 'Return for purchase order'
            WHEN MOVEMENT_TYPE = '541' THEN 'Transfer posting unrestricted-use stock - stock of material provided to vendor'
            WHEN MOVEMENT_TYPE = '653' THEN 'Returns from customer (Shipping) to unrestricted-use stock'
            WHEN MOVEMENT_TYPE = '701' THEN 'Inventory differences in unrestricted-use stock (MM-IM)'
            WHEN MOVEMENT_TYPE = 'Z63' THEN 'Consignment Issue deliveries'
        END AS MOVEMENT_TYPE_DESC

        , MATDOC_DOCUMENT_TYPE
        , USER_NAME
        , DOCUMENT_NUMBER
        , DOCUMENT_ITEM
        , SO
        , SO_LINE
        , PO
        , PO_LINE
        , DO_NUMBER
        , DO_LINE
        , SAP_BATCH_NUMBER
        , MATERIAL
        , PLANT
        , STORAGE_LOCATION
        , CONSIGNMENT_CUSTOMER
        , CUSTOMER_NAME
        , SLOC_CUSTOMER_COMBINED
        , ENTRY_DATE
        , ENTRY_TIME
        , CST_TIME_STAMP
        , CST_ENTRY_DATE
        , CST_ENTRY_TIME
        , UTC_ENTRY_DATE
        , UTC_ENTRY_TIME
        , UTC_TIMESTAMP
        , TRANSACTION_QTY
        , TRANSACTION_VALUE
        , PRODUCT_CODE
        , LOCAL_ABC
        , INTEL_ABC
        , CONSUMABLE
        , INTEL
		, tpl_order_number
        , tpl_storage_location
        , quantity
        , tracking_number
        , ship_status_3PL_order_no
        , current_status
        , edi_generated_dt
        , order_created_dt
        , order_accepted_dt
        , ready_for_shipment_dt
        , order_delivered_dt
        , shipment_route
        , header_text
        , HAWB
        , ship_conf_tracking_number
        , service_level
        , Forwarder
        , PROFIT_CENTER
        , COST_CENTER
        , SECURITY_SEGMENT
        , SECURITY_DEPARTMENT
        , SECURITY_OFFICE
        , '{{ invocation_id }}' AS AUDIT_LOG_ID
    from source_data
),

type_data as
(
    select
        CAST(MOVEMENT_TYPE as VARCHAR(16777216)) as MOVEMENT_TYPE,
        CAST(MOVEMENT_TYPE_DESC as VARCHAR(16777216)) as MOVEMENT_TYPE_DESC,
        CAST(MATDOC_DOCUMENT_TYPE as VARCHAR(16777216)) as MATDOC_DOCUMENT_TYPE,
        CAST(USER_NAME as VARCHAR(16777216)) as USER_NAME,
        CAST(DOCUMENT_NUMBER as VARCHAR(16777216)) as DOCUMENT_NUMBER,
        CAST(DOCUMENT_ITEM as VARCHAR(16777216)) as DOCUMENT_ITEM,
        CAST(SO as VARCHAR(16777216)) as SO,
        CAST(SO_LINE as VARCHAR(16777216)) as SO_LINE,
        CAST(PO as VARCHAR(16777216)) as PO,
        CAST(PO_LINE as VARCHAR(16777216)) as PO_LINE,
        CAST(DO_NUMBER as VARCHAR(16777216)) as DO_NUMBER,
        CAST(DO_LINE as VARCHAR(16777216)) as DO_LINE,
        CAST(SAP_BATCH_NUMBER as VARCHAR(16777216)) as SAP_BATCH_NUMBER,
        CAST(MATERIAL as VARCHAR(16777216)) as MATERIAL,
        CAST(PLANT as VARCHAR(16777216)) as PLANT,
        CAST(STORAGE_LOCATION as VARCHAR(16777216)) as STORAGE_LOCATION,
        CAST(CONSIGNMENT_CUSTOMER as VARCHAR(16777216)) as CONSIGNMENT_CUSTOMER,
        CAST(CUSTOMER_NAME as VARCHAR(16777216)) as CUSTOMER_NAME,
        CAST(SLOC_CUSTOMER_COMBINED as VARCHAR(16777216)) as SLOC_CUSTOMER_COMBINED,
        CAST(ENTRY_DATE as VARCHAR(16777216)) as ENTRY_DATE,
        CAST(ENTRY_TIME as VARCHAR(16777216)) as ENTRY_TIME,
        CAST(CST_TIME_STAMP as TIMESTAMP_NTZ(9)) as CST_TIME_STAMP,
        CAST(CST_ENTRY_DATE as DATE) as CST_ENTRY_DATE,
        CAST(CST_ENTRY_TIME as TIME(9)) as CST_ENTRY_TIME,
        CAST(UTC_ENTRY_DATE as DATE) as UTC_ENTRY_DATE,
        CAST(UTC_ENTRY_TIME as TIME(9)) as UTC_ENTRY_TIME,
        CAST(UTC_TIMESTAMP as TIMESTAMP_NTZ(9)) as UTC_TIMESTAMP,
        CAST(TRANSACTION_QTY as VARCHAR(16777216)) as TRANSACTION_QTY,
        CAST(TRANSACTION_VALUE as VARCHAR(16777216)) as TRANSACTION_VALUE,
        CAST(PRODUCT_CODE as VARCHAR(16777216)) as PRODUCT_CODE,
        CAST(LOCAL_ABC as VARCHAR(16777216)) as LOCAL_ABC,
        CAST(INTEL_ABC as VARCHAR(16777216)) as INTEL_ABC,
        CAST(CONSUMABLE as VARCHAR(14)) as CONSUMABLE,
        CAST(INTEL as VARCHAR(9)) as INTEL,
        CAST(TPL_ORDER_NUMBER as VARCHAR(16777216)) as TPL_ORDER_NUMBER,
        CAST(TPL_STORAGE_LOCATION as VARCHAR(16777216)) as TPL_STORAGE_LOCATION,
        CAST(QUANTITY as NUMBER(38,0)) as QUANTITY,
        CAST(TRACKING_NUMBER as VARCHAR(16777216)) as TRACKING_NUMBER,
        CAST(SHIP_STATUS_3PL_ORDER_NO as VARCHAR(16777216)) as SHIP_STATUS_3PL_ORDER_NO,
        CAST(CURRENT_STATUS as VARCHAR(16777216)) as CURRENT_STATUS,
        CAST(EDI_GENERATED_DT as TIMESTAMP_NTZ(9)) as EDI_GENERATED_DT,
        CAST(ORDER_CREATED_DT as TIMESTAMP_NTZ(9)) as ORDER_CREATED_DT,
        CAST(ORDER_ACCEPTED_DT as TIMESTAMP_NTZ(9)) as ORDER_ACCEPTED_DT,
        CAST(READY_FOR_SHIPMENT_DT as TIMESTAMP_NTZ(9)) as READY_FOR_SHIPMENT_DT,
        CAST(ORDER_DELIVERED_DT as TIMESTAMP_NTZ(9)) as ORDER_DELIVERED_DT,
        CAST(SHIPMENT_ROUTE as VARCHAR(16777216)) as SHIPMENT_ROUTE,
        CAST(HEADER_TEXT as VARCHAR(16777216)) as HEADER_TEXT,
        CAST(HAWB as VARCHAR(16777216)) as HAWB,
        CAST(SHIP_CONF_TRACKING_NUMBER as VARCHAR(16777216)) as SHIP_CONF_TRACKING_NUMBER,
        CAST(SERVICE_LEVEL as VARCHAR(16777216)) as SERVICE_LEVEL,
        CAST(FORWARDER as VARCHAR(16777216)) as FORWARDER,
        CAST(PROFIT_CENTER as VARCHAR(16777216)) as PROFIT_CENTER,
        CAST(COST_CENTER as VARCHAR(16777216)) as COST_CENTER,
        CAST(SECURITY_SEGMENT as VARCHAR(16777216)) as SECURITY_SEGMENT,
        CAST(SECURITY_DEPARTMENT as VARCHAR(16777216)) as SECURITY_DEPARTMENT,
        CAST(SECURITY_OFFICE as VARCHAR(16777216)) as SECURITY_OFFICE,
        CAST(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID
    from transform_data
)

select * from type_data