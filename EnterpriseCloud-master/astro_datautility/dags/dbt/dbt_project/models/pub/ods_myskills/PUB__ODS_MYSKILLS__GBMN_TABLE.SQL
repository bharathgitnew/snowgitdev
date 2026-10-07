/************
Model file generated from dbtGeneratePubViews: 03.17.2022.09.11.32"
*************/

{{ config(
      materialized='view',
      alias='GBMN_TABLE',
      transient=false
) }}

with source_data as (
    SELECT
        GYOMUYMD,
        GBASHOCD,
        YUKKYMD,
        YKEYMD,
        BASHOCD,
        KUNICD,
        TORIYMD,
        GBASYSNJ,
        GBASYSNE,
        GBASYONM,
        GBASYONE,
        TIMESP
    from {{ ref('ODS__MYSKILLS__GBMN_TABLE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data