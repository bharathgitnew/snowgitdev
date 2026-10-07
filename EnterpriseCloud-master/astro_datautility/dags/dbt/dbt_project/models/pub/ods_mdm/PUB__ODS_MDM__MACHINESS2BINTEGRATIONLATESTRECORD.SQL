/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.24"
*************/

{{ config(
      materialized='view',
      alias='MACHINESS2BINTEGRATIONLATESTRECORD',
      transient=false
) }}

with source_data as (
    SELECT
        LATESTTRANSACTIONDATE,
        TRANSACTIONID,
        BU,
        SN,
        SWLHMODEL,
        MPIMODELNAME,
        TELMODELCODE,
        TELMODELNAME,
        SUPPLIERCODE,
        REVENUEMETHODCODE,
        REVENUEMETHODDESCRIPTION,
        CLUSTERFLAG,
        MACHINEMODULETYPE,
        PARENTSERIALNUMBER,
        CHAMBERINSTALLPOSITION,
        CUSTOMERTOOLID,
        WAFERSIZE,
        TABLEREFRESHDATE,
        ACCEPTANCECOMMENT,
        TELSALESORDER,
        WISDOMSYSTEMNAME,
        FIRSTINTEGRATION
    from {{ ref('ODS__MDM__MACHINESS2BINTEGRATIONLATESTRECORD') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data