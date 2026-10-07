USE DATABASE <<ADMIN>>;
USE SCHEMA Policy_Access;


DROP ROW ACCESS POLICY IF EXISTS Policy_Access.SalesOperationsOrganization;

-- Create Row Access Policy Shell
CREATE ROW ACCESS POLICY Policy_Access.SalesOperationsOrganization
    AS (CurrentSalesOrganizationId VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;

-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY Policy_Access.SalesOperationsOrganization
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
                    WHERE TableName = 'SALES_OPERATIONS_SALES_CRM_SALES_ORGANIZATION'
                        AND ColumnName =  'SALESORGANIZATION_ID'
                        AND (VisibleValue = CurrentSalesOrganizationId OR VisibleValue = 'AllValuesInTable' )
                    )                               THEN true
    ELSE false
END;

-- Secure the Tables by this policy
ALTER TABLE <<Common>>.DE_Sales_Operations.sales_crm_sales_organization ADD ROW ACCESS POLICY Policy_Access.SalesOperationsOrganization ON (Sales_Organization_Id);