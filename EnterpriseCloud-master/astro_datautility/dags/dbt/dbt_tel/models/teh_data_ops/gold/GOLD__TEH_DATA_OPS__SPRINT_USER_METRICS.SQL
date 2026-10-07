
{{ config(
    alias = 'SPRINT_USER_METRICS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['SPRINT', 'ASSIGNEE'],
    meta = {
        'owners': ['Jay Spiers']
    },
) }}

with latest_snaps as (
    -- latest snapshot per sprint
    select 
        *,
    from {{ ref('SILVER__TEH_DATA_OPS__DAILY_SNAPSHOTS')}}
    qualify SNAPSHOT_DATE = max(SNAPSHOT_DATE) over(partition by SPRINT)
),

sprint_names as (
    -- unique list of sprint values to be used in next step
    select distinct
        SPRINT,
    from latest_snaps
),

prev_sprints as (
    -- cartesian join all the sprints, but only keep the previous rolling sprints
    select 
        a.SPRINT,
        b.SPRINT as PREV_SPRINT,
    from sprint_names as a
    left join sprint_names as b
    where a.SPRINT > b.SPRINT
    qualify row_number() over(partition by a.SPRINT order by b.SPRINT desc) <= 3
),

velocities as (
    -- how many points did each assignee finish per sprint
    select 
        SPRINT,
        ASSIGNEE,
        sum(SIZE) as POINTS,
    from latest_snaps
    where COLUMN_NAME = 'Done'
    group by all
),

sprint_velocities as (
    -- lookups the velocity of the previous sprints and averages it into the current sprint
    select
        latest_snaps.SPRINT,
        latest_snaps.ASSIGNEE,
        zeroifnull(avg(velocities.POINTS)) as AVG_SPRINT_VELOCITY,
    from latest_snaps
    left join prev_sprints
        on latest_snaps.SPRINT = prev_sprints.SPRINT
    left join velocities as velocities
        on latest_snaps.ASSIGNEE = velocities.ASSIGNEE
        and prev_sprints.PREV_SPRINT = velocities.SPRINT
    group by all
),

start_snaps as (
    -- looks at the metrics at the earliest snapshot per sprint
    select 
        SPRINT,
        SNAPSHOT_DATE,
        ASSIGNEE,
        sum(case when COLUMN_NAME != 'Product Backlog' then SIZE else 0 end) as POINTS_START,
    from {{ ref('SILVER__TEH_DATA_OPS__DAILY_SNAPSHOTS')}}
    where SNAPSHOT_DATE = to_date(SPRINT, 'YYYYMMDD')
    group by all
),

end_snaps as (
    -- looks at the metrics at the latest snapshot per sprint
    select 
        snaps.SPRINT,
        min(prev_sprints.SPRINT) as NEXT_SPRINT,
        snaps.SNAPSHOT_DATE,
        snaps.ASSIGNEE,
        sum(case when snaps.COLUMN_NAME != 'Product Backlog' then snaps.SIZE else 0 end) as POINTS_END,
        sum(case when snaps.COLUMN_NAME != 'Product Backlog' and snaps.COLUMN_NAME = 'Done' then snaps.SIZE else 0 end) as POINTS_DELIVERED,
        POINTS_END - POINTS_DELIVERED as POINTS_MISSED,
        zeroifnull(POINTS_DELIVERED / nullifzero(POINTS_END)) as COMMITTED_DELIVERED,
    from {{ ref('SILVER__TEH_DATA_OPS__DAILY_SNAPSHOTS')}} as snaps
    left join prev_sprints on snaps.SPRINT = prev_sprints.PREV_SPRINT
    group by all
    having SNAPSHOT_DATE = to_date(NEXT_SPRINT, 'YYYYMMDD')
),

source_data as (
    select 
        start_snaps.SPRINT as SPRINT,
        start_snaps.ASSIGNEE as ASSIGNEE,
        sprint_velocities.AVG_SPRINT_VELOCITY as AVG_SPRINT_VELOCITY,
        start_snaps.POINTS_START as POINTS_START,
        end_snaps.POINTS_END as POINTS_END,
        POINTS_END - POINTS_START as POINTS_DELTA,
        POINTS_START / nullifzero(AVG_SPRINT_VELOCITY) as COMMIT_OVER_CAPACITY_START,
        POINTS_END / nullifzero(AVG_SPRINT_VELOCITY) as COMMIT_OVER_CAPACITY_END,
        end_snaps.POINTS_DELIVERED,
        end_snaps.POINTS_MISSED,
        end_snaps.POINTS_DELIVERED / nullifzero(end_snaps.POINTS_END) as COMMITTED_DELIVERED,
    from start_snaps
    left join end_snaps 
        on start_snaps.SPRINT = end_snaps.SPRINT 
        and start_snaps.ASSIGNEE = end_snaps.ASSIGNEE
    left join sprint_velocities
        on start_snaps.SPRINT = sprint_velocities.SPRINT
        and start_snaps.ASSIGNEE = sprint_velocities.ASSIGNEE
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SPRINT,
        ASSIGNEE,
        AVG_SPRINT_VELOCITY,
        POINTS_START,
        POINTS_END,
        POINTS_DELTA,
        COMMIT_OVER_CAPACITY_START,
        COMMIT_OVER_CAPACITY_END,
        POINTS_DELIVERED,
        POINTS_MISSED,
        COMMITTED_DELIVERED,
    from transform_data
)

select * from type_data
