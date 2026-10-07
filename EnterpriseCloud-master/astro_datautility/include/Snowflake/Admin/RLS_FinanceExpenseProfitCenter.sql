USE ROLE SYSADMIN;
USE WAREHOUSE SYSTEMMAINTENANCE_WH;

CREATE ROW ACCESS POLICY IF NOT EXISTS <<ADMIN>>.Policy_Access.FINANCIAL_ABF_EXPENSE_PC
    AS (CurrentAccount VARCHAR(16777216),CurrentProfitCenter VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;
--Validations for Snowcheck
-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY <<ADMIN>>.Policy_Access.FINANCIAL_ABF_EXPENSE_PC
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
                    FROM <<ADMIN>>.Entitlement.MaskingRowData 
                    WHERE TableName = 'FINANCIAL_EXPENSE_PC'
                        AND ColumnName =  'PROFIT_CENTER' 
                        AND (VisibleValue = CurrentProfitCenter OR VisibleValue = 'AllValuesInTable' )
                    ) 
            AND EXISTS (SELECT 
                            1
                            FROM <<COMMON>>.SAPH.ORACLE_ACCOUNT_MAP
                            WHERE ORACLE_CODE = CurrentAccount
                              AND FOR_EXPENSE_REPORTING='true'
                        )                    
                    
                    THEN true
    ELSE false
END;