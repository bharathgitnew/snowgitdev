/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.03"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONSYSTEMTABLES_PROJECTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION_DSCA,
        DESCRIPTION_DSCB,
        PCSPROJECTUSAGEDESCRIPTION,
        PCSPROJECTUSAGEID,
        PROJECT,
        PROJECTPACKAGELINKDESCRIPTION,
        PROJECTPACKAGELINKID,
        SEARCHKEY_SEAB,
        SEARCHKEY_SEAK,
        TEXT
    from {{ ref('ODS__BAAN__BAANCOMMONSYSTEMTABLES_PROJECTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data