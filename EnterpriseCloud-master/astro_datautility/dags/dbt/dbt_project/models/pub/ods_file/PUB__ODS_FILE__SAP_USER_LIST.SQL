/************
Model file generated from dbtGeneratePubViews: 03.03.2023.17.18.00"
*************/

{{ config(
      materialized='view',
      alias='SAP_USER_LIST',
      transient=false
) }}

with source_data as (
    SELECT
        NAME,
        EMP_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        SUPERVISOR,
        COMPANY,
        BAAN_DEPARTMENT_CODE,
        BAAN_COMPANY_CODE,
        BAAN_SEGMENT_CODE,
        BAAN_OFFICE_CODE,
        COST_CENTER_CODE,
        COST_CENTER_OWNER,
        _FILEDATE
    from {{ ref('ODS__FILE__SAP_USER_LIST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data