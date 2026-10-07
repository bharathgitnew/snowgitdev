/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='insert_overwrite',
          alias = 'CRM_FILE_ATTRIBUTEMETADATA',
          unique_key=[],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'AttributeName')::STRING AS "ATTRIBUTENAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'AttributeType')::STRING AS "ATTRIBUTETYPE", 
 	 	get_ignore_case(to_object(JSONFIELD),'AttributeTypeCode')::STRING AS "ATTRIBUTETYPECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'Version')::STRING AS "VERSION", 
 	 	get_ignore_case(to_object(JSONFIELD),'Timestamp')::STRING AS "TIMESTAMP", 
 	 	get_ignore_case(to_object(JSONFIELD),'MetadataId')::STRING AS "METADATAID", 
 	 	get_ignore_case(to_object(JSONFIELD),'Precision')::STRING AS "PRECISION", 
 	 	get_ignore_case(to_object(JSONFIELD),'MaxLength')::STRING AS "MAXLENGTH",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'ATTRIBUTEMETADATA') }} AS ATTRIBUTEMETADATA
        --{% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        WHERE _FILEDATE = (SELECT MAX(_FILEDATE) from {{ source("CRM_FILE", "ATTRIBUTEMETADATA") }})

    ),
    transform_data as (
        SELECT
        "ENTITYNAME", 
 	 	"ATTRIBUTENAME", 
 	 	"ATTRIBUTETYPE", 
 	 	"ATTRIBUTETYPECODE", 
 	 	"VERSION", 
 	 	"TIMESTAMP", 
 	 	"METADATAID", 
 	 	"PRECISION", 
 	 	"MAXLENGTH",
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
 	 	CAST("ATTRIBUTETYPE" AS VARCHAR(16777216)) AS "ATTRIBUTETYPE", 
 	 	CAST("ATTRIBUTETYPECODE" AS VARCHAR(16777216)) AS "ATTRIBUTETYPECODE", 
 	 	CAST("VERSION" AS VARCHAR(16777216)) AS "VERSION", 
 	 	CAST("TIMESTAMP" AS VARCHAR(16777216)) AS "TIMESTAMP", 
 	 	CAST("METADATAID" AS VARCHAR(16777216)) AS "METADATAID", 
 	 	CAST("PRECISION" AS VARCHAR(16777216)) AS "PRECISION", 
 	 	CAST("MAXLENGTH" AS VARCHAR(16777216)) AS "MAXLENGTH",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data