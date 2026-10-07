/************
Model file generated from dbtGeneratePubViews: 09.13.2022.05.07.52"
*************/

{{ config(
      materialized='view',
      alias='SAP_COM_EV_CSKS',
      transient=false,
		  enabled=false
) }}

with source_data as (
    SELECT
        KOKRS,
        KOSTL,
        DATBI,
        DATAB,
        BKZKP,
        PKZKP,
        BUKRS,
        GSBER,
        KOSAR,
        VERAK,
        WAERS,
        PRCTR,
        WERKS,
        LOGSYSTEM,
        ERSDA,
        USNAM,
        ABTEI,
        KOSZSCHL,
        LAND1,
        KHINR,
        CCKEY,
        KOMPL,
        STAKZ,
        OBJNR,
        ZCCSRGKY,
        BKZKS,
        PKZKS,
        BKZER,
        PKZER,
        BKZOB,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_COM_EV_CSKS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data