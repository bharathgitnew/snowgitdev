{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_TCD_MASTER_PROD_WORKING',
    unique_key=['item_id']
) }}

WITH source_data AS (
    SELECT
        _FILEDATE,
        _FILENAME,
        jsonfield:id::string         AS item_id,
        jsonfield:name::string       AS item_name,
        jsonfield:created_at::string AS created_at,
        jsonfield:updated_at::string AS updated_at,

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

    FROM {{ source('MONDAY', 'TCD_MASTER_PROD_WORKING') }},
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

        dynamic_columns:"Name"::string                              AS NAME,
        dynamic_columns:"Judgement Flag"::string                    AS JUDGEMENT_FLAG,
        dynamic_columns:"PSL_INSDATE"::string                       AS PSL_INSDATE,
        dynamic_columns:"HS 10"::string                              AS HS_10,
        dynamic_columns:"TEL HS_6digts"::string                      AS TEL_HS_6DIGTS,
        dynamic_columns:"HS 2"::string                               AS HS_2,
        dynamic_columns:"Section 232"::string                        AS SECTION_232,
        dynamic_columns:"Section 232 Flag"::string                   AS SECTION_232_FLAG,
        dynamic_columns:"Material"::string                           AS MATERIAL,
        dynamic_columns:"Material Status"::string                    AS MATERIAL_STATUS,
        dynamic_columns:"Material Memo"::string                      AS MATERIAL_MEMO,
        dynamic_columns:"0"::string                                  AS _0,
        dynamic_columns:"BU"::string                                 AS BU,
        dynamic_columns:"P/N2"::string                               AS P_N2,
        dynamic_columns:"DESC"::string                               AS DESC,
        dynamic_columns:"Model"::string                              AS MODEL,
        dynamic_columns:"Parts Category"::string                     AS PARTS_CATEGORY,
        dynamic_columns:"COO"::string                                AS COO,
        dynamic_columns:"Supplier"::string                           AS SUPPLIER,
        dynamic_columns:"Melt/poured"::string                        AS MELT_POURD,
        dynamic_columns:"TEL Part Number"::string                    AS TEL_PART_NUMBER,
        dynamic_columns:"NET Weight Unit"::string                    AS NET_WEIGHT_UNIT,
        dynamic_columns:"Net Weight"::string                         AS NET_WEIGHT,
        dynamic_columns:"Net Weight Normalized KG"::string           AS NET_WEIGHT_NORMALIZED_KG,
        dynamic_columns:"Net Weight Normalized G"::string            AS NET_WEIGHT_NORMALIZED_G,
        dynamic_columns:"PN-Source"::string                          AS PN_SOURCE,
        dynamic_columns:"Aluminum HTS"::string                       AS ALUMINUM_HTS,
        dynamic_columns:"Steel HTS"::string                          AS STEEL_HTS,
        dynamic_columns:"Copper HTS"::string                         AS COPPER_HTS,
        dynamic_columns:"Aluminum: Country of Smelt"::string         AS ALUMINUM_COUNTRY_OF_SMELT,
        dynamic_columns:"Aluminum: Country of Cast"::string          AS ALUMINUM_COUNTRY_OF_CAST,
        dynamic_columns:"Steel: Country of Melt"::string             AS STEEL_COUNTRY_OF_MELT,
        dynamic_columns:"Steel: Country of Pour"::string             AS STEEL_COUNTRY_OF_POUR,
        dynamic_columns:"Requires 232 Research"::string              AS REQUIRES_232_RESEARCH,
        dynamic_columns:"Has Multi 232"::string                      AS HAS_MULTI_232,
        dynamic_columns:"Write Order"::string                        AS WRITE_ORDER,
        dynamic_columns:"New Record Flag"::string                    AS NEW_RECORD_FLAG,
        dynamic_columns:"Cost Ratio"::string                         AS COST_RATIO,
        dynamic_columns:"Contains Aluminum"::string                  AS CONTAINS_ALUMINUM,
        dynamic_columns:"Aluminum Weight KG"::string                 AS ALUMINUM_WEIGHT_KG,
        dynamic_columns:"Aluminum Cost Ratio"::string                AS ALUMINUM_COST_RATIO,
        dynamic_columns:"Contains Steel"::string                     AS CONTAINS_STEEL,
        dynamic_columns:"Steel Cost Ratio"::string                   AS STEEL_COST_RATIO,
        dynamic_columns:"Steel Weight KG"::string                    AS STEEL_WEIGHT_KG,
        dynamic_columns:"Contains Copper"::string                    AS CONTAINS_COPPER,
        dynamic_columns:"Copper Cost Ratio"::string                  AS COPPER_COST_RATIO,
        dynamic_columns:"Copper Weight KG"::string                   AS COPPER_WEIGHT_KG,
        dynamic_columns:"Research Status"::string                    AS RESEARCH_STATUS,
        dynamic_columns:"Cost Ratio Status"::string                  AS COST_RATIO_STATUS,
        dynamic_columns:"Declaration Letter"::string                 AS DECLARATION_LETTER,
        dynamic_columns:"Priority Flag"::string                      AS PRIORITY_FLAG,
        dynamic_columns:"材質確認者"::string                           AS "MATERIAL_CHECKER",
        dynamic_columns:"Customer PO"::string                        AS CUSTOMER_PO,
        dynamic_columns:"Creation log"::string                       AS CREATION_LOG,
        dynamic_columns:"Last updated"::string                       AS LAST_UPDATED,
        dynamic_columns:"材質調査日"::string                             AS "MATERIAL_INSPECTION_DATE",
        dynamic_columns:"タイムライン"::string                         AS "TIMELINE",
        dynamic_columns:"次に依存："::string                           AS "NEXT_DEPENDENCY",
        dynamic_columns:"期間"::string                                AS "DURATION",
        dynamic_columns:"link to TCD Master-Prod-Working"::string     AS LINK_TO_TCD_MASTER_PROD_WORKING,
        dynamic_columns:"Copper: Country of Smelt"::string           AS COPPER_COUNTRY_OF_SMELT,
        dynamic_columns:"Copper: Country of Cast"::string            AS COPPER_COUNTRY_OF_CAST,

    FROM source_data
),

type_data AS (
    SELECT * FROM transform_data
)

SELECT * FROM type_data