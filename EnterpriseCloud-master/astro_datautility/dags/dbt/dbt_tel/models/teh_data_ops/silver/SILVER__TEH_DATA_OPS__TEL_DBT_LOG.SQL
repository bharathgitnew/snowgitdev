
{{ config(
    alias = 'TEL_DBT_LOG',
    materialized = 'view',
    unique_key = ['NODE_ID'],
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

-- gather the latest run of each dbt command. this helps filter results to a recent prefect run
with invocations as (
    select
        COMMAND_INVOCATION_ID,
        INVOCATION_ARGS:invocation_command::varchar as INVOCATION_COMMAND,
        RUN_STARTED_AT,
    from {{ ref('dbt_artifacts', 'invocations') }} 
    where PROJECT_NAME = '{{ target.profile_name }}'
    qualify row_number() over(partition by INVOCATION_COMMAND order by RUN_STARTED_AT desc) = 1
),

-- the latest compilation will tell us which models are curently enabled
compiles as (
    select 
        COMMAND_INVOCATION_ID,
    from {{ ref('dbt_artifacts', 'models') }}
    where PACKAGE_NAME = 'dbt_tel'
    order by RUN_STARTED_AT desc
    limit 1
),

-- gathers enabled model info
models as (
    select 
        models.*,
        get(models.DEPENDS_ON_NODES, 0)::VARCHAR as PARENT_NODE,
        regexp_substr(models.DATABASE, '([A-Za-z]+)', 1, 1, 'ie', 1) as DATABASE_PROD,
        upper(DATABASE_PROD || '__' || models.SCHEMA || '__' || models.ALIAS) as EXPECTED_NAME,
    from {{ ref('dbt_artifacts', 'models') }} as models
    inner join compiles
        on models.COMMAND_INVOCATION_ID = compiles.COMMAND_INVOCATION_ID
),

-- gathers enabled test info
tests as (
    select 
        tests.*,
        get(tests.DEPENDS_ON_NODES, 0)::VARCHAR as PARENT_NODE,
    from {{ ref('dbt_artifacts', 'tests') }} as tests
    inner join compiles
        on tests.COMMAND_INVOCATION_ID = compiles.COMMAND_INVOCATION_ID
),

-- gathers the test results for each of the recent dbt commands
last_dbt_tests as (
    select 
        tests.PARENT_NODE,
        invocations.INVOCATION_COMMAND,
        object_construct(
            'node', tests.NODE_ID,
            'status', executions.STATUS, 
            'message', executions.MESSAGE,
            'command_invocation_id', invocations.COMMAND_INVOCATION_ID,
            'invocation_command', invocations.INVOCATION_COMMAND,
            'compiled_at', executions.COMPILE_STARTED_AT
        ) as JSON_RESULTS,
        executions.STATUS,
        executions.TOTAL_NODE_RUNTIME,
    from invocations
    inner join {{ ref('dbt_artifacts', 'test_executions') }} as executions
        on invocations.COMMAND_INVOCATION_ID = executions.COMMAND_INVOCATION_ID
    inner join tests
        on tests.NODE_ID = executions.NODE_ID
    qualify row_number() over(partition by tests.NODE_ID order by ifnull(executions.COMPILE_STARTED_AT, '1900') desc) = 1
),

-- aggregates the test results to the model level
model_tests as (
    select
        PARENT_NODE as NODE_ID,
        array_agg(distinct INVOCATION_COMMAND) as TEST_INVOCATION_COMMANDS,
        array_agg(JSON_RESULTS) as TEST_RESULTS,
        count(*) as NUM_TESTS,
        array_agg(distinct STATUS) as DISTINCT_TEST_STATUSES,
        case 
            when array_intersection(DISTINCT_TEST_STATUSES, ['fail', 'error']) > [] then 'error'
            when array_intersection(DISTINCT_TEST_STATUSES, ['skipped', 'warn']) > [] then 'warn'
            when array_intersection(DISTINCT_TEST_STATUSES, ['pass']) = ['pass'] then 'pass'
        end as OVERALL_TEST_STATUS,
        sum(TOTAL_NODE_RUNTIME) as OVERALL_TEST_RUNTIME,
    from last_dbt_tests
    group by NODE_ID
),

-- gathers the model results for each of the recent dbt commands and joins test results then filters to the most recent version of the model
last_dbt_jobs as (
    select 
        invocations.COMMAND_INVOCATION_ID,
        invocations.INVOCATION_COMMAND,
        invocations.RUN_STARTED_AT,
        models.NODE_ID,
        models.DATABASE,
        models.SCHEMA,
        models.ALIAS,
        upper(models.NAME) as NAME,
        models.MATERIALIZATION,
        models.TAGS,
        models.PARENT_NODE,
        executions.COMPILE_STARTED_AT,
        executions.STATUS,
        executions.TOTAL_NODE_RUNTIME,
        executions.MESSAGE,
        model_tests.TEST_INVOCATION_COMMANDS,
        model_tests.TEST_RESULTS,
        -- the columns below are used for validating DBT best practices/standards
        models.EXPECTED_NAME,
        zeroifnull(model_tests.NUM_TESTS) as NUM_TESTS,
        model_tests.OVERALL_TEST_STATUS,
        model_tests.OVERALL_TEST_RUNTIME,
    from invocations
    inner join {{ ref('dbt_artifacts', 'model_executions') }} as executions
        on invocations.COMMAND_INVOCATION_ID = executions.COMMAND_INVOCATION_ID
    inner join models
        on models.NODE_ID = executions.NODE_ID
    left join model_tests
        on models.NODE_ID = model_tests.NODE_ID
    qualify row_number() over(partition by models.NODE_ID order by invocations.RUN_STARTED_AT desc) = 1
)

select * from last_dbt_jobs
