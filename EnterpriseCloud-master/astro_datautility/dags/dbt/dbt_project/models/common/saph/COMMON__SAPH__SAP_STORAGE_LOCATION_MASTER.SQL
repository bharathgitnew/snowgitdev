{{ config(
        materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_STORAGE_LOCATION_MASTER'    
) }}

with source_data as
(
    SELECT 
        DISTINCT
		TWLAD._FILENAME,
		TWLAD._FILEDATE,
        TWLAD.WERKS AS PLANT,
        TWLAD.LGORT AS SLOC_CODE,
        LEFT(TWLAD.LGORT,2) AS LOCATION_CODE,
        T001L.LGOBE AS SLOC_DESCRIPTION,
        BUT000.PARTNER as BP_NAME,
        concat(ADRC.HOUSENUM1,' ',ADRC.STREET,',',split_part(ADRC.STRSUPPL1,'/',1)) as ADDRESS1,
        split_part(ADRC.STRSUPPL1,'/',2) as ADDRESS2,
        concat(ADRC.STREET,',',split_part(ADRC.STRSUPPL1,'/',1)) as ADDRESS_1_AND_2,
        ADRC.HOUSENUM1 AS HOUSENUMBER,
        concat(ADRC.STREET,',',split_part(ADRC.STRSUPPL1,'/',1),' ',split_part(ADRC.STRSUPPL1,'/',2)) AS STREET,
        ADRC.CITY1 as CITY,
        ADRC.REGION AS REGION,
        ADRC.POSTCODE1 AS POSTAL_CODE,
        ADRC.COUNTRY AS COUNTRY,
        ADRC.LANGU AS LANGUAGE,
        BUT000.NAME_ORG1 as PRINCIPAL_PARTY,
        BUT000.ZZCORPORATION AS SOLDTO_B_CODE,
        BUT000.ZZOFFICE AS BILLTO_B_CODE,
        BUT000.PARTNER as SHIPTO_C_CODE
    FROM 
        {{ ref('ODS__SAPAPI__ZCDV_T_CMTU203_TWLAD') }} TWLAD,
        {{ ref('ODS__SAPAPI__ZCDV_T_CMTU087_ADRC') }} ADRC,
        {{ ref('ODS__SAPAPI__ZCDV_T_CMTU080_T001L') }} T001L,
        {{ ref('ODS__SAPAPI__ZCDV_T_CMTU053_BUT000') }} BUT000
    WHERE 
        TWLAD.ADRNR=ADRC.ADDRNUMBER
        AND TWLAD.LGORT=T001L.LGORT
        AND T001L.kunnr=BUT000.PARTNER

)

,transform_data as
(
    SELECT
		_FILENAME,
		_FILEDATE,
        PLANT,
        SLOC_CODE,
        LOCATION_CODE,
        SLOC_DESCRIPTION,
        BP_NAME,
        ADDRESS1,
        ADDRESS2,
        ADDRESS_1_AND_2,
        HOUSENUMBER,
        STREET,
        CITY,
        REGION,
        POSTAL_CODE,
        COUNTRY,
        LANGUAGE,
        PRINCIPAL_PARTY,
        SOLDTO_B_CODE,
        BILLTO_B_CODE,
        SHIPTO_C_CODE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
        FROM source_data
)

,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        PLANT,
        SLOC_CODE,
        LOCATION_CODE,
        SLOC_DESCRIPTION,
        BP_NAME,
        ADDRESS1,
        ADDRESS2,
        ADDRESS_1_AND_2,
        HOUSENUMBER,
        STREET,
        CITY,
        REGION,
        POSTAL_CODE,
        COUNTRY,
        LANGUAGE,
        PRINCIPAL_PARTY,
        SOLDTO_B_CODE,
        BILLTO_B_CODE,
        SHIPTO_C_CODE
    from transform_data
    )
select * from type_data