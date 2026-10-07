/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINE_CHAMBER_EXCEPTION_LIST',
      transient=false
) }}

with source_data as (
    SELECT
        SN,
        BU,
        WISDOM_PARENT_SN,
        EXCEPTION_REASON,
        LAST_VERIFICATION_DATE
    from {{ ref('ODS__MDM__MACHINE_CHAMBER_EXCEPTION_LIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data