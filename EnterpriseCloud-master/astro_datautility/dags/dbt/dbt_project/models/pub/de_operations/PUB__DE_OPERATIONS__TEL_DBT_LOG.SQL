
{{ config(
    alias = 'TEL_DBT_LOG',
    materialized = 'view',
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

-- this view is unique by NODE_ID (id of dbt models)
-- INVOCATION_COMMAND column will show the most recent command used to run the model
-- this command is then used to link the results back to a Prefect dbt job so we can update Atlan near run time

with invocations as (
    select
        COMMAND_INVOCATION_ID,
        INVOCATION_ARGS:invocation_command::varchar as INVOCATION_COMMAND,
        RUN_STARTED_AT,
    from {{ ref('dbt_artifacts', 'invocations') }} 
    qualify row_number() over(partition by INVOCATION_COMMAND order by RUN_STARTED_AT desc) = 1
),

compiles as (
    select 
        PACKAGE_NAME, 
        max(RUN_STARTED_AT) as RUN_STARTED_AT,
    from {{ ref('dbt_artifacts', 'models') }} 
    group by all
),

models as (
    select 
        models.*,
        get(models.DEPENDS_ON_NODES, 0)::VARCHAR as PARENT_NODE,
    from {{ ref('dbt_artifacts', 'models') }} as models
    inner join compiles
        on models.PACKAGE_NAME = compiles.PACKAGE_NAME
        and models.RUN_STARTED_AT = compiles.RUN_STARTED_AT
),

tests as (
    select 
        tests.*,
        get(tests.DEPENDS_ON_NODES, 0)::VARCHAR as PARENT_NODE,
    from {{ ref('dbt_artifacts', 'tests') }} as tests
    inner join compiles
        on tests.PACKAGE_NAME = compiles.PACKAGE_NAME
        and tests.RUN_STARTED_AT = compiles.RUN_STARTED_AT
),

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
    from invocations
    inner join {{ ref('dbt_artifacts', 'test_executions') }} as executions
        on invocations.COMMAND_INVOCATION_ID = executions.COMMAND_INVOCATION_ID
    inner join tests
        on tests.NODE_ID = executions.NODE_ID
    qualify row_number() over(partition by tests.NODE_ID order by executions.COMPILE_STARTED_AT desc) = 1
),

model_tests as (
    select
        PARENT_NODE as NODE_ID,
        array_agg(distinct INVOCATION_COMMAND) as TEST_INVOCATION_COMMANDS,
        array_agg(JSON_RESULTS) as TEST_RESULTS,
    from last_dbt_tests
    group by NODE_ID
),

last_dbt_jobs as (
    select 
        invocations.COMMAND_INVOCATION_ID,
        invocations.INVOCATION_COMMAND,
        invocations.RUN_STARTED_AT,
        models.NODE_ID,
        models.DATABASE,
        models.SCHEMA,
        models.ALIAS,
        models.NAME,
        models.MATERIALIZATION,
        models.TAGS,
        models.PARENT_NODE,
        executions.COMPILE_STARTED_AT,
        executions.STATUS,
        executions.TOTAL_NODE_RUNTIME,
        executions.MESSAGE,
        model_tests.TEST_INVOCATION_COMMANDS,
        model_tests.TEST_RESULTS,
    from invocations
    inner join {{ ref('dbt_artifacts', 'model_executions') }} as executions
        on invocations.COMMAND_INVOCATION_ID = executions.COMMAND_INVOCATION_ID
    inner join models
        on (models.DATABASE != 'PUB' and models.NODE_ID = executions.NODE_ID)
        or (models.DATABASE = 'PUB' and models.PARENT_NODE = executions.NODE_ID)
    left join model_tests
        on models.NODE_ID = model_tests.NODE_ID
    qualify row_number() over(partition by models.NODE_ID order by executions.COMPILE_STARTED_AT desc) = 1
)

select * from last_dbt_jobs
