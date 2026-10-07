/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.20"
*************/

{{ config(
      materialized='view',
      alias='EMPLOYEE_ADP_CODE_MAPPING',
      transient=false
) }}

with source_data as (
    SELECT
        ADP_CODE,
        COMPANY_NAME,
        COMPANY_CODE,
        COMPANY_TYPE,
        COMPANY_EMP_TYPE,
        FIELDGLASS_NAME,
        EXPAT_FLAG,
        EMP_CATEGORY
    from {{ ref('ODS__MDM__EMPLOYEE_ADP_CODE_MAPPING') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data