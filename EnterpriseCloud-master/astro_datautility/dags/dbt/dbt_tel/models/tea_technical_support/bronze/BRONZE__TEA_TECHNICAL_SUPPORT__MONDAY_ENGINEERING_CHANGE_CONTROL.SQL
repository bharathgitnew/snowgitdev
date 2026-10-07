{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_ENGINEERING_CHANGE_CONTROL',
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

    FROM {{ source('MONDAY', 'ENGINEERING_CHANGE_CONTROL') }},
    LATERAL FLATTEN(input => jsonfield:column_values) f
    {% if is_tel_incremental() %} WHERE _FILEDATE > (SELECT IFNULL(MAX(_FILEDATE), TO_DATE('1900-01-01')) FROM {{ this }}) {% endif %}
    GROUP BY 1,2,3,4,5,6
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY _FILEDATE DESC )) = 1
),

transform_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        item_id,
        item_name,
        created_at,
        updated_at,
        dynamic_columns:"Name"::string                          AS name,
        dynamic_columns:"Subitems"::string                      AS subitems,
        dynamic_columns:"ECC ID#"::string                       AS ecc_id,
        dynamic_columns:"Product Line"::string                  AS product_line,
        dynamic_columns:"Attachments"::string                   AS attachments,
        dynamic_columns:"Customer"::string                      AS customer,
        dynamic_columns:"Driver"::string                        AS driver,
        dynamic_columns:"Class of Change"::string               AS class_of_change,
        dynamic_columns:"Priority"::string                      AS priority,
        dynamic_columns:"0 Stock Date"::string                  AS zero_stock_date,
        dynamic_columns:"TMEA Status"::string                   AS tmea_status,
        dynamic_columns:"Customer Status"::string               AS customer_status,
        dynamic_columns:"ECC Form"::string                      AS ecc_form,
        dynamic_columns:"Cust. Approval Record"::string         AS customer_approval_record,
        dynamic_columns:"ECC Team Owner"::string                AS ecc_team_owner,
        dynamic_columns:"Originator"::string                    AS originator,
        dynamic_columns:"Requestor"::string                     AS requestor,
        dynamic_columns:"CEID"::string                          AS ceid,
        dynamic_columns:"Sent to Customer"::string              AS sent_to_customer,
        dynamic_columns:"Last Status Change"::string            AS last_status_change,
        dynamic_columns:"Accepted by Customer"::string          AS accepted_by_customer,
        dynamic_columns:"Pilot Approved"::string                AS pilot_approved,
        dynamic_columns:"Final Approval"::string                AS final_approval,
        dynamic_columns:"UGK PN"::string                        AS ugk_pn,
        dynamic_columns:"Link to EAR/WI"::string                AS link_to_ear_wi,
        dynamic_columns:"Link to ECN"::string                   AS link_to_ecn,
        dynamic_columns:"link to TMEA Projects Portfolio"::string AS link_to_tmea_projects_portfolio,
        dynamic_columns:"Linked Top Level Project"::string      AS linked_top_level_project,
        dynamic_columns:"Project Lead"::string                  AS project_lead,
        dynamic_columns:"Action Items"::string                  AS action_items,
        dynamic_columns:"Status"::string                        AS status,
        dynamic_columns:"Linked EAR / WI"::string               AS linked_ear_wi,
        dynamic_columns:"WI Status"::string                     AS wi_status,
        dynamic_columns:"Inactivity Date"::string               AS inactivity_date,
        dynamic_columns:"Inactivity Counter"::string            AS inactivity_counter,
        coalesce(s.value:id::string   , '__null__') AS subitem_id,
        s.value:name::string                      AS subitem_name,
        s.value:column_values[0]:text::string     AS subitem_owner,
        s.value:column_values[1]:text::string     AS subitem_status,
        s.value:column_values[2]:date::string     AS subitem_date
    FROM source_data b,
    LATERAL FLATTEN(input => TRY_PARSE_JSON(b.subitems_array), OUTER => TRUE) s
),

type_data as (
    select * from transform_data
)

select * from type_data