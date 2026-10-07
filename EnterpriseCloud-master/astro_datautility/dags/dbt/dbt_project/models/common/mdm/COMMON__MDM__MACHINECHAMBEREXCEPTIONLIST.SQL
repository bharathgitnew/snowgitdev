/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\Machine_Chamber_Exception__MachineChamberException.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\MachineChamberException.SQL
-materialized incremental
-alias MachineChamberException
-incremental_strategy merge
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:04 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='MachineChamberExceptionList',
    unique_key = []
) }}

with source_data as
(
    SELECT
    Machine_Chamber_Exception_List.SN AS SN,
    Machine_Chamber_Exception_List.BU AS BU,
    Machine_Chamber_Exception_List.WISDOM_Parent_SN AS WISDOM_Parent_SN,
    Machine_Chamber_Exception_List.Exception_Reason AS Exception_Reason,
    Machine_Chamber_Exception_List.Last_Verification_Date AS Last_Verification_Date
    FROM {{ ref('ODS__MDM__MACHINE_CHAMBER_EXCEPTION_LIST') }} Machine_Chamber_Exception_List
    )
,transform_data as
(
    SELECT
        SN,
        BU,
        WISDOM_Parent_SN,
        Exception_Reason,
        Last_Verification_Date
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        -- ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
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
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data