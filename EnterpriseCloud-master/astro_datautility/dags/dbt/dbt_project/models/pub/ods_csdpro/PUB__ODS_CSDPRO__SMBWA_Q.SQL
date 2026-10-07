/************
Model file generated from dbtGeneratePubViews: 11.03.2022.11.24.28"
*************/

{{ config(
      materialized='view',
      alias='SMBWA_Q',
      transient=false
) }}

with source_data as (
    SELECT
        SMBWA_Q_ID,
        QUESTION,
        INCIDENT_CLASSIFICATION_ID,
        QUESTION_NUMBER,
        INACTIVE_DATE
    from {{ ref('ODS__CSDPRO__SMBWA_Q') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data