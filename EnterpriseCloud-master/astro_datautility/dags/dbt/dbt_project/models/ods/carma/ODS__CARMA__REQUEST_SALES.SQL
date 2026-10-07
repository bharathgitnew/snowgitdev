/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Carma\REQUESTSALES__CARMA_REQUESTSALES.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\carma\REQUEST_SALES.SQL 
-materialized incremental
-alias REQUEST_SALES 
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
    alias='REQUEST_SALES',
    unique_key = ['REQ_SALE_ID']
) }}


with source_data as 
(
    SELECT JSONFIELD:"req_sale_id"::NUMBER AS req_sale_id, 
         JSONFIELD:"rma_id"::NUMBER AS rma_id, 
         JSONFIELD:"is_cus_direct_requested"::NUMBER AS is_cus_direct_requested, 
         JSONFIELD:"receiving_expired"::NUMBER AS receiving_expired, 
         JSONFIELD:"baan_fab_id"::STRING  AS baan_fab_id, 
         JSONFIELD:"cust_descr"::STRING  AS cust_descr, 
         JSONFIELD:"damage_liability_disp_id"::NUMBER AS damage_liability_disp_id, 
         JSONFIELD:"bu_must_auth_return"::NUMBER AS bu_must_auth_return, 
         JSONFIELD:"bu_auth_return"::NUMBER AS bu_auth_return, 
         JSONFIELD:"will_customer_pay_damaged"::NUMBER AS will_customer_pay_damaged, 
         JSONFIELD:"in_transit_shipstamp_id"::NUMBER AS in_transit_shipstamp_id, 
         JSONFIELD:"emp_primary_comments"::STRING  AS emp_primary_comments, 
         JSONFIELD:"emp_secondary_comments"::STRING  AS emp_secondary_comments, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"inactive_dt" ,'/Date()/')) AS inactive_dt, 
        TO_TIMESTAMP_NTZ(TRIM(JSONFIELD:"created_dt" ,'/Date()/')) AS created_dt, 
         JSONFIELD:"active"::NUMBER AS active  
        FROM {{ source("CARMA", "REQUEST_SALES") }} as s
        WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("CARMA", "REQUEST_SALES") }} as c 
                                                where s.JSONFIELD:"req_sale_id"::NUMBER = c.JSONFIELD:"req_sale_id"::NUMBER) 
        )
,transform_data as
(
    SELECT 
        source_data.REQ_SALE_ID AS REQ_SALE_ID, 
        source_data.RMA_ID AS RMA_ID, 
        source_data.IS_CUS_DIRECT_REQUESTED AS IS_CUS_DIRECT_REQUESTED, 
        source_data.RECEIVING_EXPIRED AS RECEIVING_EXPIRED, 
        source_data.BAAN_FAB_ID AS BAAN_FAB_ID, 
        source_data.CUST_DESCR AS CUST_DESCR, 
        source_data.DAMAGE_LIABILITY_DISP_ID AS DAMAGE_LIABILITY_DISP_ID, 
        source_data.BU_MUST_AUTH_RETURN AS BU_MUST_AUTH_RETURN, 
        source_data.BU_AUTH_RETURN AS BU_AUTH_RETURN, 
        source_data.WILL_CUSTOMER_PAY_DAMAGED AS WILL_CUSTOMER_PAY_DAMAGED, 
        source_data.IN_TRANSIT_SHIPSTAMP_ID AS IN_TRANSIT_SHIPSTAMP_ID, 
        source_data.EMP_PRIMARY_COMMENTS AS EMP_PRIMARY_COMMENTS, 
        source_data.EMP_SECONDARY_COMMENTS AS EMP_SECONDARY_COMMENTS, 
        source_data.INACTIVE_DT AS INACTIVE_DT, 
        source_data.CREATED_DT AS CREATED_DT, 
        source_data.ACTIVE AS ACTIVE, 
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(REQ_SALE_ID as NUMBER(38,0)) as REQ_SALE_ID,
        cast(RMA_ID as NUMBER(38,0)) as RMA_ID,
        cast(IS_CUS_DIRECT_REQUESTED as NUMBER(38,0)) as IS_CUS_DIRECT_REQUESTED,
        cast(RECEIVING_EXPIRED as NUMBER(38,0)) as RECEIVING_EXPIRED,
        cast(BAAN_FAB_ID as VARCHAR(16777216)) as BAAN_FAB_ID,
        cast(CUST_DESCR as VARCHAR(16777216)) as CUST_DESCR,
        cast(DAMAGE_LIABILITY_DISP_ID as NUMBER(38,0)) as DAMAGE_LIABILITY_DISP_ID,
        cast(BU_MUST_AUTH_RETURN as NUMBER(38,0)) as BU_MUST_AUTH_RETURN,
        cast(BU_AUTH_RETURN as NUMBER(38,0)) as BU_AUTH_RETURN,
        cast(WILL_CUSTOMER_PAY_DAMAGED as NUMBER(38,0)) as WILL_CUSTOMER_PAY_DAMAGED,
        cast(IN_TRANSIT_SHIPSTAMP_ID as NUMBER(38,0)) as IN_TRANSIT_SHIPSTAMP_ID,
        cast(EMP_PRIMARY_COMMENTS as VARCHAR(16777216)) as EMP_PRIMARY_COMMENTS,
        cast(EMP_SECONDARY_COMMENTS as VARCHAR(16777216)) as EMP_SECONDARY_COMMENTS,
        cast(INACTIVE_DT as TIMESTAMP_NTZ(9)) as INACTIVE_DT,
        cast(CREATED_DT as TIMESTAMP_NTZ(9)) as CREATED_DT,
        cast(ACTIVE as NUMBER(38,0)) as ACTIVE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data