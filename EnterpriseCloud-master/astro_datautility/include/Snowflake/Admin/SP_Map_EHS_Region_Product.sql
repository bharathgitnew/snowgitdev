USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;

/********************************************
RULES :
-----
   Group USA that can see all BUs in USA
   Group Europe that can see all BUs in Europe
   Group 'TMEA Product Group' That can see 2 BUs and ALL Security_regions


 ********************************************/
 
CREATE OR REPLACE PROCEDURE ADMIN.Entitlement.Map_EHS_Region_ProductTeam()
  RETURNS VARCHAR(16777216)
  LANGUAGE SQL
AS
$$
    DECLARE
        Entitlement_Table_Name VARCHAR(16777216) DEFAULT 'TIRS Data';

    BEGIN
        CREATE OR REPLACE TEMPORARY TABLE Admin.Entitlement.Map_EHS_Region_ProductTeam LIKE ADMIN.ENTITLEMENT.MASKINGROWDATA;
        
        INSERT INTO Admin.Entitlement.Map_EHS_Region_ProductTeam
           WITH Source_Group_USA AS
            (
                SELECT
                    GRANTEE_NAME        -- Name of the user to whom the privilege is granted. 
                FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
                WHERE true
                AND ROLE = 'SF_EHS_USA'  -- Identifier for the role granted to the user.
                AND GRANTED_TO = 'USER' -- For this view, the value is USER.
                AND DELETED_ON IS NULL  --Time and date (in the UTC time zone) when the role is revoked.
            )
            ,Source_Group_EUROPE AS
            (
                SELECT
                    GRANTEE_NAME        -- Name of the user to whom the privilege is granted. 
                FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
                WHERE true
                AND ROLE = 'SF_EHS_EUROPE'  -- Identifier for the role granted to the user.
                AND GRANTED_TO = 'USER' -- For this view, the value is USER.
                AND DELETED_ON IS NULL  --Time and date (in the UTC time zone) when the role is revoked.
            )
            ,Source_Group_TMEA_Product AS
            (
                SELECT
                    GRANTEE_NAME        -- Name of the user to whom the privilege is granted. 
                FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
                WHERE true
                AND ROLE = 'SF_EHS_TMEA_PRODUCT'  -- Identifier for the role granted to the user.
                AND GRANTED_TO = 'USER' -- For this view, the value is USER.
                AND DELETED_ON IS NULL  --Time and date (in the UTC time zone) when the role is revoked.
            )
            , Default_Data_USA AS
            (
                SELECT 
                    GRANTEE_NAME AS Email_Address,
                    'Security Region' AS Column_Name,
                    'USA' AS VisibleValue
                FROM Source_Group_USA
                UNION 
                SELECT 
                    GRANTEE_NAME AS Email_Address,
                    'Business Unit' AS Column_Name,
                    'AllValuesInTable' AS VisibleValue
                FROM Source_Group_USA
            )
            , Default_Data_Europe AS
            (
                SELECT 
                    GRANTEE_NAME AS Email_Address,
                    'Security Region' AS Column_Name,
                    'EUROPE' AS VisibleValue
                FROM Source_Group_Europe
                UNION 
                SELECT 
                    GRANTEE_NAME AS Email_Address,
                    'Business Unit' AS Column_Name,
                    'AllValuesInTable' AS VisibleValue
                FROM Source_Group_Europe
            )
            ,Entitlement_Field_Data AS 
            (
                SELECT DISTINCT Email_Address,Column_Name,VisibleValue FROM Default_Data_USA
                UNION
                SELECT DISTINCT Email_Address,Column_Name,VisibleValue FROM Default_Data_Europe
            )
            --SELECT Email_Address, :Entitlement_Table_Name AS Table_Name, Column_Name, VisibleValue,NULL,NULL,NULL,NULL
            SELECT Email_Address, 'TIRS Data' AS Table_Name, Column_Name, VisibleValue,NULL,NULL,NULL,NULL
            FROM Entitlement_Field_Data;
        
        DELETE FROM ADMIN.ENTITLEMENT.MASKINGROWDATA 
        WHERE TableName = :Entitlement_Table_Name;
    
        INSERT INTO ADMIN.ENTITLEMENT.MASKINGROWDATA
            SELECT UserId, TableName, ColumnName, VisibleValue,NULL,NULL,NULL,NULL
            FROM Admin.Entitlement.Map_EHS_Region_ProductTeam;
    
        DROP TABLE IF EXISTS Admin.Entitlement.Map_EHS_Region_ProductTeam;
        
        RETURN 'SUCCESS';
    END;
$$
;

USE ROLE TASKADMIN;
USE WAREHOUSE SYSTEMMAINTENANCE_WH;

CREATE OR REPLACE TASK ADMIN.Entitlement.Map_EHS_Region_ProductTeam_Load
  WAREHOUSE = SYSTEMMAINTENANCE_WH
  SCHEDULE = 'USING CRON 0 21 * * * America/Chicago'
  ALLOW_OVERLAPPING_EXECUTION = FALSE
  COMMENT = 'Environment Health and Safety Entitlement Security Load'
    AS CALL ADMIN.Entitlement.Map_EHS_Region_ProductTeam()
;

ALTER TASK ADMIN.Entitlement.Map_EHS_Region_ProductTeam_Load RESUME;

--EXECUTE TASK ADMIN.Entitlement.Map_EHS_Region_ProductTeam_Load ;

SHOW TASKS;

select *
  from table(Admin.information_schema.task_history())
  order by scheduled_time DESC;              