USE ROLE SYSADMIN;
USE WAREHOUSE SYSTEMMAINTENANCE_WH;

CREATE OR REPLACE PROCEDURE <<ADMIN>>.Entitlement.Map_Finance_Expense_PC()
  RETURNS VARCHAR(16777216)
  LANGUAGE SQL
AS
$$

    BEGIN
        CREATE OR REPLACE TEMPORARY TABLE <<ADMIN>>.Entitlement.Map_Finance_Expense_PC LIKE <<ADMIN>>.ENTITLEMENT.MASKINGROWDATA;
                    
        INSERT INTO <<ADMIN>>.Entitlement.Map_Finance_Expense_PC 
with Source_data as (
               SELECT 
                    SVP_LEVEL,Director_VP_LEVEL,Manager_Level,Budget_Planner,Department,SAP_Dept,Profit_Center
                FROM <<COMMON>>.saph.ORACLE_PC_MGMT_HIERARCHY
            )
            , Admins AS
            (
                SELECT * FROM Source_data WHERE  Profit_Center= '<ALL>'
            )   
            , Non_Admins AS
            (
                SELECT * FROM Source_data WHERE Profit_Center != '<ALL>'
            )
            ,Expense_Fields_Builder AS
            (
                SELECT SVP_LEVEL AS Employee_ID,Department,SAP_Dept,Profit_Center FROM Non_Admins UNION ALL
                SELECT Director_VP_LEVEL,Department,SAP_Dept,Profit_Center FROM Non_Admins UNION ALL
                SELECT Manager_Level,Department,SAP_Dept,Profit_Center FROM Non_Admins UNION ALL
                SELECT Budget_Planner,Department,SAP_Dept,Profit_Center FROM Non_Admins UNION ALL
                SELECT SVP_LEVEL AS Employee_ID,'AllValuesInTable','AllValuesInTable','AllValuesInTable' FROM Admins UNION ALL
                SELECT Budget_Planner,'AllValuesInTable','AllValuesInTable','AllValuesInTable' FROM Admins
            )
            ,Financial_Expense_Fields AS 
            (
                SELECT DISTINCT Employee_ID,Column_Name, VisibleValue 
                FROM Expense_Fields_Builder
                UNPIVOT(VisibleValue FOR Column_Name IN (Department, SAP_Dept, Profit_Center))
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
                JOIN <<COMMON>>.SHARED_DATASETS.Global_Employee
                ON Global_Employee.Employee_ID = Combined_Data.Employee_ID
            )
            SELECT Email_Address, 'FINANCIAL_EXPENSE_PC' AS Table_Name, Column_Name, VisibleValue,NULL,NULL,NULL,NULL
            FROM Transform_Employees;
        
        DELETE FROM <<ADMIN>>.ENTITLEMENT.MASKINGROWDATA 
        WHERE TableName = 'FINANCIAL_EXPENSE_PC';
    
        INSERT INTO <<ADMIN>>.ENTITLEMENT.MASKINGROWDATA
            SELECT UserId, TableName, ColumnName, VisibleValue,NULL,NULL,NULL,NULL
            FROM <<ADMIN>>.Entitlement.Map_Finance_Expense_PC ;
    
        DROP TABLE IF EXISTS <<ADMIN>>.Entitlement.Map_Finance_Expense_PC;
        
        RETURN 'SUCCESS';
    END;
$$
;


