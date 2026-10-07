/************
Model file generated from dbtGeneratePubViews: 10.18.2022.03.17.34"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_INOB',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        CUOBJ,
        KLART,
        OBTAB,
        OBJEK,
        ROBTAB,
        ROBJEK,
        CLINT,
        STATU,
        CUCOZHL,
        PARENT,
        ROOT,
        EXPERTE,
        MATNR,
        DATUV,
        TECHS,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_INOB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data