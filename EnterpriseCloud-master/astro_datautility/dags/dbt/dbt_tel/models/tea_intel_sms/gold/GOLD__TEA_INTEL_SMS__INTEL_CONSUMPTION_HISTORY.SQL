{{ config(
  materialized = 'tel_incremental',
  incremental_strategy = 'insert_overwrite',
  alias = 'INTEL_CONSUMPTION_HISTORY',
  transient = false
) }}

WITH source_data AS (

  SELECT
    tel_part_number,
    customer_part_number,
    customer_part_description,
    quantity,
    stock_room,
    date_consumed,
    date_received,
    transaction_type,
    transaction_reason,
    factory_name,
    tel_serial_number,
    intel_serial_number,
    sales_org,
    warehouse,
    consumable_flag,
    transferred_flag,
    reconciled_flag,
    error_flag,
    transferred_date,
    customer_transaction_id,
    customer_transaction_line_id,
    NCDR_NUMBER
  FROM
    {{ ref('SILVER__TEA_INTEL_SMS__CONSIGNMENT_TRANSACTION') }}
),
transform_data AS (
  SELECT
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') AS _ROW_HASH,
    tel_part_number,
    customer_part_number,
    customer_part_description,
    quantity,
    stock_room,
    TO_TIMESTAMP_NTZ(date_consumed::varchar) AS consumed_date_time,
    DATE(date_consumed) AS consumed_date,
    TO_TIMESTAMP_NTZ(date_received::varchar) AS received_date_time,
    DATE(date_received) AS received_date,
    UPPER(TRIM(
      CASE
        WHEN UPPER(TRIM(transaction_type)) = 'ACCEPTED  RETURN' THEN 'ACCEPTED RETURN'
        WHEN UPPER(TRIM(transaction_type)) = 'CUSTORDERISSUE' THEN 'CUST ORDER ISSUE'
        ELSE transaction_type
      END
    )) AS transaction_type,

    UPPER(TRIM(
      CASE
        WHEN UPPER(TRIM(transaction_reason)) = 'TRANSFER CROSS-SITE' THEN 'TRANSFER CROSS SITE'
        WHEN UPPER(TRIM(transaction_reason)) = 'TRANSFER CROSS-SITE (BUNKER)' THEN 'TRANSFER CROSS SITE (BUNKER)'
        ELSE transaction_reason
      END
    )) AS transaction_reason,
    NULLIF(factory_name, '') AS factory_name_original,
    tel_serial_number,
    UPPER(TRIM(intel_serial_number)) AS intel_serial_number,
    sales_org,
    warehouse,
    consumable_flag,
    transferred_flag,
    reconciled_flag,
    error_flag,
    transferred_date,
    customer_transaction_id,
    customer_transaction_line_id,
    UPPER(REGEXP_SUBSTR(UPPER(TRIM(intel_serial_number)), '^([A-Z]+)')) AS tool_id_prefix,

    /* If factory_name is blank, fallback to stock_room */
    COALESCE(NULLIF(factory_name, ''), stock_room) AS factory_name,
    IFF(
      UPPER(TRIM(
        CASE
          WHEN UPPER(TRIM(transaction_type)) = 'ACCEPTED  RETURN' THEN 'ACCEPTED RETURN'
          WHEN UPPER(TRIM(transaction_type)) = 'CUSTORDERISSUE' THEN 'CUST ORDER ISSUE'
          ELSE transaction_type
        END
      )) = 'ACCEPTED RETURN',
      -1 * TRY_TO_NUMBER(quantity),
      TRY_TO_NUMBER(quantity)
    ) AS corrected_quantity,
    
    IFF(
      REGEXP_LIKE(
        UPPER(TRIM(
          CASE
            WHEN UPPER(TRIM(transaction_type)) = 'CUSTORDERISSUE' THEN 'CUST ORDER ISSUE'
            ELSE transaction_type
          END
        )),
        '^ADJUST QTY$'
      ) OR
      REGEXP_LIKE(
        UPPER(TRIM(transaction_reason)),
        'RETURN FOR REPAIR|STOCKROOM TRANSFER|TRANSFER CROSS SITE'
      ),
      'No',
      'Yes'
    ) AS is_actual_consumption,

    
    IFF(
      UPPER(TRIM(stock_room)) IN (
        'ALOHA COPPER',
        'ALOHA STORE',
        'AZ FAB PRODUCTION',
        'AZ FAB COPPER',
        'NM FAB 11X STORE',
        'NM FAB 11X COPPER STORES',
        'RONLER STORE',
        'RONLER COPPER STORES'
      ),
      'Yes',
      'No'
    ) AS is_transaction_tel_tsm,

    
    CASE
      WHEN SPLIT_PART(TRIM(stock_room),' ',1) = 'NM' THEN 'New Mexico'
      WHEN SPLIT_PART(TRIM(stock_room),' ',1) = 'AZ' THEN 'Arizona'
      ELSE SPLIT_PART(TRIM(stock_room),' ',1)
    END AS factory,

    CASE
      WHEN LENGTH(UPPER(TRIM(intel_serial_number))) = 10 THEN 'Chamber'
      WHEN LENGTH(UPPER(TRIM(intel_serial_number))) = 6  THEN 'Tool'
      ELSE NULL
    END AS tool_type,
    NCDR_NUMBER
from source_data

),
  type_data AS (
    SELECT
      _AUDIT_LOG_ID,
      _ROW_HASH,
      tel_part_number,
      customer_part_number,
      customer_part_description,
      quantity :: NUMBER(38,0) AS quantity,
      stock_room,
      CAST(consumed_date_time AS timestamp_ntz(9)) AS consumed_date_time,
      consumed_date::DATE as consumed_date,
      CAST(received_date_time AS timestamp_ntz(9)) AS received_date_time,
      CAST(received_date AS DATE) AS received_date,
      transaction_type,
      transaction_reason,
      factory_name_original,
      tel_serial_number,
      intel_serial_number,
      sales_org,
      warehouse,
      consumable_flag :: NUMBER(38,0) AS consumable_flag,
      transferred_flag :: NUMBER(38,0) AS transferred_flag,
      reconciled_flag :: NUMBER(38,0) AS reconciled_flag,
      error_flag :: NUMBER(38,0) AS error_flag,
      CAST(transferred_date AS timestamp_ntz(9)) AS transferred_date,

      customer_transaction_id,
      customer_transaction_line_id:: NUMBER(38,0) AS customer_transaction_line_id,
      tool_id_prefix,
      factory_name,
      corrected_quantity :: NUMBER(38,0) AS corrected_quantity,
      is_actual_consumption,
      is_transaction_tel_tsm,
      factory,
      tool_type,
      NCDR_NUMBER
    FROM
      transform_data
  )
  SELECT
    *
  FROM
    type_data
