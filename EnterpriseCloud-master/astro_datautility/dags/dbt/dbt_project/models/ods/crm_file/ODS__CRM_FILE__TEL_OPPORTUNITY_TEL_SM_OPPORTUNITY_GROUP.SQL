/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='incremental',
          incremental_strategy='merge',
          alias='TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUP',
          unique_key=['ID'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
        get_ignore_case(to_object(JSONFIELD),'Id')::STRING AS "ID", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkCreatedOn')::STRING AS "SINKCREATEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'SinkModifiedOn')::STRING AS "SINKMODIFIEDON", 
 	 	get_ignore_case(to_object(JSONFIELD),'versionnumber')::STRING AS "VERSIONNUMBER", 
 	 	get_ignore_case(to_object(JSONFIELD),'opportunityid')::STRING AS "OPPORTUNITYID", 
 	 	get_ignore_case(to_object(JSONFIELD),'tel_sm_opportunity_groupid')::STRING AS "TEL_SM_OPPORTUNITY_GROUPID", 
 	 	get_ignore_case(to_object(JSONFIELD),'tel_opportunity_tel_sm_opportunity_groupid')::STRING AS "TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUPID", 
 	 	get_ignore_case(to_object(JSONFIELD),'IsDelete')::STRING AS "ISDELETE", 
 	 	get_ignore_case(to_object(JSONFIELD),'CreatedOn')::STRING AS "CREATEDON",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE
        FROM {{ source('CRM_FILE', 'TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUP') }} AS TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUP
        {% if is_incremental() %}WHERE  _UPLOADDATE > IFNULL((SELECT MAX(_UPLOADDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY get_ignore_case(to_object(JSONFIELD),'Id')::STRING  ORDER BY _FILEDATE DESC,_UPLOADDATE DESC)) = 1
    ),
    transform_data as (
        SELECT
        "ID", 
 	 	TRY_TO_TIMESTAMP("SINKCREATEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKCREATEDON", 
 	 	TRY_TO_TIMESTAMP("SINKMODIFIEDON", 'MM/DD/YYYY HH:MI:SS PM') AS "SINKMODIFIEDON", 
 	 	"VERSIONNUMBER", 
 	 	"OPPORTUNITYID", 
 	 	"TEL_SM_OPPORTUNITY_GROUPID", 
 	 	"TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUPID", 
 	 	"ISDELETE", 
 	 	"CREATEDON",
        _FILEDATE,
		_FILENAME,
        _UPLOADDATE,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
    ),
    type_data as (
        SELECT
        CAST("ID" AS VARCHAR(16777216)) AS "ID", 
 	 	CAST("SINKCREATEDON" AS TIMESTAMP_LTZ(9)) AS "SINKCREATEDON", 
 	 	CAST("SINKMODIFIEDON" AS TIMESTAMP_LTZ(9)) AS "SINKMODIFIEDON", 
 	 	CAST("VERSIONNUMBER" AS NUMBER(38,0)) AS "VERSIONNUMBER", 
 	 	CAST("OPPORTUNITYID" AS VARCHAR(16777216)) AS "OPPORTUNITYID", 
 	 	CAST("TEL_SM_OPPORTUNITY_GROUPID" AS VARCHAR(16777216)) AS "TEL_SM_OPPORTUNITY_GROUPID", 
 	 	CAST("TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUPID" AS VARCHAR(16777216)) AS "TEL_OPPORTUNITY_TEL_SM_OPPORTUNITY_GROUPID", 
 	 	CAST("ISDELETE" AS BOOLEAN) AS "ISDELETE", 
 	 	CAST("CREATEDON" AS TIMESTAMP_LTZ(9)) AS "CREATEDON",
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_UPLOADDATE as TIMESTAMP_NTZ(9)) as _UPLOADDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
        FROM transform_data
    )
    SELECT * FROM type_data