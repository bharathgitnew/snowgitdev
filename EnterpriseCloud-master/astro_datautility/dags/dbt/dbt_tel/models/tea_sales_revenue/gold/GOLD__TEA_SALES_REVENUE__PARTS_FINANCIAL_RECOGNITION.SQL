{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'PARTS_FINANCIAL_RECOGNITION',
    transient = false
) }}

WITH source_data AS (

    SELECT DISTINCT
        so_number AS sales_order_nbr,
        so_line AS sales_order_line_nbr,
        obdo_number AS outbound_delivery_order_nbr,
        do_line AS delivery_order_line_nbr,
        CONCAT(so_number, '-', so_line, '-', obdo_number, '-', do_line) AS key,
        FIRST_VALUE(cust_po_number) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY cust_po_number) AS cust_po_number,
        so_create_dt AS booking_date,
        qty AS total_order_quantity,
        do_qty AS delivery_quantity,
        order_type,
        UPPER(order_type_name) AS order_type_name,
        item AS material_number,
        material_cost,
        sales_price,
        order_amount,
        sloc,
        UPPER(sloc_desc) AS sloc_desc,
        CASE
            WHEN sloc_desc = 'DROPSHIP'
                THEN actual_goods_movement_date
            ELSE actual_goods_movement_date_ob
        END AS actual_shipment_date,
        ENDUSER_CUSTOMER_GROUP AS END_USER_CUSTOMER,
        sold_to_customer_group,
        FIRST_VALUE(actual_shipment_date) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY actual_shipment_date) AS actual_ship_date,
        FIRST_VALUE(bu_group) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY bu_group) AS bu_group,
        FIRST_VALUE(tel_model) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY tel_model) AS tel_model,
        FIRST_VALUE(swlh_model) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY swlh_model) AS swlh_model,
        FIRST_VALUE(customer_tool_id) IGNORE NULLS
            OVER (PARTITION BY key ORDER BY customer_tool_id) AS customer_tool_id,
        LISTAGG(DISTINCT invoice_number, ', ')
            WITHIN GROUP (ORDER BY invoice_number)
            OVER (PARTITION BY key) AS invoice_number,
        UPPER(reason) AS reason,
        CASE
            WHEN consumable_flag IS NULL THEN 'Repair Service'
            ELSE consumable_flag
        END AS product_type,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME
    FROM {{ source('DE_OPERATIONS', 'SALES_ORDER_WITH_REF_DATA') }}
WHERE do_qty <> 0
      AND obdo_number IS NOT NULL
      AND do_line IS NOT NULL
      AND sales_billing_document_is_canceled <> 'X'
      AND order_type NOT IN ('ZPR1', 'ZP11', 'ZSR0', 'ZS14')
      AND UPPER(SALES_CATEGORY_NAME) NOT LIKE '%NCDR%'
      AND SALES_CATEGORY NOT IN (10, 99)
      AND ENDUSER_CUSTOMER_GROUP IS NOT NULL
      AND UPPER(ENDUSER_CUSTOMER_GROUP) <> 'TEL GROUP'
),

source_data_total_do_qty AS (

    SELECT
        key,
        SUM(delivery_quantity) AS total_delivery_quantity
    FROM source_data
    GROUP BY key
),

transform_data AS (

    SELECT DISTINCT
        sales_order_nbr,
        sales_order_line_nbr,
        outbound_delivery_order_nbr,
        delivery_order_line_nbr,
        key,
        cust_po_number,
        booking_date,
        total_order_quantity,
        order_type,
        order_type_name,
        material_number,
        material_cost,
        sales_price,
        order_amount,
        sloc,
        sloc_desc,
        NULLIF(TRIM(sold_to_customer_group), '') AS sold_to_customer_group,
         NULLIF(TRIM(END_USER_CUSTOMER), '') AS END_USER_CUSTOMER,
        actual_ship_date,
        CASE
            WHEN bu_group IS NULL AND LEFT(material_number, 2) = 'BT' THEN '3DI'
            WHEN bu_group IS NULL AND LEFT(material_number, 2) IN ('P5', 'TF') THEN 'TMEA'
            ELSE bu_group
        END AS bu_group,
        tel_model,
        swlh_model,
        customer_tool_id,
        reason,
        NULLIF(invoice_number, '') AS invoice_number,
        product_type,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        '{{ invocation_id }}' AS _audit_log_id,
        SHA2('hash_me') AS _row_hash

    FROM source_data
),

final_data AS (

    SELECT
        b.sales_order_nbr,
        b.sales_order_line_nbr,
        b.outbound_delivery_order_nbr,
        b.delivery_order_line_nbr,
        a.key,
        b.cust_po_number,
        b.booking_date,
        b.total_order_quantity,
        a.total_delivery_quantity,
        b.order_type,
        b.order_type_name,
        b.material_number,
        b.material_cost,
        b.sales_price,
        b.order_amount,
        b.sloc,
        b.sloc_desc,
        b.sold_to_customer_group,
        b.end_user_customer,
        b.actual_ship_date,
        b.bu_group,
        b.tel_model,
        b.swlh_model,
        b.customer_tool_id,
        b.invoice_number,
        b.product_type,
        b.SALES_CATEGORY,
        b.SALES_CATEGORY_NAME,
        b._audit_log_id,
        b._row_hash,
        ROUND(b.sales_price * a.total_delivery_quantity, 2) AS total_deliver_amount,
        CASE
            WHEN UPPER(b.reason) = 'CANCEL' THEN 'CANCELLED'
            WHEN b.actual_ship_date <= CURRENT_DATE() THEN 'SHIPPED'
            WHEN b.actual_ship_date IS NULL THEN 'NOT SHIPPED'
        END AS current_status,
        CASE
            WHEN b.invoice_number IS NULL THEN 'No'
            ELSE 'Yes'
        END AS is_invoiced
    FROM source_data_total_do_qty a
    LEFT JOIN transform_data b
        ON a.key = b.key
),

type_data AS (

    SELECT
        CAST(_audit_log_id AS VARCHAR(128)) AS _audit_log_id,
        CAST(_row_hash AS VARCHAR(128)) AS _row_hash,
        sales_order_nbr,
        sales_order_line_nbr,
        outbound_delivery_order_nbr,
        delivery_order_line_nbr,
        key,
        cust_po_number,
        CAST(booking_date AS DATE) AS booking_date,
        CAST(total_order_quantity AS FLOAT) AS total_order_quantity,
        CAST(total_delivery_quantity AS FLOAT) AS total_delivery_quantity,
        order_type,
        order_type_name,
        material_number,
        material_cost,
        CAST(sales_price AS FLOAT) AS sales_price,
        CAST(order_amount AS FLOAT) AS order_amount,
        sloc,
        sloc_desc,
        sold_to_customer_group,
        end_user_customer,
        CAST(actual_ship_date AS DATE) AS actual_ship_date,
        bu_group,
        tel_model,
        swlh_model,
        customer_tool_id,
        invoice_number,
        product_type,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        CAST(total_deliver_amount AS FLOAT) AS total_deliver_amount,
        current_status,
        is_invoiced

    FROM final_data
)

SELECT *
FROM type_data
