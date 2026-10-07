{{ config(
      materialized='view',
      alias='LOCATIONS',
      transient=false
) }}

with source_data as (
    SELECT
        CompanyID,
        LocationCode,
        Description,
        Address1,
        Address2,
        City,
        StateProv,
        PostalCode,
        ISRegion,
        LastUpdated,
        LastUpdatedBy,
        AddressCode
    from {{ ref('ODS__TEACOMMON__LOCATIONS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data