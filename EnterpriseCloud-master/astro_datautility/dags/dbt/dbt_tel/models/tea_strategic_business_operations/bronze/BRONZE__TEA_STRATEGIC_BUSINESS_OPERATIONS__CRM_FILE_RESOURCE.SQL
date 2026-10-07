/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='CRM_FILE_RESOURCE',
          unique_key=['ID'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'Id')::STRING AS "ID", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkCreatedOn')::STRING AS "SINKCREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkModifiedOn')::STRING AS "SINKMODIFIEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'isdisabled')::STRING AS "ISDISABLED", 
 	 	get_ignore_case(to_object(JSONFIELD),'displayinserviceviews')::STRING AS "DISPLAYINSERVICEVIEWS", 
 	 	get_ignore_case(to_object(JSONFIELD),'organizationid')::STRING AS "ORGANIZATIONID", 
 	 	get_ignore_case(to_object(JSONFIELD),'organizationid_entitytype')::STRING AS "ORGANIZATIONID_ENTITYTYPE", 
 	 	get_ignore_case(to_object(JSONFIELD),'siteid')::STRING AS "SITEID", 
 	 	get_ignore_case(to_object(JSONFIELD),'siteid_entitytype')::STRING AS "SITEID_ENTITYTYPE", 
 	 	get_ignore_case(to_object(JSONFIELD),'businessunitid')::STRING AS "BUSINESSUNITID", 
 	 	get_ignore_case(to_object(JSONFIELD),'businessunitid_entitytype')::STRING AS "BUSINESSUNITID_ENTITYTYPE", 
 	 	get_ignore_case(to_object(JSONFIELD),'utcconversiontimezonecode')::STRING AS "UTCCONVERSIONTIMEZONECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'calendarid')::STRING AS "CALENDARID", 
 	 	get_ignore_case(to_object(JSONFIELD),'versionnumber')::STRING AS "VERSIONNUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'objecttypecode')::STRING AS "OBJECTTYPECODE", 
 	 	get_ignore_case(to_object(JSONFIELD),'timezoneruleversionnumber')::STRING AS "TIMEZONERULEVERSIONNUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'entityimageid')::STRING AS "ENTITYIMAGEID", 
 	 	get_ignore_case(to_object(JSONFIELD),'entityimage_timestamp')::STRING AS "ENTITYIMAGE_TIMESTAMP", 
 	 	get_ignore_case(to_object(JSONFIELD),'entityimage_url')::STRING AS "ENTITYIMAGE_URL", 
 	 	get_ignore_case(to_object(JSONFIELD),'businessunitidname')::STRING AS "BUSINESSUNITIDNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'organizationidname')::STRING AS "ORGANIZATIONIDNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'siteidname')::STRING AS "SITEIDNAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'importsequencenumber')::STRING AS "IMPORTSEQUENCENUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'overriddencreatedon')::STRING AS "OVERRIDDENCREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'resourceid')::STRING AS "RESOURCEID", 
 	 	get_ignore_case(to_object(JSONFIELD),'name')::STRING AS "NAME", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsDelete')::STRING AS "ISDELETE", 
 	 	get_ignore_case(to_object(JSONFIELD),'CreatedOn')::STRING AS "CREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'entityimage')::STRING AS "ENTITYIMAGE",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'RESOURCE') }} AS RESOURCE
        {% if is_tel_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'Id')::STRING  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
        "ID", 
 	 	TRY_TO_TIMESTAMP("SINKCREATEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKCREATEDON", 
 	 	TRY_TO_TIMESTAMP("SINKMODIFIEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKMODIFIEDON", 
 	 	"ISDISABLED", 
 	 	"DISPLAYINSERVICEVIEWS", 
 	 	"ORGANIZATIONID", 
 	 	"ORGANIZATIONID_ENTITYTYPE", 
 	 	"SITEID", 
 	 	"SITEID_ENTITYTYPE", 
 	 	"BUSINESSUNITID", 
 	 	"BUSINESSUNITID_ENTITYTYPE", 
 	 	"UTCCONVERSIONTIMEZONECODE", 
 	 	"CALENDARID", 
 	 	"VERSIONNUMBER", 
 	 	"OBJECTTYPECODE", 
 	 	"TIMEZONERULEVERSIONNUMBER", 
 	 	"ENTITYIMAGEID", 
 	 	"ENTITYIMAGE_TIMESTAMP", 
 	 	"ENTITYIMAGE_URL", 
 	 	"BUSINESSUNITIDNAME", 
 	 	"ORGANIZATIONIDNAME", 
 	 	"SITEIDNAME", 
 	 	"IMPORTSEQUENCENUMBER", 
 	 	"OVERRIDDENCREATEDON", 
 	 	"RESOURCEID", 
 	 	"NAME", 
 	 	"ISDELETE", 
 	 	"CREATEDON", 
 	 	"ENTITYIMAGE",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME as _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        "ID" AS "ID", 
 	 	CAST("SINKCREATEDON" AS TIMESTAMP_LTZ(9)) AS "SINKCREATEDON", 
 	 	CAST("SINKMODIFIEDON" AS TIMESTAMP_LTZ(9)) AS "SINKMODIFIEDON", 
 	 	CAST("ISDISABLED" AS BOOLEAN) AS "ISDISABLED", 
 	 	CAST("DISPLAYINSERVICEVIEWS" AS BOOLEAN) AS "DISPLAYINSERVICEVIEWS", 
 	 	"ORGANIZATIONID" AS "ORGANIZATIONID", 
 	 	"ORGANIZATIONID_ENTITYTYPE" AS "ORGANIZATIONID_ENTITYTYPE", 
 	 	"SITEID" AS "SITEID", 
 	 	"SITEID_ENTITYTYPE" AS "SITEID_ENTITYTYPE", 
 	 	"BUSINESSUNITID" AS "BUSINESSUNITID", 
 	 	"BUSINESSUNITID_ENTITYTYPE" AS "BUSINESSUNITID_ENTITYTYPE", 
 	 	CAST("UTCCONVERSIONTIMEZONECODE" AS NUMBER(38,0)) AS "UTCCONVERSIONTIMEZONECODE", 
 	 	"CALENDARID" AS "CALENDARID", 
 	 	CAST("VERSIONNUMBER" AS NUMBER(38,0)) AS "VERSIONNUMBER", 
 	 	"OBJECTTYPECODE" AS "OBJECTTYPECODE", 
 	 	CAST("TIMEZONERULEVERSIONNUMBER" AS NUMBER(38,0)) AS "TIMEZONERULEVERSIONNUMBER", 
 	 	"ENTITYIMAGEID" AS "ENTITYIMAGEID", 
 	 	CAST("ENTITYIMAGE_TIMESTAMP" AS NUMBER(38,0)) AS "ENTITYIMAGE_TIMESTAMP", 
 	 	"ENTITYIMAGE_URL" AS "ENTITYIMAGE_URL", 
 	 	"BUSINESSUNITIDNAME" AS "BUSINESSUNITIDNAME", 
 	 	"ORGANIZATIONIDNAME" AS "ORGANIZATIONIDNAME", 
 	 	"SITEIDNAME" AS "SITEIDNAME", 
 	 	CAST("IMPORTSEQUENCENUMBER" AS NUMBER(38,0)) AS "IMPORTSEQUENCENUMBER", 
 	 	CAST("OVERRIDDENCREATEDON" AS TIMESTAMP_LTZ(9)) AS "OVERRIDDENCREATEDON", 
 	 	"RESOURCEID" AS "RESOURCEID", 
 	 	"NAME" AS "NAME", 
 	 	CAST("ISDELETE" AS BOOLEAN) AS "ISDELETE", 
 	 	CAST("CREATEDON" AS TIMESTAMP_LTZ(9)) AS "CREATEDON", 
 	 	"ENTITYIMAGE" AS "ENTITYIMAGE",
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE
        FROM transform_data
    )
    SELECT * FROM type_data