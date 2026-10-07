/************
Model file generated from dbtGeneratePubViews: 09.07.2022.09.55.09"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_CEPC',
      transient=false,
		  enabled=false
) }}

with source_data as (
    SELECT
        KOKRS,
        PRCTR,
        DATBI,
        DATAB,
        ERSDA,
        USNAM,
        MERKMAL,
        ABTEI,
        VERAK,
        WAERS,
        BUKRS,
        KHINR,
        ZPCSRGKY,
        LOCK_IND,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_CEPC') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data