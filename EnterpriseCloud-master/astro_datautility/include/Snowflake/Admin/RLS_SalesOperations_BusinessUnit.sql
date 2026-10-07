USE DATABASE <<ADMIN>>;
USE SCHEMA Policy_Access;

DROP ROW ACCESS POLICY IF EXISTS Policy_Access.SalesOperationsBusinessUnit;

-- Create Row Access Policy Shell
CREATE ROW ACCESS POLICY Policy_Access.SalesOperationsBusinessUnit
    AS (CurrentBusinessUnitId VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;

-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY Policy_Access.SalesOperationsBusinessUnit
SET BODY ->
CASE
    WHEN CURRENT_USER() = 'SVC_PREFECT'           THEN true
    WHEN CURRENT_USER() = 'SVC_THOUGHTSPOT'       THEN true
    WHEN CURRENT_ROLE() = 'SYSADMIN_PROD'         THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_DEV'          THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_QA'           THEN true 
    WHEN CURRENT_ROLE() = 'SYSADMIN_SIT'          THEN true 
    WHEN CURRENT_ROLE() = 'PBISERVICE@US.TEL.COM' THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM'         THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_DEV'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_SIT'     THEN true 
    WHEN CURRENT_ROLE() = 'PLATFORM_TEAM_QA'      THEN true 
    
    WHEN CURRENT_USER() IN (
                    SELECT UserId
                    FROM Entitlement.MaskingRowData
                    WHERE TableName = 'SALES_OPERATIONS_SALES_CRM_BUSINESS_UNIT'
                        AND ColumnName =  'BUSINESSUNIT_ID'
                        AND (VisibleValue = CurrentBusinessUnitId OR VisibleValue = 'AllValuesInTable' )
                    )                               THEN true
    ELSE false
END;

-- Secure the Tables by this policy
ALTER TABLE <<Common>>.DE_Sales_Operations.sales_crm_business_unit ADD ROW ACCESS POLICY Policy_Access.SalesOperationsBusinessUnit ON (BU_ID);