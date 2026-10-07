/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.22"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICESERVICEORDERCONTROL_MAINTAINREASONFORORDERINGPARTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        REASONCODE
    from {{ ref('ODS__BAAN__BAANSERVICESERVICEORDERCONTROL_MAINTAINREASONFORORDERINGPARTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data