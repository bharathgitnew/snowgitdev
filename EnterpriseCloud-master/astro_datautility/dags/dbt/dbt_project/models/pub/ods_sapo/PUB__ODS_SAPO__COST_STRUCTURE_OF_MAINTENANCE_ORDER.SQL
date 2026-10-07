{{ config(
      materialized='view',
      alias='COST_STRUCTURE_OF_MAINTENANCE_ORDER',
      transient=false
) }}

with source_data as (
    SELECT
         MANDT,
		OBJNR,
		COCUR,
		BELTP,
		WRTTP,
		GJAHR,
		ACPOS,
		VERSN,
		PERBL,
		VORGA,
		BEMOT,
		ABKAT,
		WRT00,
		WRT01,
		WRT02,
		WRT03,
		WRT04,
		WRT05,
		WRT06,
		WRT07,
		WRT08,
		WRT09,
		WRT10,
		WRT11,
		WRT12,
		WRT13,
		WRT14,
		WRT15,
		WRT16,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__COST_STRUCTURE_OF_MAINTENANCE_ORDER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data