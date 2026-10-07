/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.36"
*************/

{{ config(
      materialized='view',
      alias='CUSTOMIZING_ORDER_REPORT_PROFILES',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        PROFID,
        AENAM,
        PROTECT,
        HIER_LEVEL,
        KZKAU,
        ADOBJ,
        EXCMRPLOGIC,
        AVAILDATELOGIC,
        AVAILATPLOGIC,
        AVAILSSTOCK,
        EXCQUANTITY,
        PR_MENDIF,
        EXCDATE,
        TATVZ,
        MEIVT,
        ERWVZ,
        MEIVE,
        ADDMATERIAL,
        REORDER,
        BULKMAT,
        COBYPRODUCT,
        ADDELEMENT,
        PIPELINE,
        USEBUFFER,
        MLDELAY,
        MLAPPROACH,
        MLOPER,
        SLDELAY,
        MLGREEN,
        MLYELLOW,
        MLRED,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__CUSTOMIZING_ORDER_REPORT_PROFILES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data