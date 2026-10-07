{{ config(
      materialized='view',
      alias='MATERIAL_DATA_FOR_EACH_WAREHOUSE_NUMBER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
		MATNR,
		LGNUM,
		LVORM,
		LGBKZ,
		LTKZE,
		LTKZA,
		LHMG1,
		LHMG2,
		LHMG3,
		LHME1,
		LHME2,
		LHME3,
		LETY1,
		LETY2,
		LETY3,
		LVSME,
		KZZUL,
		BLOCK,
		KZMBF,
		BSSKZ,
		MKAPV,
		BEZME,
		PLKPT,
		VOMEM,
		L2SKR,
		_CAPTUREDATETIME
    from {{ ref('ODS__SAPO__MATERIAL_DATA_FOR_EACH_WAREHOUSE_NUMBER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data