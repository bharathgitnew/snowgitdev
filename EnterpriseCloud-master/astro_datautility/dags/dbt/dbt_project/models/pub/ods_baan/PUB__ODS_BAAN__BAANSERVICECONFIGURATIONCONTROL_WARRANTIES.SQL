/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.19"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICECONFIGURATIONCONTROL_WARRANTIES',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        DESCRIPTION,
        NUMBEROFPERIODS,
        PERIODOFVALIDITYFROM,
        PERIODOFVALIDITYTO,
        PERIODUNITDESCRIPTION,
        PERIODUNITID,
        SALESREP,
        SEARCHARGUMENT,
        TERMID,
        WARRANTY,
        WARRANTYTEXT,
        WARRANTYTYPEDESCRIPTION,
        WARRANTYTYPEID
    from {{ ref('ODS__BAAN__BAANSERVICECONFIGURATIONCONTROL_WARRANTIES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data