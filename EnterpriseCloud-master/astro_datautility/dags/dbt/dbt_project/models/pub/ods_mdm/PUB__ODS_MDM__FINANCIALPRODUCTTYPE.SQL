/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.22"
*************/

{{ config(
      materialized='view',
      alias='FINANCIALPRODUCTTYPE',
      transient=false
) }}

with source_data as (
    SELECT
        PRODUCTTYPECODE,
        FINANCIALSTATEMENTTYPE,
        ACTIVEFLAG,
        REVENUESOURCE,
        OWNER,
        CATEGORY,
        GROUPNAME,
        TELGROUPING,
        GROUPTEAOPERATIONSGROUPING,
        GLOBALKPI,
        BAANINCOMESTATEMENT
    from {{ ref('ODS__MDM__FINANCIALPRODUCTTYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data