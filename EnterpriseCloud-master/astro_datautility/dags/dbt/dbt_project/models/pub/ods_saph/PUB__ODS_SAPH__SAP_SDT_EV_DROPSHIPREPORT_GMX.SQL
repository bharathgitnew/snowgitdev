/************
Model file generated from dbtGeneratePubViews: 04.12.2023.07.14.09
*************/

{{ config(
      materialized='view',
      alias='SAP_SDT_EV_DROPSHIPREPORT_GMX',
      transient=false
) }}

with source_data as (
    SELECT
       VBAK_VBELN_TEA, 
 	 	VBAP_VBELN_TEA, 
 	 	VBAP_POSNR_TEA, 
 	 	VBAP_MATNR_TEA, 
 	 	VBAP_ARKTX_TEA, 
 	 	VBAP_NETWR_TEA, 
 	 	VBAP_MEINS_TEA, 
 	 	VBAP_KWMENG_TEA, 
 	 	VBAP_WERKS_TEA, 
 	 	VBAP_LGORT_TEA, 
 	 	VBAP_VSTEL_TEA, 
 	 	VBAP_ERDAT_TEA, 
 	 	VBAP_ZZSWDD_TEA, 
 	 	VBAP_ZZSWDDCG_TEA, 
 	 	LIPS_VGBEL_TEA_SO, 
 	 	LIPS_VBELN_TEA_SO, 
 	 	LIPS_POSNR_TEA_SO, 
 	 	LIPS_LFIMG_TEA_SO, 
 	 	LIKP_WADAT_IST_TEA_SO, 
 	 	VBRP_VGBEL_TEA, 
 	 	VBRP_VGPOS_TEA, 
 	 	VBRP_VBELN_TEA, 
 	 	VBRP_POSNR_TEA, 
 	 	VBRP_FBUDA_TEA, 
 	 	VBRP_MATNR_TEA, 
 	 	VBRP_FKIMG_TEA, 
 	 	VBRP_ERDAT_TEA, 
 	 	VBFA_VBELV, 
 	 	VBFA_POSNV, 
 	 	VBFA_VBELN, 
 	 	VBFA_POSNN, 
 	 	VBFA_VBTYP_N, 
 	 	EKPO_EBELN_TEA, 
 	 	EKPO_EBELP_TEA, 
 	 	EKPO_MATNR_TEA, 
 	 	EKPO_MENGE_TEA, 
 	 	EKPO_ZZPODDZ, 
 	 	EKPO_ZZSCDDZ, 
 	 	EKPO_AEDAT, 
 	 	LIPS_VGBEL_TEA_PO, 
 	 	LIPS_VGPOS_TEA_PO, 
 	 	LIPS_VBELN_TEA_PO, 
 	 	LIPS_POSNR_TEA_PO, 
 	 	LIPS_LFIMG_TEA_PO, 
 	 	LIKP_WADAT_IST_TEA_PO, 
 	 	ZSDT0093_BSTKD, 
 	 	ZSDT0093_VBELN, 
 	 	ZSDT0093_ZREINO, 
 	 	VBAP_VBELN_TEL_SO, 
 	 	VBAP_POSNR_TEL_SO, 
 	 	LIPS_VGBEL_TEL_SO, 
 	 	LIPS_VGPOS_TEL_SO, 
 	 	LIPS_VBELN_TEL_SO, 
 	 	LIPS_POSNR_TEL_SO, 
 	 	LIKP_WADAT_TEL_SO, 
 	 	LIKP_WADAT_IST_TEL_SO, 
 	 	LIPS_MATNR_TEL_SO, 
 	 	LIPS_LFIMG_TEL_SO, 
 	 	LIPS_ERDAT_TEL_SO, 
 	 	VBRP_VGBEL_TEL_SO, 
 	 	VBRP_VGPOS_TEL_SO, 
 	 	PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDT_EV_DROPSHIPREPORT_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data