USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;
USE DATABASE ADMIN;
USE SCHEMA Policy_Access;

/* DROP ROW ACCESS POLICY Policy_Access.EHS_Region_Product; */

-- Create Row Access Policy Shell
CREATE ROW ACCESS POLICY IF NOT EXISTS Policy_Access.EHS_Region_Product
    AS (Current_Region VARCHAR(16777216),Current_Business_Unit VARCHAR(16777216))  RETURNS BOOLEAN ->
CASE
    WHEN 1=1 THEN true
    ELSE false
END
;

-- Alter Row Access Policy to provide body of Business Rules
ALTER ROW ACCESS POLICY Policy_Access.EHS_Region_Product
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
    WHEN CURRENT_ROLE() = 'MANUFACTURING_TEAM' 
        AND Current_Business_Unit IN ('DSS (Epion-GCIB)','DSS (Epion-GCIB)') then true
   
    WHEN CURRENT_USER() IN (
                    SELECT UserId 
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'TIRS Data' ) 
                        AND ColumnName =  'Security Region' 
                        AND (VisibleValue = Current_Region OR VisibleValue = 'AllValuesInTable' )
                    )
        AND CURRENT_USER() IN (
                    SELECT UserId 
                    FROM Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'TIRS Data') 
                        AND ColumnName =  'Business Unit'
                        AND (VisibleValue = Current_Business_Unit OR VisibleValue = 'AllValuesInTable' )
                    ) THEN true
    ELSE false
END;


USE ROLE SECURITYADMIN;
GRANT APPLY ON ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product TO ROLE SYSADMIN_PROD;

USE ROLE SYSADMIN_PROD;
/* REMOVAL 
ALTER TABLE ODS.TIRS.ACCIDENTREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE ODS.TIRS.TRAFFICREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE COMMON.TIRS.ACCIDENTREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE COMMON.TIRS.TRAFFICREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE COMMON.DE_EHS.ACCIDENTREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE COMMON.DE_EHS.TRAFFICREPORTSFORUS_NOLOCK 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
ALTER TABLE COMMON.DE_EHS.TIRSACCIDENT 
    DROP ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product;
*/

-- ODS
ALTER TABLE ODS.TIRS.ACCIDENTREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
ALTER TABLE ODS.TIRS.TRAFFICREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
-- COMMON.TIRS
ALTER TABLE COMMON.TIRS.ACCIDENTREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
ALTER TABLE COMMON.TIRS.TRAFFICREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
-- COMMON.DE_EHS
ALTER TABLE COMMON.DE_EHS.ACCIDENTREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
ALTER TABLE COMMON.DE_EHS.TRAFFICREPORTSFORUS_NOLOCK 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );
ALTER TABLE COMMON.DE_EHS.TIRSACCIDENT 
    ADD ROW ACCESS POLICY Admin.Policy_Access.EHS_Region_Product on (SECURITY_REGION, COMMON_BU_EN );



    
USE ROLE SYSADMIN;
USE ROLE SYSADMIN_PROD;



                        SELECT *
                    FROM ADMIN.Entitlement.MaskingRowData 
                    WHERE TableName IN ( 'TIRS Data' ) 
                        --AND ColumnName =  'Business Unit'
                        AND USERID = 'MINH.CAO@US.TEL.COM'
;
                        
                        AND (VisibleValue = Current_Sensitive OR VisibleValue = 'AllValuesInTable' );


---- TESTING Entries

DELETE FROM ADMIN.Entitlement.MaskingRowData WHERE USERID = 'MINH.CAO@US.TEL.COM' AND TableName IN ( 'TIRS Data' );
INSERT INTO ADMIN.Entitlement.MaskingRowData
VALUES 

-- USA Testing
-- ('MINH.CAO@US.TEL.COM','TIRS Data','Security Region','USA',NULL,NULL,NULL,NULL),
-- ('MINH.CAO@US.TEL.COM','TIRS Data','Business Unit','AllValuesInTable',NULL,NULL,NULL,NULL)

-- Europe Testing
('MINH.CAO@US.TEL.COM','TIRS Data','Security Region','Europe',NULL,NULL,NULL,NULL),
('MINH.CAO@US.TEL.COM','TIRS Data','Business Unit','AllValuesInTable',NULL,NULL,NULL,NULL)

-- --- TMEA Product Testing
-- ('MINH.CAO@US.TEL.COM','TIRS Data','Security Region','AllValuesInTable',NULL,NULL,NULL,NULL),
-- ('MINH.CAO@US.TEL.COM','TIRS Data','Business Unit','DSS (FSI-CCS)',NULL,NULL,NULL,NULL),
-- ('MINH.CAO@US.TEL.COM','TIRS Data','Business Unit','DSS (Epion-GCIB)',NULL,NULL,NULL,NULL)

;