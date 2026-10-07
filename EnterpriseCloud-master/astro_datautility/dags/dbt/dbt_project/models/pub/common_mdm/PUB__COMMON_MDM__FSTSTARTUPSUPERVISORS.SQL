/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.11"
*************/

{{ config(
      materialized='view',
      alias='FSTSTARTUPSUPERVISORS',
      transient=false
) }}

with source_data as (
    SELECT
        BU,
        MACHINE_HISTORY_REASON,
        STARTUP_SUPERVISOR,
        STARTUP_SUPERVISOR_ID
    from {{ ref('COMMON__MDM__FSTSTARTUPSUPERVISORS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data