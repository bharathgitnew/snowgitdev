{{ config(
    alias = 'ATLAN_DQ_AUDIT',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

-- aggregates each test result of a model into a comma separated result
with dbt_data as (
    select
        models.NODE_ID,
        models.NAME,
        models.RUN_STARTED_AT,
        listagg(distinct tests.VALUE:status, ',') as DBT_TEST_RESULTS,
    from {{ ref('SILVER__TEH_DATA_OPS__TEL_DBT_LOG') }} as models
    inner join lateral flatten(input => models.TEST_RESULTS) as tests
    group by all
),

-- joins to Atlan metadata but inner join is used to only look at active objects
source_data as (
    select
        atlan.GUID as ATLAN_GUID,
        atlan.ATTRIBUTES:qualified_name::string as ATLAN_QUALIFIED_NAME, 
        'https://tel.atlan.com/assets/' || atlan.GUID as ATLAN_URL,
        atlan.ATTRIBUTES:certificate_status::string as ATLAN_TEST_STATUS, 
        atlan._FILEDATE as ATLAN_EXTRACT_DT,
        dbt_data.NODE_ID as DBT_NODE_ID,
        dbt_data.RUN_STARTED_AT as DBT_RUN_DT,
        dbt_data.DBT_TEST_RESULTS,
        case -- format dbt test results to match atlan format
            when dbt_data.DBT_TEST_RESULTS = 'pass' then 'VERIFIED'
            when dbt_data.DBT_TEST_RESULTS ilike any ('%fail%', '%warn%') then 'DRAFT'
        end as DBT_TEST_STATUS,
    from dbt_data
    inner join {{ ref('BRONZE__TEH_DATA_OPS__ATLAN_TABLES') }} as atlan
        on atlan.ATTRIBUTES:qualified_name = 'default/snowflake/1650402931/' || replace(dbt_data.NAME, '__', '/')
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        ATLAN_GUID,
        ATLAN_QUALIFIED_NAME, 
        ATLAN_URL,
        ATLAN_TEST_STATUS, 
        ATLAN_EXTRACT_DT,
        DBT_NODE_ID,
        DBT_RUN_DT,
        DBT_TEST_RESULTS,
        DBT_TEST_STATUS,
    from transform_data
)

select * from type_data
