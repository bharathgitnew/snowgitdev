{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='TPL_Storage_Location',
    unique_key = ['Storage_Location']
) }}


with source_data as (
    SELECT 
        JSONFIELD:"Storage_Location"::STRING AS Storage_Location,
        JSONFIELD:"Location_Code"::STRING AS Location_Code,
        JSONFIELD:"Plant"::STRING AS Plant,
        JSONFIELD:"Description"::STRING AS Description,
        JSONFIELD:"Trading_Partner"::STRING AS Trading_Partner,
        JSONFIELD:"TPL_Account_Number"::STRING AS TPL_Account_Number,
        JSONFIELD:"TPL_Warehouse"::STRING AS TPL_Warehouse,
        JSONFIELD:"Enabled_For_EDI"::STRING AS Enabled_For_EDI,
        JSONFIELD:"Active"::STRING AS Active,
        JSONFIELD:"Last_Updated"::STRING AS Last_Updated,
        JSONFIELD:"Last_Updated_By"::STRING AS Last_Updated_By,
        JSONFIELD:"Consignment"::STRING AS Consignment,
        JSONFIELD:"Address_Id"::STRING AS Address_Id,
        JSONFIELD:"Sold_To_Bcode"::STRING AS Sold_To_Bcode,
        JSONFIELD:"Bill_To_Bcode"::STRING AS Bill_To_Bcode,
        JSONFIELD:"Ship_To_Ccode"::STRING AS Ship_To_Ccode,
        JSONFIELD:"Country_Code"::STRING AS Country_Code,
        _filedate as _FILEDATE
        FROM {{ source('THREEPL','TPL_STORAGE_LOCATION') }}
       {% if is_incremental() %} WHERE _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01') {% endif %}
      QUALIFY (ROW_NUMBER() OVER (PARTITION BY Storage_Location ORDER BY _FILEDATE DESC )) = 1
),

transform_data as(
    select
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
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    from source_data
),

type_data as(
    select
        CAST(Storage_Location AS VARCHAR(16777216)) AS Storage_Location,
        CAST(Location_Code AS VARCHAR(16777216)) AS Location_Code,
        CAST(Plant AS VARCHAR(16777216)) AS Plant,
        CAST(Description AS VARCHAR(16777216)) AS Description,
        CAST(Trading_Partner AS VARCHAR(16777216)) AS Trading_Partner,
        CAST(TPL_Account_Number AS VARCHAR(16777216)) AS TPL_Account_Number,
        CAST(TPL_Warehouse AS VARCHAR(16777216)) AS TPL_Warehouse,
        CAST(Enabled_For_EDI AS VARCHAR(16777216)) AS Enabled_For_EDI,
        CAST(Active AS VARCHAR(16777216)) AS Active,
        CAST(Last_Updated AS VARCHAR(16777216)) AS Last_Updated,
        CAST(Last_Updated_By AS VARCHAR(16777216)) AS Last_Updated_By,
        CAST(Consignment AS VARCHAR(16777216)) AS Consignment,
        CAST(Address_Id AS VARCHAR(16777216)) AS Address_Id,
        CAST(Sold_To_Bcode AS VARCHAR(16777216)) AS Sold_To_Bcode,
        CAST(Bill_To_Bcode AS VARCHAR(16777216)) AS Bill_To_Bcode,
        CAST(Ship_To_Ccode AS VARCHAR(16777216)) AS Ship_To_Ccode,
        CAST(Country_Code AS VARCHAR(16777216)) AS Country_Code,
        CAST(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        CAST(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        CAST(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
)
select * from type_data