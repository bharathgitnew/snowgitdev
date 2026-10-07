{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_ENGINEERING_ACTION_REQUESTS',
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

    FROM {{ source('MONDAY', 'ENGINEERING_ACTION_REQUESTS') }},
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
        dynamic_columns:"Product Line"::string                                      AS product_line,
        dynamic_columns:"Requester"::string                                         AS requester,
        dynamic_columns:"Request Type"::string                                      AS request_type,
        dynamic_columns:"Scope"::string                                             AS scope,
        dynamic_columns:"Priority"::string                                          AS priority,
        dynamic_columns:"Submit State"::string                                      AS submit_state,
        dynamic_columns:"Project Type"::string                                      AS project_type,
        dynamic_columns:"PCC?"::string                                              AS pcc_flag,
        dynamic_columns:"Approval"::string                                          AS approval,
        dynamic_columns:"EAR #"::string                                             AS ear_number
    FROM source_data
),

type_data as (
    select * from transform_data
)

select * from type_data