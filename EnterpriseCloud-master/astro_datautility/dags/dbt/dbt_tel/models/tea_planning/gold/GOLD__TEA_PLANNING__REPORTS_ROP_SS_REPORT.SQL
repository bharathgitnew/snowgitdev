{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='REPORTS_ROP_SS_REPORT',
    transient=false
) }}

with MDMA as 
(
    select 
        WERKS as PLANT
        , right(BERID,4) as SLOC
        , MATNR as MDMA_MATERIAL_NUMBER
        , max(MINBE) as ROP
        , max(EISBE) as SS
        , max(MABST) as MAX
    from {{ ref('BRONZE__TEA_PLANNING__SAPAPI_ZCDV_T_CMTU106_MDMA') }}
    where WERKS between '3200' and '3400'
    group by PLANT, SLOC, MDMA_MATERIAL_NUMBER
),


MARC as 
(
    select DISTINCT
        MATERIAL_NUMBER
        ,PLANT
        ,LOCAL_ABC
        ,SPECIFIC_CUSTOMER_ABC
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_PLANT_MATERIAL') }}
),

MVKE as
(
    select distinct
        MVKE_MATERIAL_NUMBER
        ,PLANT_WERKS   
        ,MATERIAL_GROUP_1
        ,MATERIAL_GROUP_2
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_SALES_MATERIAL') }} 
),

source_data as
(
    select distinct
        MDMA.MDMA_MATERIAL_NUMBER as Material
        , MDMA.PLANT
        , MDMA.SLOC as Storage_Location
        , MARC.LOCAL_ABC as Local_ABC
        , MARC.SPECIFIC_CUSTOMER_ABC as Intel_ABC
        , case when substr(MDMA.SLOC,3,1) = '3' then 'Intel' else 'Non-Intel' end as INTEL
        , MVKE.MATERIAL_GROUP_1 as Product_Code
        , case when MVKE.MATERIAL_GROUP_2 = '0' then 'Non-Consumable' else 'Consumable'end as CONSUMABLE
        , MDMA.ROP
        , MDMA.SS
        , MDMA.MAX
        , MARA.NARITA_ABC as Narita_ABC
        , MARA.PART_SCORE as Criticality_Score
    from MDMA
    join MARC on MARC.MATERIAL_NUMBER = MDMA.MDMA_MATERIAL_NUMBER and MARC.PLANT = MDMA.PLANT
    join MVKE  MVKE on MDMA.MDMA_MATERIAL_NUMBER = MVKE.MVKE_MATERIAL_NUMBER and MDMA.PLANT = MVKE.PLANT_WERKS
    join {{ ref('SILVER__TEA_PLANNING__SAPH_MATERIAL_PLANT_MASTER') }} as MARA on MDMA.MDMA_MATERIAL_NUMBER = MARA.MARA_MATERIAL_NUMBER
    where MDMA.PLANT in ('3200','3300','3400')
),

transform_data AS
(
    select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
    a.* from source_data a
)

    select * from transform_data