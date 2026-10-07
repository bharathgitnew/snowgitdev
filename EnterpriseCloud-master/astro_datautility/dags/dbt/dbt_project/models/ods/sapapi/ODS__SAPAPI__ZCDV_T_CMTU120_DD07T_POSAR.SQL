/************
	Model file generated from SAPAPIUtility
	*************/


	{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='ZCDV_T_CMTU120_DD07T_POSAR',
    	  unique_key = [''],
    	  transient=false
) }}

	with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Domname::STRING AS DOMNAME,
		JSONFIELD:Ddlanguage::STRING AS DDLANGUAGE,
		JSONFIELD:As4local::STRING AS AS4LOCAL,
		JSONFIELD:Valpos::STRING AS VALPOS,
		JSONFIELD:As4vers::STRING AS AS4VERS,
		JSONFIELD:Ddtext::STRING AS DDTEXT,
		JSONFIELD:DomvalLd::STRING AS DOMVALLD,
		JSONFIELD:DomvalHd::STRING AS DOMVALHD,
		JSONFIELD:DomvalueL::STRING AS DOMVALUEL
    from {{ source('SAPH','SAP_SDM_EV_DD07T_GMX') }}
	    WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_DD07T_GMX'
        )
		AND JSONFIELD:"DDLANGUAGE"::STRING='EN' --Changes as a part of GMX migration
		QUALIFY ROW_NUMBER() OVER ( PARTITION BY AS4LOCAL,AS4VERS,DDLANGUAGE,DOMNAME,VALPOS ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),

	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		DOMNAME as DOMNAME,
		DDLANGUAGE as DDLANGUAGE,
		AS4LOCAL as AS4LOCAL,
		VALPOS as VALPOS,
		AS4VERS as AS4VERS,
		DDTEXT as DDTEXT,
		DOMVALLD as DOMVALLD,
		DOMVALHD as DOMVALHD,
		DOMVALUEL as DOMVALUEL
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		DOMNAME,
		DDLANGUAGE,
		AS4LOCAL,
		VALPOS,
		AS4VERS,
		DDTEXT,
		DOMVALLD,
		DOMVALHD,
		DOMVALUEL
    FROM transform_data
)

	select * from type_data