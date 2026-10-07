/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.19"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONFIGURATIONCONTROL_SURBERRORMASTERTABLE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ERRORCODE,
        ERRORMESSAGE
    from {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_SURBERRORMASTERTABLE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data