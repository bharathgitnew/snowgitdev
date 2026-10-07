{{ config(
      materialized='view',
      alias='COST_ELEMENT_TEXTS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		SPRAS,
		KTOPL,
		KSTAR,
		KTEXT,
		LTEXT,
		MCTXT,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__COST_ELEMENT_TEXTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data