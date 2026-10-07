{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SEGMENT_MAPPING',
    unique_key = ['SEGMENT_CODE']
) }}

WITH segment_all AS
(
    SELECT
        DISTINCT SAP_CODE AS SEGMENTCODE
    FROM {{ ref('COMMON__SAPH__SAP_SEGMENT') }}
    UNION
    SELECT
        DISTINCT LEFT(DIMENSION_2,4)
    FROM {{ source('ODS__BAAN', 'LEGACY_TELR_BAANV_TEA_FINALIZED_TRANSACTIONS') }}
    WHERE LEN(DIMENSION_2) > 1
),
sap_segment AS
(
    SELECT
        SAP_CODE
        ,ORACLE_CODE
        ,ORACLE_DESCRIPTION
        ,SAP_DESCRIPTION
    FROM {{ ref('COMMON__SAPH__SAP_SEGMENT') }}
    WHERE SAP_CODE IS NOT NULL
),
mapping AS (
    SELECT
        SEGMENT_CODE
        ,SEGMENT_NAME
        ,SOURCE
        ,BU_GROUP
        ,BU_GROUP_2
        ,MACHINE_BU
        ,GCE_BU
        ,FS_FLAG
    FROM {{ ref('ODS__SHAREPOINT__SERVICE_SEGMENT_MAPPING') }}
),
transform_data AS (
    SELECT
        segment_all.SEGMENTCODE AS SEGMENT_CODE
        ,mapping.SEGMENT_NAME
        ,mapping.BU_GROUP
        ,mapping.BU_GROUP_2
        ,mapping.MACHINE_BU
        ,mapping.GCE_BU
        ,mapping.FS_FLAG
        ,CASE
            WHEN
                UPPER(mapping.SOURCE) = 'BAAN' THEN 'S'||segment_all.SEGMENTCODE
            ELSE COALESCE(sap_segment.ORACLE_CODE,MAPTOMAP.ORACLE_CODE)
            END AS ORACLE_CODE
        ,COALESCE(sap_segment.ORACLE_DESCRIPTION,MAPTOMAP.ORACLE_DESCRIPTION) AS ORACLE_DESCRIPTION
        ,COALESCE(sap_segment.SAP_DESCRIPTION,MAPTOMAP.SAP_DESCRIPTION) AS SAP_DESCRIPTION
        ,CASE
            WHEN
                sap_segment.SAP_CODE IS NOT NULL THEN 'SAP'
            ELSE mapping.SOURCE
            END AS SOURCE_APPLICATION
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH
    FROM segment_all
    LEFT OUTER JOIN sap_segment
    ON segment_all.SEGMENTCODE = sap_segment.SAP_CODE
    LEFT OUTER JOIN mapping
    ON segment_all.SEGMENTCODE = mapping.SEGMENT_CODE
    LEFT OUTER JOIN sap_segment MAPTOMAP
    ON MAPTOMAP.ORACLE_CODE = 'S'||mapping.SEGMENT_CODE
    WHERE NULLIF(segment_all.SEGMENTCODE, '') IS NOT NULL OR LEN(segment_all.SEGMENTCODE) < 1
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY segment_all.SEGMENTCODE ORDER BY mapping.BU_GROUP,mapping.SEGMENT_NAME) = 1)
),

type_data AS
(
    SELECT
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
        ,CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
        ,CAST(SEGMENT_CODE as VARCHAR(16777216)) AS SEGMENT_CODE
        ,CAST(SEGMENT_NAME as VARCHAR(16777216)) AS SEGMENT_NAME
        ,CAST(BU_GROUP as VARCHAR(16777216)) AS BU_GROUP
        ,CAST(BU_GROUP_2 as VARCHAR(16777216)) AS BU_GROUP_2
        ,CAST(MACHINE_BU as VARCHAR(16777216)) AS MACHINE_BU
        ,CAST(GCE_BU as VARCHAR(16777216)) AS GCE_BU
        ,CAST(FS_FLAG as VARCHAR(16777216)) AS FS_FLAG
        ,CAST(ORACLE_CODE as VARCHAR(16777216)) AS ORACLE_CODE
        ,CAST(ORACLE_DESCRIPTION as VARCHAR(16777216)) AS ORACLE_DESCRIPTION
        ,CAST(SAP_DESCRIPTION as VARCHAR(16777216)) AS SAP_DESCRIPTION
        ,CAST(SOURCE_APPLICATION as VARCHAR(16777216)) AS SOURCE_APPLICATION
    FROM transform_data
)
SELECT * FROM type_data