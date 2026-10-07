{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='MACHINE_BUSINESS_UNIT_MAPPING',
    unique_key = ['MACHINE_BU']
) }}

WITH machine_bu AS
(
    SELECT
        MACHINE_BU_KEY
        ,CASE
            WHEN
                MACHINE_BU_KEY = 'FSI' THEN 'CCS'
            WHEN
                MACHINE_BU_KEY = 'EP' THEN 'GCIB'
            WHEN
                LEFT(MACHINE_BU_KEY,3) = '3DI' THEN '3DI'
            ELSE MACHINE_BU_KEY
            END AS MACHINE_BU_KEY_ADJ
        ,MACHINE_BU_NAME
        ,TEL_GROUP_BU
        ,FS_BU_NAME
        ,BAAN_CONFIG_PREFIX
        ,ACTIVE_BU_FLAG
        ,CHANGE_COMMENTS
    FROM {{ ref('ODS__FILE__MACHINE_BUSINESS_UNIT_MAPPING') }}
),
segment AS
(
    SELECT DISTINCT
        MACHINE_BU
        ,GCE_BU
        ,BU_GROUP
        ,BU_GROUP_2
    FROM {{ ref('ODS__SHAREPOINT__SERVICE_SEGMENT_MAPPING') }}
),
bu_leader AS
(
    SELECT
        BU_SOURCE_KEY
        ,BU_GROUP_LEADER
        ,BU_GROUP_LEADER_ID
    FROM {{ ref('ODS__SHAREPOINT__SERVICE_BUSINESS_UNIT_MAPPING') }}
),
combined AS
(
    SELECT
        machine_bu.MACHINE_BU_KEY AS MACHINE_BU
        ,machine_bu.MACHINE_BU_NAME
        ,segment.GCE_BU
        ,segment.BU_GROUP
        ,segment.BU_GROUP_2
        ,bu_leader.BU_GROUP_LEADER
        ,bu_leader.BU_GROUP_LEADER_ID
        ,machine_bu.TEL_GROUP_BU
        ,machine_bu.FS_BU_NAME
        ,machine_bu.BAAN_CONFIG_PREFIX
        ,machine_bu.ACTIVE_BU_FLAG
        ,machine_bu.CHANGE_COMMENTS
        FROM machine_bu
        LEFT OUTER JOIN segment
        ON machine_bu.MACHINE_BU_KEY_ADJ = segment.MACHINE_BU
        LEFT OUTER JOIN bu_leader
        ON machine_bu.MACHINE_BU_KEY_ADJ = bu_leader.BU_SOURCE_KEY
        WHERE LEN(machine_bu.MACHINE_BU_KEY) > 1
        QUALIFY ROW_NUMBER() over (partition by machine_bu.MACHINE_BU_KEY order by machine_bu.ACTIVE_BU_FLAG) = 1
),
transform_data AS
(
    SELECT
        MACHINE_BU
        ,MACHINE_BU_NAME
        ,GCE_BU
        ,BU_GROUP
        ,BU_GROUP_2
        ,BU_GROUP_LEADER
        ,BU_GROUP_LEADER_ID
        ,TEL_GROUP_BU
        ,FS_BU_NAME
        ,BAAN_CONFIG_PREFIX
        ,ACTIVE_BU_FLAG
        ,CHANGE_COMMENTS
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH
    FROM combined
    ORDER BY ACTIVE_BU_FLAG DESC, MACHINE_BU
),
type_data AS
(
    SELECT
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
        ,CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
        ,CAST(MACHINE_BU as VARCHAR(16777216)) AS MACHINE_BU
        ,CAST(MACHINE_BU_NAME as VARCHAR(16777216)) AS MACHINE_BU_NAME
        ,CAST(GCE_BU as VARCHAR(16777216)) AS GCE_BU
        ,CAST(BU_GROUP as VARCHAR(16777216)) AS BU_GROUP
        ,CAST(BU_GROUP_2 as VARCHAR(16777216)) AS BU_GROUP_2
        ,CAST(BU_GROUP_LEADER as VARCHAR(16777216)) AS BU_GROUP_LEADER
        ,CAST(BU_GROUP_LEADER_ID as VARCHAR(16777216)) AS BU_GROUP_LEADER_ID
        ,CAST(TEL_GROUP_BU as VARCHAR(16777216)) AS TEL_GROUP_BU
        ,CAST(FS_BU_NAME as VARCHAR(16777216)) AS FS_BU_NAME
        ,CAST(BAAN_CONFIG_PREFIX as VARCHAR(16777216)) AS BAAN_CONFIG_PREFIX
        ,CAST(ACTIVE_BU_FLAG as VARCHAR(16777216)) AS ACTIVE_BU_FLAG
        ,CAST(CHANGE_COMMENTS as VARCHAR(16777216)) AS CHANGE_COMMENTS
    FROM transform_data
)
SELECT * FROM type_data