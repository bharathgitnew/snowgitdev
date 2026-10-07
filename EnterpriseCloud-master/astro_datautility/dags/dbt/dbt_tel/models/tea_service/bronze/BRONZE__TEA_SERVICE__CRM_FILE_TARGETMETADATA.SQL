/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='insert_overwrite',
          alias = 'CRM_FILE_TARGETMETADATA',
          unique_key=[],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'AttributeName')::STRING AS "ATTRIBUTENAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'ReferencedEntity')::STRING AS "REFERENCEDENTITY", 
 	 	get_ignore_case(to_object(JSONFIELD),'ReferencedAttribute')::STRING AS "REFERENCEDATTRIBUTE",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'TARGETMETADATA') }} AS TARGETMETADATA
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source("CRM_FILE", "TARGETMETADATA") }})
    ),
    transform_data as (
        SELECT
        "ENTITYNAME", 
 	 	"ATTRIBUTENAME", 
 	 	"REFERENCEDENTITY", 
 	 	"REFERENCEDATTRIBUTE",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST("ENTITYNAME" AS VARCHAR(16777216)) AS "ENTITYNAME", 
 	 	CAST("ATTRIBUTENAME" AS VARCHAR(16777216)) AS "ATTRIBUTENAME", 
 	 	CAST("REFERENCEDENTITY" AS VARCHAR(16777216)) AS "REFERENCEDENTITY", 
 	 	CAST("REFERENCEDATTRIBUTE" AS VARCHAR(16777216)) AS "REFERENCEDATTRIBUTE",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data