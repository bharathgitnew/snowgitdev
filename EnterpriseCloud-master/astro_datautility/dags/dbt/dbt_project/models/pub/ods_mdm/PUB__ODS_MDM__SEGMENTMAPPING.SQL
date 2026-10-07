/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.31"
*************/

{{ config(
      materialized='view',
      alias='SEGMENTMAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        SEGMENTCODE,
        SEGMENTDESCRIPTION,
        SEGMENTSHORTNAME,
        SEGMENTGROUP,
        STANDARDMACHINEBU,
        GROUPMACHINEBU,
        PAIDSERVICEFORECASTMACHINEBU,
        SALESFORECASTBUNAME,
        SALESFORECASTBUGROUP,
        FSFLAG,
        FSBUGROUP
    from {{ ref('ODS__MDM__SEGMENTMAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data