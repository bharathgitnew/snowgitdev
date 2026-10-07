/************
Model file generated from dbtGeneratePubViews: 07.18.2022.18.18.56"
*************/

{{ config(
      materialized='view',
      alias='SAP_MMM_EV_MDMA_GMX',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        MATNR,
 	 	BERID_TEXT,
 	 	BERID,
 	 	DISMM,
 	 	EISBE,
 	 	MABST,
 	 	MINBE,
 	 	WERKS,
 	 	BSTMA,
 	 	LOEKZ,
 	 	AUTRU,
 	 	PSTAT,
 	 	KZKFK,
 	 	SCM_MATLOCID_GUID16,
 	 	SCM_MATLOCID_GUID22,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_MMM_EV_MDMA_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data