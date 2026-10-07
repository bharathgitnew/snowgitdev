{{ config(
        alias = 'US_MACHINE_CTA_DELAY_REASON_HISTORY',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}


WITH REASON AS (
    SELECT 
        MAC_ID,
        ITEM_NO,
        DELAY_CD,
        CASE
            WHEN DELAY_CD = '11' THEN 'Under Start-Up'
            WHEN DELAY_CD = '21' THEN 'Hardware problem'
            WHEN DELAY_CD = '22' THEN 'Software problem'
            WHEN DELAY_CD = '23' THEN 'Process problem'
            WHEN DELAY_CD = '24' THEN 'Network problem'
            WHEN DELAY_CD = '25' THEN 'Unstable system problem'
            WHEN DELAY_CD = '26' THEN 'Spec/RFQ has not been satisfied'
            WHEN DELAY_CD = '32' THEN 'Other sales issue'
            WHEN DELAY_CD = '33' THEN 'No probess spec. agreement'
            WHEN DELAY_CD = '41' THEN 'Holding Start-Up due to customer issue'
            WHEN DELAY_CD = '42' THEN 'Customer new request'
            WHEN DELAY_CD = '43' THEN 'Customer-requested remaining work'
            WHEN DELAY_CD = '44' THEN 'Monitoring/Evaluation of the system'
            WHEN DELAY_CD = '45' THEN 'Internal paperwork'
            WHEN DELAY_CD = '46' THEN 'Waiting for customer sign-off'
            WHEN DELAY_CD = '51' THEN 'Done'
            WHEN DELAY_CD = '61' THEN 'Other than the aboves'
            WHEN DELAY_CD = '62' THEN 'Pre-Start-Up Issue'
            WHEN DELAY_CD = '320' THEN 'No Category'
            ELSE NULL
        END AS DELAY_CATEGORY,
        NOTE,
        MOD_DATE,
        MOD_EMP_NO,
        CASE
            WHEN LEFT(MOD_EMP_NO, 2) = 'US' THEN LEFT(REPLACE(MOD_EMP_NO, 'US', ''), 6)
            WHEN LEFT(MOD_EMP_NO, 2) = 'EU' THEN LEFT(REPLACE(MOD_EMP_NO, 'EU', ''), 6)
            ELSE LEFT(MOD_EMP_NO, 6)
        END AS MODIFIEDBY_EMPLOYEE_ID,
        _FILEDATE,
        ROW_NUMBER() OVER (
            PARTITION BY (MAC_ID || '.' || ITEM_NO)
            ORDER BY _FILEDATE
        ) AS MAC_ID_ITEM_RN
    FROM {{ ref('COMMON__WISDOM__WISDOM_SURB_DELAY') }}
),

MAC_LIST AS (
    SELECT 
        MACHINE_ID,
        MACHINE_SN,
        SWLH_MODEL,
        REGION_NAME AS CURRENT_REGION,
        CUSTOMER_NAME AS CURRENT_CUSTOMER_NAME,
        LOCATION_NAME AS CURRENT_LOCATION_NAME,
        MACHINE_HISTORY AS CURRENT_MACHINE_HISTORY_REASON,
        START_UP_STATUS AS CURRENT_STARTUP_STATUS
    FROM {{ ref('COMMON__WISDOM__TEA_MAC_LIST') }}
),

EMPLOYEE AS (
    SELECT 
        EMPLOYEE_ID,
        FULL_NAME AS EMPLOYEE_NAME
    FROM {{ ref('COMMON__SHARED_DATASETS__GLOBAL_EMPLOYEE') }}
),

source_data AS (
    SELECT 
        MAC_LIST.MACHINE_SN,
        MAC_LIST.CURRENT_REGION,
        MAC_LIST.CURRENT_CUSTOMER_NAME,
        MAC_LIST.CURRENT_LOCATION_NAME,
        MAC_LIST.CURRENT_MACHINE_HISTORY_REASON,
        MAC_LIST.CURRENT_STARTUP_STATUS,
        REASON.ITEM_NO,
        REASON.DELAY_CATEGORY,
        REASON.NOTE,
        REASON.MOD_DATE,
        REASON.MODIFIEDBY_EMPLOYEE_ID,
        EMPLOYEE.EMPLOYEE_NAME,
        REASON.MAC_ID,
        REASON.DELAY_CD,
        (REASON.MAC_ID || '.' || MAC_LIST.MACHINE_SN || '.' || REASON.ITEM_NO) AS MACID_SN_ITEM
    FROM REASON
        LEFT OUTER JOIN MAC_LIST ON MAC_LIST.MACHINE_ID = REASON.MAC_ID
        LEFT OUTER JOIN EMPLOYEE ON EMPLOYEE.EMPLOYEE_ID = REASON.MODIFIEDBY_EMPLOYEE_ID
    WHERE REASON.MAC_ID_ITEM_RN = 1
        AND MAC_LIST.CURRENT_REGION = 'North America'
),

transform_data as (
    select
        MACHINE_SN,
        CURRENT_REGION,
        CURRENT_CUSTOMER_NAME,
        CURRENT_LOCATION_NAME,
        CURRENT_MACHINE_HISTORY_REASON,
        CURRENT_STARTUP_STATUS,
        ITEM_NO,
        DELAY_CATEGORY,
        NOTE,
        MOD_DATE,
        MODIFIEDBY_EMPLOYEE_ID,
        EMPLOYEE_NAME,
        MAC_ID,
        DELAY_CD,
        MACID_SN_ITEM,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
    from source_data
),

type_data AS (
    SELECT 
        CAST(MACHINE_SN as VARCHAR(16777216)) AS MACHINE_SN,
        CAST(CURRENT_REGION as VARCHAR(16777216)) AS CURRENT_REGION,
        CAST(CURRENT_CUSTOMER_NAME as VARCHAR(16777216)) AS CURRENT_CUSTOMER_NAME,
        CAST(CURRENT_LOCATION_NAME as VARCHAR(16777216)) AS CURRENT_LOCATION_NAME,
        CAST(CURRENT_MACHINE_HISTORY_REASON as VARCHAR(16777216)) AS CURRENT_MACHINE_HISTORY_REASON,
        CAST(CURRENT_STARTUP_STATUS as VARCHAR(16777216)) AS CURRENT_STARTUP_STATUS,
        CAST(ITEM_NO as VARCHAR(16777216)) AS ITEM_NO,
        CAST(DELAY_CATEGORY as VARCHAR(16777216)) AS DELAY_CATEGORY,
        CAST(NOTE as VARCHAR(16777216)) AS NOTE,
        CAST(MOD_DATE as DATE) AS MOD_DATE,
        CAST(MODIFIEDBY_EMPLOYEE_ID as VARCHAR(16777216)) AS MODIFIEDBY_EMPLOYEE_ID,
        CAST(EMPLOYEE_NAME as VARCHAR(16777216)) AS EMPLOYEE_NAME,
        CAST(MAC_ID as VARCHAR(16777216)) AS MAC_ID,
        CAST(DELAY_CD as VARCHAR(16777216)) AS DELAY_CD,
        CAST(MACID_SN_ITEM as VARCHAR(16777216)) AS MACID_SN_ITEM,
        cast(AUDIT_LOG_ID as VARCHAR(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
    FROM transform_data
)

SELECT * FROM type_data