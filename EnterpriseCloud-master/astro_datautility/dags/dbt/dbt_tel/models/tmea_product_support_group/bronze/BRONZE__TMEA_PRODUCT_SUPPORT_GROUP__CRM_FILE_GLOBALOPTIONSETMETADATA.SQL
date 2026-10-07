{{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='CRM_FILE_GLOBALOPTIONSETMETADATA',
          unique_key=['OPTIONSETNAME',
     'OPTION',
     'ISUSERLOCALIZEDLABEL',
     'LOCALIZEDLABELLANGUAGECODE',
    'GLOBALOPTIONSETNAME',
    'ENTITYNAME'],
          transient=false    
) }} 
    
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'OptionSetName')::STRING AS "OPTIONSETNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'Option')::STRING AS "OPTION", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsUserLocalizedLabel')::STRING AS "ISUSERLOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabelLanguageCode')::STRING AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'LocalizedLabel')::STRING AS "LOCALIZEDLABEL", 
 	 	get_ignore_case(to_object(JSONFIELD),'GlobalOptionSetName')::STRING AS "GLOBALOPTIONSETNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'EntityName')::STRING AS "ENTITYNAME",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'GLOBALOPTIONSETMETADATA') }} AS GLOBALOPTIONSETMETADATA
        {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY "OPTIONSETNAME", "OPTION", "ISUSERLOCALIZEDLABEL", "LOCALIZEDLABELLANGUAGECODE", "GLOBALOPTIONSETNAME","ENTITYNAME" ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
        "OPTIONSETNAME", 
 	 	"OPTION", 
 	 	"ISUSERLOCALIZEDLABEL", 
 	 	"LOCALIZEDLABELLANGUAGECODE", 
 	 	"LOCALIZEDLABEL", 
 	 	"GLOBALOPTIONSETNAME", 
 	 	"ENTITYNAME"
        FROM source_data
    ),
    type_data as (
        SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        CAST("OPTIONSETNAME" AS VARCHAR(16777216)) AS "OPTIONSETNAME", 
 	 	CAST("OPTION" AS VARCHAR(16777216)) AS "OPTION", 
 	 	CAST("ISUSERLOCALIZEDLABEL" AS VARCHAR(16777216)) AS "ISUSERLOCALIZEDLABEL", 
 	 	CAST("LOCALIZEDLABELLANGUAGECODE" AS VARCHAR(16777216)) AS "LOCALIZEDLABELLANGUAGECODE", 
 	 	CAST("GLOBALOPTIONSETNAME" AS VARCHAR(16777216)) AS "GLOBALOPTIONSETNAME", 
 	 	CAST("ENTITYNAME" AS VARCHAR(16777216)) AS "ENTITYNAME",
 	 	CAST("LOCALIZEDLABEL" AS VARCHAR(16777216)) AS "LOCALIZEDLABEL"
        FROM transform_data
    )
    SELECT * FROM type_data