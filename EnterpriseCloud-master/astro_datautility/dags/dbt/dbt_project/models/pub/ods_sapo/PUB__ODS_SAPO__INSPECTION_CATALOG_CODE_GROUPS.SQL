{{ config(
      materialized='view',
      alias='INSPECTION_CATALOG_CODE_GROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		KATALOGART,
		CODEGRUPPE,
		ERSTELLER,
		E_DATUM,
		AENDERER,
		A_DATUM,
		VERWENDUNG,
		INAKTIV,
		STATUS,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INSPECTION_CATALOG_CODE_GROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data