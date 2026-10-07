{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER'
) }}




with sales_data as
(
    select
        item
        ,to_char(material_order_date,'yyyy-mm') as period
        ,sold_to_bp
        ,case when upper(delivery_type) = 'TO WAREHOUSE' then ordered_qty*-1 else ordered_qty end as ordered_qty
    from {{ ref('SILVER__TEA_INTEL_SMS__SERVICEORDER') }}
    where left(service_order_no,3) not in ('IPO','FCN','FAC','EVL','MOD')
    and cancelled_date is null
    and ITEM between 'CS' and 'TZ'

    union all
    select
        item
        ,to_char(order_date,'yyyy-mm') as period
        ,soldto_bp
        ,ordered_qty
    from {{ ref('SILVER__TEA_INTEL_SMS__SALESORDER') }}
    where cancelled != 'Yes'
    and ITEM between 'CS' and 'TZ'
),

source_data as
(
    select
        item
        ,period
        ,sold_to_bp
        ,sum(ordered_qty) as qty
    from sales_data
    group by
        item
        ,period
        ,sold_to_bp
),

	transform_data as
(
    select 
    	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
    	ITEM,
        PERIOD,
        SOLD_TO_BP,
        QTY
     from source_data
		
		),
		
		type_data as
		(
		select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH, 
        ITEM,
        PERIOD,
        SOLD_TO_BP,
        CAST(QTY AS NUMBER(31,5) ) AS QTY
        from transform_data
)

select * from type_data