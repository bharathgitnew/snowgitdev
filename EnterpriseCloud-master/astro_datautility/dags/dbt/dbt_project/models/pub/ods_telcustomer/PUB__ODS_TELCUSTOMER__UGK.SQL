{{ config(
      materialized='view',
      alias='UGK',
      transient=false
) }}

with source_data as (
    SELECT
        UGK_ID,
        BU,
        DOC_NUMBER,
        NAME,
        LANGUAGE,
        FILENAME,
        ACL_RULE,
        ACL_APPLIES_TO,
        CREATE_DT,
        UPDATE_BY,
        UPDATE_DT,
        ACTIVE,
        PUBLISH_MONTH,
        PUBLISH_YEAR,
        BENEFIT_FORMAT
    from {{ ref('ODS__TELCUSTOMER__UGK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data