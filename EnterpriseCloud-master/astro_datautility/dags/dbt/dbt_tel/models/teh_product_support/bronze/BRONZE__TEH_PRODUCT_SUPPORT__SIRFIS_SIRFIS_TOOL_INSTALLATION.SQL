/**********************************
File built from dbtConvert.ps1
parameters:
-filename C:\Source\Repos\EnterpriseCloud\Snowflake\LZ_2_ODS-Sirfis\sirfis_forecast.SQL
-newFile C:\Source\Repos\EnterpriseCloud\dbt\lz_to_ods\models\sirfis\Sirfis_Forecast.SQL
-materialized incremental
-alias Sirfis_Forecast
-incremental_strategy merge
-envVariable <<LZ>>
-sourceSchema sirfis
-sourceDatabase LZ_DEV
-useDistinct $false
model file generated on: 1/10/2022 11:04:06 AM
***********************************/
{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SIRFIS_SIRFIS_TOOL_INSTALLATION'
) }}

with source_data as
(
    SELECT
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS SNAPSHOT_DATE,
        JSONFIELD:installScheduleId::STRING AS INSTALL_SCHEDULE_ID,
        _FILENAME,
        _FILEDATE,
        JSONFIELD:batch::STRING AS BATCH,
        JSONFIELD:building::STRING AS BUILDING,
        JSONFIELD:capacityProcess::STRING AS CAPACITY_PROCESS,
        JSONFIELD:ceid::STRING AS CE_ID,
        JSONFIELD:ckDescription::STRING AS CK_DESCRIPTION,
        JSONFIELD:convKitSdd::STRING AS CONV_KIT_SDD,
        JSONFIELD:datePublished::STRING AS DATE_PUBLISHED,
        JSONFIELD:entityCode::STRING AS ENTITY_CODE,
        JSONFIELD:entityType::STRING AS ENTITY_TYPE,
        JSONFIELD:eventType::STRING AS EVENT_TYPE,
        JSONFIELD:fulfillmentType::STRING AS FULFILLMENT_TYPE,
        JSONFIELD:functionalArea::STRING AS FUNCTIONAL_AREA,
        JSONFIELD:inInventory::STRING AS IN_INVENTORY,
        JSONFIELD:life::STRING AS LIFE,
        JSONFIELD:manufacturerName::STRING AS MANUFACTURER_NAME,
        JSONFIELD:manufacturerNumber::STRING AS MANUFACTURER_NUMBER,
        JSONFIELD:manufacturingType::STRING AS MANUFACTURING_TYPE,
        milestones.value:durationDays::STRING AS MILESTONES_DURATION_DAYS,
        milestones.value:finish::STRING AS MILESTONES_FINISH,
        milestones.value:finishActualized::STRING AS MILESTONES_FINISH_ACTUALIZED,
        milestones.value:name::STRING AS MILESTONES_NAME,
        milestones.value:start::STRING AS MILESTONES_START,
        milestones.value:timelineFinish::STRING AS MILESTONES_TIMELINE_FINISH,
        milestones.value:timelineStart::STRING AS MILESTONES_TIMELINE_START,
        JSONFIELD:model::STRING AS MODEL,
        JSONFIELD:originEntityCode::STRING AS ORIGIN_ENTITY_CODE,
        JSONFIELD:originSite::STRING AS ORIGIN_SITE,
        JSONFIELD:prefacSdd::STRING AS PREFAC_SDD,
        JSONFIELD:releasedForecast::STRING AS RELEASED_FORECAST,
        JSONFIELD:sdd AS SDD,
        JSONFIELD:site::STRING AS SITE,
        JSONFIELD:state::STRING AS STATE,
        JSONFIELD:supplierCanRespond::STRING AS SUPPLIER_CAN_RESPOND,
        JSONFIELD:team::STRING AS TEAM,
        JSONFIELD:timelineRows::STRING AS TIMELINE_ROWS,
        JSONFIELD:ueid::STRING AS UE_ID
    FROM {{ source("SIRFIS", "SIRFIS_TOOL_INSTALLATION") }} sti,
        LATERAL FLATTEN (input => sti.jsonfield:milestones, OUTER => true) milestones
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source("SIRFIS", "SIRFIS_TOOL_INSTALLATION") }})

)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        to_date(SNAPSHOT_DATE) AS SNAPSHOT_DATE,
        INSTALL_SCHEDULE_ID,
        _FILENAME,
        _FILEDATE,
        BATCH,
        BUILDING,
        CAPACITY_PROCESS,
        CE_ID,
        CK_DESCRIPTION,
        CONV_KIT_SDD,
        DATE_PUBLISHED,
        ENTITY_CODE,
        ENTITY_TYPE,
        EVENT_TYPE,
        FULFILLMENT_TYPE,
        FUNCTIONAL_AREA,
        IN_INVENTORY,
        LIFE,
        MANUFACTURER_NAME,
        MANUFACTURER_NUMBER,
        MANUFACTURING_TYPE,
        MILESTONES_DURATION_DAYS,
        to_date(MILESTONES_FINISH) as MILESTONES_FINISH,
        MILESTONES_FINISH_ACTUALIZED,
        MILESTONES_NAME,
        to_date(coalesce(MILESTONES_START,MILESTONES_TIMELINE_START)) as MILESTONES_START,
        MILESTONES_TIMELINE_FINISH,
        MILESTONES_TIMELINE_START,
        MODEL,
        ORIGIN_ENTITY_CODE,
        ORIGIN_SITE,
        PREFAC_SDD,
        RELEASED_FORECAST,
        SDD,
        SITE,
        STATE,
        SUPPLIER_CAN_RESPOND,
        TEAM,
        TIMELINE_ROWS,
        UE_ID
    FROM source_data
),

pivot_milestones as
(
   SELECT
    INSTALL_SCHEDULE_ID,

    -- Vendor Activities
    MAX(CASE WHEN MILESTONES_NAME = 'Vendor Activities'      THEN MILESTONES_START              END) AS Vendor_Activities_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Vendor Activities'      THEN MILESTONES_FINISH             END) AS Vendor_Activities_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Vendor Activities'      THEN MILESTONES_FINISH_ACTUALIZED  END) AS Vendor_Activities_Finish_Actualized,

    -- Supplier Qual
    MAX(CASE WHEN MILESTONES_NAME = 'Supplier Qual'          THEN MILESTONES_START              END) AS Supplier_Qual_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Supplier Qual'          THEN MILESTONES_FINISH             END) AS Supplier_Qual_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Supplier Qual'          THEN MILESTONES_FINISH_ACTUALIZED  END) AS Supplier_Qual_Finish_Actualized,

    -- Set
    MAX(CASE WHEN MILESTONES_NAME = 'Set'                    THEN MILESTONES_START              END) AS Set_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Set'                    THEN MILESTONES_FINISH             END) AS Set_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Set'                    THEN MILESTONES_FINISH_ACTUALIZED  END) AS Set_Finish_Actualized,

    -- SL2 Signoff
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Signoff'            THEN MILESTONES_START              END) AS SL2_Signoff_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Signoff'            THEN MILESTONES_FINISH             END) AS SL2_Signoff_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Signoff'            THEN MILESTONES_FINISH_ACTUALIZED  END) AS SL2_Signoff_Finish_Actualized,

    -- SL2 Construction
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Construction'       THEN MILESTONES_START              END) AS SL2_Construction_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Construction'       THEN MILESTONES_FINISH             END) AS SL2_Construction_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'SL2 Construction'       THEN MILESTONES_FINISH_ACTUALIZED  END) AS SL2_Construction_Finish_Actualized,

    -- SL1 Signoff
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Signoff'            THEN MILESTONES_START              END) AS SL1_Signoff_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Signoff'            THEN MILESTONES_FINISH             END) AS SL1_Signoff_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Signoff'            THEN MILESTONES_FINISH_ACTUALIZED  END) AS SL1_Signoff_Finish_Actualized,

    -- SL1 Construction
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Construction'       THEN MILESTONES_START              END) AS SL1_Construction_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Construction'       THEN MILESTONES_FINISH             END) AS SL1_Construction_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'SL1 Construction'       THEN MILESTONES_FINISH_ACTUALIZED  END) AS SL1_Construction_Finish_Actualized,

    -- Prefac
    MAX(CASE WHEN MILESTONES_NAME = 'Prefac'                 THEN MILESTONES_START              END) AS Prefac_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Prefac'                 THEN MILESTONES_FINISH             END) AS Prefac_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Prefac'                 THEN MILESTONES_FINISH_ACTUALIZED  END) AS Prefac_Finish_Actualized,

    -- Post SL2 Conversion
    MAX(CASE WHEN MILESTONES_NAME = 'Post SL2 Conversion'    THEN MILESTONES_START              END) AS Post_SL2_Conversion_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Post SL2 Conversion'    THEN MILESTONES_FINISH             END) AS Post_SL2_Conversion_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Post SL2 Conversion'    THEN MILESTONES_FINISH_ACTUALIZED  END) AS Post_SL2_Conversion_Finish_Actualized,

    -- OSM Prefac
    MAX(CASE WHEN MILESTONES_NAME = 'OSM Prefac'             THEN MILESTONES_START              END) AS OSM_Prefac_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'OSM Prefac'             THEN MILESTONES_FINISH             END) AS OSM_Prefac_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'OSM Prefac'             THEN MILESTONES_FINISH_ACTUALIZED  END) AS OSM_Prefac_Finish_Actualized,

    -- Move Out
    MAX(CASE WHEN MILESTONES_NAME = 'Move Out'               THEN MILESTONES_START              END) AS Move_Out_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Move Out'               THEN MILESTONES_FINISH             END) AS Move_Out_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Move Out'               THEN MILESTONES_FINISH_ACTUALIZED  END) AS Move_Out_Finish_Actualized,

    -- Mini SL2 Signoff
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2 Signoff'       THEN MILESTONES_START              END) AS Mini_SL2_Signoff_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2 Signoff'       THEN MILESTONES_FINISH             END) AS Mini_SL2_Signoff_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2 Signoff'       THEN MILESTONES_FINISH_ACTUALIZED  END) AS Mini_SL2_Signoff_Finish_Actualized,

    -- Mini SL2
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2'               THEN MILESTONES_START              END) AS Mini_SL2_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2'               THEN MILESTONES_FINISH             END) AS Mini_SL2_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL2'               THEN MILESTONES_FINISH_ACTUALIZED  END) AS Mini_SL2_Finish_Actualized,

    -- Mini SL1 Signoff
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1 Signoff'       THEN MILESTONES_START              END) AS Mini_SL1_Signoff_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1 Signoff'       THEN MILESTONES_FINISH             END) AS Mini_SL1_Signoff_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1 Signoff'       THEN MILESTONES_FINISH_ACTUALIZED  END) AS Mini_SL1_Signoff_Finish_Actualized,

    -- Mini SL1
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1'               THEN MILESTONES_START              END) AS Mini_SL1_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1'               THEN MILESTONES_FINISH             END) AS Mini_SL1_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Mini SL1'               THEN MILESTONES_FINISH_ACTUALIZED  END) AS Mini_SL1_Finish_Actualized,

    -- MRCL
    MAX(CASE WHEN MILESTONES_NAME = 'MRCL'                   THEN MILESTONES_START              END) AS MRCL_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'MRCL'                   THEN MILESTONES_FINISH             END) AS MRCL_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'MRCL'                   THEN MILESTONES_FINISH_ACTUALIZED  END) AS MRCL_Finish_Actualized,

    -- Disconnect Tool
    MAX(CASE WHEN MILESTONES_NAME = 'Disconnect Tool'        THEN MILESTONES_START              END) AS Disconnect_Tool_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Disconnect Tool'        THEN MILESTONES_FINISH             END) AS Disconnect_Tool_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Disconnect Tool'        THEN MILESTONES_FINISH_ACTUALIZED  END) AS Disconnect_Tool_Finish_Actualized,

    -- Demo
    MAX(CASE WHEN MILESTONES_NAME = 'Demo'                   THEN MILESTONES_START              END) AS Demo_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Demo'                   THEN MILESTONES_FINISH             END) AS Demo_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Demo'                   THEN MILESTONES_FINISH_ACTUALIZED  END) AS Demo_Finish_Actualized,

    -- Decon
    MAX(CASE WHEN MILESTONES_NAME = 'Decon'                  THEN MILESTONES_START              END) AS Decon_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Decon'                  THEN MILESTONES_FINISH             END) AS Decon_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Decon'                  THEN MILESTONES_FINISH_ACTUALIZED  END) AS Decon_Finish_Actualized,

    -- DSL2
    MAX(CASE WHEN MILESTONES_NAME = 'DSL2'                   THEN MILESTONES_START              END) AS DSL2_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'DSL2'                   THEN MILESTONES_FINISH             END) AS DSL2_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'DSL2'                   THEN MILESTONES_FINISH_ACTUALIZED  END) AS DSL2_Finish_Actualized,

    -- DSL1
    MAX(CASE WHEN MILESTONES_NAME = 'DSL1'                   THEN MILESTONES_START              END) AS DSL1_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'DSL1'                   THEN MILESTONES_FINISH             END) AS DSL1_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'DSL1'                   THEN MILESTONES_FINISH_ACTUALIZED  END) AS DSL1_Finish_Actualized,

    -- Convert
    MAX(CASE WHEN MILESTONES_NAME = 'Convert'                THEN MILESTONES_START              END) AS Convert_Start,
    MAX(CASE WHEN MILESTONES_NAME = 'Convert'                THEN MILESTONES_FINISH             END) AS Convert_Finish,
    MAX(CASE WHEN MILESTONES_NAME = 'Convert'                THEN MILESTONES_FINISH_ACTUALIZED  END) AS Convert_Finish_Actualized

FROM transform_data
GROUP BY INSTALL_SCHEDULE_ID
),

join_pivoted as (
    SELECT
       b.*,

        -- All pivoted milestone columns
        p.Vendor_Activities_Start,          p.Vendor_Activities_Finish,          p.Vendor_Activities_Finish_Actualized,
        p.Supplier_Qual_Start,              p.Supplier_Qual_Finish,              p.Supplier_Qual_Finish_Actualized,
        p.Set_Start,                        p.Set_Finish,                        p.Set_Finish_Actualized,
        p.SL2_Signoff_Start,                p.SL2_Signoff_Finish,                p.SL2_Signoff_Finish_Actualized,
        p.SL2_Construction_Start,           p.SL2_Construction_Finish,           p.SL2_Construction_Finish_Actualized,
        p.SL1_Signoff_Start,                p.SL1_Signoff_Finish,                p.SL1_Signoff_Finish_Actualized,
        p.SL1_Construction_Start,           p.SL1_Construction_Finish,           p.SL1_Construction_Finish_Actualized,
        p.Prefac_Start,                     p.Prefac_Finish,                     p.Prefac_Finish_Actualized,
        p.Post_SL2_Conversion_Start,        p.Post_SL2_Conversion_Finish,        p.Post_SL2_Conversion_Finish_Actualized,
        p.OSM_Prefac_Start,                 p.OSM_Prefac_Finish,                 p.OSM_Prefac_Finish_Actualized,
        p.Move_Out_Start,                   p.Move_Out_Finish,                   p.Move_Out_Finish_Actualized,
        p.Mini_SL2_Signoff_Start,           p.Mini_SL2_Signoff_Finish,           p.Mini_SL2_Signoff_Finish_Actualized,
        p.Mini_SL2_Start,                   p.Mini_SL2_Finish,                   p.Mini_SL2_Finish_Actualized,
        p.Mini_SL1_Signoff_Start,           p.Mini_SL1_Signoff_Finish,           p.Mini_SL1_Signoff_Finish_Actualized,
        p.Mini_SL1_Start,                   p.Mini_SL1_Finish,                   p.Mini_SL1_Finish_Actualized,
        p.MRCL_Start,                       p.MRCL_Finish,                       p.MRCL_Finish_Actualized,
        p.Disconnect_Tool_Start,            p.Disconnect_Tool_Finish,            p.Disconnect_Tool_Finish_Actualized,
        p.Demo_Start,                       p.Demo_Finish,                       p.Demo_Finish_Actualized,
        p.Decon_Start,                      p.Decon_Finish,                      p.Decon_Finish_Actualized,
        p.DSL2_Start,                       p.DSL2_Finish,                       p.DSL2_Finish_Actualized,
        p.DSL1_Start,                       p.DSL1_Finish,                       p.DSL1_Finish_Actualized,
        p.Convert_Start,                    p.Convert_Finish,                    p.Convert_Finish_Actualized

    FROM (
        SELECT DISTINCT
            _AUDIT_LOG_ID,
            _ROW_HASH,
            SNAPSHOT_DATE,
            INSTALL_SCHEDULE_ID,
            _FILENAME,
            _FILEDATE,
            BATCH,
            BUILDING,
            CAPACITY_PROCESS,
            CE_ID,
            CK_DESCRIPTION,
            CONV_KIT_SDD,
            DATE_PUBLISHED,
            ENTITY_CODE,
            ENTITY_TYPE,
            EVENT_TYPE,
            FULFILLMENT_TYPE,
            FUNCTIONAL_AREA,
            IN_INVENTORY,
            LIFE,
            MANUFACTURER_NAME,
            MANUFACTURER_NUMBER,
            MANUFACTURING_TYPE,
            MODEL,
            ORIGIN_ENTITY_CODE,
            ORIGIN_SITE,
            PREFAC_SDD,
            RELEASED_FORECAST,
            SDD,
            SITE,
            STATE,
            SUPPLIER_CAN_RESPOND,
            TEAM,
            TIMELINE_ROWS,
            UE_ID
        FROM transform_data
    ) b
    INNER JOIN pivot_milestones p
        ON b.INSTALL_SCHEDULE_ID = p.INSTALL_SCHEDULE_ID
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        SNAPSHOT_DATE,
        INSTALL_SCHEDULE_ID,
        _FILENAME,
        _FILEDATE,
        BATCH,
        BUILDING,
        CAPACITY_PROCESS,
        CE_ID,
        CK_DESCRIPTION,
        CAST(CONV_KIT_SDD AS TIMESTAMP_NTZ(9)) AS CONV_KIT_SDD,
        CAST(DATE_PUBLISHED AS TIMESTAMP_NTZ(9)) AS DATE_PUBLISHED,
        ENTITY_CODE,
        ENTITY_TYPE,
        EVENT_TYPE,
        FULFILLMENT_TYPE,
        FUNCTIONAL_AREA,
        IN_INVENTORY,
        LIFE,
        MANUFACTURER_NAME,
        MANUFACTURER_NUMBER,
        MANUFACTURING_TYPE,
        MODEL,
        ORIGIN_ENTITY_CODE,
        ORIGIN_SITE,
        CAST(PREFAC_SDD AS TIMESTAMP_NTZ(9)) AS PREFAC_SDD,
        RELEASED_FORECAST,
        CAST(SDD AS TIMESTAMP_NTZ(9)) AS SDD,
        SITE,
        STATE,
        SUPPLIER_CAN_RESPOND,
        TEAM,
        TIMELINE_ROWS,
        UE_ID,
        Vendor_Activities_Start,
        Vendor_Activities_Finish,
        Vendor_Activities_Finish_Actualized,
        Supplier_Qual_Start,
        Supplier_Qual_Finish,
        Supplier_Qual_Finish_Actualized,
        Set_Start,
        Set_Finish,
        Set_Finish_Actualized,
        SL2_Signoff_Start,
        SL2_Signoff_Finish,
        SL2_Signoff_Finish_Actualized,
        SL2_Construction_Start,
        SL2_Construction_Finish,
        SL2_Construction_Finish_Actualized,
        SL1_Signoff_Start,
        SL1_Signoff_Finish,
        SL1_Signoff_Finish_Actualized,
        SL1_Construction_Start,
        SL1_Construction_Finish,
        SL1_Construction_Finish_Actualized,
        Prefac_Start,
        Prefac_Finish,
        Prefac_Finish_Actualized,
        Post_SL2_Conversion_Start,
        Post_SL2_Conversion_Finish,
        Post_SL2_Conversion_Finish_Actualized,
        OSM_Prefac_Start,
        OSM_Prefac_Finish,
        OSM_Prefac_Finish_Actualized,
        Move_Out_Start,
        Move_Out_Finish,
        Move_Out_Finish_Actualized,
        Mini_SL2_Signoff_Start,
        Mini_SL2_Signoff_Finish,
        Mini_SL2_Signoff_Finish_Actualized,
        Mini_SL2_Start,
        Mini_SL2_Finish,
        Mini_SL2_Finish_Actualized,
        Mini_SL1_Signoff_Start,
        Mini_SL1_Signoff_Finish,
        Mini_SL1_Signoff_Finish_Actualized,
        Mini_SL1_Start,
        Mini_SL1_Finish,
        Mini_SL1_Finish_Actualized,
        MRCL_Start,
        MRCL_Finish,
        MRCL_Finish_Actualized,
        Disconnect_Tool_Start,
        Disconnect_Tool_Finish,
        Disconnect_Tool_Finish_Actualized,
        Demo_Start,
        Demo_Finish,
        Demo_Finish_Actualized,
        Decon_Start,
        Decon_Finish,
        Decon_Finish_Actualized,
        DSL2_Start,
        DSL2_Finish,
        DSL2_Finish_Actualized,
        DSL1_Start,
        DSL1_Finish,
        DSL1_Finish_Actualized,
        Convert_Start,
        Convert_Finish,
        Convert_Finish_Actualized
    from join_pivoted
    )
select * from type_data