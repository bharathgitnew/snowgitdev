/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.06.58"
*************/

{{ config(
      materialized='view',
      alias='SAP_FIM_EV_LFB1',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        LIFNR,
        BUKRS,
        PERNR,
        ERDAT,
        ERNAM,
        SPERR,
        LOEVM,
        ZUAWA,
        AKONT,
        BEGRU,
        ZAHLS,
        ZTERM,
        ZSABE,
        KVERM,
        LNRZE,
        LNRZB,
        ZWELS,
        HBKID,
        XVERR,
        TLFXS,
        INTAD,
        QSREC,
        QSZNR,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_FIM_EV_LFB1') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data