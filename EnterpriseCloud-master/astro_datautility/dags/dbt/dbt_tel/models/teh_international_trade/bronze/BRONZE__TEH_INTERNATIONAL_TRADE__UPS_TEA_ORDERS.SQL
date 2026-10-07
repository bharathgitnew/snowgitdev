/************
    Model file generated from SAPAPIUtility 
    *************/
    
    
    {{ config(
          materialized='tel_incremental',
          incremental_strategy='insert_overwrite',
          alias='UPS_TEA_ORDERS',
          transient=false    
) }} 
    
    with source_data as (
        SELECT
            JSONFIELD:"TMS # "::STRING AS TMS_NUMBER,
            JSONFIELD:"TEA/MNX HOUSEBILL #"::STRING AS TEA_MNX_HOUSEBILL_NUMBER,
            JSONFIELD:"TEA PO # "::STRING AS TEA_PURCHASE_ORDER_NUMBER,
            JSONFIELD:"INT MAWB"::STRING AS INT_MAWB,
            JSONFIELD:"Piece Count"::STRING AS PIECE_COUNT,
            JSONFIELD:"Weight"::STRING AS WEIGHT_KG,
            JSONFIELD:"Airport"::STRING AS AIRPORT_CURRENT_LOCATION,
            JSONFIELD:"Arrival Date to LAX"::STRING AS ARRIVAL_DATE_FOR_LAX,
            JSONFIELD:"Day Cleared"::STRING AS DAY_CLEARED,
            JSONFIELD:"Storage"::STRING AS STORAGE_FEE_PAID_USD,
            _FILEDATE,
            _FILENAME,
            _UPLOADDATE
        FROM {{ source('UPS', 'TEA_ORDERS') }} AS TEA_SEC_232
        WHERE
            _FILEDATE=(SELECT MAX(_FILEDATE) FROM {{ source('UPS', 'TEA_ORDERS') }}) 
            AND JSONFIELD:"Storage"::STRING NOT IN ('Fee','Paid USD','Storage')
    ),
    transform_data as (
        SELECT
            '{{ invocation_id }}' AS _AUDIT_LOG_ID,
            SHA2('hash_me') as _ROW_HASH,
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
            TMS_NUMBER,
            TEA_MNX_HOUSEBILL_NUMBER,
            TEA_PURCHASE_ORDER_NUMBER,
            INT_MAWB,
            PIECE_COUNT,
            WEIGHT_KG,
            AIRPORT_CURRENT_LOCATION,
            CAST(TRY_TO_DATE(ARRIVAL_DATE_FOR_LAX) AS DATE) AS ARRIVAL_DATE_FOR_LAX,
            CAST(TRY_TO_DATE(DAY_CLEARED) AS DATE) AS DAY_CLEARED,
            CAST(REGEXP_SUBSTR(REPLACE(REPLACE(STORAGE_FEE_PAID_USD, '$', ''),',',''), '\\d*\\.?\\d+') AS NUMBER(38,2)) AS STORAGE_FEE_PAID_USD,
            CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
            CAST(_FILENAME AS varchar(128)) AS _FILENAME,
            CAST(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE
        FROM transform_data
    )
    SELECT * FROM type_data