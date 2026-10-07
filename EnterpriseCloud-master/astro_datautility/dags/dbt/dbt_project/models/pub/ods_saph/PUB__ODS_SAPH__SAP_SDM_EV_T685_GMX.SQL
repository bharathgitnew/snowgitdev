/************
Model file generated from dbtGeneratePubViews: 02.02.2023.03.56.43"
*************/

{{ config(
      materialized='view',
      alias='SAP_SDM_EV_T685_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        KVEWE,
        KAPPL,
        KSCHL,
        KOZGF,
        DATVO,
        DTVOB,
        OBSOLETE,
        J_3GPRAEND,
        J_3GBUARTL,
        J_3GBUARTB,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_SDM_EV_T685_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data