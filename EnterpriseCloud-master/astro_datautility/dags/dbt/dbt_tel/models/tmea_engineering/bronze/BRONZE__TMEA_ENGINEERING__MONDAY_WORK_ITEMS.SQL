{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MONDAY_WORK_ITEMS',
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

    FROM {{ source('MONDAY', 'WORK_ITEMS') }},
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
        dynamic_columns:"WI#"::string                                          AS wi_number,
        dynamic_columns:"Timeline"::string                                     AS timeline,
        dynamic_columns:"Requested by"::string                                 AS requested_by,
        dynamic_columns:"Product Line"::string                                 AS product_line,
        dynamic_columns:"Owner"::string                                        AS owner,
        dynamic_columns:"WI Status"::string                                    AS wi_status,
        dynamic_columns:"Production Impact"::string                            AS production_impact,
        dynamic_columns:"Priority"::string                                     AS priority,
        dynamic_columns:"Requestor"::string                                    AS requestor,
        dynamic_columns:"Eng Hours"::string                                    AS eng_hours,
        dynamic_columns:"Des Hours"::string                                    AS des_hours,
        dynamic_columns:"PCC?"::string                                         AS pcc_flag,
        dynamic_columns:"PCC Status"::string                                   AS pcc_status,
        dynamic_columns:"ECC Class"::string                                    AS ecc_class,
        dynamic_columns:"ECC TMEA Status"::string                              AS ecc_tmea_status,
        dynamic_columns:"ECC Cust Status"::string                              AS ecc_cust_status,
        dynamic_columns:"Request Type"::string                                 AS request_type,
        dynamic_columns:"WI MDC ID"::string                                    AS wi_mdc_id

    FROM source_data
),

type_data as (
    select * from transform_data
)

select * from type_data