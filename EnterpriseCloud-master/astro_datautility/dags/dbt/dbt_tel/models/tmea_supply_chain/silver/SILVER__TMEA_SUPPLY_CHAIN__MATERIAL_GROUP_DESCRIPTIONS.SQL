{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MATERIAL_GROUP_DESCRIPTIONS',
    unique_key = ['CLIENT',
    'LANGUAGE_KEY',
    'MATERIAL_GROUP']
) }}

with source_data as
(
    SELECT
		MANDT  AS CLIENT ,
		SPRAS  AS LANGUAGE_KEY,
		MATKL  AS MATERIAL_GROUP ,
		WGBEZ  AS MATERIAL_GROUP_DESCRIPTION ,
		WGBEZ60  AS MAT_GRP_DESC_2 ,
        _CAPTUREDATETIME
        FROM {{ ref('BRONZE__TMEA_SUPPLY_CHAIN__SAPO_MATERIAL_GROUP_DESCRIPTIONS') }}
        
        )
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH, -- Adds column to table on full refresh.
        _CAPTUREDATETIME	,
      CLIENT ,
      LANGUAGE_KEY ,
      MATERIAL_GROUP ,
      MATERIAL_GROUP_DESCRIPTION ,
      MAT_GRP_DESC_2 
        FROM source_data
        )
,type_data as 
(
    select
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
		cast(_CAPTUREDATETIME	AS	TIMESTAMP_LTZ(9)) AS	_CAPTUREDATETIME	,
		cast( CLIENT  AS VARCHAR(16777216))  AS CLIENT ,
		cast( LANGUAGE_KEY  AS VARCHAR(16777216))  AS LANGUAGE_KEY ,
		cast( MATERIAL_GROUP  AS VARCHAR(16777216))  AS MATERIAL_GROUP ,
		cast( MATERIAL_GROUP_DESCRIPTION  AS VARCHAR(16777216))  AS MATERIAL_GROUP_DESCRIPTION ,
		cast( MAT_GRP_DESC_2  AS VARCHAR(16777216))  AS MAT_GRP_DESC_2 

    from transform_data
    )
select * from type_data