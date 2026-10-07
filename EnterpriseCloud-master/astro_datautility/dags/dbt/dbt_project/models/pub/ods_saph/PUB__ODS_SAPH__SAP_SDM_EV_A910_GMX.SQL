/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.02"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_A910_GMX',
      transient=false,
		  enabled=false
) }}

with source_data as (
    SELECT
        KAPPL,
        KSCHL,
        ZPLAND,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_A910_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data