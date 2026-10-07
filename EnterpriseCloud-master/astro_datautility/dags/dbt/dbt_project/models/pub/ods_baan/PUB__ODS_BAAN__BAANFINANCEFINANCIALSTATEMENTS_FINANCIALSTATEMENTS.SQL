/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.09"
*************/

{{ config(
      materialized='view',
      alias='BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DATECREATED,
        DATEMODIFIED,
        FINANCIALSTATEMENT,
        LASTMODIFIEDBYUSER,
        STATEMENTDESCRIPTION,
        TIMECREATED,
        TIMEMODIFIED,
        USERCREATED
    from {{ ref('ODS__BAAN__BAANFINANCEFINANCIALSTATEMENTS_FINANCIALSTATEMENTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data