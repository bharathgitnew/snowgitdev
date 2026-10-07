USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;
USE DATABASE ADMIN;
USE SCHEMA Policy_Access;

/* 
DROP ROW ACCESS POLICY Admin.Policy_Access.Financial_DepartmentCode;
*/

-- Create Row Access Policy Shell
CREATE ROW ACCESS POLICY IF NOT EXISTS Policy_Access.Financial_DAILY_ACTUALS_EXPENSE
    AS (CurrentAccount VARCHAR(16777216),CurrentDepartmentCode VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;

-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY Policy_Access.Financial_DAILY_ACTUALS_EXPENSE
SET BODY ->
CASE
    WHEN CURRENT_USER() = 'SVC_PREFECT'           THEN true
    WHEN CURRENT_ROLE() = 'SYSADMIN_PROD'         THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_DEV'          THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_QA'           THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_SIT'          THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM'         THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_DEV'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_SIT'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_QA'      THEN true     
    WHEN CURRENT_USER() IN (
                    SELECT UserId
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName = 'Financial Expense'
                        AND ColumnName =  'SAP_DEPT' 
                        AND (VisibleValue = CurrentDepartmentCode OR VisibleValue = 'AllValuesInTable' )
                    ) 
            AND EXISTS (SELECT 
                            1
                            FROM COMMON.SAPH.ORACLE_ACCOUNT_MAP
                            WHERE SAP_CODE = CurrentAccount
                        )                    
                    
                    THEN true
    ELSE false
END;

USE ROLE SECURITYADMIN;
GRANT APPLY ON ROW ACCESS POLICY Admin.Policy_Access.Financial_DAILY_ACTUALS_EXPENSE TO ROLE SYSADMIN_PROD;

USE ROLE SYSADMIN_PROD;
    ALTER TABLE COMMON.SAPH.DAILY_ACTUALS_EXPENSE ADD ROW ACCESS POLICY Admin.Policy_Access.Financial_DAILY_ACTUALS_EXPENSE on (ACCOUNT_NUMBER,DEPARTMENT_CODE);
