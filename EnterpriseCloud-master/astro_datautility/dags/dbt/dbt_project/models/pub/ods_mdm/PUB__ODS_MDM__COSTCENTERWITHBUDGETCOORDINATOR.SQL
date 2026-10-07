/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.19"
*************/

{{ config(
      materialized='view',
      alias='COSTCENTERWITHBUDGETCOORDINATOR',
      transient=false
) }}

with source_data as (
    SELECT
        NAME,
        DIVISIONNAME,
        DIVISIONOWNERID,
        DIVISIONOWNERNAME,
        SUBDIVISIONNAME,
        SUBDIVISIONOWNERID,
        SUBDIVISIONOWNERNAME,
        GROUPNAME,
        GROUPOWNERID,
        GROUPOWNERNAME,
        STATUS,
        EFFECTIVEDATE,
        EXPIRATIONDATE,
        BUDGETCOORDINATORID,
        BUDGETCOORDINATORNAME,
        COSTCENTERGROUP
    from {{ ref('ODS__MDM__COSTCENTERWITHBUDGETCOORDINATOR') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data