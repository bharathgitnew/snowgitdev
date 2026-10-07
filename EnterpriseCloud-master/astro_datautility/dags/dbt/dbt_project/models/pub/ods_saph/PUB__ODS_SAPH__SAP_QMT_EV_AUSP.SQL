/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.33"
*************/

{{ config(
      materialized='view',
      alias='SAP_QMT_EV_AUSP',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        OBJEK,
        ATINN,
        ATZHL,
        MAFID,
        KLART,
        ADZHL,
        ATWRT,
        ATFLV,
        ATAWE,
        ATFLB,
        ATAW1,
        ATCOD,
        ATTLV,
        ATTLB,
        ATPRZ,
        ATINC,
        ATAUT,
        AENNR,
        DATUV,
        LKENZ,
        ATIMB,
        ATZIS,
        ATSRT,
        ATVGLART,
        DATUB,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_QMT_EV_AUSP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data