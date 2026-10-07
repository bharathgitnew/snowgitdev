/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-MDM\Machine_Chamber_Exception__MDM_Machine_Chamber.SQL 
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\mdm\Machine_Chamber_Exception_List.SQL 
-materialized incremental
-alias Machine_Chamber_Exception_List 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema MDM
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 7:25:00 PM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MDM_MACHINE_CHAMBER_EXCEPTION_LIST',
    unique_key = ['SN']
) }}


with source_data as 
(
    SELECT 
        jsonfield:"SN"::VARCHAR AS SN, 
        jsonfield:"BU"::VARCHAR AS BU, 
        jsonfield:"WISDOM Parent SN"::VARCHAR AS WISDOM_Parent_SN, 
        jsonfield:"Exception Reason"::VARCHAR AS Exception_Reason, 
        jsonfield:"Last Verification Date"::VARCHAR AS Last_Verification_Date 
        FROM {{ source("MDM", "MACHINE_CHAMBER_EXCEPTION_LIST") }} 
        WHERE _FileDate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "MACHINE_CHAMBER_EXCEPTION_LIST") }}) 
        )
,transform_data as
(
    SELECT 
        source_data.SN AS SN, 
        source_data.BU AS BU, 
        source_data.WISDOM_PARENT_SN AS WISDOM_Parent_SN, 
        source_data.EXCEPTION_REASON AS Exception_Reason, 
        TO_TIMESTAMP_NTZ ( REPLACE ( REPLACE ( source_data.LAST_VERIFICATION_DATE , '/Date(' , '' ) , ')/' , '' ) ) AS Last_Verification_Date, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(SN as VARCHAR(16777216)) as SN,
        cast(BU as VARCHAR(16777216)) as BU,
        cast(WISDOM_PARENT_SN as VARCHAR(16777216)) as WISDOM_PARENT_SN,
        cast(EXCEPTION_REASON as VARCHAR(16777216)) as EXCEPTION_REASON,
        cast(LAST_VERIFICATION_DATE as TIMESTAMP_NTZ(9)) as LAST_VERIFICATION_DATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data

