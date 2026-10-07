{{ config(
    alias = 'FILE_SAPO_A005',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['MANDT', 'KAPPL', 'KSCHL', 'VKORG', 'VTWEG', 'KUNNR', 'MATNR', 'DATBI'],
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        MANDT,
        KAPPL,
        KSCHL,
        VKORG,
        VTWEG,
        KUNNR,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
    from {{ source('FILE', 'SAPO_A005') }}
    where MATNR is not null
    {% if is_tel_incremental() %} and _FILEDATE >= (select ifnull(max(_FILEDATE), '1970-01-01') from {{ this }}) {% endif %}
    qualify row_number() over(
        partition by
            MANDT,
            KAPPL,
            KSCHL,
            VKORG,
            VTWEG,
            KUNNR,
            MATNR,
            DATBI
        order by _FILEDATE desc
    ) = 1
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
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        MANDT,
        KAPPL,
        KSCHL,
        VKORG,
        VTWEG,
        KUNNR,
        MATNR,
        DATBI,
        DATAB,
        KNUMH,
    from transform_data
)

select * from type_data
