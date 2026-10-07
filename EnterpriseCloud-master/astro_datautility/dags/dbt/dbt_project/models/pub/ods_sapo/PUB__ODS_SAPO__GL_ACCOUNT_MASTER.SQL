/************
Model file generated from dbtGeneratePubViews: 08.28.2023.08.32.44"
*************/

{{ config(
      materialized='view',
      alias='GL_ACCOUNT_MASTER',
      transient=false
) }}

with source_data as (
    SELECT
        MANDT,
        KTOPL,
        SAKNR,
        XBILK,
        SAKAN,
        BILKT,
        ERDAT,
        ERNAM,
        GVTYP,
        KTOKS,
        MUSTR,
        VBUND,
        XLOEV,
        XSPEA,
        XSPEB,
        XSPEP,
        MCOD1,
        FUNC_AREA,
        _CAPTUREDATETIME
    from {{ ref('ODS__SAPO__GL_ACCOUNT_MASTER') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data