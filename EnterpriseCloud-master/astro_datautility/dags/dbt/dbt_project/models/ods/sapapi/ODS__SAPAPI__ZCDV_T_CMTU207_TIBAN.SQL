{{ config(
	materialized='incremental',
	incremental_strategy='insert_overwrite',
	alias='ZCDV_T_CMTU207_TIBAN',
	transient=false
) }}

with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"BANKL"::STRING        AS "BANKL",
        JSONFIELD:"BANKN"::STRING        AS "BANKN",
        JSONFIELD:"BANKS"::STRING        AS "BANKS",
        JSONFIELD:"BKONT"::STRING        AS "BKONT",
        JSONFIELD:"DELFLAG"::STRING      AS "DELFLAG",
        JSONFIELD:"ERDAT"::STRING        AS "ERDAT",
        JSONFIELD:"ERNAM"::STRING        AS "ERNAM",
        JSONFIELD:"IBAN"::STRING         AS "IBAN",
        JSONFIELD:"PSL_INSDATE"::STRING  AS "PSL_INSDATE",
        JSONFIELD:"TABKEY"::STRING       AS "TABKEY",
        JSONFIELD:"TABNAME"::STRING      AS "TABNAME",
        JSONFIELD:"VALID_FROM"::STRING   AS "VALIDFROM",
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:"PSL_UPDDATE"::STRING AS UPDATE_DATE
    from {{ source('SAPH','SAP_ZZM_EV_TIBAN') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_ZZM_EV_TIBAN'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY BANKL, BANKN, BANKS, BKONT ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
),
transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		BANKS as BANKS,
		BANKL as BANKL,
		BANKN as BANKN,
		BKONT as BKONT,
		IBAN as IBAN,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("VALIDFROM"),'-',''),'') as "VALIDFROM",
		ERNAM as ERNAM,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("ERDAT"),'-',''),'') as "ERDAT",
		TABNAME as TABNAME,
		TABKEY as TABKEY,
		UPDATE_DATE as UPDATE_DATE
    FROM source_data
),
type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		MANDT,
		BANKS,
		BANKL,
		BANKN,
		BKONT,
		IBAN,
		VALIDFROM,
		ERNAM,
		ERDAT,
		TABNAME,
		TABKEY,
		UPDATE_DATE
    FROM transform_data
)
select * from type_data