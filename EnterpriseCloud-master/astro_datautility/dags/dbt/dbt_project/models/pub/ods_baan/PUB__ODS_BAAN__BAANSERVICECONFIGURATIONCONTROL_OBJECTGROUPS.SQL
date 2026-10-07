/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.17"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        LABORRATE,
        OBJECTGROUP
    from {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_OBJECTGROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data