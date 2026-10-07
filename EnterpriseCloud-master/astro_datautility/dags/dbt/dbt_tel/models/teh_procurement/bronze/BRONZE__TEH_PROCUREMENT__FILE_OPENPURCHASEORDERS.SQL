/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-File\OpenPurchaseOrders__File_OpenPO.SQL
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\file\OpenPurchaseOrders.SQL
-materialized incremental
-alias OpenPurchaseOrders
-incremental_strategy insert_overwrite
-envVariable <<LZ>>
-sourceSchema FILE
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/10/2022 11:56:58 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='FILE_OPENPURCHASEORDERS',
    unique_key = []
) }}


with source_data as
(
    SELECT
        	_FILENAME
        	,_FILEDATE
        	,BUYER
        	,SUPPLIER
        	,BU
        	,ORDER_NO
        	,LINE
        	,ORDER_NO_LINE
        	,SEQ
        	,ITEM
        	,ITEM_DESCRIPTION
        	,WHS
        	,ORDERED
        	,BACK_ORD_QTY
        	,ORDER_DATE
        	,PLANNED_DEL_DT
        	,COMMIT_DATE
        	,CHG_DEL_DATE
        	,TEL_UPDATE_DATE
        	,ORDER_DT_VS_PLANNED
        	,PLANNED_VS_CHG_DEL
        	,LEAD_TIME
        	,ORDER_AMT
        	,REF_A
        	,REF_B
        	,ORDER_PRIORITY
        	,SOLDTO_BP
        	,LOCAL_ABC_CODE
        	,INTEL_ABC_CODE
        	,STATUS
        	,COMMENTS
        	,HAWB_NO
        FROM {{ source("FILE", "OPENPO") }}
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("FILE", "OPENPO") }})
        )
,transform_data as
(
    SELECT
        BACK_ORD_QTY as BACKORDEREDQUANTITY,
        BUYER as BUYEREMPID,
        SUPPLIER as BUYFROMBPID,
        CHG_DEL_DATE as CHANGEDDELIVERYDATE,
        COMMENTS as COMMENTS,
        COMMIT_DATE as CONFIRMEDDELIVERYDATE,
        HAWB_NO as HAWBNUMBER,
        INTEL_ABC_CODE INTELABCCODE,
        ITEM as ITEM,
        ITEM_DESCRIPTION as ITEMDESCRIPTION,
        LEAD_TIME as LEADTIMEDAYS,
        LOCAL_ABC_CODE as LOCALABCCODE,
        ORDER_AMT as ORDEREDAMOUNT,
        ORDERED as ORDEREDQUANTITY,
        ORDER_DT_VS_PLANNED as ORDERPLANNEDVARIANCEDAYS,
        ORDER_PRIORITY as ORDERPRIORITY,
        STATUS as ORDERSTATUS,
        PLANNED_VS_CHG_DEL as PLANNEDCHANGEDVARIANCEDAYS,
        PLANNED_DEL_DT as PLANNEDDELIVERYDATE,
        ORDER_NO as  PONUMBER,
        ORDER_NO_LINE as PONUMBERPOSITION,
        LINE as POPOSITIONNUMBER,
        SEQ as POSEQUENCENUMBER,
        ORDER_DATE as PURCHASEORDERDATE,
        REF_A as REFERENCEA,
        REF_B as REFERENCEB,
        SOLDTO_BP as SOLDTOSEARCHKEY,
        BU as TEABUCODE,
        TEL_UPDATE_DATE as TELUPDATEDATE,
        WHS as WAREHOUSECODE,
        _FileDate AS _FileDate,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM source_data
)
,type_data as
(
    select
        cast(BUYEREMPID as VARCHAR(16777216)) as BUYEREMPID,
        cast(BUYFROMBPID as VARCHAR(16777216)) as BUYFROMBPID,
        cast(TEABUCODE as VARCHAR(16777216)) as TEABUCODE,
        cast(PONUMBER as VARCHAR(16777216)) as PONUMBER,
        cast(POPOSITIONNUMBER as VARCHAR(16777216)) as POPOSITIONNUMBER,
        cast(PONUMBERPOSITION as VARCHAR(16777216)) as PONUMBERPOSITION,
        cast(POSEQUENCENUMBER as VARCHAR(16777216)) as POSEQUENCENUMBER,
        cast(ITEM as VARCHAR(16777216)) as ITEM,
        cast(ITEMDESCRIPTION as VARCHAR(16777216)) as ITEMDESCRIPTION,
        cast(WAREHOUSECODE as VARCHAR(16777216)) as WAREHOUSECODE,
        cast(ORDEREDQUANTITY as NUMBER(11,2)) as ORDEREDQUANTITY,
        cast(BACKORDEREDQUANTITY as NUMBER(11,2)) as BACKORDEREDQUANTITY,
        cast(PURCHASEORDERDATE as DATE) as PURCHASEORDERDATE,
        cast(PLANNEDDELIVERYDATE as DATE) as PLANNEDDELIVERYDATE,
        cast(CONFIRMEDDELIVERYDATE as DATE) as CONFIRMEDDELIVERYDATE,
        cast(CHANGEDDELIVERYDATE as DATE) as CHANGEDDELIVERYDATE,
        cast(TELUPDATEDATE as DATE) as TELUPDATEDATE,
        cast(ORDERPLANNEDVARIANCEDAYS as NUMBER(38,0)) as ORDERPLANNEDVARIANCEDAYS,
        cast(PLANNEDCHANGEDVARIANCEDAYS as NUMBER(38,0)) as PLANNEDCHANGEDVARIANCEDAYS,
        cast(LEADTIMEDAYS as NUMBER(38,0)) as LEADTIMEDAYS,
        cast(ORDEREDAMOUNT as NUMBER(11,2)) as ORDEREDAMOUNT,
        cast(REFERENCEA as VARCHAR(16777216)) as REFERENCEA,
        cast(REFERENCEB as VARCHAR(16777216)) as REFERENCEB,
        cast(ORDERPRIORITY as VARCHAR(16777216)) as ORDERPRIORITY,
        cast(SOLDTOSEARCHKEY as VARCHAR(16777216)) as SOLDTOSEARCHKEY,
        cast(LOCALABCCODE as VARCHAR(16777216)) as LOCALABCCODE,
        cast(INTELABCCODE as VARCHAR(16777216)) as INTELABCCODE,
        cast(ORDERSTATUS as VARCHAR(16777216)) as ORDERSTATUS,
        cast(COMMENTS as VARCHAR(16777216)) as COMMENTS,
        cast(HAWBNUMBER as VARCHAR(16777216)) as HAWBNUMBER,
        cast(_FileDate as TIMESTAMP_NTZ) as _FileDate,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data