{{ config(
      materialized='view',
      alias='INSPECTION_CATALOG_CODES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		KATALOGART,
		CODEGRUPPE,
		CODE,
		VERSION,
		GUELTIGAB,
		FEHLKLASSE,
		ERSTELLER,
		E_DATUM,
		AENDERER,
		A_DATUM,
		INAKTIV,
		VERWENDUNG,
		GELOESCHT,
		FOLGEAKTI,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__INSPECTION_CATALOG_CODES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data