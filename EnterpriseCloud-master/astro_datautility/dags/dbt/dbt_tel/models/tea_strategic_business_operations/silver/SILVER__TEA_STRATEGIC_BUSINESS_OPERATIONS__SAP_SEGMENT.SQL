{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_SEGMENT',
    tags=["finance"]
) }}

with source_data as
(
    SELECT
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
    FROM {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__SHAREPOINT_ORACLE_SEGMENT') }} AS SEG
    LEFT JOIN (SELECT ORACLE_SEGMENT_CODE,SEGMENT_ID,SEGMENT_NAME FROM {{ source('STATIC_OBJECTS', 'D_SEGMENT') }}  
    WHERE DW_CURRENT_INDICATOR='Y') BAAN
        ON SEG.ORACLE_CODE = BAAN.ORACLE_SEGMENT_CODE
 QUALIFY (ROW_NUMBER() OVER (PARTITION BY SAP_CODE  ORDER BY MODIFIED DESC)) = 1  


)

,transform_data as
(
    SELECT
		ORACLE_CODE,
		ORACLE_DESCRIPTION,
		SAP_CODE,
		SAP_DESCRIPTION,
		BAAN_CODE,
		BAAN_DESCRIPTION,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
        FROM source_data
)

,type_data as
(
    select
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
        ORACLE_CODE AS ORACLE_CODE,
        ORACLE_DESCRIPTION AS ORACLE_DESCRIPTION,
        SAP_CODE AS SAP_CODE,
        SAP_DESCRIPTION AS SAP_DESCRIPTION,
		BAAN_CODE,
		BAAN_DESCRIPTION,
        CREATED,
        MODIFIED,
        CREATEDBY,
        MODIFIEDBY
    from transform_data
    )
select * from type_data