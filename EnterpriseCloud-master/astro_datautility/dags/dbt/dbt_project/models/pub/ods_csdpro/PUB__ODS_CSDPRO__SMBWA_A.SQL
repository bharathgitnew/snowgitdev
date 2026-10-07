/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='SMBWA_A',
      transient=false
) }}

with source_data as (
    SELECT
        SMBWA_A_ID,
        INCIDENT_ID,
        SMBWA_Q_ID,
        IS_SATISFACTORY,
        COMMENT
    from {{ ref('ODS__CSDPRO__SMBWA_A') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data