USE ROLE SYSADMIN;
USE WAREHOUSE DEVELOPER_WH;

CREATE OR REPLACE PROCEDURE ADMIN.Policy_Access.RLS_Tracker_Apply( pSource_Envrionment VARCHAR(16777216), Target_Environment VARCHAR(16777216) )
  RETURNS VARCHAR(16777216)
  LANGUAGE SQL
AS
$$
    DECLARE
        Counter INTEGER DEFAULT 0;
        Execution_DateTime TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP();
        Table_Exists_CURSOR CURSOR FOR SELECT COUNT(1) AS Counter FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES WHERE Table_Catalog = ? AND Table_Schema = ? AND Table_Name = ?;
        
        Table_Exist_Row_Count NUMBER(38,0);
        
        Rows_Calculated NUMBER(38,0) DEFAULT 0;
        Rows_Tested NUMBER(38,0) DEFAULT 0;
        Rows_NotFound NUMBER(38,0) DEFAULT 0;
    BEGIN
        CREATE OR REPLACE TEMPORARY TABLE ADMIN.Policy_Access.RLS_Tracker_Usage AS
        WITH Source_Data AS ( SELECT * FROM ADMIN.Policy_Access.RLS_Tracker WHERE Source_Environment = :pSource_Envrionment )
           , Max_Set AS ( SELECT MAX(Loaded_Timestamp) AS Max_Date FROM Source_Data )
           , Last_DataSet AS ( SELECT * FROM Source_Data JOIN Max_Set ON Max_Date = Loaded_Timestamp )
           SELECT * FROM Last_DataSet
        ;

        SELECT COUNT(1) INTO :Rows_Calculated FROM ADMIN.Policy_Access.RLS_Tracker_Usage;

        LET Usage_Cursor CURSOR FOR SELECT * FROM ADMIN.Policy_Access.RLS_Tracker_Usage;

        FOR Usage_Row in Usage_Cursor DO
            Rows_Tested := Rows_Tested + 1;
            -- Test for Table Existance
            OPEN Table_Exists_CURSOR USING (Usage_Row.Table_Database_Name, Usage_Row.Table_Schema_Name, Usage_Row.Table_Table_Name);
            FETCH Table_Exists_CURSOR INTO Table_Exist_Row_Count;
            IF (:Table_Exist_Row_Count = 0 ) THEN 
                Rows_NotFound := Rows_NotFound + 1;
                CONTINUE;
            END IF;
            CLOSE Table_Exists_CURSOR;

          
            -- Test for RLS Already Applied
            -- Apply RLS if not applied
            -- Log Result

           
        END FOR;
        
        -- Log Result
        RETURN 'SUCCESS ->'||TO_VARCHAR(:Rows_NotFound)||'---'||TO_VARCHAR(:Rows_Calculated)||'---'||TO_VARCHAR(:Rows_Tested);
    END;
$$
;

CALL ADMIN.Policy_Access.RLS_Tracker_Apply('PROD','PROD');
--SELECT * FROM ADMIN.Policy_Access.RLS_Tracker;
SELECT * FROM ADMIN.Control.RLS_Tracker_Log;

RETURN id;
            
            Table_Exists_SQL = 'SELECT COUNT(1) AS Counter FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES;';
            
            Table_Exists_ResultSet := (EXECUTE IMMEDIATE :Table_Exists_SQL);
            
            LET Table_Exists_Cursor CURSOR FOR Table_Exists_ResultSet;
            
            -- FOR Table_Exist_Row IN Table_Exists_Cursor DO
            --     Table_Exist_Row_Count := Table_Exist_Row.Counter;
            -- END FOR;


 WHERE Table_Catalog = '''|| Usage_Row.Table_Database_Name || '''
            --' AND Table_Schema = '''||Usage_Row.Table_Schema_Name||''' AND Table_Name = '''||Usage_Row.Table_Table_Name||''';';



        
 


       WITH Source_Data AS ( SELECT * FROM ADMIN.Policy_Access.RLS_Tracker WHERE Source_Environment = 'PROD' )
           , Max_Set AS ( SELECT MAX(Loaded_Timestamp) AS Max_Date FROM Source_Data )
           , Last_DataSet AS ( SELECT * FROM Source_Data JOIN Max_Set ON Max_Date = Loaded_Timestamp )
           SELECT * FROM Last_DataSet
        ;

            

            -- IF NOT EXISTS (SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES WHERE Table_Catalog = Usage_Row.Table_Database_Name AND Table_Schema = Usage_Row.Table_Schema_Name AND Table_Name = Usage_Row.Table_Table_Name ) THEN 
            --     Rows_NotFound = Rows_NotFound + 1;
            --     CONTINUE;
            -- END IF;


        -- INSERT INTO  ADMIN.Control.RLS_Tracker_Log
        --         (Execution_DateTime, Execution_Process, Source_Environment, Target_Environment, Notes )
        --     SELECT 
        --         :Execution_DateTime, 'RLS Tracker Application', :Source_Envrionment, :Target_Envrionment, TO_VARCHAR(COUNT(Rows_NotFound))||' Rows Not Found' FROM ADMIN.Policy_Access.RLS_Tracker_Builder
        --         ;
            
/*



    
    
        SHOW ROW ACCESS POLICIES IN ACCOUNT;
        
        CREATE OR REPLACE TEMPORARY TABLE ADMIN.Policy_Access.RLS_Tracker_Builder AS
            SELECT 
                :Source_Envrionment AS Source_Environment,
                :Execution_DateTime AS Loaded_Timestamp,
                References.Policy_DB AS Policy_Database_Name,
                References.Policy_Schema AS Policy_Schema_Name,
                References.Policy_Name As Policy_Name,
                References.Ref_Database_Name AS Table_Database_Name,
                References.Ref_Schema_Name AS Table_Schema_Name,
                References.Ref_Entity_Name AS Table_Table_Name,
                References.Ref_Arg_Column_Names AS Table_Column_Names,
                CAST('Discovered' AS VARCHAR(16777216)) AS Policy_Status            
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
                (Execution_DateTime, Execution_Process, Source_Environment, Target_Environment, Inserted_Count )
            SELECT 
                :Execution_DateTime, 'RLS Tracker Load', :Source_Envrionment, NULL, COUNT(1) FROM ADMIN.Policy_Access.RLS_Tracker_Builder
        ;
            




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

   