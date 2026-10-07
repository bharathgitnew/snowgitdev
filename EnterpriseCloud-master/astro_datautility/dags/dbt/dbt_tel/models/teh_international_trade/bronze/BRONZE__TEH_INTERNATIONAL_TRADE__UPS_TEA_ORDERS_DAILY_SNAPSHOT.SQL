/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='UPS_TEA_ORDERS_DAILY_SNAPSHOT',
          unique_key=['SNAPSHOT_DATE','TMS_NUMBER','TEA_MNX_HOUSEBILL_NUMBER','INT_MAWB','AIRPORT_CURRENT_LOCATION','STORAGE_FEE_PAID_USD'],
          transient=false    
) }} 
    
    with source_data as (
        SELECT
            TMS_NUMBER,
            TEA_MNX_HOUSEBILL_NUMBER,
            TEA_PURCHASE_ORDER_NUMBER,
            INT_MAWB,
            PIECE_COUNT,
            WEIGHT_KG,
            AIRPORT_CURRENT_LOCATION,
            ARRIVAL_DATE_FOR_LAX,
            DAY_CLEARED,
            STORAGE_FEE_PAID_USD,
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE
        FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__UPS_TEA_ORDERS') }} AS TEA_SEC_232
    ),
    transform_data as (
        SELECT
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') as _ROW_HASH,
            CURRENT_DATE() AS SNAPSHOT_DATE,
            TMS_NUMBER,
            TEA_MNX_HOUSEBILL_NUMBER,
            TEA_PURCHASE_ORDER_NUMBER,
            INT_MAWB,
            PIECE_COUNT,
            WEIGHT_KG,
            AIRPORT_CURRENT_LOCATION,
            ARRIVAL_DATE_FOR_LAX,
            DAY_CLEARED,
            STORAGE_FEE_PAID_USD,
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE	
        FROM source_data
    ),
    type_data as (
        SELECT
            cast(_AUDIT_LOG_ID AS varchar(128)) AS _AUDIT_LOG_ID,
            cast(_ROW_HASH AS varchar(128)) AS _ROW_HASH,
            SNAPSHOT_DATE,
            TMS_NUMBER,
            TEA_MNX_HOUSEBILL_NUMBER,
            TEA_PURCHASE_ORDER_NUMBER,
            INT_MAWB,
            PIECE_COUNT,
            WEIGHT_KG,
            AIRPORT_CURRENT_LOCATION,
            CAST(TRY_TO_DATE(ARRIVAL_DATE_FOR_LAX) AS DATE) AS ARRIVAL_DATE_FOR_LAX,
            CAST(TRY_TO_DATE(DAY_CLEARED) AS DATE) AS DAY_CLEARED,
            STORAGE_FEE_PAID_USD,
            CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
            CAST(_FILENAME AS varchar(128)) AS _FILENAME,
            CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE
        FROM transform_data
    )
    SELECT * FROM type_data