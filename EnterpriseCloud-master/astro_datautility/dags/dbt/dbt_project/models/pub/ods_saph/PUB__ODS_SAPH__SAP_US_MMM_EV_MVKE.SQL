/************
Model file generated from dbtGeneratePubViews: 10.11.2022.09.06.58"
*************/

{{ config(
      materialized='view',
      alias='SAP_US_MMM_EV_MVKE',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        MATNR,
        VKORG,
        VTWEG,
        ERSDA,
        LAEDA,
        LVORM,
        VERSG,
        PRODH,
        MVGR1,
        MVGR2,
        MVGR3,
        MVGR4,
        MVGR5,
        PRAT1,
        PRAT2,
        PRAT3,
        PRAT4,
        PRAT5,
        PRAT6,
        PRAT7,
        PRAT8,
        PRAT9,
        PRATA,
        VRKME,
        VMSTA,
        VMSTD,
        DWERK,
        AUMNG,
        MEINS,
        LFMNG,
        MEINS001,
        SCMNG,
        MEINS002,
        KONDM,
        MTPOS,
        ZZORITN,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_US_MMM_EV_MVKE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data