/************
Model file generated from dbtGeneratePubViews: 03.02.2023.08.55.43"
*************/

{{ config(
      materialized='view',
      alias='SAP_AAM_EV_T090NAT_GMX',
      transient=false
) }}

with source_data as (
    SELECT
        SPRAS,
        AFAPL,
        AFASL,
        AFATXT,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        _FILEDATE,
        _FILENAME
    from {{ ref('ODS__SAPH__SAP_AAM_EV_T090NAT_GMX') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data