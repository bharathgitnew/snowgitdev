/************
    Model file generated from TelTool SQL SERVER Ingestion Utility 
    *************/
    

    {{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='WISDOM_WISDOM_UG_UNNEC_CTG',
            unique_key=[],
            transient=false    
) }} 
    
    with source_data as (
        SELECT
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"ID"::NUMBER AS ID, 
 	 	JSONFIELD:"NAME"::STRING AS NAME, 
 	 	JSONFIELD:"NAME_J"::STRING AS NAME_J, 
 	 	JSONFIELD:"SORT_ITEM"::NUMBER AS SORT_ITEM, 
 	 	JSONFIELD:"CHANGE"::NUMBER AS CHANGE
        FROM {{ source('WISDOM', 'WISDOM_UG_UNNEC_CTG') }} AS WISDOM_UG_UNNEC_CTG
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('WISDOM', 'WISDOM_UG_UNNEC_CTG') }})
    ),
    transform_data as (
        SELECT
        _FILEDATE,
        _FILENAME,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ID, 
 	 	NAME, 
 	 	NAME_J, 
 	 	SORT_ITEM, 
 	 	CHANGE
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(ID AS NUMBER(38,2)) AS ID, 
 	 	NAME, 
 	 	NAME_J, 
 	 	CAST(SORT_ITEM AS NUMBER(38,2)) AS SORT_ITEM, 
 	 	CAST(CHANGE AS NUMBER(38,2)) AS CHANGE
        FROM transform_data
    )
    SELECT * FROM type_data