{{ config(
      materialized='view',
      alias='STATISTICS_MOVEMENTS_FOR_CURRENT_STOCKS',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		SSOUR,
		VRSIO,
		SPMON,
		SPTAG,
		SPWOC,
		SPBUP,
		WERKS,
		MATNR,
		LGORT,
		PERIV,
		VWDAT,
		BASME,
		HWAER,
		MZUBB,
		WZUBB,
		AZUBB,
		MZUKB,
		AZUKB,
		MAGBB,
		WAGBB,
		AAGBB,
		MAGKB,
		AAGKB,
		AMBWG,
		MGVBR,
		WGVBR,
		AGVBR,
		MUVBR,
		WUVBR,
		AUVBR,
		ASTOR,
		BBNULL,
		KBNULL,
		GBNULL,
		BESZUG,
		WBESZUG,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__STATISTICS_MOVEMENTS_FOR_CURRENT_STOCKS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data