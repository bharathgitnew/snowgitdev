{{ config(
    alias='FAB21_EHS_AUDIT_FORM_DETAILS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['_FILENAME', 'CATEGORY', 'FINDING', 'REGION']
) }}
with header as (
    select
        _FILENAME,
        MAX(CASE
            WHEN HEADER1::STRING = 'Tool ID: '
            THEN HEADER2::STRING
        END) AS TOOL_ID,
        MAX(CASE
            WHEN HEADER3::STRING = 'Date'
            THEN TRY_TO_DATE(HEADER5::STRING)
        END) AS AUDIT_DATE
    from {{ ref('BRONZE__TEH_EHS__FILE_FAB21_EHS_AUDIT_ETC') }}
    where HEADER1 IS NOT NULL
    -- {% if is_tel_incremental() %}
    --     and _FILEDATE > (select max(_FILEDATE) from {{ this }})
    -- {% endif %}
    group by _FILENAME
),
findings as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        HEADER1::STRING                                         AS CATEGORY,
        HEADER2::STRING                                         AS FINDING,
        CASE WHEN UPPER(HEADER3::STRING) = 'X' THEN 'X' ELSE NULL END AS S,
        CASE WHEN UPPER(HEADER4::STRING) = 'X' THEN 'X' ELSE NULL END AS U,
        CASE WHEN UPPER(HEADER5::STRING) = 'X' THEN 'X' ELSE NULL END AS OC,
        CASE WHEN UPPER(HEADER6::STRING) = 'X' THEN 'X' ELSE NULL END AS NA,
        split_part(_filename,'_',1) AS REGION
    from {{ ref('BRONZE__TEH_EHS__FILE_FAB21_EHS_AUDIT_ETC') }}
    where HEADER1 IS NOT NULL
      and HEADER1::STRING IN ('Form', 'Safety', 'Safey', 'PPE')
    -- {% if is_tel_incremental() %}
    --     and _FILEDATE > (select max(_FILEDATE) from {{ this }})
    -- {% endif %}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY _FILENAME, HEADER1, HEADER2
        ORDER BY _FILEDATE DESC
    ) = 1
),
joined as (
    select
        f._FILENAME,
        f._FILEDATE,
        f._UPLOADDATE,
        h.TOOL_ID,
        h.AUDIT_DATE,
        f.REGION,
        f.CATEGORY,
        f.FINDING,
        f.S,
        f.U,
        f.OC,
        f.NA
    from findings f
    join header h on f._FILENAME = h._FILENAME
),
transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        TOOL_ID,
        AUDIT_DATE,
        REGION,
        CATEGORY,
        FINDING,
        S,
        U,
        OC,
        NA,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH
    from joined
    -- where TOOL_ID IS NOT NULL
),
type_data as (
    select
        CAST(_FILENAME    AS VARCHAR)      AS _FILENAME,
        CAST(_FILEDATE    AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CAST(_UPLOADDATE  AS TIMESTAMP_NTZ(9))  AS _UPLOADDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128))     AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH    AS VARCHAR(128))      AS _ROW_HASH,
        CAST(REGION       AS VARCHAR)        AS REGION,
        CAST(TOOL_ID      AS VARCHAR)           AS TOOL_ID,
        CAST(AUDIT_DATE   AS DATE)              AS AUDIT_DATE,
        CAST(CATEGORY     AS VARCHAR)           AS CATEGORY,
        CAST(FINDING      AS VARCHAR)           AS FINDING,
        CAST(S            AS VARCHAR)        AS S,
        CAST(U            AS VARCHAR)        AS U,
        CAST(OC           AS VARCHAR)        AS OC,
        CAST(NA           AS VARCHAR)        AS NA
    from transform_data
)
select
    _FILENAME,
    _FILEDATE,
    _UPLOADDATE,
    _AUDIT_LOG_ID,
    _ROW_HASH,
    REGION,
    TOOL_ID,
    AUDIT_DATE,
    CATEGORY,
    FINDING,
    S,
    U,
    OC,
    NA
from type_data
order by TOOL_ID, CATEGORY, FINDING