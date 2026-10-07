{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'PARTS_REVENUE_FORECAST_HISTORY',
    transient = false
) }}

WITH source_data AS (

    SELECT DISTINCT
        year AS fiscal_year,
        fiscal_half,
        fiscal_qtr,
        TO_DATE(
            CONCAT(
                SUBSTR(calendar_year_month, 1, 4), '-',
                SUBSTR(calendar_year_month, 6, 2), '-01'
            )
        ) AS calendar_date,
        revenue_source,
        customer_group,
        departmentcode,
        segmentcode,
        officecode,
        financialproductcode,
        corporation,
        corporation_name,
        product_type,
        product_type_group,
        product_type_group_legacy,
        statutory_group,
        prelim_close_rpt,
        oracle_account_number,
        customercode,
        currency,
        amount,
        scenario,
        forecastbudget_filedate
    FROM {{ source('DE_SAP_REVENUE_COGS', 'ACTUAL_BUDGET_FORECAST_PNL') }}
    WHERE UPPER(account_type) = 'REVENUE'
      AND scenario = 'Forecast'
      AND financialproductcode IN ('RPREXC', 'RPRPRT', 'RPRSVC', 'SPAREC', 'SPAREN')
      AND UPPER(entity) = 'TEA'
      AND UPPER(customer_group) <> 'TEL GROUP'
),

-- ---------------------------------------------------------------------------
-- Backfill for months the forecast is missing, per the business rule (Leah QI):
--     April   (month = 04) -> Original Budget
--     October (month = 10) -> Revised Budget
-- Budget rows are relabelled scenario = 'Forecast'.
-- ---------------------------------------------------------------------------
budget_candidates AS (

    SELECT DISTINCT
        year AS fiscal_year,
        fiscal_half,
        fiscal_qtr,
        TO_DATE(
            CONCAT(
                SUBSTR(calendar_year_month, 1, 4), '-',
                SUBSTR(calendar_year_month, 6, 2), '-01'
            )
        ) AS calendar_date,
        revenue_source,
        customer_group,
        departmentcode,
        segmentcode,
        officecode,
        financialproductcode,
        corporation,
        corporation_name,
        product_type,
        product_type_group,
        product_type_group_legacy,
        statutory_group,
        prelim_close_rpt,
        oracle_account_number,
        customercode,
        currency,
        amount,
        'Forecast' AS scenario,
        forecastbudget_filedate
    FROM {{ source('DE_SAP_REVENUE_COGS', 'ACTUAL_BUDGET_FORECAST_PNL') }}
    WHERE UPPER(account_type) = 'REVENUE'
      AND financialproductcode IN ('RPREXC', 'RPRPRT', 'RPRSVC', 'SPAREC', 'SPAREN')
      AND UPPER(entity) = 'TEA'
      AND UPPER(customer_group) <> 'TEL GROUP'
      AND (
              (SUBSTR(calendar_year_month, 6, 2) = '04' AND scenario = 'Original Budget')
           OR (SUBSTR(calendar_year_month, 6, 2) = '10' AND scenario = 'Revised Budget')
          )
),

-- Only fill months the forecast genuinely lacks. NOT EXISTS is used instead
-- of NOT IN so a NULL calendar_date in source_data can never blank out the
-- entire backfill. This guard is what prevents UNION ALL from double-counting
-- the Aprils/Octobers the forecast already carries (e.g. 2024-04, 2025-10).

budget_backfill AS (

    SELECT *
    FROM budget_candidates bc
    WHERE NOT EXISTS (
        SELECT 1
        FROM source_data sd
        WHERE sd.calendar_date = bc.calendar_date
    )
),

merged_data AS (
    SELECT * FROM source_data
    UNION ALL
    SELECT * FROM budget_backfill
),

dim_segmentcode_inline AS (
    -- Inline Business Unit mapping (SAP derived)
    SELECT *
    FROM (
        SELECT column1, column2, column3, column4
        FROM VALUES
            ('S4110', 'FS-CT', 'CT', 'CT'),
            ('S4111', 'FS-3DI Bonder', '3DI', 'SS'),
            ('S4120', 'FS-TPS', 'TPS', 'DS'),
            ('S4130', 'FS-ES', 'ES', 'ES'),
            ('S4190', 'FS-RLSA', 'ES', 'RE'),
            ('S4131', 'FS-Certas', 'CERTAS', 'LI'),
            ('S4140', 'FS-SPS', 'SPS', 'CS or SR or D4'),
            ('S4150', 'FS-TS', 'TS', 'TS'),
            ('S4160', 'FS-SD', 'SD', 'MB'),
            ('S4161', 'FS-PVD', 'PVD', 'HD'),
            ('S5980', 'TMEA', 'TMEA', 'TF or P5'),
            ('S4175', 'FS-CCS', 'TMEA', 'TF'),
            ('S5000', 'FS-GCB', 'TMEA', 'P5'),
            ('S4195', 'FS-SiC', 'SIC', 'J8')
    ) AS t (segmentcode, description, bu, pn_supplier_code)
),

transform_data AS (

    SELECT DISTINCT
        a.fiscal_year,
        a.fiscal_half,
        a.fiscal_qtr,
        b.fiscal_year_month_short_text AS fiscal_year_month,
        CASE
            WHEN DATE_FROM_PARTS(b.year_number, b.month_of_year_number, 1)
                 = DATE_TRUNC('MONTH', CURRENT_DATE())
                THEN 'Current'
            WHEN DATE_FROM_PARTS(b.year_number, b.month_of_year_number, 1)
                 < DATE_TRUNC('MONTH', CURRENT_DATE())
                THEN 'Past'
            ELSE 'Future'
        END AS fiscal_year_month_state,
        a.revenue_source,
        a.customer_group,
        a.departmentcode,
        a.segmentcode,
        c.bu AS business_unit,
        a.officecode,
        a.financialproductcode,
        a.corporation,
        a.corporation_name,
        CASE
            WHEN a.product_type = 'Spare Parts-Consumable' THEN 'Consumables'
            WHEN a.product_type = 'Spare Parts-Non Consumable' THEN 'Non-consumables'
            ELSE a.product_type
        END AS product_type,
        a.product_type_group,
        a.product_type_group_legacy,
        a.statutory_group,
        a.prelim_close_rpt,
        a.oracle_account_number,
        a.customercode,
        a.currency,
        a.amount,
        a.scenario,
        a.forecastbudget_filedate,
        a.calendar_date,
        CONCAT(scenario, '-', fiscal_year_month) AS key,
        '{{ invocation_id }}' AS _audit_log_id,
        SHA2('hash_me') AS _row_hash

    FROM merged_data a
    LEFT JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} b
        ON a.calendar_date = b.calendar_date
    LEFT JOIN dim_segmentcode_inline c
        ON a.segmentcode = c.segmentcode
),

type_data AS (

    SELECT
        CAST(_audit_log_id AS VARCHAR(128)) AS _audit_log_id,
        CAST(_row_hash AS VARCHAR(128)) AS _row_hash,
        fiscal_year,
        fiscal_half,
        fiscal_qtr,
        fiscal_year_month,
        fiscal_year_month_state,
        revenue_source,
        customer_group,
        departmentcode,
        segmentcode,
        business_unit,
        officecode,
        financialproductcode,
        corporation,
        corporation_name,
        product_type,
        product_type_group,
        product_type_group_legacy,
        statutory_group,
        prelim_close_rpt,
        oracle_account_number,
        customercode,
        currency,
        CAST(amount AS NUMBER(38,2)) AS amount,
        scenario,
        CAST(forecastbudget_filedate AS TIMESTAMP_NTZ(9)) AS forecastbudget_filedate,
        CAST(calendar_date AS DATE) AS calendar_date,
        key
    FROM transform_data
)

SELECT *
FROM type_data