{{ config(
    materialized='view',
    alias='SUBITEMS'
) }}

WITH source_data AS 
(
    SELECT 
        WORKSPACE_ID
        ,WORKSPACE_NAME
        ,ACCOUNT_ID
        ,BOARDS_ID
        ,BOARDS_NAME
        ,ITEMS_ID
        ,ITEMS_NAME
        ,SUBITEMS_ID
        ,SUBITEMS_NAME
        ,SUBITEMS_OWNER_R
        ,SUBITEMS_TIMELINE_R
        ,SUBITEMS_DURATION_R
        ,SUBITEMS_STATUS_R
        ,SUBITEMS_COMPLETION_R
        ,SUBITEMS_STARTDATE
        ,SUBITEMS_ENDDATE
        ,SUBITEMS_UPDATED_AT
        ,_FILEDATE
    FROM {{ ref('COMMON__MONDAY__SUBITEMS') }}
)

,transform_data AS
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data