{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='STO_SITE_ORIGIN_AND_RECEIVING',
        transient = false
) }}

with T001L as 
  (
  select * from {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU080_T001L') }} 
  ),

LIKP as 
  (
  select * from {{ ref('BRONZE__TEA_LOGISTICS__ZCDV_T_CMTU012_LIKP') }} 
  WHERE TRIM(LOWER(IS_DELETED)) NOT LIKE 'y%'
  ),

LIPS as 
  (
  select * from {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU013_LIPS') }} 
  WHERE TRIM(LOWER(IS_DELETED)) NOT LIKE 'y%'
  ),

EKPO as 
  (
  select * from {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU028_EKPO') }} 
  ),

sto_src_tgt_transform as 
  (
    select  
        lkp.VBELN AS DELIVERY,
        lips.POSNR AS ITEM,
        lips.PSTYV AS ITEM_CATEGORY,
        lkp.ERNAM AS CREATED_BY,
        lkp.ERDAT AS CREATED_ON,
        lkp.WADATIST AS PGID_ON,
        lips.MATNR AS MATERIAL,
        lips.WERKS AS PLANT,
        lips.LGORT AS ISSUING_LOCATION,
        t1.LGOBE AS ISSUING_SLOC_NAME,
        CASE
            WHEN ISSUING_LOCATION IN ('A120', 'A124', 'A129') THEN 'SDF'
            WHEN ISSUING_LOCATION = 'A324' THEN 'AUS'
            WHEN ISSUING_LOCATION IN ('A530', 'A534', 'A539') THEN 'PDX'
            WHEN ISSUING_LOCATION = 'A624' THEN 'BOI'
            WHEN ISSUING_LOCATION = 'A724' THEN 'DCA'
            WHEN ISSUING_LOCATION = 'B220' THEN 'PHX'
            WHEN ISSUING_LOCATION = 'B230' THEN 'PHX'
            WHEN ISSUING_LOCATION = 'B330' THEN 'ABQ'
            WHEN ISSUING_LOCATION = 'B430' THEN 'SJC'
            WHEN ISSUING_LOCATION = 'B520' THEN 'AUS'
            WHEN ISSUING_LOCATION IN ('B625', 'B627', 'B727') THEN 'TCS9'
            WHEN ISSUING_LOCATION = 'H420' THEN 'NPX'
            WHEN ISSUING_LOCATION = 'D930' THEN 'AZ'
            WHEN ISSUING_LOCATION = 'E130' THEN 'NM'
            WHEN ISSUING_LOCATION = 'E230' THEN 'OR'
            WHEN ISSUING_LOCATION = 'E330' THEN 'OR'
            WHEN ISSUING_LOCATION = 'F430' THEN 'OR'
        ELSE NULL
        END AS ISSUE_NAME,
        ekpo.LGORT AS RECEIVING_SLOC,
        t2.LGOBE AS RECEIVING_SLOC_NAME,
        CASE
            WHEN RECEIVING_SLOC = 'D930' THEN 'AZ'
            WHEN RECEIVING_SLOC = 'E130' THEN 'NM'
            WHEN RECEIVING_SLOC IN ('E230', 'E330', 'F430') THEN 'OR'
            ELSE NULL
        END AS REC_NAME,
        lips.CHARG AS BATCH,
        lips.LFIMG AS DELIVERY_QUANTITY,
        lips.VRKME AS SALES_UNIT,
        lips.VGBEL AS REFERENCE_PO,
        lips.VGPOS AS PO_ITEM
    FROM LIKP lkp
    JOIN LIPS lips ON lkp.VBELN = lips.VBELN
    LEFT JOIN T001L t1 ON lips.WERKS = t1.WERKS AND lips.LGORT = t1.LGORT
    LEFT JOIN EKPO ekpo ON lips.VGBEL = ekpo.EBELN AND try_to_number(lips.VGPOS) = try_to_number(ekpo.EBELP)
    LEFT JOIN T001L t2 ON ekpo.WERKS = t2.WERKS AND ekpo.LGORT = t2.LGORT
),



transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        DELIVERY,
        ITEM,
        ITEM_CATEGORY,
        CREATED_BY,
        CREATED_ON,
        TRY_TO_DATE(PGID_ON, 'YYYYMMDD')   AS PGID_ON,
        MATERIAL,
        PLANT,
        ISSUING_LOCATION,
        ISSUING_SLOC_NAME,
        ISSUE_NAME,
        RECEIVING_SLOC,
        RECEIVING_SLOC_NAME,
        REC_NAME,
        BATCH,
        TRY_TO_NUMBER(DELIVERY_QUANTITY) AS  DELIVERY_QUANTITY,
        SALES_UNIT,
        REFERENCE_PO,
        PO_ITEM    
    from sto_src_tgt_transform
    where DELIVERY_QUANTITY <> 0
),
type_data as (
    select 
        *
    from transform_data
)
select * from type_data