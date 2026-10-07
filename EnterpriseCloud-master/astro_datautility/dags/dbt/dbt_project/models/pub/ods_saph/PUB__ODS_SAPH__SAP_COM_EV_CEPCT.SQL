/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.06.58"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_CEPCT',
      transient=false,
		  enabled=false
) }}

with source_data as (
    SELECT
        SPRAS,
        KOKRS,
        PRCTR,
        DATBI,
        KTEXT,
        LTEXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_CEPCT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data