{{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='CRM_FILE_STATUSMETADATA',
          unique_key=['ENTITYNAME',
     'STATE',
     'STATUS',
     'ISUSERLOCALIZEDLABEL',
     'LOCALIZEDLABELLANGUAGECODE'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME", 
        get_ignore_case(to_object(JSONFIELD),'State')::STRING AS "STATE", 
        get_ignore_case(to_object(JSONFIELD),'Status')::STRING AS "STATUS", 
        get_ignore_case(to_object(JSONFIELD),'IsUserLocalizedLabel')::STRING AS "ISUSERLOCALIZEDLABEL", 
        get_ignore_case(to_object(JSONFIELD),'LocalizedLabelLanguageCode')::STRING AS "LOCALIZEDLABELLANGUAGECODE", 
        get_ignore_case(to_object(JSONFIELD),'LocalizedLabel')::STRING AS "LOCALIZEDLABEL",
        _FILEDATE,
        _FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'STATUSMETADATA') }} AS STATUSMETADATA
        {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY "ENTITYNAME", "STATE", "STATUS", "ISUSERLOCALIZEDLABEL", "LOCALIZEDLABELLANGUAGECODE"  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
        "ENTITYNAME", 
 	 	"STATE", 
 	 	"STATUS", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL"
        FROM source_data
    ),
    type_data as (
        SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        CAST("ENTITYNAME" AS VARCHAR(16777216)) AS "ENTITYNAME", 
 	 	CAST("STATE" AS VARCHAR(16777216)) AS "STATE", 
 	 	CAST("STATUS" AS VARCHAR(16777216)) AS "STATUS", 
 	 	CAST("ISUSERLOCALIZEDLABEL" AS VARCHAR(16777216)) AS "ISUSERLOCALIZEDLABEL", 
 	 	CAST("LOCALIZEDLABELLANGUAGECODE" AS VARCHAR(16777216)) AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	CAST("LOCALIZEDLABEL" AS VARCHAR(16777216)) AS "LOCALIZEDLABEL"
        FROM transform_data
    )
    SELECT * FROM type_data