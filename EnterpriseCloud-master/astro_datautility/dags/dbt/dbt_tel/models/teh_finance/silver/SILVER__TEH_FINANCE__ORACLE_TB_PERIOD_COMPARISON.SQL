{{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_TB_PERIOD_COMPARISON',
            transient=false    
) }}


WITH fiscal_calendar AS (
    -- Derive current fiscal period from today's date
    -- Fiscal year starts April, so April = Period 1
   SELECT
        -- Fiscal Year: April start
        -- Jan/Feb/Mar 2027 --> FY2026, Apr/May.../Mar ---> FY = calendar year
        CASE
            WHEN MONTH(CURRENT_DATE()) >= 4
                THEN YEAR(CURRENT_DATE())        -- Apr 2026 --> 2026
            ELSE YEAR(CURRENT_DATE()) - 1        -- Jan 2027 --> 2026
        END AS current_fiscal_year,

        -- Fiscal Period: April = 1, May = 2 ... March = 12
        CASE
            WHEN MONTH(CURRENT_DATE()) >= 4
                THEN MONTH(CURRENT_DATE()) - 3   -- Apr=1, May=2, Jun=3, Jul=4...
            ELSE MONTH(CURRENT_DATE()) + 9       -- Jan=10, Feb=11, Mar=12
        END AS current_period
),

-- last closed month is one period behind current
closed_period AS (
    SELECT
        current_fiscal_year,
        current_period - 1 AS REPORTING_PERIOD,  -- last closed month
        current_period - 2 AS COMPARISON_PERIOD  -- one before that
    FROM fiscal_calendar
),

transform_data AS (
    SELECT
        t.FISCAL_YEAR,
        t.COMPANY_CODE,
        t.LEDGER_ACCOUNT,
        cp.REPORTING_PERIOD                                         AS REPORTING_PERIOD_NUM,
        cp.COMPARISON_PERIOD                                        AS COMPARISON_PERIOD_NUM,
                
        -- Reporting Period YTD (eg: Apr–June for July run)
        CASE
            -- Balance Sheet (no profit center): already rolling, take latest period amount directly
            WHEN MAX(t.PROFIT_CENTER) IS NULL OR MAX(t.PROFIT_CENTER) = ''
                THEN MAX(CASE WHEN t.FISCAL_PERIOD = cp.REPORTING_PERIOD
                        THEN t.AMOUNT ELSE NULL END)
            -- has profit center: incremental, SUM for YTD
            ELSE SUM(CASE WHEN t.FISCAL_PERIOD <= cp.REPORTING_PERIOD
                    THEN t.AMOUNT ELSE 0 END)
        END                                                             AS YTD_REPORTING,

        -- Comparison Period (eg: Apr–May for July run)
        CASE
            WHEN MAX(t.PROFIT_CENTER) IS NULL OR MAX(t.PROFIT_CENTER) = ''
                THEN MAX(CASE WHEN t.FISCAL_PERIOD = cp.COMPARISON_PERIOD
                        THEN t.AMOUNT ELSE NULL END)
            ELSE SUM(CASE WHEN t.FISCAL_PERIOD <= cp.COMPARISON_PERIOD
                    THEN t.AMOUNT ELSE 0 END)
        END                                                             AS YTD_COMPARISON


    FROM {{ ref('SILVER__TEH_FINANCE__ORACLE_TB_LOAD_ENHANCED') }}  t
    CROSS JOIN closed_period cp
    WHERE t.FISCAL_YEAR = cp.CURRENT_FISCAL_YEAR  
    GROUP BY
        t.FISCAL_YEAR,
        t.COMPANY_CODE,
        t.LEDGER_ACCOUNT,
        cp.REPORTING_PERIOD,
        cp.COMPARISON_PERIOD
),

type_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        FISCAL_YEAR,
        COMPANY_CODE,
        LEDGER_ACCOUNT,
        REPORTING_PERIOD_NUM,
        COMPARISON_PERIOD_NUM,
        YTD_REPORTING,
        YTD_COMPARISON,
        YTD_REPORTING - YTD_COMPARISON AS DIFFERENCE
    from transform_data
)


select * from type_data