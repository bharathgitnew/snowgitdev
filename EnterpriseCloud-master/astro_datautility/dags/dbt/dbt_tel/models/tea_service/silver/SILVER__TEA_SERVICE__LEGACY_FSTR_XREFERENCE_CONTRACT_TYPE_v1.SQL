{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='XREFERENCE_CONTRACT_TYPE',
      meta = {
          'sunset': '2025-08-28'
      },
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        CONTRACTTYPE,
        DESCRIPTION,
        TAXINDICATORDESCRIPTION,
        TAXINDICATORID,
        AUDIT_LOG_ID,
        _ROW_HASH
    FROM {{ ref('BRONZE__TEA_SERVICE__BAAN_BAANSERVICECONTRACTMANAGEMENT_CONTRACTTYPES') }}
),

transform_data as (
    SELECT
        CONTRACTTYPE AS Contract_Type,
        DESCRIPTION AS Contract_Type_Desc,
        CASE
            WHEN DESCRIPTION = 'Managed Inventory Services'
            THEN 'SCS'
            ELSE 'FST'
        END AS Contract_Type_Owner
    FROM source_data
),

type_data as (
    SELECT
        CAST(Contract_Type AS VARCHAR(16777216)) AS Contract_Type,
        CAST(Contract_Type_Desc AS VARCHAR(16777216)) AS Contract_Type_Desc,
        CAST(Contract_Type_Owner AS VARCHAR(16777216)) AS Contract_Type_Owner
    FROM transform_data
)

SELECT * FROM type_data