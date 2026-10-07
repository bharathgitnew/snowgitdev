USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;
USE DATABASE ADMIN;
USE SCHEMA Policy_Access;

DESCRIBE ROW ACCESS POLICY Policy_Access.Indirect_Procurement__Indirect_Purchase_Order_Information;

CREATE ROW ACCESS POLICY Policy_Access.Indirect_Procurement__Indirect_Purchase_Order_Information AS 
(CurrentCostCenterCode VARCHAR(16777216)) 
RETURNS BOOLEAN -> true;

ALTER ROW ACCESS POLICY Policy_Access.Indirect_Procurement__Indirect_Purchase_Order_Information
SET BODY ->
CASE
    WHEN CURRENT_USER() = 'SVC_PREFECT'           THEN true
    -- WHEN CURRENT_ROLE() = 'SYSADMIN_PROD'         THEN true
    -- WHEN CURRENT_ROLE() = 'SYSADMIN_DEV'          THEN true
    -- WHEN CURRENT_ROLE() = 'SYSADMIN_QA'           THEN true
    -- WHEN CURRENT_ROLE() = 'SYSADMIN_SIT'          THEN true 

    -- WHEN CURRENT_USER() IN (
    --                 SELECT UserId
    --                 FROM Entitlement.MaskingRowData
    --                 WHERE TableName = 'SalesAccount'
    --                     AND ColumnName =  'Account_ID'
    --                     AND (VisibleValue = CurrentAccountId OR VisibleValue = 'AllValuesInTable' )
    --                 )                               THEN true
    ELSE true
END;

CREATE OR REPLACE TABLE COMMON_DEV.DE_ADMIN.Roger_RLS_Test (ID Int, CostCerterCode VArCHAR(16777216));
ALTER TABLE COMMON_DEV.DE_ADMIN.Roger_RLS_Test ADD ROW ACCESS POLICY Admin.Policy_Access.Indirect_Procurement__Indirect_Purchase_Order_Information ON (CostCenterCode);


BEGIN 
    IF( NOT EXISTS
            (
select * from table(information_schema.policy_references(ref_entity_name => 'COMMON_DEV.DE_ADMIN.Roger_RLS_Test' , ref_entity_domain => 'table'))
            )
        )
    THEN 
        ALTER TABLE COMMON_DEV.DE_ADMIN.Roger_RLS_Test
            ADD ROW ACCESS POLICY Admin.Policy_Access.Indirect_Procurement__Indirect_Purchase_Order_Information ON (<CostCenterCode>); 
    END IF; 
END;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.ROW_ACCESS_POLICIES WHERE DELETED IS NULL;



BEGIN 
    IF (NOT EXISTS(select * from table(information_schema.policy_references(ref_entity_name =>  {{ this }} , ref_entity_domain => 'table')))) THEN alter table {{ this }} add row access policy <policy_to_add> ON (<column_to_add_to>); END IF; END;"


RLS Application System