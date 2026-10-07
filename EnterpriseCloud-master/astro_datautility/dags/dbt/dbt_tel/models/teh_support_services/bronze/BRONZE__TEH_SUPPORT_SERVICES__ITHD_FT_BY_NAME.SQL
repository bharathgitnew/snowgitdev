{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='ITHD_FT_BY_NAME',
    unique_key = ['Title']
) }}


with source_data as
(
     SELECT
        _FILENAME
        ,_FILEDATE
        ,JSONFIELD:fields.Title::STRING AS Title
        ,JSONFIELD:fields.field_1::STRING AS field_1
        FROM {{ source("ITHD", "FT_BY_NAME") }}
        {% if is_tel_incremental() %}WHERE  _FileDate > IFNULL((SELECT MAX(_FileDate) FROM {{ this }}),'1970-01-01'){% endif %}
		QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:fields.Title::STRING ORDER BY _Filedate DESC )) = 1
        )
,transform_data as
(
    SELECT
        _FILENAME
        ,_FILEDATE
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
        ,Title AS TITLE
        ,field_1 AS FUNCTION_AREA
    FROM source_data
)
,type_data as
(
    select
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH,
        TITLE,
        FUNCTION_AREA
    from transform_data
)
select distinct * from type_data