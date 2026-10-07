/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.40.38"
*************/

{{ config(
      materialized='view',
      alias='TBL_ASSETS',
      transient=false
) }}

with source_data as (
    SELECT
        ASSET_ID,
        ASSET_UNIQUE,
        DOMAIN,
        USER_NAME,
        USER_DOMAIN,
        FQDN,
        IP_ADDRESS,
        IP_NUMERIC,
        SITE_ID,
        SCAN_SERVER,
        OS_CODE,
        SP,
        DESCRIPTION,
        DESCRIPTION_LOCK,
        ASSET_TYPE,
        ASSET_TYPE_LOCK,
        ASSET_NAME,
        ASSET_NAME_LOCK,
        MAC,
        FIRST_SEEN,
        LAST_SEEN,
        LAST_TRIED,
        LAST_TRIGGERED,
        LAST_SCHEDULED,
        LAST_ACTIVE_SCAN,
        LAST_IP_SCAN,
        LAST_LS_PUSH,
        LAST_SAVED,
        UPTIME,
        MEMORY,
        NR_PROCESSORS,
        PROCESSOR,
        SERVICE_VERSION,
        LAST_WORK_GROUP_SCAN,
        LOCATION_ID,
        MANUAL_MAC,
        LAST_CHANGED,
        LAST_LS_FALLBACK,
        BUILD_NUMBER,
        VERSION,
        LS_AGENT_VERSION,
        LAST_LS_AGENT,
        HOST_TYPE_ID,
        LAST_PERFORMANCE_SCAN,
        SCANNED_BY,
        LAST_SCCM_SCAN,
        _FILEDATE,
        LS_PUSH_VERSION
    from {{ ref('ODS__LANSWEEPER__TBL_ASSETS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data