{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_ACCOUNT',
      transient=false
) }}

with source_data as (
    SELECT
		  *
      exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__SAPH__SAP_ACCOUNT') }}
)

select * from SOURCE_DATA