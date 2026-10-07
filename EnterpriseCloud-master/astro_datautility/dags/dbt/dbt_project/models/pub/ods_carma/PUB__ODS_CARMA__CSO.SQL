/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.51"
*************/

{{ config(
      materialized='view',
      alias='CSO',
      transient=false
) }}

with source_data as (
    SELECT
        CSO_ID,
        ORIG_SERVICE_ORDER_NBR,
        ORIG_NCDR_NBR,
        FINAL_ALLOWED_CONSUMPTION_DT,
        ALL_CSO_LINES_COMPLETE,
        COMPLETED_IN_BAAN_DT,
        COMPLETED_IN_BAAN_USER_ID,
        ASSIST_REQUEST_DT,
        ASSIST_REQUEST_BY_USER_ID,
        ASSIST_REQUEST_CMTS,
        CREATED_DT,
        CREATED_USER_ID,
        CREATED_ROLE_ID,
        FIRST_RMA_GEN_DT,
        FIRST_RMA_GEN_USER_ID,
        LAST_UPDATED_DT,
        LAST_UPDATED_USER_ID,
        INACTIVE_DT,
        INACTIVE_USER_ID,
        ACTIVE
    from {{ ref('ODS__CARMA__CSO') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data