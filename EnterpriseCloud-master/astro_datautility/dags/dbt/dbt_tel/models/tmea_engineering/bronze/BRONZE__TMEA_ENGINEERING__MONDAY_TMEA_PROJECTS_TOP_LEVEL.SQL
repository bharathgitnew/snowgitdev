{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_TMEA_PROJECTS_TOP_LEVEL',
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

    FROM {{ source('MONDAY', 'TMEA_PROJECTS_TOP_LEVEL') }},
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
        dynamic_columns:"Lead"::string                                           AS lead,
        dynamic_columns:"Priority"::string                                       AS priority,
        dynamic_columns:"Type"::string                                           AS type,
        dynamic_columns:"DSS Review?"::string                                    AS dss_review,
        dynamic_columns:"Project Health"::string                                 AS project_health,
        dynamic_columns:"Project #"::string                                      AS project_number,
        dynamic_columns:"Project State"::string                                  AS project_state,
        dynamic_columns:"Target Date"::string                                    AS target_date,
        dynamic_columns:"Product Line"::string                                   AS product_line,
        dynamic_columns:"Project ID"::string                                     AS project_id,
        dynamic_columns:"Request Type"::string                                   AS request_type,
        dynamic_columns:"EAR #"::string                                          AS ear_number,
        dynamic_columns:"Priority Rank - Acrevia"::string                        AS priority_rank_acrevia,
        dynamic_columns:"Priority Rank - Antares"::string                        AS priority_rank_antares,
        dynamic_columns:"Priority Rank - Finesta"::string                        AS priority_rank_finesta,
        dynamic_columns:"Priority Rank - UT+"::string                            AS priority_rank_ut_plus,
        dynamic_columns:"Priority Rank - Zeta"::string                           AS priority_rank_zeta,
        dynamic_columns:"Roadmap"::string                                        AS roadmap,
        dynamic_columns:"Development Preliminary"::string                        AS development_preliminary,
        dynamic_columns:"Design Concept"::string                                 AS design_concept,
        dynamic_columns:"Development Specification"::string                      AS development_specification,
        dynamic_columns:"Development Main"::string                               AS development_main,
        dynamic_columns:"Structure & Cost"::string                               AS structure_and_cost,
        dynamic_columns:"Design Review Based on FMEA"::string                    AS design_review_fmea,
        dynamic_columns:"Design Verification"::string                            AS design_verification,
        dynamic_columns:"Assembly Results"::string                               AS assembly_results,
        dynamic_columns:"Validation Planning"::string                            AS validation_planning,
        dynamic_columns:"Validation Results VPS"::string                         AS validation_results_vps,
        dynamic_columns:"Shift into Volume Production"::string                   AS shift_into_volume_production

    FROM source_data
),

type_data as (
    select * from transform_data
)

select * from type_data