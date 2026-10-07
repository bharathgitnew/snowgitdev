{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='BILL_OF_MATERIAL',
    	transient=false
) }}


WITH RECURSIVE BOM_LIST (
               PARENT_PART_NUMBER
              ,MATERIAL_DESCRIPTION
              ,CROSS_PLANT_STATUS
              ,PLANT
              ,PLANT_SPECIFIC_STATUS
              ,PARENT_PROCUREMENT_TYPE
              ,Parent_special_procurement_Type
              ,CHILD_PART_NUMBER
              ,CHILD_MATERIAL_DESCRIPTION
              ,COMPONENT_QUANTITY
              ,bom_item_number
              ,BOM_GROUP
             )
AS (
    -- Initial selection logic for BOM_LIST (same as in your original query)
    select distinct 
           MARA.MATERIAL_NUMBER
         , MDPARENT.MATERIAL_DESCRIPTION
         , MARA.CROSS_PLANT_MATERIAL_STATUS
         , MARC.PLANT
         , MARC.PLANT_SPECIFIC_MATERIAL_STATUS
         , MARC.PROCUREMENT_TYPE
         , MARC.SPECIAL_PROCUREMENT_TYPE
         , Valid_COMP.BOM_COMPONENT
         , MDCHILD.MATERIAL_DESCRIPTION
         , Valid_COMPONENT_QUANTITY
         , valid_BOM_ITEM_NUMBER
         , Valid_COMP.BILL_OF_MATERIAL
    from {{ ref('SILVER__TMEA_MANUFACTURING__GENERAL_MATERIAL_DATA') }} as MARA
    join {{ ref('SILVER__TMEA_MANUFACTURING__PLANT_DATA_FOR_MATERIAL') }} as MARC
        on MARA.CLIENT = MARC.CLIENT
        and MARA.MATERIAL_NUMBER = MARC.MATERIAL_NUMBER
    join {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_TO_BOM_LINK') }} as MAST
        on MARC.CLIENT = MAST.CLIENT
        and MARC.PLANT = MAST.PLANT
        and MARC.MATERIAL_NUMBER = MAST.MATERIAL_NUMBER
    join {{ ref('SILVER__TMEA_MANUFACTURING__BOM_HEADER') }} as  STKO
        on MAST.CLIENT = STKO.CLIENT
        and MAST.BILL_OF_MATERIAL = STKO.BILL_OF_MATERIAL
        and MAST.ALTERNATIVE_BOM = STKO.ALTERNATIVE_BOM
    join  {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_DESCRIPTIONS') }} as mdPARENT
        on mdPARENT.material_number = MARA.MATERIAL_NUMBER
        AND mdPARENT.LANGUAGE_KEY = 'E'
    join (
        select distinct 
               STPO.BOM_COMPONENT
             , STPO.BOM_CATEGORY
             , SQT_STAS.ALTERNATIVE_BOM
             , STPO.BILL_OF_MATERIAL
             , SQT_STAS.INHERITED_NODE_NUMBER_OF_BOM_ITEM as Valid_INHERITED_NODE_NUMBER_OF_BOM_ITEM 
             , SQT_STAS.BOM_ITEM_NODE_NUMBER as Valid_BOM_ITEM_NODE_NUMBER
             , STPO.COMPONENT_QUANTITY as valid_COMPONENT_QUANTITY
             , STPO.BOM_ITEM_NUMBER AS valid_BOM_ITEM_NUMBER
        from {{ ref('SILVER__TMEA_MANUFACTURING__BOM_ITEM') }} as STPO
        inner join 
            (select 
               ACTSTAS.BOM_CATEGORY
             , ACTSTAS.BILL_OF_MATERIAL
             , ACTSTAS.ALTERNATIVE_BOM
             , ACTSTAS.INHERITED_NODE_NUMBER_OF_BOM_ITEM
             , ACTSTAS.BOM_ITEM_NODE_NUMBER
             , ACTSTAS.INTERNAL_COUNTER
            from
                (select distinct
                    BOM_CATEGORY
                 , BILL_OF_MATERIAL
                 , ALTERNATIVE_BOM
                 , INHERITED_NODE_NUMBER_OF_BOM_ITEM
                 , BOM_ITEM_NODE_NUMBER
                 , MAX(cast(INTERNAL_COUNTER as smallint)) as Valid_INTERNAL_COUNTER 
                 from {{ ref('SILVER__TMEA_MANUFACTURING__BOMS_ITEM_SELECTION') }} as STAS
                 group by BOM_CATEGORY, BILL_OF_MATERIAL, ALTERNATIVE_BOM, INHERITED_NODE_NUMBER_OF_BOM_ITEM, BOM_ITEM_NODE_NUMBER
                )MXSTAS
                inner join {{ ref('SILVER__TMEA_MANUFACTURING__BOMS_ITEM_SELECTION') }}  as ACTSTAS 
                    on ACTSTAS.DELETION_INDICATOR != 'X'
                    and MXSTAS.BOM_CATEGORY=ACTSTAS.BOM_CATEGORY 
                    and MXSTAS.BILL_OF_MATERIAL=ACTSTAS.BILL_OF_MATERIAL 
                    and MXSTAS.ALTERNATIVE_BOM=ACTSTAS.ALTERNATIVE_BOM 
                    and MXSTAS.BOM_ITEM_NODE_NUMBER=ACTSTAS.BOM_ITEM_NODE_NUMBER 
                    and MXSTAS.Valid_INTERNAL_COUNTER=ACTSTAS.INTERNAL_COUNTER
            ) SQT_STAS
        on SQT_STAS.BOM_ITEM_NODE_NUMBER=STPO.BOM_ITEM_NODE_NUMBER 
        and SQT_STAS.BOM_CATEGORY=STPO.BOM_CATEGORY 
        and SQT_STAS.BILL_OF_MATERIAL=STPO.BILL_OF_MATERIAL
    ) Valid_COMP
        on Valid_COMP.BOM_CATEGORY = STKO.BOM_CATEGORY
        and Valid_COMP.BILL_OF_MATERIAL = STKO.BILL_OF_MATERIAL
    join {{ ref('SILVER__TMEA_MANUFACTURING__PLANT_DATA_FOR_MATERIAL') }}  as MARC_COMP
        on MAST.PLANT = MARC_COMP.PLANT
        and Valid_COMP.BOM_COMPONENT = MARC_COMP.MATERIAL_NUMBER
    join {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_DESCRIPTIONS') }} as MDCHILD
        on MDCHILD.material_number = MARC_COMP.MATERIAL_NUMBER
        AND MDCHILD.LANGUAGE_KEY = 'E'
),
BOM_TREE AS (
    -- Building BOM hierarchy
    select distinct 
        plant
        , parent_part_number as root_part_number
        , parent_part_number
        , MATERIAL_DESCRIPTION
        , PARENT_PROCUREMENT_TYPE
        , Parent_special_procurement_Type
        , CROSS_PLANT_STATUS
        , PLANT_SPECIFIC_STATUS
        , child_part_number
        , CHILD_MATERIAL_DESCRIPTION
        , COMPONENT_QUANTITY
        , bom_item_number
        , bom_group
        , 1 as level
        , case when 1 = 1 then child_part_number else null end as level_1_child_part_number -- capture level 1 Child Part Number
    from BOM_LIST
    union all
    select 
        child.plant
        , parent.root_part_number
        , child.parent_part_number
        , CHILD.MATERIAL_DESCRIPTION
        , child.PARENT_PROCUREMENT_TYPE
        , child.Parent_special_procurement_Type
        , child.CROSS_PLANT_STATUS
        , child.PLANT_SPECIFIC_STATUS
        , child.child_part_number
        , child.CHILD_MATERIAL_DESCRIPTION
        , child.COMPONENT_QUANTITY
        , child.bom_item_number
        , child.bom_group
        , parent.level + 1
        , case when parent.level + 1 = 1 then child.child_part_number else parent.level_1_child_part_number end as level_1_child_part_number
    from BOM_TREE as parent
    join BOM_LIST as child 
        on parent.child_part_number = child.parent_part_number
        and parent.plant = child.plant
    where parent.LEVEL < 15
),
source_data AS(
select 
    BOM_TREE.*
from BOM_TREE 
WHERE plant in ('0010')
    AND (root_part_number LIKE ('AV-%')
    OR root_part_number LIKE ('AN-%')
    OR root_part_number LIKE ('Z2-%')
    OR root_part_number LIKE ('Z3-%')
    OR root_part_number LIKE ('UT-%')
    OR root_part_number LIKE ('FN-%'))
    AND root_part_number NOT LIKE ('%COMMON%') 
ORDER BY level, parent_part_number, child_part_number
),

transform_data as(
select 
'{{ invocation_id }}' AS _AUDIT_LOG_ID,
SHA2('hash_me') as _ROW_HASH,
PLANT,
ROOT_PART_NUMBER,
PARENT_PART_NUMBER,
MATERIAL_DESCRIPTION,
PARENT_PROCUREMENT_TYPE,
PARENT_SPECIAL_PROCUREMENT_TYPE,
CROSS_PLANT_STATUS,
PLANT_SPECIFIC_STATUS,
CHILD_PART_NUMBER,
CHILD_MATERIAL_DESCRIPTION,
COMPONENT_QUANTITY,
BOM_ITEM_NUMBER,
BOM_GROUP,
TO_VARCHAR(LEVEL) AS LEVEL,
LEVEL_1_CHILD_PART_NUMBER
from source_data
),

type_data as (
select 
CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
PLANT,
ROOT_PART_NUMBER,
PARENT_PART_NUMBER,
MATERIAL_DESCRIPTION,
PARENT_PROCUREMENT_TYPE,
PARENT_SPECIAL_PROCUREMENT_TYPE,
CROSS_PLANT_STATUS,
PLANT_SPECIFIC_STATUS,
CHILD_PART_NUMBER,
CHILD_MATERIAL_DESCRIPTION,
COMPONENT_QUANTITY,
BOM_ITEM_NUMBER,
BOM_GROUP,
TO_VARCHAR(LEVEL) AS LEVEL,
LEVEL_1_CHILD_PART_NUMBER	
from transform_data 
)
select * from type_data