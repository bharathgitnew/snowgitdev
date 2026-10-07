/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.17"
*************/

{{ config(
      materialized='view',
      alias='CONTRACTBUNDLETERMS',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACTNUMBER,
        FLEXFLAG,
        FLEXHOURS,
        FLX,
        FUL,
        OS2,
        OS4,
        OS8,
        PGR,
        PM,
        PRT,
        STC,
        TSP,
        TSS,
        AUDITDATE,
        BUNDLETERMSDESC
    from {{ ref('ODS__MDM__CONTRACTBUNDLETERMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data