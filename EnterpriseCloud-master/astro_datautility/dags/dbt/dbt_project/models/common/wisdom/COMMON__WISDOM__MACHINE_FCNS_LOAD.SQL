{{ config(
        alias = 'MACHINE_FCNS_LOAD',
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with source_data as (
    select
        expl.UPGRADE_NO,
        expl.UPGRADE_NAME,
        expl.FINISHED,
        expl.CUST_COMPANY_NAME,
        expl.CUST_MASTER_NAME,
        expl.STATION_NAME,
        rcd.EXPLAINED_NAME,
        rcd.EXPLAINED_FILE_NAMES,
        rcd.EXPLAINED_DT,
        rcd.RECEIVED_NAME, 
        rcd.RECEIVED_FILE_NAMES, 
        rcd.RECEIVED_DT,
    from {{ ref('ODS__WISDOM__UG_EXPLN') }} as expl
    inner join {{ ref('ODS__WISDOM__UG_EXPLN_RCD') }} as rcd
        on rcd.WISDOM_UG_EXPLN_ID = expl.ID
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        UPGRADE_NO,
        UPGRADE_NAME,
        FINISHED,
        CUST_COMPANY_NAME,
        CUST_MASTER_NAME,
        STATION_NAME,
        EXPLAINED_NAME,
        EXPLAINED_FILE_NAMES,
        EXPLAINED_DT,
        RECEIVED_NAME, 
        RECEIVED_FILE_NAMES, 
        RECEIVED_DT,
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        UPGRADE_NO,
        UPGRADE_NAME,
        FINISHED::NUMBER(38,10) as FINISHED,
        CUST_COMPANY_NAME,
        CUST_MASTER_NAME,
        STATION_NAME,
        EXPLAINED_NAME,
        EXPLAINED_FILE_NAMES,
        EXPLAINED_DT::DATE as EXPLAINED_DT,
        RECEIVED_NAME, 
        RECEIVED_FILE_NAMES, 
        RECEIVED_DT::DATE as RECEIVED_DT,
    from transform_data
)

select * from type_data