/************
	Model file generated from SAPAPIUtility
	*************/


	{{ config(
		materialized='incremental',
		incremental_strategy='merge',
		alias='ZCDV_T_CMTU230_ZSDT2004',
		unique_key = ['SEQNO'],
		transient=false,
		tags = ['on_demand']
) }}

	with source_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:"SEQNO"::STRING AS "SEQNO",
 	 	JSONFIELD:"PRC_STS"::STRING AS "PRC_STS",
 	 	JSONFIELD:"AUFNR"::STRING AS "AUFNR",
 	 	JSONFIELD:"VORNR"::STRING AS "VORNR",
 	 	JSONFIELD:"BUDAT"::STRING AS "BUDAT",
 	 	JSONFIELD:"WERKS"::STRING AS "WERKS",
 	 	JSONFIELD:"ZSEQUE"::STRING AS "ZSEQUE",
 	 	JSONFIELD:"ARBPL"::STRING AS "ARBPL",
 	 	JSONFIELD:"ZKUNNR"::STRING AS "ZKUNNR",
 	 	JSONFIELD:"ZACTBC"::STRING AS "ZACTBC",
 	 	JSONFIELD:"ZACTWH"::STRING AS "ZACTWH",
 	 	JSONFIELD:"C_DATE"::STRING AS "C_DATE",
 	 	JSONFIELD:"C_TIME"::STRING AS "C_TIME",
 	 	JSONFIELD:"C_USER"::STRING AS "C_USER",
 	 	JSONFIELD:"C_PGM"::STRING AS "C_PGM",
 	 	JSONFIELD:"U_DATE"::STRING AS "U_DATE",
 	 	JSONFIELD:"U_TIME"::STRING AS "U_TIME",
 	 	JSONFIELD:"U_USER"::STRING AS "U_USER",
 	 	JSONFIELD:"U_PGM"::STRING AS "U_PGM",
    from {{ source('SAPH','SAP_SDT_EV_ZSDT2004_GMX') }}
	{% if is_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:"SEQNO"::STRING  ORDER BY _FILEDATE DESC )) = 1
	),

	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		LPAD(coalesce("SEQNO",''),10,'0') as "SEQNO",
		MANDT as MANDT,
		coalesce("ARBPL",'') as "ARBPL",
		coalesce("AUFNR",'') as "AUFNR",
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("BUDAT"),'-',''),'') as "BUDAT",
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("C_DATE"),'-',''),'') as "C_DATE",
		C_PGM as C_PGM,
		REGEXP_REPLACE("C_TIME",':') as "C_TIME",
		C_USER as C_USER,
		PRC_STS as PRC_STS,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("U_DATE"),'-',''),'') as "U_DATE",
		U_PGM as U_PGM,
		REGEXP_REPLACE("U_TIME",':') as "U_TIME",
		coalesce("U_USER",'') as "U_USER",
		LPAD(coalesce("VORNR",''),4,'0') as "VORNR",
		WERKS as WERKS,
		coalesce("ZACTBC",'') as "ZACTBC",
		coalesce("ZACTWH",'') as "ZACTWH",
		LPAD(coalesce("ZKUNNR",''),6,'0') as "ZKUNNR",
		coalesce("ZSEQUE",'') as "ZSEQUE"
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
		SEQNO,
		MANDT,
		ARBPL,
		AUFNR,
		BUDAT,
		C_DATE,
		C_PGM,
		C_TIME,
		C_USER,
		PRC_STS,
		U_DATE,
		U_PGM,
		U_TIME,
		U_USER,
		VORNR,
		WERKS,
		ZACTBC,
		ZACTWH,
		ZKUNNR,
		ZSEQUE
    FROM transform_data
)

	select * from type_data