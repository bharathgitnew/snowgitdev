{{ config(
        alias='INVENTORY_MATCH_3PL_DATA',
        SCHEMA='de_threepl',
        transient=false
) }}

with source_data as
(
        select
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,DATE_OF_EXTRACT AS EXTRACT_DATE
        ,sum(QUANTITY) as ON_HAND_QTY
        ,count(distinct WMS_BATCH_NUMBER) over (partition by PART_NUMBER,STORAGE_LOCATION) as BATCH_COUNT
        ,count(distinct SERIAL_NUMBER) over (partition by PART_NUMBER,STORAGE_LOCATION) as SERIAL_COUNT        
    from {{ ref('COMMON__THREEPL__TPL_UPS_INVENTORY_FILE_US') }} 
    group by 
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,EXTRACT_DATE
    order by
        PART_NUMBER
        ,STORAGE_LOCATION
), 
transform_data AS
(
        select
            PART_NUMBER
            ,STORAGE_LOCATION
            ,WMS_BATCH_NUMBER
            ,SERIAL_NUMBER
            ,EXTRACT_DATE
            ,ON_HAND_QTY
            ,BATCH_COUNT
            ,SERIAL_COUNT
            ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
            ,SHA2('hash_me') as _ROW_HASH      
    from source_data
),

type_data as
(
    SELECT
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        PART_NUMBER
        ,STORAGE_LOCATION
        ,WMS_BATCH_NUMBER
        ,SERIAL_NUMBER
        ,EXTRACT_DATE
        ,ON_HAND_QTY
        ,BATCH_COUNT
        ,SERIAL_COUNT
     from transform_data
)

    select * from type_data