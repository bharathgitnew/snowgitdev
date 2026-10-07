/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.21"
*************/

{{ config(
      materialized='view',
      alias='FINANCIALCOSTCENTER',
      transient=false
) }}

with source_data as (
    SELECT
        COSTCENTERID,
        SUBDIVISIONID,
        SUBDIVISIONNAME,
        DIVISIONID,
        DIVISIONNAME,
        SEGMENTID,
        SEGMENTNAME,
        DEPARTMENTID,
        DEPARTMENTNAME,
        SECTIONID,
        SECTIONNAME,
        COMPANYID,
        COMPANYNAME,
        SUBDIVISIONOWNERUSERID,
        SUBDIVISIONOWNERUSERNAME,
        DIVISIONOWNERUSERID,
        DIVISIONOWNERUSERNAME,
        SECTIONOWNERUSERNAME,
        EFFECTIVEDATE,
        SECTIONOWNERUSERID
    from {{ ref('ODS__MDM__FINANCIALCOSTCENTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data