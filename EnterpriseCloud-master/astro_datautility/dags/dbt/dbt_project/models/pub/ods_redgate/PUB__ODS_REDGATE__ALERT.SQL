/************
Model file generated from dbtGeneratePubViews: 03.09.2022.17.41.09"
*************/

{{ config(
      materialized='view',
      alias='ALERT',
      transient=false
) }}

with source_data as (
    SELECT
        ALERTID,
        ALERTTYPE,
        CLEARED,
        CLEAREDDATE,
        GROUPCIR,
        LASTCOMMENT,
        LASTSEVERITY,
        LASTUPDATE,
        RAISED,
        READ,
        READDATE,
        ROOTCIR,
        SUBTYPE,
        TARGETOBJECT,
        WORSTSEVERITY
    from {{ ref('ODS__REDGATE__ALERT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data