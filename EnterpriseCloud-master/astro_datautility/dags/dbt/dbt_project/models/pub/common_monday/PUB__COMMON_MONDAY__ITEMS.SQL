{{ config(
    materialized='view',
    alias='ITEMS'
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
        -- ,ITEMS_GROUP_TITLE
        ,PROJECT_STATUS_R
        ,CLASS_R
        ,BUSINESS_GROUP_R
        ,TASKS_STATUS_R
        ,STRATEGIC_INITIATIVE_R
        ,PROJECT_MANAGER_R
        ,SPONSOR_R
        ,TEAM_MEMBERS_R
        ,GOAL_STATEMENT_R
        ,PROBLEM_STATEMENT_R
        ,SCOPE_R
        ,BUSINESS_CASE_R
        ,LEVEL_OF_CONFIDENTIALITY_R
        ,STARTDATE_ENDDATE_R
        ,PROJECT_COMPLETION_R
        ,GROUP_R
        ,PRIORITY_R
        ,CREATION_LOG_R
        ,SPONSOR_BUSINESS_GROUP_O
        ,RESOURCE_HOURS_O
        ,COST_TO_IMPLEMENT_O
        ,FINANCIAL_IMPACT_O
        ,INTANGIBLE_IMPACT_O
        ,FOUR_CORNERS_O
        ,PHASE_O
        ,RELATED_DOCS_O
        ,ITEMS_STARTDATE
        ,ITEMS_ENDDATE
        ,ITEMS_DURATION
        ,PROJECT_FLAG_R
        -- ,SUBITEMS_STARTDATE_MIN
        -- ,SUBITEMS_ENDDATE_MAX
        -- ,GT_TASK_OWNER_R
        -- ,GT_TIMELINE_R
        -- ,GT_TASK_DURATION_R
        -- ,GT_PRIORITY_R
        -- ,GT_TASK_COMPLETION_R
        -- ,GT_TASK_DESCRIPTION_R
        -- ,GT_TASK_STARTDATE
        -- ,GT_TASK_ENDDATE
        ,ITEMS_UPDATED_AT
        ,_FILEDATE
    FROM {{ ref('COMMON__MONDAY__ITEMS') }}
)

,transform_data AS
(
    SELECT * FROM source_data
)

SELECT * FROM transform_data