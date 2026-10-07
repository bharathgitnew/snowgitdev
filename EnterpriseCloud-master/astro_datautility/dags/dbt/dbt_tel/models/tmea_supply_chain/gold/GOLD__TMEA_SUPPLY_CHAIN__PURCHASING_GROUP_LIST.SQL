{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'PURCHASING_GROUP_LIST',
        transient = false
) }}


WITH source_data
AS (
	SELECT PURCHASING_GROUP,
		DESCRIPTION_OF_PURCHASING_GROUP,
		TELEPHONE_NUMBER_OF_PURCHASING_GROUP,
		EMAIL_ADDRESS
	FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} AS pg
	WHERE pg.SPOOL_OUTPUT_DEVICE = 'EMAI'
	),
transform_data
AS (
	SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH,
		PURCHASING_GROUP,
		DESCRIPTION_OF_PURCHASING_GROUP,
		TELEPHONE_NUMBER_OF_PURCHASING_GROUP,
		EMAIL_ADDRESS
	FROM source_data
	)
SELECT *
FROM transform_data