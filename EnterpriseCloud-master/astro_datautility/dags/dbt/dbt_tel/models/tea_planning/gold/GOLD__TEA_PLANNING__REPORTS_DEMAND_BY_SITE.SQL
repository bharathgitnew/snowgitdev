{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='REPORTS_DEMAND_BY_SITE',
        transient=false,
        enabled=true
) }}

with BPGD as (
Select Distinct 
BUSINESS_PARTNER_NUMBER
,NAME_1_OF_ORGANIZATION
,NAME_2_OF_ORGANIZATION
,NAME_3_OF_ORGANIZATION
,NAME_4_OF_ORGANIZATION
,BUT000_NAME_1
,BUT000_NAME_2
,NAME_1
,NAME_2
from {{ ref('SILVER__TEA_PLANNING__SAPH_BUSINESS_PARTNERS_GENERAL_DATA') }}
where LANGUAGE_KEY = 'EN'

),

TEA_SAP_SALES_DATA AS
(
    select
        MATERIAL_NUMBER_LIPS as item
        , cal.YEAR_MONTH_TEXT as PERIOD
        , LIKP_SOLD_TO_PARTY as sold_to_bp_code
        , BPGD.NAME_1 as sold_to_bp
        ,vbak_sales_document_type as SALES_DOC_TYPE
        ,SALES_DOC_TYPE_DESC AS SALES_DOC_TYPE_DESC
        ,sum(case when vbak_sales_document_type in ('ZPR2','ZPR1') then -1*ACTUAL_QUANTITY_DELIVERED else ACTUAL_QUANTITY_DELIVERED end) as QTY
    from {{ ref('SILVER__TEA_PLANNING__SAPH_SALES_ORDER_DELIVERY_LINE') }}
    left join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} AS cal on cal.CALENDAR_DATE_KEY = vbak_delivery_create_date 
    left join BPGD on BPGD.BUSINESS_PARTNER_NUMBER = LIKP_SOLD_TO_PARTY
    where MATERIAL_NUMBER_LIPS is not null
    and vbak_sales_document_type in ('ZPR2'
                                    ,'ZPR1'
                                    ,'ZT10'
                                    ,'ZP12'
                                    ,'ZP10'
                                     )
    group by
        material_number_lips        
        ,cal.YEAR_MONTH_TEXT
        ,LIKP_SOLD_TO_PARTY
        ,BPGD.NAME_1
        ,SALES_DOC_TYPE
        ,SALES_DOC_TYPE_DESC
),

TEA_BAAN_SALES_DATA AS
(
    select
        item
        ,period
        ,sold_to_bp as sold_to_bp_code
        ,sold_to_bp
        ,sum(qty) as qty
    from {{ ref('SILVER__TEA_PLANNING__BAAN_TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER') }}
    group by
        item
        ,period
        ,sold_to_bp
    order by period, item
    
),

MARA as
(
    select distinct
    inv.MATDOC_MATERIAL_NUMBER
    ,mara.MATERIAL_DESCRIPTION
    ,mara.SALES_LEAD_TIME_ZZSLTR as Lead_time
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_GENERAL_MATERIAL') }} inv
    join {{ ref('SILVER__TEA_PLANNING__SAPH_MATERIAL_PLANT_MASTER') }} mara on mara.mara_material_number = inv.matdoc_material_number
),

TEA_TEE_COMBINED_SALES_DATA AS
(
    select
        item
        ,sold_to_bp_code
        ,sold_to_bp
        ,PERIOD
        ,SALES_DOC_TYPE
        ,SALES_DOC_TYPE_DESC
        , QTY
        ,'SAP' as Source 
    from TEA_SAP_SALES_DATA

    union all
   
    select
        ITEM
        ,sold_to_bp_code
        ,sold_to_bp
        , PERIOD
        ,'BAAN' as SALES_DOC_TYPE
        ,'BAAN' as SALES_DOC_TYPE_DESC
        , QTY
        ,'BAAN' as Source 
    from TEA_BAAN_SALES_DATA   
    ),

SOURCE_DATA as (
    SELECT 
        ITEM
        ,MATDOC_MATERIAL_NUMBER
        ,MATERIAL_DESCRIPTION 
        ,SOLD_TO_BP_CODE
        ,SOLD_TO_BP
        ,PERIOD
        ,SALES_DOC_TYPE
        ,SALES_DOC_TYPE_DESC
        ,QTY
        ,SOURCE
        ,concat( Left(PERIOD, 4) , right(PERIOD, 2)) as YEARMONTH
        ,Left(PERIOD, 4) as YEAR
    ,case 
        when sold_to_bp ='I48002' then 'Israel'
        when sold_to_bp ='I73300' then 'Ireland'
        when sold_to_bp ='Intel IMR' then 'Intel IMR'
        when sold_to_bp ='Intel Ireland c/o DB Schenker Ltd.' then 'Intel Ireland c/o DB Schenker Ltd.'
        when sold_to_bp ='Intel Mobile Communications-INTMBL' then 'Intel Mobile Communications-INTMBL'
        when sold_to_bp ='Intel-CH4' then 'Intel-CH4'
        when sold_to_bp ='INTEL-INT11X' then 'INTEL-INT11X'
        when sold_to_bp ='Intel-INT12' then 'AZ'
        when sold_to_bp ='INTEL-INT12C' then 'AZ'
        when sold_to_bp ='Intel-INT15' then 'Intel-INT15'
        when sold_to_bp ='Intel-INT17' then 'Intel-INT17'
        when sold_to_bp ='Intel-INT20' then 'Intel-INT20'
        when sold_to_bp ='INTEL-INT32' then 'AZ'
        when sold_to_bp ='Intel-INT5' then 'Intel-INT5'
        when sold_to_bp ='INTEL-INTAFO' then 'AFO'
        when sold_to_bp ='INTEL-INTBLT' then 'INTEL-INTBLT'
        when sold_to_bp ='Intel-INTCVC' then 'Intel-INTCVC'
        when sold_to_bp ='INTEL-INTD1C' then 'PTD'
        when sold_to_bp ='INTEL-INTD1D' then 'PTD'
        when sold_to_bp ='INTEL-INTD1X' then 'PTD'
        when sold_to_bp ='Intel-INTD2' then 'Intel-INTD2'
        when sold_to_bp ='Intel-INTFM2' then 'Intel-INTFM2'
        when sold_to_bp ='Intel-INTFM6' then 'Intel-INTFM6'
        when sold_to_bp ='Intel-INTITT' then 'Intel-INTITT'
        when sold_to_bp ='INTEL-INTMRA' then 'INTEL-INTMRA'
        when sold_to_bp ='Intel-INTPG1' then 'Intel-INTPG1'
        when sold_to_bp ='INTEL-INTRA4' then 'INTEL-INTRA4'
        when sold_to_bp ='INTEL-INTRB1' then 'INTEL-INTRB1'
        when sold_to_bp ='INTEL-INTRP1' then 'INTEL-INTRP1'
        when sold_to_bp ='INTEL-INTSCR' then 'INTEL-INTSCR'
        when sold_to_bp ='TD7601' then 'Israel'
        when sold_to_bp ='TD7606' then 'Israel'
        when sold_to_bp ='INTEL-INT42' then 'AZ'
        when sold_to_bp ='BA4800' then 'Israel'
        else sold_to_bp 
    end as SOLD_TO
    ,case 
        when sold_to_bp ='I48002' then 'Israel'
        when sold_to_bp ='I73300' then 'Ireland'
        when sold_to_bp ='Intel IMR' then 'Intel IMR'
        when sold_to_bp ='Intel Ireland c/o DB Schenker Ltd.' then 'Intel Ireland c/o DB Schenker Ltd.'
        when sold_to_bp ='Intel Mobile Communications-INTMBL' then 'Intel Mobile Communications-INTMBL'
        when sold_to_bp ='Intel-CH4' then 'Intel-CH4'
        when sold_to_bp ='INTEL-INT11X' then 'INTEL-INT11X'
        when sold_to_bp ='Intel-INT12' then 'AZ'
        when sold_to_bp ='INTEL-INT12C' then 'AZ'
        when sold_to_bp ='Intel-INT15' then 'Intel-INT15'
        when sold_to_bp ='Intel-INT17' then 'Intel-INT17'
        when sold_to_bp ='Intel-INT20' then 'Intel-INT20'
        when sold_to_bp ='INTEL-INT32' then 'AZ'
        when sold_to_bp ='Intel-INT5' then 'Intel-INT5'
        when sold_to_bp ='INTEL-INTAFO' then 'AFO'
        when sold_to_bp ='INTEL-INTBLT' then 'INTEL-INTBLT'
        when sold_to_bp ='Intel-INTCVC' then 'Intel-INTCVC'
        when sold_to_bp ='INTEL-INTD1C' then 'PTD'
        when sold_to_bp ='INTEL-INTD1D' then 'PTD'
        when sold_to_bp ='INTEL-INTD1X' then 'PTD'
        when sold_to_bp ='Intel-INTD2' then 'Intel-INTD2'
        when sold_to_bp ='Intel-INTFM2' then 'Intel-INTFM2'
        when sold_to_bp ='Intel-INTFM6' then 'Intel-INTFM6'
        when sold_to_bp ='Intel-INTITT' then 'Intel-INTITT'
        when sold_to_bp ='INTEL-INTMRA' then 'INTEL-INTMRA'
        when sold_to_bp ='Intel-INTPG1' then 'Intel-INTPG1'
        when sold_to_bp ='INTEL-INTRA4' then 'INTEL-INTRA4'
        when sold_to_bp ='INTEL-INTRB1' then 'INTEL-INTRB1'
        when sold_to_bp ='INTEL-INTRP1' then 'INTEL-INTRP1'
        when sold_to_bp ='INTEL-INTSCR' then 'INTEL-INTSCR'
        when sold_to_bp ='TD7601' then 'Israel'
        when sold_to_bp ='TD7606' then 'Israel'
        when sold_to_bp ='INTEL-INT42' then 'AZ'
        when sold_to_bp ='BA4800' then 'Israel'
        else 'Unmapped' 
    end as SOLD_TO_MAP_FLAG
    FROM TEA_TEE_COMBINED_SALES_DATA AS SALES
    LEft join MARA on MARA.MATDOC_MATERIAL_NUMBER = SALES.item
),

TRANSFORM_DATA AS (
    SELECT
        ITEM
        ,MATDOC_MATERIAL_NUMBER
        ,MATERIAL_DESCRIPTION 
        ,SOLD_TO_BP_CODE
        ,SOLD_TO_BP
        ,PERIOD
        ,SALES_DOC_TYPE
        ,SALES_DOC_TYPE_DESC
        ,QTY
        ,SOURCE
        ,YEARMONTH
        ,YEAR
        ,SOLD_TO
        ,SOLD_TO_MAP_FLAG
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
    FROM SOURCE_DATA
), 

TYPE_DATA AS (
    SELECT
        CAST(AUDIT_LOG_ID AS VARCHAR(36)) AS _AUDIT_LOG_ID
        ,CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
        ,CAST(ITEM AS VARCHAR(16777216)) AS ITEM
        ,CAST(MATDOC_MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATDOC_MATERIAL_NUMBER
        ,CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION
        ,CAST(SOLD_TO_BP_CODE AS VARCHAR(16777216)) AS SOLD_TO_BP_CODE
        ,CAST(SOLD_TO_BP AS VARCHAR(16777216)) AS SOLD_TO_BP
        ,CAST(PERIOD AS VARCHAR(16777216)) AS PERIOD
        ,CAST(SALES_DOC_TYPE AS VARCHAR(16777216)) AS SALES_DOC_TYPE
        ,CAST(SALES_DOC_TYPE_DESC AS VARCHAR(16777216)) AS SALES_DOC_TYPE_DESC
        ,CAST(QTY AS FLOAT) AS QTY
        ,CAST(SOURCE AS VARCHAR(4)) AS SOURCE
        ,CAST(YEARMONTH AS VARCHAR(16777216)) AS YEARMONTH
        ,CAST(YEAR AS VARCHAR(16777216)) AS YEAR
        ,CAST(SOLD_TO AS VARCHAR(16777216)) AS SOLD_TO
        ,CAST(SOLD_TO_MAP_FLAG AS VARCHAR(34)) AS SOLD_TO_MAP_FLAG
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA