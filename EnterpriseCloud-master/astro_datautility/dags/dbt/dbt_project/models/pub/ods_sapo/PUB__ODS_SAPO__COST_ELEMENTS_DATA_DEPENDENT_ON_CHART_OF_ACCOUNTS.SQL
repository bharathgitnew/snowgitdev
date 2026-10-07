{{ config(
      materialized='view',
      alias='COST_ELEMENTS_DATA_DEPENDENT_ON_CHART_OF_ACCOUNTS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		KTOPL,
		KSTAR,
		ERSDA,
		USNAM,
		STEKZ,
		ZAHKZ,
		KSTSN,
		FUNC_AREA,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__COST_ELEMENTS_DATA_DEPENDENT_ON_CHART_OF_ACCOUNTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data