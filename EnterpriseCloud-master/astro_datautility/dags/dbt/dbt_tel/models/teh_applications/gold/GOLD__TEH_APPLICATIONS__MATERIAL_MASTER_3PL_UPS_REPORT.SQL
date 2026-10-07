{{ config(
        alias='MATERIAL_MASTER_3PL_UPS_REPORT',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as
(
    SELECT    
        MATERIAL_NUMBER,
        MARA_MATERIAL_DESCRIPTION,
        MARA_UOM,
        STANDARD_PRICE,
        UNNUM1,
        FINAL_UPDATE_DATE AS UPDATE_DATE,
        SERIAL_NUMBER_PROFILE,
        SERIALIZED,
        BIN_BULK_INDICATOR,
        MARC_PLANT AS PLANT
    FROM {{ ref('SILVER__TEH_APPLICATIONS__MATERIAL_MASTER_3PL') }} 
    WHERE MARC_PLANT='3200' 
            AND (TRY_TO_NUMBER(SUBSTR(MATERIAL_NUMBER,1,1)) IS NULL OR SUBSTR(MATERIAL_NUMBER,1,1)='E')
            AND ((TRY_TO_NUMBER(SUBSTR(MATERIAL_NUMBER,2,1)) IS NULL OR SUBSTR(MATERIAL_NUMBER,2,1)='E')
                    OR LEFT(MATERIAL_NUMBER,2) IN ('L1','J8','P5'))
            AND LEFT(MATERIAL_NUMBER,2) NOT IN ('CC','CL','FC','HP','NX','UL')
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
        UPDATE_DATE,
        SERIAL_NUMBER_PROFILE,
        SERIALIZED,
        BIN_BULK_INDICATOR,
        PLANT
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
    PLANT,
    UPDATE_DATE
from transform_data
)

select * from type_data