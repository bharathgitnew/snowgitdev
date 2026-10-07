/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.22"
*************/

{{ config(
      materialized='view',
      alias='FST_STARTUP_SUPERVISORS',
      transient=false
) }}

with source_data as (
    SELECT
        BU,
        MACHINE_HISTORY_REASON,
        STARTUP_SUPERVISOR,
        STARTUP_SUPERVISOR_ID
    from {{ ref('ODS__MDM__FST_STARTUP_SUPERVISORS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data