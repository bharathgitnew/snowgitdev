{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_SEGMENT',
    tags=["finance", "insert_overwrite_tea_logistics"]
) }}

with source_data as
(
    SELECT
	    _FILENAME,
	    _FILEDATE,
	    ORACLE_CODE,
	    ORACLE_NAME AS ORACLE_DESCRIPTION,
	    SAP_CODE,
	    SAP_NAME AS SAP_DESCRIPTION,
        BAAN.SEGMENT_ID AS BAAN_CODE,    
        BAAN.SEGMENT_NAME AS BAAN_DESCRIPTION,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    FROM {{ ref('BRONZE__TEA_LOGISTICS__SHAREPOINT_ORACLE_SEGMENT') }} AS SEG
    LEFT JOIN (SELECT ORACLE_SEGMENT_CODE,SEGMENT_ID,SEGMENT_NAME FROM {{ source('STATIC_OBJECTS', 'D_SEGMENT') }}  
    WHERE DW_CURRENT_INDICATOR='Y') BAAN
        ON SEG.ORACLE_CODE = BAAN.ORACLE_SEGMENT_CODE
 QUALIFY (ROW_NUMBER() OVER (PARTITION BY SAP_CODE  ORDER BY MODIFIED DESC)) = 1  


)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        ORACLE_CODE,
        ORACLE_DESCRIPTION,
        SAP_CODE,
        SAP_DESCRIPTION,
        BAAN_CODE,
        BAAN_DESCRIPTION,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
FROM source_data
)

,type_data as
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(ORACLE_CODE AS VARCHAR(16777216)) AS ORACLE_CODE,
        CAST(ORACLE_DESCRIPTION AS VARCHAR(16777216)) AS ORACLE_DESCRIPTION,
        CAST(SAP_CODE AS VARCHAR(16777216)) AS SAP_CODE,
        CAST(SAP_DESCRIPTION AS VARCHAR(16777216)) AS SAP_DESCRIPTION,
        BAAN_CODE,
        BAAN_DESCRIPTION,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
from transform_data
    )
select * from type_data