/************
Model file generated from dbtGeneratePubViews: 01.09.2023.04.53.48"
*************/

{{ config(
      materialized='view',
      alias='ZCDV_T_CMTU010_VBAP',
      transient=false
) }}

with source_data as (
    SELECT
    * exclude(AUDIT_LOG_ID,_ROW_HASH,_FILENAME)
from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU010_VBAP') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data