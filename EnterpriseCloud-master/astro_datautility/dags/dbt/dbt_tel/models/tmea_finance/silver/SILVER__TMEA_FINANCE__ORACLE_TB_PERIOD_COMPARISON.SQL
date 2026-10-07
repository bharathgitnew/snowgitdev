{{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='ORACLE_TB_PERIOD_COMPARISON',
            transient=false    
) }}


WITH fiscal_calendar AS (
    SELECT
        CASE
            WHEN MONTH(CURRENT_DATE()) >= 4 THEN YEAR(CURRENT_DATE()) + 1
            ELSE YEAR(CURRENT_DATE())
        END AS current_fiscal_year,
        CASE
            WHEN MONTH(CURRENT_DATE()) >= 4 THEN MONTH(CURRENT_DATE()) - 3
            ELSE MONTH(CURRENT_DATE()) + 9
        END AS current_period
),

closed_period AS (
    SELECT
        current_fiscal_year,
        current_period - 1 AS reporting_period,
        current_period - 2 AS comparison_period
    FROM fiscal_calendar
),

period_mapped AS (
    SELECT
        FISCAL_YEAR,
        COMPANY_CODE,
        ACCOUNT_NUMBER                                              AS LEDGER_ACCOUNT,
        BALANCE_CARRIED_FORWARD_IN_LOCAL_CURRENCY_CURRENCY_2       AS CARRY_FORWARD,
        CASE PERIOD_COL
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2'    THEN 1
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_2'  THEN 2
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_3'  THEN 3
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_4'  THEN 4
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_5'  THEN 5
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_6'  THEN 6
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_7'  THEN 7
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_8'  THEN 8
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_9'  THEN 9
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_10' THEN 10
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_11' THEN 11
            WHEN 'TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_12' THEN 12
        END                                                         AS FISCAL_PERIOD,
        AMOUNT
    FROM (
        SELECT *
        FROM {{ ref('SILVER__TMEA_FINANCE__G_L_ACCOUNT_MASTER_RECORD_TRANSACTION_FIGURES') }}
        -- WHERE LEDGER      = '00'       
        -- AND   RECORD_TYPE = '0'         
        -- AND   VERSION     = '001'       
    ) src
    UNPIVOT (AMOUNT FOR PERIOD_COL IN (
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_2,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_3,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_4,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_5,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_6,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_7,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_8,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_9,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_10,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_11,
        TOTAL_TRANSACTIONS_IN_THE_PERIOD_IN_LOCAL_CURRENCY_CURR_2_12
    ))
),

final AS (
    SELECT
        p.FISCAL_YEAR,
        p.COMPANY_CODE,
        p.LEDGER_ACCOUNT,
        cp.reporting_period                                         AS REPORTING_PERIOD_NUM,
        cp.comparison_period                                        AS COMPARISON_PERIOD_NUM,

        -- Reporting Period YTD (include carry forward)
        MAX(p.CARRY_FORWARD) +
        SUM(CASE WHEN p.FISCAL_PERIOD <= cp.reporting_period
            THEN p.AMOUNT ELSE 0 END)                              AS YTD_REPORTING,

        -- Comparison Period YTD (include carry forward)
        MAX(p.CARRY_FORWARD) +
        SUM(CASE WHEN p.FISCAL_PERIOD <= cp.comparison_period
            THEN p.AMOUNT ELSE 0 END)                              AS YTD_COMPARISON,


    FROM period_mapped p
    CROSS JOIN closed_period cp
    WHERE p.FISCAL_YEAR = cp.current_fiscal_year
    GROUP BY
        p.FISCAL_YEAR,
        p.COMPANY_CODE,
        p.LEDGER_ACCOUNT,
        cp.reporting_period,
        cp.comparison_period
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
    from final
)


select * from type_data