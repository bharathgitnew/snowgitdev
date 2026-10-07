USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;
USE DATABASE ADMIN;
USE SCHEMA Policy_Access;



/* DROP ROW ACCESS POLICY Policy_Access.Financial_DepartmentCode; */

-- Create Row Access Policy Shell
CREATE ROW ACCESS POLICY IF NOT EXISTS Policy_Access.Financial_OracleExpenseAccount
    AS (Current_Is_Expense VARCHAR(16777216),Current_Sensitive VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;

-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY Policy_Access.Financial_OracleExpenseAccount
SET BODY ->
CASE
    -- Access to All Account Info
    WHEN CURRENT_ROLE() = 'SVC_PREFECT'           THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_PROD'         THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_DEV'          THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_QA'           THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_SIT'          THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM'         THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_DEV'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_SIT'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_QA'      THEN true 
    -- Everyone has access to NON-Expense Accounts
    WHEN Current_Is_Expense = 'false' THEN true

    WHEN CURRENT_USER() IN (
                    SELECT UserId 
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'Financial Expense Admin' ) 
                    )  THEN true
                    
    WHEN CURRENT_USER() IN (
                    SELECT UserId 
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'Financial Expense' ) 
                        AND ColumnName =  'Expense Account' 
                        AND (VisibleValue = Current_Is_Expense OR VisibleValue = 'AllValuesInTable' )
                    )
        AND CURRENT_USER() IN (
                    SELECT UserId 
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'Financial Expense' ) 
                        AND ColumnName =  'Sensitive Account'
                        AND (VisibleValue = Current_Sensitive OR VisibleValue = 'AllValuesInTable' )
                    ) THEN true
    ELSE false
END;


USE ROLE SECURITYADMIN;
GRANT APPLY ON ROW ACCESS POLICY Admin.Policy_Access.Financial_OracleExpenseAccount TO ROLE SYSADMIN_PROD;

USE ROLE SYSADMIN_PROD;
ALTER TABLE COMMON.SAPH.ORACLE_ACCOUNT_MAP 
    DROP ROW ACCESS POLICY Admin.Policy_Access.Financial_OracleExpenseAccount;

ALTER TABLE COMMON.SAPH.ORACLE_ACCOUNT_MAP 
    ADD ROW ACCESS POLICY Admin.Policy_Access.Financial_OracleExpenseAccount on (SECURITY_IS_EXPENSE, SENSITIVE_INDICATOR);

USE ROLE SYSADMIN;
USE ROLE SYSADMIN_PROD;



                        SELECT VisibleValue , COUNT(*)
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'Financial Expense' ) 
                        AND ColumnName =  'Sensitive Account'
                        AND USERID = 'ROGER.X.WEBB@US.TEL.COM'
                        GROUP BY ALL;
                        
                        AND (VisibleValue = Current_Sensitive OR VisibleValue = 'AllValuesInTable' );

                        
SELECT Security_Is_Expense, SENSITIVE_INDICATOR, COUNT(*) FROM  COMMON.SAPH.ORACLE_ACCOUNT_MAP GROUP BY  ALL; 


SELECT 
                            *
                            FROM COMMON.SAPH.ORACLE_ACCOUNT_MAP
                            WHERE ORACLE_CODE = 'A6211990-210';
