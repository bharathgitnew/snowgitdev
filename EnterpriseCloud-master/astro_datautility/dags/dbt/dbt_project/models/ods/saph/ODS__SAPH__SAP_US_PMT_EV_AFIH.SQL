
{{ config(
    alias = 'SAP_US_PMT_EV_AFIH',
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['AUFNR'],
    enabled = false,
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        JSONFIELD:"DELFLAG"::STRING as DELFLAG,
        JSONFIELD:"CDCHANGENR"::STRING AS CDCHANGENR,
        JSONFIELD:"PSL_INSDATE"::STRING as PSL_INSDATE,
        JSONFIELD:"PSL_UPDDATE"::STRING as PSL_UPDDATE,
        JSONFIELD:"AUFNR"::STRING as AUFNR,
        JSONFIELD:"ARTPR"::STRING as ARTPR,
        JSONFIELD:"ILOAN"::STRING as ILOAN,
        JSONFIELD:"ILOAI"::STRING as ILOAI,
        JSONFIELD:"IWERK"::STRING as IWERK,
        JSONFIELD:"PM_OBJTY"::STRING as PM_OBJTY,
        JSONFIELD:"GEWRK"::STRING as GEWRK,
        JSONFIELD:"KUNUM"::STRING as KUNUM,
        JSONFIELD:"OBKNR"::STRING as OBKNR,
        JSONFIELD:"ADDAT"::STRING as ADDAT,
        JSONFIELD:"ADUHR"::STRING as ADUHR,
        JSONFIELD:"IPHAS"::STRING as IPHAS,
        JSONFIELD:"ILART"::STRING as ILART,
        JSONFIELD:"AKKNZ"::STRING as AKKNZ,
        JSONFIELD:"DEVICEID"::STRING as DEVICEID,
        JSONFIELD:"SCREENTY"::STRING as SCREENTY,
    from {{ source('SAPH', 'SAP_US_PMT_EV_AFIH') }} 
    {% if is_incremental() %}WHERE  _FILENAME > IFNULL((SELECT MAX(_FILENAME) FROM {{ this }}),'1970-01-01'){% endif %}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY AUFNR ORDER BY _FILEDATE DESC )) = 1
),

transform_data as (
    select 
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        AUFNR,
        ARTPR,
        ILOAN,
        ILOAI,
        IWERK,
        PM_OBJTY,
        GEWRK,
        KUNUM,
        OBKNR,
        ADDAT,
        ADUHR,
        IPHAS,
        ILART,
        AKKNZ,
        DEVICEID,
        SCREENTY,
    from source_data
),

type_data as (
    select 
        _FILENAME,
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        DELFLAG,
        CDCHANGENR,
        PSL_INSDATE,
        PSL_UPDDATE,
        AUFNR,
        ARTPR,
        ILOAN,
        ILOAI,
        IWERK,
        PM_OBJTY,
        GEWRK,
        KUNUM,
        OBKNR,
        ADDAT,
        ADUHR,
        IPHAS,
        ILART,
        AKKNZ,
        DEVICEID,
        SCREENTY,
    from transform_data
)

select * from type_data
