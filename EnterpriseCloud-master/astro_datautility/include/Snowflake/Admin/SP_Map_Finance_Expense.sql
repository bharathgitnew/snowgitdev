USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;

CREATE OR REPLACE PROCEDURE ADMIN.Entitlement.Map_Finance_Expense()
  RETURNS VARCHAR(16777216)
  LANGUAGE SQL
AS
$$
    DECLARE
        Entitlement_Table_Name VARCHAR(16777216) DEFAULT 'Financial Expense';

    BEGIN
        CREATE OR REPLACE TEMPORARY TABLE Admin.Entitlement.Map_Finance_Expense LIKE ADMIN.ENTITLEMENT.MASKINGROWDATA;
            
            
        INSERT INTO Admin.Entitlement.Map_Finance_Expense
           WITH Source_data AS
            (
                SELECT 
                    SVP_LEVEL,Director_VP_LEVEL,Manager_Level,Budget_Planner,Department,SAP_Dept,Cost_Center
                FROM COMMON.saph.ORACLE_DEPT_MGMT_HIERARCHY
            )
            , Admins AS
            (
                SELECT * FROM Source_data WHERE Department = '<ALL>'
            )            
            , Non_Admins AS
            (
                SELECT * FROM Source_data WHERE Department != '<ALL>'
            )
            ,Expense_Fields_Builder AS
            (
                SELECT SVP_LEVEL AS Employee_ID,Department,SAP_Dept,Cost_Center FROM Non_Admins UNION ALL
                SELECT Director_VP_LEVEL,Department,SAP_Dept,Cost_Center FROM Non_Admins UNION ALL
                SELECT Manager_Level,Department,SAP_Dept,Cost_Center FROM Non_Admins UNION ALL
                SELECT Budget_Planner,Department,SAP_Dept,Cost_Center FROM Non_Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'AllValuesInTable','AllValuesInTable','AllValuesInTable' FROM Admins UNION ALL
                SELECT Budget_Planner,'AllValuesInTable','AllValuesInTable','AllValuesInTable' FROM Admins
            )
            ,Financial_Expense_Fields AS 
            (
                SELECT DISTINCT Employee_ID,Column_Name, VisibleValue 
                FROM Expense_Fields_Builder
                UNPIVOT(VisibleValue FOR Column_Name IN (Department, SAP_Dept, Cost_Center))
            )
            ,Financial_Is_Expense AS
            (
                SELECT SVP_LEVEL AS Employee_ID,'true' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Director_VP_LEVEL,'true' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Manager_Level,'true' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Budget_Planner,'true' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'true' AS VisibleValue FROM Admins UNION ALL
                SELECT Director_VP_LEVEL,'true' AS VisibleValue FROM Admins UNION ALL
                SELECT Manager_Level,'true' AS VisibleValue FROM Admins UNION ALL
                SELECT Budget_Planner,'true' AS VisibleValue FROM Admins
            )
            ,Financial_Sensitive_Account AS
            (
                SELECT SVP_LEVEL AS Employee_ID,'Y' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'N' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'Y' AS VisibleValue FROM Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'N' AS VisibleValue FROM Admins UNION ALL
                SELECT Director_VP_LEVEL,'Y' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Director_VP_LEVEL,'N' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Manager_Level,'Y' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Manager_Level,'N' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Budget_Planner,'N' AS VisibleValue FROM Non_Admins UNION ALL
                SELECT Budget_Planner,'N' AS VisibleValue FROM Admins
            )
            ,Combined_Data AS
            (
                    SELECT DISTINCT Employee_ID, Column_Name, VisibleValue FROM Financial_Expense_Fields UNION ALL
                    SELECT DISTINCT Employee_ID, 'Expense Account', VisibleValue FROM Financial_Is_Expense UNION ALL
                    SELECT DISTINCT Employee_ID, 'Sensitive Account', VisibleValue FROM Financial_Sensitive_Account
            )
            ,Transform_Employees AS
            (
                SELECT UPPER(Global_Employee.EmailAddress) AS Email_Address,Combined_Data.Column_Name, Combined_Data.VisibleValue
                FROM Combined_Data
                JOIN COMMON.SHARED_DATASETS.Global_Employee
                ON Global_Employee.Employee_ID = Combined_Data.Employee_ID
            )
            SELECT Email_Address, 'Financial Expense' AS Table_Name, Column_Name, VisibleValue,NULL,NULL,NULL,NULL
            FROM Transform_Employees;
        
        DELETE FROM ADMIN.ENTITLEMENT.MASKINGROWDATA 
        WHERE TableName = 'Financial Expense';
    
        INSERT INTO ADMIN.ENTITLEMENT.MASKINGROWDATA
            SELECT UserId, TableName, ColumnName, VisibleValue,NULL,NULL,NULL,NULL
            FROM Admin.Entitlement.Map_Finance_Expense;
    
        DROP TABLE IF EXISTS Admin.Entitlement.Map_Finance_Expense;
        
        RETURN 'SUCCESS';
    END;
$$
;

USE ROLE TASKADMIN;
USE WAREHOUSE SYSTEMMAINTENANCE_WH;

CREATE OR REPLACE TASK ADMIN.Entitlement.Map_Finance_Expense_Load
  WAREHOUSE = SYSTEMMAINTENANCE_WH
  SCHEDULE = 'USING CRON 0 21 * * * America/Chicago'
  ALLOW_OVERLAPPING_EXECUTION = FALSE
  COMMENT = 'Finance_Expense Entitlement Security Load'
    --WHEN SYSTEM$STREAM_HAS_DATA('Admin.Entitlement.Map_Finance_Expense_Stream')
    AS CALL ADMIN.Entitlement.Map_Finance_Expense()
;
ALTER TASK ADMIN.Entitlement.Map_Finance_Expense_Load RESUME;

EXECUTE TASK ADMIN.Entitlement.Map_Finance_Expense_Load ;

SHOW TASKS;

select *
  from table(Admin.information_schema.task_history())
  order by scheduled_time DESC;

