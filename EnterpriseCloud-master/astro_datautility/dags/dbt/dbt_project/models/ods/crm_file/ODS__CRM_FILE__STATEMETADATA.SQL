/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
  {{ config(
          materialized='incremental',
          incremental_strategy='merge',
          alias='STATEMETADATA',
          unique_key=['ENTITYNAME',
     'STATE',
     'ISUSERLOCALIZEDLABEL',
     'LOCALIZEDLABELLANGUAGECODE',
     'LOCALIZEDLABEL'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'State')::STRING AS "STATE", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsUserLocalizedLabel')::STRING AS "ISUSERLOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabelLanguageCode')::STRING AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabel')::STRING AS "LOCALIZEDLABEL",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'STATEMETADATA') }} AS STATEMETADATA
        {% if is_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY "ENTITYNAME", "STATE", "ISUSERLOCALIZEDLABEL", "LOCALIZEDLABELLANGUAGECODE", "LOCALIZEDLABEL"  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1

    ),
    transform_data as (
        SELECT
        "ENTITYNAME", 
 	 	"STATE", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL",
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
 	 	CAST("STATE" AS VARCHAR(16777216)) AS "STATE", 
 	 	CAST("ISUSERLOCALIZEDLABEL" AS VARCHAR(16777216)) AS "ISUSERLOCALIZEDLABEL", 
 	 	CAST("LOCALIZEDLABELLANGUAGECODE" AS VARCHAR(16777216)) AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	CAST("LOCALIZEDLABEL" AS VARCHAR(16777216)) AS "LOCALIZEDLABEL",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data