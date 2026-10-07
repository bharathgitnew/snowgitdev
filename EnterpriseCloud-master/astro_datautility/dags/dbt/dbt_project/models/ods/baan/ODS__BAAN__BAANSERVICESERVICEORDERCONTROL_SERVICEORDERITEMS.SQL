/**********************************
File built from dbtConvert.ps1
parameters: 
-filename C:\Sources\Repos\EnterpriseCloud\Snowflake\LZ_HVR-BAAN_2_ODS-BAAN\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS.SQL 
-newFile C:\Sources\Repos\EnterpriseCloud\dbt\lz_to_ods\models\baan\BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS.SQL 
-materialized incremental
-alias BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS 
-incremental_strategy insert_overwrite
-envVariable <<LZ>> 
-sourceSchema BAAN_ORACLE_LIVE
-sourceDatabase LZ_DEV
-useDistinct no 
model file generated on: 1/17/2022 12:52:55 PM
***********************************/
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS',
    unique_key = []
) }}


with source_data as 
(
   SELECT
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.ACTUALWAREHOUSE,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.CONFIGURATION,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.ITEM,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.LINENUMBER,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.SERIALNUMBER,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.SERVICECONTRACTNUMBER,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems.SERVICEORDER,
        QRY_Baanserviceserviceordercontrol_Serviceorderitems._CAPTUREDATETIME
        FROM
        (
        WITH CTE_SERVICEORDERS AS 
        (SELECT DISTINCT
            SERVICEORDERS._CAPTUREDATETIME,
            SERVICEORDERS.SERVICEORDER,
            SERVICEORDERMATERIALCOSTS.LINENUMBER,
            SERVICEORDERMATERIALCOSTS.ITEM,
            OBJECTS.SERIALNUMBER,
            SERVICEORDERS.SERVICECONTRACT AS SERVICECONTRACTNUMBER,
            SERVICEORDERMATERIALCOSTS.ACTUALWAREHOUSE,
            COALESCE(SERVICEORDERACTIVITIES.CONFIGURATION,SERVICEORDERS.CONFIGURATION)  AS SERVICEORDERACTIVITIESCONFIGURATION
        FROM {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICESERVICEORDERCONTROL_SERVICEORDERS") }} AS SERVICEORDERS
        LEFT OUTER JOIN {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICESERVICEORDERCONTROL_SERVICEORDERMATERIALCOSTS") }}  AS SERVICEORDERMATERIALCOSTS ON SERVICEORDERMATERIALCOSTS.SERVICEORDER = SERVICEORDERS.SERVICEORDER
        LEFT JOIN {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES") }}  AS SERVICEORDERACTIVITIES ON SERVICEORDERMATERIALCOSTS.SERVICEORDER = SERVICEORDERACTIVITIES.SERVICEORDER 
            AND SERVICEORDERMATERIALCOSTS.ACTIVITY = SERVICEORDERACTIVITIES.ACTIVITY
        LEFT JOIN {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICECONFIGURATIONCONTROL_OBJECTS") }}  AS OBJECTS ON SERVICEORDERACTIVITIES.CONFIGURATION = OBJECTS.CONFIGURATION AND SERVICEORDERACTIVITIES.OBJECT = OBJECTS.OBJECT
            AND SERVICEORDERACTIVITIES.OBJECTNUMBER = OBJECTS.OBJECTNUMBER
        ),
            
        CTE_SERVICEORDEROTHERCOSTS AS 
        (SELECT ServiceOrderOtherCosts.ServiceOrder,
        ServiceOrderOtherCosts.LineNumber,
        BaanServiceObjects.SerialNumber,
        BaanServiceObjects.Configuration
        FROM {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICESERVICEORDERCONTROL_SERVICEORDEROTHERCOSTS") }}  AS ServiceOrderOtherCosts
        INNER JOIN {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICESERVICEORDERCONTROL_SERVICEORDERACTIVITIES") }}  AS ServiceOrderActivities
        ON ServiceOrderOtherCosts.ServiceOrder = ServiceOrderActivities.ServiceOrder
        AND ServiceOrderActivities.Activity = ServiceOrderOtherCosts.Activity
        INNER JOIN {{ source("BAAN_ODS_SRC_FOR_LZ_TO_ODS_CONV", "BAANSERVICECONFIGURATIONCONTROL_OBJECTS") }}  AS BaanServiceObjects
        ON BaanServiceObjects.Object = ServiceOrderActivities.Object
        AND BaanServiceObjects.Configuration = ServiceOrderActivities.Configuration
        AND BaanServiceObjects.ObjectNumber = ServiceOrderActivities.ObjectNumber
        )

        SELECT IFNULL(SO_Items.ServiceOrder, SO_SerialNumber.ServiceOrder) AS ServiceOrder,--1,566,994 rows --1581533
                IFNULL(SO_Items.LineNumber, SO_SerialNumber.LineNumber) AS LineNumber,
                SO_Items.Item,
                SO_Items.ServiceContractNumber,
                SO_Items.ActualWarehouse,
                IFNULL(SO_Items.ServiceOrderActivitiesConfiguration, SO_SerialNumber.Configuration) AS Configuration,
                IFNULL(SO_SerialNumber.SerialNumber, SO_Items.SerialNumber) AS SerialNumber,
                SO_Items._CAPTUREDATETIME
        FROM CTE_SERVICEORDERS SO_Items FULL OUTER JOIN CTE_SERVICEORDEROTHERCOSTS SO_SerialNumber
        ON SO_Items.SERVICEORDER = SO_SerialNumber.SERVICEORDER AND SO_Items.LINENUMBER = SO_SerialNumber.LINENUMBER
        ) QRY_Baanserviceserviceordercontrol_Serviceorderitems
        
)

,transform_data as
(    SELECT
        source_data.ACTUALWAREHOUSE,
        source_data.CONFIGURATION,
        source_data.ITEM,
        source_data.LINENUMBER,
        source_data.SERIALNUMBER,
        source_data.SERVICECONTRACTNUMBER,
        source_data.SERVICEORDER,
        source_data._CAPTUREDATETIME
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.  
        FROM source_data
        )
,type_data as 
(
    select
        cast(SERVICEORDER as VARCHAR(16777216)) as SERVICEORDER,
        cast(LINENUMBER as NUMBER(38,0)) as LINENUMBER,
        cast(ITEM as VARCHAR(16777216)) as ITEM,
        cast(SERVICECONTRACTNUMBER as VARCHAR(16777216)) as SERVICECONTRACTNUMBER,
        cast(ACTUALWAREHOUSE as VARCHAR(16777216)) as ACTUALWAREHOUSE,
        cast(CONFIGURATION as VARCHAR(16777216)) as CONFIGURATION,
        cast(SERIALNUMBER as VARCHAR(16777216)) as SERIALNUMBER,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
		cast(_CAPTUREDATETIME as TIMESTAMP_LTZ(9)) as _CAPTUREDATETIME,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data