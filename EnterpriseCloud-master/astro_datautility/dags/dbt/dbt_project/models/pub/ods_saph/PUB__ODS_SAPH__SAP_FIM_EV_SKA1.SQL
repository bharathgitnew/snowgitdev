/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.02"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_SKA1',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        KTOPL,
        SAKNR,
        SAKAN,
        BILKT,
        ERDAT,
        ERNAM,
        XBILK,
        GVTYP,
        KTOKS,
        XLOEV,
        XSPEA,
        XSPEB,
        XSPEP,
        MCOD1,
        GLACCOUNT_TYPE,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_SKA1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data