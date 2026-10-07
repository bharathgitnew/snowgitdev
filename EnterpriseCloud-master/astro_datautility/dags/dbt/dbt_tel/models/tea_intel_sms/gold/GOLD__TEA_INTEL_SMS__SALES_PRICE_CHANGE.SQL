{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'SALES_PRICE_CHANGE'
) }}

WITH sales_order_billing_line AS (

    SELECT
        *
    FROM
        {{ ref('SILVER__TEA_INTEL_SMS__SALES_ORDER_BILLING_LINE') }}
),
sales_order_delivery_line AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TEA_INTEL_SMS__SALES_ORDER_DELIVERY_LINE') }}
),
consignment_transaction AS (
    SELECT
        *
    FROM
        {{ ref('SILVER__TEA_INTEL_SMS__CONSIGNMENT_TRANSACTION') }}
),
business_partners_general_data AS(
    SELECT
        *
    FROM
        {{ ref('SILVER__TEA_INTEL_SMS__BUSINESS_PARTNERS_GENERAL_DATA') }}
), source_data AS (
    SELECT
        bl.disposition,
        bl.change_comment AS change_comment_so,
        ct.transaction_type AS customer_trans_type,
        ct.transaction_reason AS customer_trans_reason,
        bl.transaction_id,
        bl.transaction_id_item AS transaction_id_item,
        bl.ref_transaction_id,
        bl.ref_transaction_id_item,
        bl.vbak_sales_document_type || ':' || dl.sales_doc_type_desc AS sales_document_type,
        bl.vbak_sales_document AS sales_document,
        bl.sales_document_item_posnr AS sales_document_item,
        bl.vbak_sales_organization AS sales_organization,
        bl.vbak_sold_to_party AS sold_to_party,
        bl.special_stock_number_sonum AS special_stock_partner,
        bp.name_1_of_organization AS special_Stock_Partner_Name,
        bl.customer_reference,
        bl.customer_reference_date,
        bl.po_start_date,
        bl.po_end_date,
        bl.vbap_material_number AS material_number,
        bl.material_number_used_by_customer,
        bl.vbap_short_text_for_sales_order_item AS customer_item_desc,
        bl.cumulative_order_quantity_in_sales_units AS qty,
        bl.vbap_sales_unit AS sales_unit,
        bl.tool_serial_no,
        bl.storage_location_vbap AS storage_location,
        bl.vbap_net_price AS unit_price,
        bl.net_value_of_the_order_item_in_document_currency AS net_value,
        bl.vbak_sd_document_currency AS currency,
        bl.vbrp_bill_cost_in_document_currency AS cost,
        dl.lips_delivery AS delivery_order_no,
        dl.delivery_item_posnr AS delivery_item_posnr,
        dl.actual_quantity_delivered AS delivery_qty,
        dl.actual_quantity_delivered AS gi_qty,
        bl.actual_goods_movement_date AS gi_date,
        bl.sales_billing_document AS billing_document,
        bl.vbrp_bill_billing_item AS billing_item,
        bl.vbrp_bill_actual_billed_quantity AS billing_qty
    FROM
        sales_order_billing_line AS bl
        LEFT JOIN sales_order_delivery_line AS dl
        ON bl.sales_order_number = dl.sales_order_number
        AND bl.item_number_in_sales_order = dl.item_number_in_sales_order
        AND bl.likp_delivery = dl.likp_delivery
        AND bl.delivery_item_posnr = dl.delivery_item_posnr
        LEFT JOIN (
            SELECT
                customer_transaction_id,
                transaction_type,
                transaction_reason
            FROM
                (
                    SELECT
                        customer_transaction_id,
                        transaction_type,
                        transaction_reason,
                        ROW_NUMBER() over (
                            PARTITION BY customer_transaction_id
                            ORDER BY
                                date_received DESC nulls last
                        ) AS rn
                    FROM
                        consignment_transaction
                )
            WHERE
                rn = 1
        ) AS ct
        ON bl.transaction_id = ct.customer_transaction_id
        LEFT JOIN business_partners_general_data bp
        ON bl.special_stock_number_sonum = bp.business_partner_number
    WHERE
        bl.transaction_id IS NOT NULL
        AND bl.transaction_id <> ''
),
transform_data AS(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        disposition,
        change_comment_so,
        customer_trans_type,
        customer_trans_reason,
        transaction_id,
        transaction_id_item,
        ref_transaction_id,
        ref_transaction_id_item,
        sales_document_type,
        sales_document,
        sales_document_item,
        sales_organization,
        sold_to_party,
        special_stock_partner,
        special_Stock_Partner_Name,
        customer_reference,
        TRY_TO_DATE(
            customer_reference_date :: VARCHAR,
            'YYYYMMDD'
        ) AS customer_reference_date,
        TRY_TO_DATE(
            po_start_date :: VARCHAR,
            'YYYYMMDD'
        ) AS po_start_date,
        TRY_TO_DATE(
            po_end_date :: VARCHAR,
            'YYYYMMDD'
        ) AS po_end_date,
        material_number,
        material_number_used_by_customer,
        customer_item_desc,
        qty :: NUMBER(
            38,
            2
        ) AS qty,
        sales_unit,
        tool_serial_no,
        storage_location,
        unit_price,
        net_value,
        currency,
        cost,
        delivery_order_no,
        delivery_item_posnr,
        delivery_qty :: NUMBER(
            38,
            2
        ) AS delivery_qty,
        gi_qty :: NUMBER(
            38,
            2
        ) AS gi_qty,
        TRY_TO_DATE(
            gi_date :: VARCHAR,
            'YYYYMMDD'
        ) AS gi_date,
        billing_document,
        billing_item,
        billing_qty :: NUMBER(
            38,
            2
        ) AS billing_qty
    FROM
        source_data
),
type_data AS(
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        disposition,
        change_comment_so,
        customer_trans_type,
        customer_trans_reason,
        transaction_id,
        transaction_id_item,
        ref_transaction_id,
        ref_transaction_id_item,
        sales_document_type,
        sales_document,
        sales_document_item,
        sales_organization,
        sold_to_party,
        special_stock_partner,
        special_Stock_Partner_Name,
        customer_reference,
        CAST(
            customer_reference_date AS DATE
        ) AS customer_reference_date,
        CAST(
            po_start_date AS DATE
        ) AS po_start_date,
        CAST(
            po_end_date AS DATE
        ) AS po_end_date,
        material_number,
        material_number_used_by_customer,
        customer_item_desc,
        CAST(qty AS NUMBER(38, 2)) AS qty,
        sales_unit,
        tool_serial_no,
        storage_location,
        CAST(unit_price AS NUMBER(38, 2)) AS unit_price,
        CAST(net_value AS NUMBER(38, 2)) AS net_value,
        currency,
        CAST(cost AS NUMBER(38, 2)) AS cost,
        delivery_order_no,
        delivery_item_posnr,
        CAST(delivery_qty AS NUMBER(38, 2)) AS delivery_qty,
        CAST(gi_qty AS NUMBER(38, 2)) AS gi_qty,
        CAST(gi_date AS DATE) AS gi_date,
        billing_document,
        billing_item,
        CAST(billing_qty AS NUMBER(38, 2)) AS billing_qty
    FROM
        transform_data
)
SELECT
    *
FROM
    type_data