{{ config(
        materialized = 'tel_incremental',
        incremental_strategy = 'merge',
        alias = 'SIRFIS_TIS_FACT',
        unique_key = ['ID'],
        transient = false
) }}

WITH SOURCE AS
(SELECT DISTINCT install_schedule_id
, CASE WHEN SNAPSHOT_DATE < '2025-01-13' THEN SNAPSHOT_DATE ELSE _FILEDATE END AS _FILEDATE
, STATE
, date_published
FROM  {{ ref('SILVER__TEH_PRODUCT_SUPPORT__SIRFIS_TOOL_INSTALLATION_BASE') }}
WHERE UPPER(state) <> 'PAST'
)

, latest_value AS (
SELECT DISTINCT install_schedule_id AS id,
        UPPER(FIRST_VALUE(state) over (PARTITION BY install_schedule_id ORDER BY _FILEDATE DESC)) AS latest_state,
        TO_DATE(FIRST_VALUE(date_published) over (PARTITION BY install_schedule_id ORDER BY _FILEDATE DESC)) AS latest_published_date
FROM SOURCE
)

, var_max_date AS (
  SELECT MAX(_FILEDATE) AS max_date
  FROM {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_MILESTONES_HISTORY') }}
)

, dim_tel_start_end_dates AS (
        SELECT
                DISTINCT A.id,
                CASE
                        WHEN b.event_type = 'DEMO' THEN FIRST_VALUE(
                                A.milestone_start_date
                        ) over (
                                PARTITION BY A.id
                                ORDER BY
                                        CASE
                                                WHEN A.milestones_name = 'DEMO' THEN A.milestone_start_date
                                        END
                        )
                        WHEN b.event_type IN (
                                'INSTALL',
                                'INSTALL-CONV'
                        ) THEN FIRST_VALUE(
                                A.milestone_start_date
                        ) over (
                                PARTITION BY A.id
                                ORDER BY
                                        CASE
                                                WHEN A.milestones_name = 'SET' THEN A.milestone_start_date
                                        END
                        )
                        WHEN b.event_type IN (
                                'CONV-FAC',
                                'CONV'
                        )
                        AND NOT EXISTS (
                                SELECT
                                        1
                                FROM
                                        {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_CURRENT_MILESTONES') }}
                                        sub
                                WHERE
                                        sub.id = A.id
                                        AND sub.milestones_name = 'CONVERSION'
                        ) THEN NULL
                        WHEN b.event_type IN (
                                'CONV-FAC',
                                'CONV'
                        )
                        AND EXISTS (
                                SELECT
                                        1
                                FROM
                                        {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_CURRENT_MILESTONES') }}
                                        sub
                                WHERE
                                        sub.id = A.id
                                        AND sub.milestones_name = 'CONVERSION'
                                        AND sub.milestone_start_date IS NULL
                        ) THEN NULL
                        WHEN b.event_type IN (
                                'CONV-FAC',
                                'CONV'
                        ) THEN FIRST_VALUE(
                                A.milestone_start_date
                        ) over (
                                PARTITION BY A.id
                                ORDER BY
                                        CASE
                                                WHEN A.milestones_name = 'CONVERSION' THEN A.milestone_start_date
                                        END
                        )
                        ELSE NULL
                END AS tel_start_date,
                CASE
                        WHEN b.event_type = 'DEMO' THEN FIRST_VALUE(
                                A.milestone_finish_date
                        ) over (
                                PARTITION BY A.id
                                ORDER BY
                                        CASE
                                                WHEN A.milestones_name = 'DEMO' THEN A.milestone_finish_date
                                        END
                        )
                        WHEN b.event_type IN (
                                'INSTALL',
                                'INSTALL-CONV',
                                'CONV-FAC',
                                'CONV'
                        )
                        AND NOT EXISTS (
                                SELECT
                                        1
                                FROM
                                        {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_CURRENT_MILESTONES') }}
                                        sub
                                WHERE
                                        sub.id = A.id
                                        AND sub.milestones_name = 'SUPPLIER QUAL'
                        ) THEN NULL
                        WHEN b.event_type IN (
                                'INSTALL',
                                'INSTALL-CONV',
                                'CONV-FAC',
                                'CONV'
                        )
                        AND EXISTS (
                                SELECT
                                        1
                                FROM
                                        {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_CURRENT_MILESTONES') }}
                                        sub
                                WHERE
                                        sub.id = A.id
                                        AND sub.milestones_name = 'SUPPLIER QUAL'
                                        AND sub.milestone_finish_date IS NULL
                        ) THEN NULL
                        WHEN b.event_type IN (
                                'INSTALL',
                                'INSTALL-CONV',
                                'CONV-FAC',
                                'CONV'
                        ) THEN FIRST_VALUE(
                                A.milestone_finish_date
                        ) over (
                                PARTITION BY A.id
                                ORDER BY
                                        CASE
                                                WHEN A.milestones_name = 'SUPPLIER QUAL' THEN A.milestone_finish_date
                                        END
                        )
                        ELSE NULL
                END AS tel_finish_date
        FROM
                {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_CURRENT_MILESTONES') }} A
                LEFT JOIN {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_ITEM_CONFIGURATION') }}
                b
                ON A.id = b.id
),
transform_data AS (
        SELECT
                DISTINCT '{{ invocation_id }}' AS _AUDIT_LOG_ID,
                SHA2('hash_me') AS _ROW_HASH,
                main.id,
                MIN(
                        main._FILEDATE
                ) over (
                        PARTITION BY main.id
                ) AS added_date,
                MAX(
                        main._FILEDATE
                ) over (
                        PARTITION BY main.id
                ) AS latest_date,
                latest_value.latest_state,
                latest_value.latest_published_date,
                start_end.tel_start_date,
                start_end.tel_finish_date,
                CASE
                        WHEN latest_date = var_max_date.max_date
                        AND start_end.tel_finish_date IS NULL THEN 'CURRENT'
                        WHEN latest_date = var_max_date.max_date
                        AND start_end.tel_finish_date IS NOT NULL
                        AND start_end.tel_finish_date >= latest_date THEN 'CURRENT'
                        WHEN latest_date = var_max_date.max_date
                        AND start_end.tel_finish_date IS NOT NULL
                        AND start_end.tel_finish_date < latest_date THEN 'LIKELY COMPLETED'
                        WHEN latest_date < var_max_date.max_date
                        AND start_end.tel_finish_date IS NULL THEN 'DELETED'
                        WHEN latest_date < var_max_date.max_date
                        AND start_end.tel_finish_date IS NOT NULL
                        AND latest_date >= start_end.tel_finish_date THEN 'COMPLETED'
                        WHEN latest_date < var_max_date.max_date
                        AND start_end.tel_finish_date IS NOT NULL
                        AND latest_date < start_end.tel_finish_date THEN 'DELETED'
                END AS expected_status
        FROM
                {{ ref('GOLD__TEH_PRODUCT_SUPPORT__SIRFIS_TIS_MILESTONES_HISTORY') }}
                main
                LEFT JOIN dim_tel_start_end_dates start_end
                ON main.id = start_end.id
                LEFT JOIN latest_value
                ON main.id = latest_value.id
                LEFT JOIN var_max_date
                ON 1 = 1
),
type_data AS (
        SELECT
                CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
                CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
                id,
                CAST(
                        added_date AS DATE
                ) AS added_date,
                CAST(
                        latest_date AS DATE
                ) AS latest_date,
                latest_state,
                CAST(
                        latest_published_date AS DATE
                ) AS latest_published_date,
                CAST(
                        tel_start_date AS DATE
                ) AS tel_start_date,
                CAST(
                        tel_finish_date AS DATE
                ) AS tel_finish_date,
                expected_status
        FROM
                transform_data)
        SELECT
                *
        FROM
                type_data