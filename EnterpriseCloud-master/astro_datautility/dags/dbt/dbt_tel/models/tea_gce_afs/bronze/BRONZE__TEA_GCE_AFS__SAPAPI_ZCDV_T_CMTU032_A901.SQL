/************
Model file generated from SAPAPIUtility
*************/


{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAPAPI_ZCDV_T_CMTU032_A901',
    unique_key = ['']
) }}

with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:"Mandt"::STRING AS MANDT,
		JSONFIELD:"KAPPL"::STRING AS KAPPL,
		JSONFIELD:"KSCHL"::STRING AS KSCHL,
		JSONFIELD:"VKORG"::STRING AS VKORG,
		JSONFIELD:"KUNNR"::STRING AS KUNNR,
		JSONFIELD:"MATNR"::STRING AS MATNR,
		JSONFIELD:"DATBI"::STRING AS DATBI,
		JSONFIELD:"DATAB"::STRING AS DATAB,
		JSONFIELD:"KNUMH"::STRING AS KNUMH,
		JSONFIELD:update_date::STRING AS UPDATE_DATE,
    from {{ source('SAPH','SAP_SDM_EV_A901_GMX') }}
	WHERE _FILEDATE::STRING = (
        SELECT MAX(RUN_TIME)::STRING
        FROM {{ source('SAPH', 'CONTROLTABLE') }}
        WHERE TABLE_NAME = 'SAP_SDM_EV_A901_GMX'
        )
	QUALIFY ROW_NUMBER() OVER ( PARTITION BY DATBI, KAPPL, KSCHL, KUNNR, MATNR, VKORG ORDER BY _FILEDATE DESC, _UPLOADDATE DESC) = 1
	),

transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		MANDT as MANDT,
		KAPPL as KAPPL,
		KSCHL as KSCHL,
		VKORG as VKORG,
		KUNNR as KUNNR,
		MATNR as MATNR,
		lead(COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-',''),'')) over (partition by KAPPL,KSCHL,VKORG,KUNNR,MATNR order by DATAB) as NEXT_DATAB,
		to_varchar(dateadd('day', -1, try_to_date(NEXT_DATAB, 'YYYYMMDD')), 'YYYYMMDD') as ADJ_DATBI,
		coalesce(ADJ_DATBI, REGEXP_REPLACE(TRY_TO_DATE("DATBI"),'-','')) as DATBI,
		COALESCE(REGEXP_REPLACE(TRY_TO_DATE("DATAB"),'-',''),'') as DATAB,
		COALESCE(LPAD("KNUMH",'10','0'),'') AS KNUMH,
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
		KAPPL,
		KSCHL,
		VKORG,
		KUNNR,
		MATNR,
		DATBI,
		DATAB,
		KNUMH,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data