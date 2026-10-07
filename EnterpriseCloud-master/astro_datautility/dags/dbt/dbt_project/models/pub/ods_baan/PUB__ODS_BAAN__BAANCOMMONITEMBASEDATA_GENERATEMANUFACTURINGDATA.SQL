/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.13.59"
*************/

{{ config(
      materialized='view',
      alias='BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTUALDELIVERYDATE,
        CUSTOMER,
        ESTINHOUSELABOR,
        FIRSTOPERATIONDESCRIPTION,
        FIRSTOPERATIONID,
        GENERATEDDATE,
        IN_HOUSEREPAIRDESCRIPTION,
        IN_HOUSEREPAIRID,
        ITEMBEINGREPAIRED,
        KITPART_HASH__KIT1,
        KITPART_HASH__KIT10,
        KITPART_HASH__KIT2,
        KITPART_HASH__KIT3,
        KITPART_HASH__KIT4,
        KITPART_HASH__KIT5,
        KITPART_HASH__KIT6,
        KITPART_HASH__KIT7,
        KITPART_HASH__KIT8,
        KITPART_HASH__KIT9,
        LOGINCODE,
        MAINITEM,
        PLANNEDDELIVERYDATEETA,
        PRODUCTIONORDER,
        REPAIRPROGRAMDESCRIPTION,
        REPAIRPROGRAMID,
        RMANUMBER,
        SALESORDER,
        SOURCEITEMTYPEDESCRIPTION,
        SOURCEITEMTYPEID,
        STATUSDESCRIPTION,
        STATUSID,
        SUBCONTRACTDESCRIPTION,
        SUBCONTRACTID,
        SUBCONTRACTING,
        SUBCONTRACTINGPO,
        SUBCONTRACTRATE
    from {{ ref('ODS__BAAN__BAANCOMMONITEMBASEDATA_GENERATEMANUFACTURINGDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data