{{ config(
      materialized='view',
      alias='TPL_Storage_Location',
      transient=false
) }}

with source_data as (
    SELECT
        Storage_Location,
        Location_Code,
        Plant,
        Description,
        Trading_Partner,
        TPL_Account_Number,
        TPL_Warehouse,
        Enabled_For_EDI,
        Active,
        Last_Updated,
        Last_Updated_By,
        Consignment,
        Address_Id,
        Sold_To_Bcode,
        Bill_To_Bcode,
        Ship_To_Ccode,
        Country_Code,	
        _FILEDATE
    from {{ ref('ODS__THREEPL__TPL_STORAGE_LOCATION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data