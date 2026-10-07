/************
Model file generated from dbtGeneratePubViews: 02.20.2023.06.07.12"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_KNMT',
      transient=false
) }}

with source_data as (
    SELECT
        VKORG,
        VTWEG,
        KUNNR,
        MATNR,
        ERNAM,
        ERDAT,
        SORTL,
        KDMAT,
        POSTX,
        LPRIO,
        MINLF,
        MEINS,
        MEINS001,
        CHSPL,
        KZTLF,
        ANTLF,
        UNTTO,
        UEBTO,
        UEBTK,
        WERKS,
        RDPRF,
        MEGRU,
        VRKME_T,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_KNMT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data