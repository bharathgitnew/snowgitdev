WITH
 Schema_List AS
(
            SELECT Catalog_Name, Schema_Name ,'LZ.'      || Catalog_Name ||'.' || Schema_Name AS Ordering FROM LZ_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'ODS.'     || Catalog_Name ||'.' || Schema_Name AS Ordering FROM ODS_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'COMMON.'  || Catalog_Name ||'.' || Schema_Name AS Ordering FROM COMMON_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'EDW.'     || Catalog_Name ||'.' || Schema_Name AS Ordering FROM EDW_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'TESTING.' || Catalog_Name ||'.' || Schema_Name AS Ordering FROM TESTING_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'ADMIN.' || Catalog_Name ||'.' || Schema_Name AS Ordering FROM ADMIN_QA.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
)
,SOURCE_DATA AS
(
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT  OWNERSHIP ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE SYSADMIN_QA REVOKE CURRENT GRANTS;
            GRANT  OWNERSHIP ON ALL         VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE SYSADMIN_QA REVOKE CURRENT GRANTS;
            REVOKE ALL       ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' FROM ROLE VIEW_DDL_ONLY;
            REVOKE ALL       ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' FROM ROLE PROCESSADMIN_PROD;
            REVOKE ALL       ON     FUTURE  VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' FROM ROLE PROCESSADMIN_PROD;
            REVOKE ALL       ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' FROM ROLE READ_ONLY;
            REVOKE ALL       ON     FUTURE  VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' FROM ROLE READ_ONLY;
        ' AS grant_statement
        ,'A.A.TablesAndViews.'|| Ordering AS Ordering
    FROM Schema_List
), SOURCE_DATA_TABLES AS
(
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT  SELECT    ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_QA;
            GRANT  SELECT    ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_QA;
            GRANT  ALL       ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_QA;
            GRANT  ALL       ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_QA;
        ' AS grant_statement
        ,'A.B.TablesAndViews.'|| Ordering AS Ordering
    FROM Schema_List
    WHERE Catalog_Name IN ('LZ_QA','ODS_QA','COMMON_QA','EDW_QA','TESTING_QA','ADMIN_QA')
)
, SOURCE_DATA_VIEWS AS
(
    SELECT
        'USE ROLE SecurityAdmin;
 		    GRANT  USAGE    ON SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_QA;
            GRANT  SELECT    ON ALL        VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_QA;
            GRANT  SELECT    ON     FUTURE VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_QA;
            GRANT  ALL       ON ALL        VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_QA;
            GRANT  ALL       ON     FUTURE VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_QA;
        ' AS grant_statement
        ,'A.C.TablesAndViews.'|| Ordering AS Ordering
    FROM Schema_List
    WHERE Catalog_Name IN ('TESTING_QA','ADMIN_QA')
) 
,ALL_TEAM_ROLES AS(

    select distinct name from snowflake.account_usage.roles 
        where name not  like '%QA%' and name not  like '%DEV%' and name not like 'SF%' and name like '%TEAM%' and name!='SECURITY_TEAM' and deleted_on is null
)

, UNIONALL as 
(
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA
UNION ALL
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA_Tables
UNION ALL
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA_Views
UNION ALL
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT OWNERSHIP ON STREAM LZ_QA.' || "schema_name" || '.' || "name" || ' TO ROLE SYSADMIN_QA REVOKE CURRENT GRANTS;
         ' AS grant_statement
        ,'B.Streams.LZ_QA.' || "schema_name" || '.' || "name"  AS ORDERING
    FROM ADMIN.CONTROL.CURRENT_STREAMS
    WHERE "database_name" = 'LZ_PROD'
    AND "schema_name" NOT IN ('BAAN')
    AND "schema_name" NOT LIKE '%DEV%'
    AND "stale" = 'false'
 UNION ALL
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT OWNERSHIP ON STREAM ODS_QA.' || "schema_name" || '.' || "name" || ' TO ROLE SYSADMIN_QA REVOKE CURRENT GRANTS;
         ' AS grant_statement
        ,'B.Streams.ODS_QA.' || "schema_name" || '.' || "name"  AS ORDERING
    FROM ADMIN.CONTROL.CURRENT_STREAMS
    WHERE "database_name" = 'ODS'
    AND "schema_name" NOT IN ('COMMON')
    AND "schema_name" NOT LIKE '%DEV%'
    AND "stale" = 'false'
UNION ALL
    SELECT
         'USE ROLE SecurityAdmin;GRANT OWNERSHIP ON ALL FILE FORMATS IN SCHEMA LZ_QA.CONTROL TO ROLE SYSADMIN_QA REVOKE CURRENT GRANTS;'	AS grant_statement
        ,'C.FileFormats' as ORDERING
UNION ALL
	SELECT
    	 'USE ROLE SYSADMIN_QA;'||LISTAGG('CREATE STAGE LZ_QA.'|| Schema_Name || '.'|| Schema_Name || '_STG;') WITHIN GROUP (ORDER BY Schema_Name)	AS grant_statement
		,'I'  as ORDERING
	FROM LZ_QA.Information_Schema.Schemata
	WHERE Schema_Name NOT IN ('INFORMATION_SCHEMA','CONTROL','PUBLIC')
)
SELECT Grant_Statement
FROM UNIONALL
ORDER BY Ordering;