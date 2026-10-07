{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_DOCUMENT_TYPE',
      transient=false
) }}

with source_data as (
    SELECT
		BAAN_DOC_TYPE,
		SAP_DOC_TYPE
    from {{ ref('COMMON__SAPH__SAP_DOCUMENT_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data