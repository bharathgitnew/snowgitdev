/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.01"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_CREDITRATINGS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTIONDESCRIPTION,
        ACTIONID,
        CREDITRATING,
        DESCRIPTION,
        INCLUDEOPENSALESORDERINFINANCIALRISKCALCULATIONDESCRIPTION,
        INCLUDEOPENSALESORDERINFINANCIALRISKCALCULATIONID,
        PHASE1CREDITCHECKDESCRIPTION,
        PHASE1CREDITCHECKID,
        PHASE2CREDITCHECKDESCRIPTION,
        PHASE2CREDITCHECKID,
        REVIEWCREDITRATINGAFTER
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_CREDITRATINGS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data