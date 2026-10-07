{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='RELATIONSHIP_INFO'
) }}

with source_data as 
(
    SELECT
        ID,
        MAIN_FUNCTION_ID,
        MAIN_MNG_NM,
        SUB_FUNCTION_ID,
        SUB_MNG_NM,
        _FILEDATE,
        _FILENAME
    FROM {{ ref('BRONZE__TEH_SUPPORT_SERVICES__TGIS_RELATIONSHIP_INFO') }} 
    {% if is_tel_incremental() %} WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
)

,transform_data as (
    SELECT
        ID,
        MAIN_FUNCTION_ID,
        MAIN_MNG_NM,
        SUB_FUNCTION_ID,
        SUB_MNG_NM,
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
)

,type_data as (
    SELECT 
        CAST (ID AS VARCHAR(16777216)) AS ID,
        CAST (MAIN_FUNCTION_ID AS VARCHAR(16777216)) AS MAIN_FUNCTION_ID,
        CAST (MAIN_MNG_NM AS VARCHAR(16777216)) AS MAIN_MNG_NM,
        CAST (SUB_FUNCTION_ID AS VARCHAR(16777216)) AS SUB_FUNCTION_ID,
        CAST (SUB_MNG_NM AS VARCHAR(16777216)) AS SUB_MNG_NM,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) as _FILEDATE,
		CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
		CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
		CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
	FROM transform_data
)

SELECT * FROM type_data