/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\RECEIVEREQUEST__CARMA_RECEIVEREQUEST.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\RECEIVE_REQUEST.SQL 
-materialized incremental
-alias RECEIVE_REQUEST 
-incremental_strategy merge
-envVariable <<LZ>> 
-sourceSchema CARMA
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/10/2022 2:23:24 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='RECEIVE_REQUEST',
    unique_key = ['RECEIVE_REQUEST_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"receive_request_id"::NUMBER AS receive_request_id, 
         JSONFIELD:"rma_id"::NUMBER AS rma_id, 
         JSONFIELD:"qty_received"::NUMBER AS qty_received, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"received_dt" ,'/Date()/')) AS received_dt, 
         JSONFIELD:"damaged_in_transit"::NUMBER AS damaged_in_transit, 
         JSONFIELD:"rma_overage_accepted"::NUMBER AS rma_overage_accepted, 
         JSONFIELD:"qty_overage"::NUMBER AS qty_overage, 
         JSONFIELD:"damaged_further_in_transit"::NUMBER AS damaged_further_in_transit, 
         JSONFIELD:"inbound_shipping_carrier"::STRING  AS inbound_shipping_carrier, 
         JSONFIELD:"inbound_tracking_nbr"::STRING  AS inbound_tracking_nbr, 
         JSONFIELD:"has_part_been_received"::NUMBER AS has_part_been_received, 
         JSONFIELD:"has_part_been_expired"::NUMBER AS has_part_been_expired, 
         JSONFIELD:"has_refused_delivery"::NUMBER AS has_refused_delivery, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"active"::NUMBER AS active, 
         JSONFIELD:"receiving_users_action"::NUMBER AS receiving_users_action, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"reopen_dt" ,'/Date()/')) AS reopen_dt, 
         JSONFIELD:"reopen_user_id"::STRING  AS reopen_user_id  
        FROM {{ source("CARMA", "RECEIVE_REQUEST") }} as s
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "RECEIVE_REQUEST") }} as c 
                                                where s.JSONFIELD:"receive_request_id"::NUMBER  = c.JSONFIELD:"receive_request_id"::NUMBER ) 
        )
,transform_data as
(
    SELECT 
        source_data.RECEIVE_REQUEST_ID AS RECEIVE_REQUEST_ID, 
        source_data.RMA_ID AS RMA_ID, 
        source_data.QTY_RECEIVED AS QTY_RECEIVED, 
        source_data.RECEIVED_DT AS RECEIVED_DT, 
        source_data.DAMAGED_IN_TRANSIT AS DAMAGED_IN_TRANSIT, 
        source_data.RMA_OVERAGE_ACCEPTED AS RMA_OVERAGE_ACCEPTED, 
        source_data.QTY_OVERAGE AS QTY_OVERAGE, 
        source_data.DAMAGED_FURTHER_IN_TRANSIT AS DAMAGED_FURTHER_IN_TRANSIT, 
        source_data.INBOUND_SHIPPING_CARRIER AS INBOUND_SHIPPING_CARRIER, 
        source_data.INBOUND_TRACKING_NBR AS INBOUND_TRACKING_NBR, 
        source_data.HAS_PART_BEEN_RECEIVED AS HAS_PART_BEEN_RECEIVED, 
        source_data.HAS_PART_BEEN_EXPIRED AS HAS_PART_BEEN_EXPIRED, 
        source_data.HAS_REFUSED_DELIVERY AS HAS_REFUSED_DELIVERY, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.ACTIVE AS ACTIVE, 
        source_data.RECEIVING_USERS_ACTION AS RECEIVING_USERS_ACTION, 
        source_data.REOPEN_DT AS REOPEN_DT, 
        source_data.REOPEN_USER_ID AS REOPEN_USER_ID, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(RECEIVE_REQUEST_ID as NUMBER(38,0)) as RECEIVE_REQUEST_ID,
        cast(RMA_ID as NUMBER(38,0)) as RMA_ID,
        cast(QTY_RECEIVED as NUMBER(38,0)) as QTY_RECEIVED,
        cast(RECEIVED_DT as TIMESTAMP_NTZ(9)) as RECEIVED_DT,
        cast(DAMAGED_IN_TRANSIT as NUMBER(38,0)) as DAMAGED_IN_TRANSIT,
        cast(RMA_OVERAGE_ACCEPTED as NUMBER(38,0)) as RMA_OVERAGE_ACCEPTED,
        cast(QTY_OVERAGE as NUMBER(38,0)) as QTY_OVERAGE,
        cast(DAMAGED_FURTHER_IN_TRANSIT as NUMBER(38,0)) as DAMAGED_FURTHER_IN_TRANSIT,
        cast(INBOUND_SHIPPING_CARRIER as VARCHAR(16777216)) as INBOUND_SHIPPING_CARRIER,
        cast(INBOUND_TRACKING_NBR as VARCHAR(16777216)) as INBOUND_TRACKING_NBR,
        cast(HAS_PART_BEEN_RECEIVED as NUMBER(38,0)) as HAS_PART_BEEN_RECEIVED,
        cast(HAS_PART_BEEN_EXPIRED as NUMBER(38,0)) as HAS_PART_BEEN_EXPIRED,
        cast(HAS_REFUSED_DELIVERY as NUMBER(38,0)) as HAS_REFUSED_DELIVERY,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(RECEIVING_USERS_ACTION as NUMBER(38,0)) as RECEIVING_USERS_ACTION,
        cast(REOPEN_DT as TIMESTAMP_NTZ(9)) as REOPEN_DT,
        cast(REOPEN_USER_ID as VARCHAR(16777216)) as REOPEN_USER_ID,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data