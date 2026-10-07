{{ config(
        alias='MATERIAL_MASTER_3PL',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as
(
    SELECT    
        mat_3pl.MATERIAL_NUMBER,
        mat_3pl.MARA_MATERIAL_DESCRIPTION,
        mat_3pl.MARA_UOM,
        mat_3pl.STANDARD_PRICE,
        mat_3pl.UNNUM1,
        mat_3pl.MARA_FILEDATE,
        mat_3pl.COST_FILEDATE,
        mat_3pl.GTM_FILEDATE,
        mat_3pl.FINAL_UPDATE_DATE,
        mat_3pl.SNAPSHOT_DATE,
        marc.SERNP AS SERIAL_NUMBER_PROFILE,
        marc.WERKS AS MARC_PLANT
    FROM {{ ref('BRONZE__TEH_APPLICATIONS__SAPAPI_MATERIAL_MASTER_3PL') }} mat_3pl
        LEFT JOIN {{ ref('BRONZE__TEH_APPLICATIONS__SAPAPI_ZCDV_T_CMTU026_MARC') }} marc
        ON mat_3pl.MATERIAL_NUMBER = marc.MATNR
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        MATERIAL_NUMBER,
        MARA_MATERIAL_DESCRIPTION,
        MARA_UOM,
        STANDARD_PRICE,
        UNNUM1,
        MARA_FILEDATE,
        COST_FILEDATE,
        GTM_FILEDATE,
        FINAL_UPDATE_DATE,
        SNAPSHOT_DATE,
        SERIAL_NUMBER_PROFILE,
        CASE WHEN SERIAL_NUMBER_PROFILE='Z002' THEN 'Y' ELSE 'N' end AS SERIALIZED,
        CASE
            WHEN SERIAL_NUMBER_PROFILE='Z002' THEN 0
            WHEN (STANDARD_PRICE IS NOT NULL AND TRIM(STANDARD_PRICE)!='' and STANDARD_PRICE>30) THEN 0 
            ELSE 1 
        END AS BIN_BULK_INDICATOR,
        MARC_PLANT
    FROM source_data
),
type_data as (
select
    CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
    CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
    MATERIAL_NUMBER,
    MARA_MATERIAL_DESCRIPTION,
    MARA_UOM,
    STANDARD_PRICE,
    UNNUM1,
    SERIAL_NUMBER_PROFILE,
    SERIALIZED,
    BIN_BULK_INDICATOR,
    MARC_PLANT,
    MARA_FILEDATE,
    COST_FILEDATE,
    GTM_FILEDATE,
    CAST(FINAL_UPDATE_DATE AS DATE) AS FINAL_UPDATE_DATE,
    CAST(SNAPSHOT_DATE AS DATE) AS SNAPSHOT_DATE
from transform_data
)

select * from type_data