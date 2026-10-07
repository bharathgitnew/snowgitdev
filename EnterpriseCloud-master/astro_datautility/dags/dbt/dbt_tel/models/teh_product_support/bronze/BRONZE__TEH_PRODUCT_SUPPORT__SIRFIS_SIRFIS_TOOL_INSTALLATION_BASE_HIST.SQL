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
    incremental_strategy='merge',
    alias='SIRFIS_SIRFIS_TOOL_INSTALLATION_BASE_HIST',
    unique_key = ['SNAPSHOT_DATE']
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
    WHERE _FILEDATE> (SELECT COALESCE(MAX(_FILEDATE),'1900-01-01') FROM {{ this }})

)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
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
        MILESTONES_DURATION_DAYS,
        MILESTONES_FINISH,
        MILESTONES_FINISH_ACTUALIZED,
        MILESTONES_NAME,
        MILESTONES_START,
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
)
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(SNAPSHOT_DATE AS TIMESTAMP_NTZ(9)) AS SNAPSHOT_DATE,
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
        MILESTONES_DURATION_DAYS,
        CAST(MILESTONES_FINISH AS TIMESTAMP_NTZ(9)) AS MILESTONES_FINISH,
        MILESTONES_FINISH_ACTUALIZED,
        MILESTONES_NAME,
        CAST(MILESTONES_START AS TIMESTAMP_NTZ(9)) AS MILESTONES_START,
        CAST(MILESTONES_TIMELINE_FINISH AS TIMESTAMP_NTZ(9)) AS MILESTONES_TIMELINE_FINISH,
        CAST(MILESTONES_TIMELINE_START AS TIMESTAMP_NTZ(9)) AS MILESTONES_TIMELINE_START,
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
        UE_ID
    from transform_data
    )
select * from type_data