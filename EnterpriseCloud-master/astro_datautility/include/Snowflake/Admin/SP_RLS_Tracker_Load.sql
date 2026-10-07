USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;

CREATE OR REPLACE TABLE ADMIN.Policy_Access.RLS_Tracker
(
    Source_Environment VARCHAR(16777216),
    Loaded_Timestamp TIMESTAMP_NTZ,
    Policy_Database_Name VARCHAR(16777216),
    Policy_Schema_Name VARCHAR(16777216),
    Policy_Name VARCHAR(16777216),
    Table_Database_Name VARCHAR(16777216),
    Table_Schema_Name VARCHAR(16777216),
    Table_Table_Name VARCHAR(16777216),
    Table_Column_Names VARCHAR(16777216),
    Policy_Status VARCHAR(16777216)
)
;
CREATE OR REPLACE TABLE ADMIN.Control.RLS_Tracker_Log
(
    Execution_DateTime TIMESTAMP_NTZ,
    Execution_Process VARCHAR(16777216),
    Source_Environment VARCHAR(16777216),
    Target_Environment VARCHAR(16777216),
    Notes VARCHAR(16777216)
)
;

CREATE OR REPLACE PROCEDURE ADMIN.Policy_Access.RLS_Tracker_Load( Source_Envrionment VARCHAR(16777216) )
  RETURNS VARCHAR(16777216)
  LANGUAGE SQL
AS
$$
    DECLARE
        Counter INTEGER DEFAULT 0;
        Execution_DateTime TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP();
    BEGIN
        SHOW ROW ACCESS POLICIES IN ACCOUNT;
        
        CREATE OR REPLACE TEMPORARY TABLE ADMIN.Policy_Access.RLS_Tracker_Builder AS
            SELECT 
                References.Policy_DB AS Policy_Database_Name,
                References.Policy_Schema AS Policy_Schema_Name,
                References.Policy_Name As Policy_Name,
                References.Ref_Database_Name AS Table_Database_Name,
                References.Ref_Schema_Name AS Table_Schema_Name,
                References.Ref_Entity_Name AS Table_Table_Name,
                References.Ref_Arg_Column_Names AS Table_Column_Names            
            FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) RAPs
            JOIN Snowflake.Account_Usage.Policy_References References
             ON References.Policy_DB = RAPs."database_name"
             AND References.Policy_Schema = RAPs."schema_name"
             AND References.Policy_Name = RAPs."name"
             AND References.Policy_Kind = 'ROW_ACCESS_POLICY'
             AND References.Ref_Entity_Domain = 'TABLE'
             AND References.Policy_Status = 'ACTIVE'  
            JOIN ADMIN.ACCESSCONTROL.DATABASE_ENVIRONEMNT EnvDbs
            ON EnvDbs.Database_Name = References.Ref_Database_Name
            AND EnvDbs.Environment_Name = :Source_Envrionment
        ;

        INSERT INTO ADMIN.Policy_Access.RLS_Tracker
            SELECT * FROM ADMIN.Policy_Access.RLS_Tracker_Builder;

        INSERT INTO  ADMIN.Control.RLS_Tracker_Log
                (Execution_DateTime, Execution_Process, Source_Environment, Target_Environment, Notes )
            SELECT 
                :Execution_DateTime, 'RLS Tracker Load', :Source_Envrionment, NULL, TO_VARCHAR(COUNT(1))||' Rows Loaded' FROM ADMIN.Policy_Access.RLS_Tracker_Builder
        ;
        
        DROP TABLE ADMIN.Policy_Access.RLS_Tracker_Builder;
            
        RETURN 'SUCCESS';
    END;
$$
;

CALL ADMIN.Policy_Access.RLS_Tracker_Load('PROD');
SELECT * FROM ADMIN.Policy_Access.RLS_Tracker;
SELECT * FROM ADMIN.Control.RLS_Tracker_Log;


/*

USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;
CREATE OR REPLACE STREAM Admin.Entitlement.Map_Finance_Expense_Stream ON TABLE COMMON.saph.ORACLE_DEPT_MGMT_HIERARCHY;

USE ROLE SECURITYADMIN;
GRANT USAGE ON DATABASE COMMON TO ROLE TASKADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE COMMON TO ROLE TASKADMIN;
GRANT SELECT ON ALL TABLES IN DATABASE COMMON TO ROLE TASKADMIN;
GRANT SELECT ON FUTURE TABLES IN DATABASE COMMON TO ROLE TASKADMIN;
GRANT SELECT ON ALL TABLES IN DATABASE ADMIN TO ROLE TASKADMIN;
GRANT SELECT ON FUTURE TABLES IN DATABASE ADMIN TO ROLE TASKADMIN;
GRANT SELECT ON ALL STREAMS IN DATABASE ADMIN TO ROLE TASKADMIN;
GRANT SELECT ON FUTURE STREAMS IN DATABASE ADMIN TO ROLE TASKADMIN;

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





   Different MAX(_FileDate) > MAX(_FileDate) of Same table TIMETRAVEL: 24 hours ago




               /*
        
        RAP_Table_SQL := 'SELECT Database_Name, Schema_Name, Name, Database_Name||''.''||Schema_Name||''.''||Name AS Full_Name FROM ADMIN.Policy_Access.RLS_Tracker_Builder';
        RAP_TABLE_ResultSet := ( EXECUTE IMMEDIATE :RAP_Table_SQL );
        LET RAP_TABLE_Cursor CURSOR FOR RAP_TABLE_ResultSet;
        
        FOR Table_Row in RAP_TABLE_Cursor DO
            RAP_Usage_SQL := 'SELECT * FROM Snowflake.Account_Usage.Policy_References WHERE Policy_DB = '''||Table_Row.Database_Name||''' AND Policy_Schema = '''||Table_Row.Schema_Name||''' AND Policy_Name = '''||Table_Row.Name||'''';
            RAP_Usage_ResultSet := ( EXECUTE IMMEDIATE :RAP_Usage_SQL );
            -- LET RAP_Usage_Cursor CURSOR FOR RAP_Usage_ResultSet;
              
            -- FOR Usage_Row in RAP_Usage_Cursor DO
                Counter := Counter +1;
--                INSERT INTO ADMIN.Policy_Access.RLS_Tracker_Status VALUES (Table_Row.Full_Name, Usage_Row, 'Discovered');
            -- END FOR;
        END FOR;
         */

   