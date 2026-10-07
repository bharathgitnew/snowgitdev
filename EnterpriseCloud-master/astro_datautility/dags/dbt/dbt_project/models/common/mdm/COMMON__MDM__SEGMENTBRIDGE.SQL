/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\ODS_2_Common-MDM\SegmentBridge__SegmentBridge.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\ods_to_common\models\mdm\SegmentBridge.SQL
-materialized incremental
-alias SegmentBridge
-incremental_strategy insert_overwrite
-envVariable <<ODS>>
-sourceSchema MDM
-sourceDatabase ODS_DEV
-useDistinct no
model file generated on: 2/2/2022 4:06:05 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SegmentBridge',
    unique_key = []
) }}

with source_data as
(
    SELECT
    SegmentBridge.Account,
    SegmentBridge.BU_FS,
    SegmentBridge.BU_Flag,
    SegmentBridge.Bill_To_Company,
    SegmentBridge.MachineBU_TypeOfWorkWithEval,
    SegmentBridge.Machine_BU,
    SegmentBridge.Product_Type,
    SegmentBridge.Segment_Code,
    SegmentBridge.Segment_Name,
    SegmentBridge.Transfer_Pricing,
    SegmentBridge.Type_Of_Work_With_Eval
    FROM {{ ref('ODS__MDM__SEGMENTBRIDGE') }} SegmentBridge
    )
,transform_data as
(
    SELECT
        Account,
        BU_FS,
        BU_Flag,
        Bill_To_Company,
        MachineBU_TypeOfWorkWithEval,
        Machine_BU,
        Product_Type,
        Segment_Code,
        Segment_Name,
        Transfer_Pricing,
        Type_Of_Work_With_Eval
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        FROM source_data
        )
,type_data as 
(
    select
        cast(BU_FLAG as VARCHAR(16777216)) as BU_FLAG,
        cast(SEGMENT_CODE as NUMBER(38,0)) as SEGMENT_CODE,
        cast(SEGMENT_NAME as VARCHAR(16777216)) as SEGMENT_NAME,
        cast(MACHINE_BU as VARCHAR(16777216)) as MACHINE_BU,
        cast(TYPE_OF_WORK_WITH_EVAL as VARCHAR(16777216)) as TYPE_OF_WORK_WITH_EVAL,
        cast(PRODUCT_TYPE as VARCHAR(16777216)) as PRODUCT_TYPE,
        cast(MACHINEBU_TYPEOFWORKWITHEVAL as VARCHAR(16777216)) as MACHINEBU_TYPEOFWORKWITHEVAL,
        cast(ACCOUNT as NUMBER(38,0)) as ACCOUNT,
        cast(TRANSFER_PRICING as NUMBER(38,0)) as TRANSFER_PRICING,
        cast(BU_FS as NUMBER(38,0)) as BU_FS,
        cast(BILL_TO_COMPANY as VARCHAR(16777216)) as BILL_TO_COMPANY,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data