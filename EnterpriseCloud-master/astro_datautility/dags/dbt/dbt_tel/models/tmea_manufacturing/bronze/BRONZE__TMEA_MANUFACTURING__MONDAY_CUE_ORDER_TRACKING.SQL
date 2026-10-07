{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_CUE_ORDER_TRACKING',
    unique_key=['item_id', 'subitem_id']
) }}

WITH source_data AS (
    SELECT
        _FILEDATE,
        _FILENAME,
        jsonfield:id::string         AS item_id,
        jsonfield:name::string       AS item_name,
        jsonfield:created_at::string AS created_at,
        jsonfield:updated_at::string AS updated_at,
        ANY_VALUE(jsonfield:subitems) AS subitems_array,
        OBJECT_AGG(
            f.value:column.title::string,
            TO_VARIANT(
                COALESCE(
                    f.value:display_value::string,
                    f.value:text::string,
                    TRY_PARSE_JSON(f.value:value),
                    f.value:value::string
                )
            )
        ) AS dynamic_columns

    FROM {{ source('MONDAY', 'CUE_ORDER_TRACKING') }},
    LATERAL FLATTEN(input => jsonfield:column_values) f
    {% if is_tel_incremental() %} WHERE _FILEDATE > (SELECT IFNULL(MAX(_FILEDATE), TO_DATE('1900-01-01')) FROM {{ this }}) {% endif %}
    GROUP BY 1,2,3,4,5,6
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY _FILEDATE DESC )) = 1
),

transform_data AS (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        item_id,
        item_name,
        created_at,
        updated_at,
        dynamic_columns:"Name"::string                                                  AS name,
        dynamic_columns:"Subitems"::string                                              AS subitems,
        dynamic_columns:"Goal Timeline (Beginning from RMA Receipt Date)"::string       AS goal_timeline_beginning_from_rma_receipt_date,
        dynamic_columns:"Status"::string                                                AS status,
        dynamic_columns:"TMEA Sales Order Number"::string                               AS tmea_sales_order_number,
        dynamic_columns:"TMEA Service Order"::string                                    AS tmea_service_order,
        dynamic_columns:"Customer"::string                                              AS customer,
        dynamic_columns:"Material PN"::string                                           AS material_pn,
        dynamic_columns:"Serial Number"::string                                         AS serial_number,
        dynamic_columns:"Tool"::string                                                  AS tool,
        dynamic_columns:"Plate Type"::string                                            AS plate_type,
        dynamic_columns:"Shortage Part #s (qty and ship date)"::string                  AS shortage_part_numbers_qty_and_ship_date,
        dynamic_columns:"RMA Request Date"::string                                      AS rma_request_date,
        dynamic_columns:"Time Between RMA Request and Part Arrival at TMEA"::string     AS time_between_rma_request_and_part_arrival_at_tmea,
        dynamic_columns:"RMA Receipt Date"::string                                      AS rma_receipt_date,
        dynamic_columns:"Time Between Part Arrival and Quote Issuance"::string          AS time_between_part_arrival_and_quote_issuance,
        dynamic_columns:"Quote Issue Date"::string                                      AS quote_issue_date,
        dynamic_columns:"Time Between Quote Issuance and PO Issuance"::string           AS time_between_quote_issuance_and_po_issuance,
        dynamic_columns:"PO Receipt Date"::string                                       AS po_receipt_date,
        dynamic_columns:"Time Between PO Receipt and Parts Available"::string           AS time_between_po_receipt_and_parts_available,
        dynamic_columns:"Parts Available Date"::string                                  AS parts_available_date,
        dynamic_columns:"Time Between Parts Available Date and Repair Start Date"::string AS time_between_parts_available_date_and_repair_start_date,
        dynamic_columns:"Repair Start Date"::string                                     AS repair_start_date,
        dynamic_columns:"Burn In Date"::string                                          AS burn_in_date,
        dynamic_columns:"Time Taken to Complete Repair"::string                         AS time_taken_to_complete_repair,
        dynamic_columns:"Process Out Date"::string                                      AS process_out_date,
        dynamic_columns:"Actual Completion Timeline"::string                            AS actual_completion_timeline,
        dynamic_columns:"Goal: Complete in # of Days or Less"::string                   AS goal_complete_in_number_of_days_or_less,
        dynamic_columns:"Actual Days Taken To Complete"::string                         AS actual_days_taken_to_complete,
        dynamic_columns:"Non-Standard Repair - Requires Requote"::string                AS non_standard_repair_requires_requote,
        dynamic_columns:"Timeliness"::string                                            AS timeliness,
        dynamic_columns:"Include in Thursday Meeting"::string                           AS include_in_thursday_meeting,
        dynamic_columns:"Customer Price"::string                                        AS customer_price,
        dynamic_columns:"TEL Cost"::string                                              AS tel_cost,
        COALESCE(s.value:id::string, '__null__')                                         AS subitem_id,
        s.value:name::string                                                             AS subitem_name,
        s.value:created_at::string                                                       AS subitem_created_at,
        s.value:updated_at::string                                                       AS subitem_updated_at,
        s.value:column_values                                                            AS subitem_column_values

    FROM source_data b,
    LATERAL FLATTEN(input => TRY_PARSE_JSON(b.subitems_array), OUTER => TRUE) s
),

type_data AS (
    SELECT * FROM transform_data
)

SELECT * FROM type_data