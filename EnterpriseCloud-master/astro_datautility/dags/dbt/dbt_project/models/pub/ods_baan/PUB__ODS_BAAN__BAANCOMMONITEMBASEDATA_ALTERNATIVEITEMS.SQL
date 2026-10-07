{{ config(
      materialized='view',
      alias='BAANCOMMONITEMBASEDATA_ALTERNATIVEITEMS',
      transient=false
) }}

with source_data as (
    SELECT
    _CAPTUREDATETIME,
    _COMPANYID,
    ITEM,
    ALTERNATIVEITEMS,
    PRIORITY,
    REVERSEDESCRIPTION,
    REVERSEID,
    INTERCHANGEABLEDESCRIPTION,
    INTERCHANGEABLEID,
    INTRODUCTIONDATE,
    EXPIRYDATE,
    REPLACEMENTDESCRIPTION,
    REPLACEMENTID
    FROM {{ ref('ODS__BAAN__BAANCOMMONITEMBASEDATA_ALTERNATIVEITEMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data