{{ config(
      materialized='view',
      schema='de_sap_master_data',
      alias='SAP_DOCUMENT_TYPE_DESCRIPTION',
      transient=false
) }}

with source_data as (
    SELECT
		DOC_TYPE,
		DOC_TYPE_DESCRIPTION
    from {{ ref('COMMON__SAPH__SAP_DOCUMENT_TYPE_DESCRIPTION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data