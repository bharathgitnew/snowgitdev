{{ config(
      materialized='view',
      alias='CONTACT',
      transient=false
) }}

with source_data as (
    SELECT
        ID,
        EMPLOYEEID,
        CDI_TOTALSCORE,
        CDI_VISITORKEY,
        CDI_IDENTIFIEDON,
        TMKTG_TOTALPAGEVIEWS,
        TMKTG_TOTALPAGEVIEWS_DATE,
        TMKTG_TOTALPAGEVIEWS_STATE,
        TMKTG_TOTALVISITS,
        TMKTG_TOTALVISITS_DATE,
        TMKTG_TOTALVISITS_STATE,
        MODIFIEDON
    from {{ ref('ODS__TELCUSTOMER__CONTACT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data