/************
Model file generated from dbtGeneratePubViews: 02.10.2023.12.59.36"
*************/

{{ config(
      materialized='view',
      alias='SAP_ZZM_EV_ADRC',
      transient=false,
	  enabled=false
) }}

with source_data as (
    SELECT
        *
    from {{ ref('ODS__SAPH__SAP_ZZM_EV_ADRC') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data