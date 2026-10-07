WITH
 Schema_List AS
(
            SELECT Catalog_Name, Schema_Name ,'LZ.'      || Catalog_Name ||'.' || Schema_Name AS Ordering FROM LZ_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'ODS.'     || Catalog_Name ||'.' || Schema_Name AS Ordering FROM ODS_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'COMMON.'  || Catalog_Name ||'.' || Schema_Name AS Ordering FROM COMMON_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'EDW.'     || Catalog_Name ||'.' || Schema_Name AS Ordering FROM EDW_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'PUB.'     || Catalog_Name ||'.' || Schema_Name AS Ordering FROM PUB_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
  UNION ALL SELECT Catalog_Name, Schema_Name ,'TESTING.' || Catalog_Name ||'.' || Schema_Name AS Ordering FROM TESTING_BUILD.Information_Schema.Schemata WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA', 'PUBLIC','META','DBT')
)
,SOURCE_DATA AS
(
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT  OWNERSHIP ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE SYSADMIN_SIT REVOKE CURRENT GRANTS;
            GRANT  OWNERSHIP ON ALL         VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE SYSADMIN_SIT REVOKE CURRENT GRANTS;
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
            GRANT  SELECT    ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_SIT;
            GRANT  SELECT    ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_SIT;
            GRANT  ALL       ON ALL        TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_SIT;
            GRANT  ALL       ON     FUTURE TABLES IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_SIT;
        ' AS grant_statement
        ,'A.B.TablesAndViews.'|| Ordering AS Ordering
    FROM Schema_List
    WHERE Catalog_Name IN ('LZ_BUILD','ODS_BUILD','COMMON_BUILD','EDW_BUILD','TESTING_BUILD')
), SOURCE_DATA_VIEWS AS
(
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT  SELECT    ON ALL        VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_SIT;
            GRANT  SELECT    ON     FUTURE VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE READ_ONLY_SIT;
            GRANT  ALL       ON ALL        VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_SIT;
            GRANT  ALL       ON     FUTURE VIEWS IN SCHEMA ' || Catalog_Name ||'.' || Schema_Name || ' TO   ROLE PROCESSADMIN_SIT;
        ' AS grant_statement
        ,'A.C.TablesAndViews.'|| Ordering AS Ordering
    FROM Schema_List
    WHERE Catalog_Name IN ('PUB_BUILD','TESTING_BUILD')
), UNIONALL as 
(
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA
UNION ALL
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA_Tables
UNION ALL
    SELECT Grant_Statement, Ordering FROM SOURCE_DATA_Views

UNION ALL
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT OWNERSHIP ON STREAM LZ_BUILD.' || "schema_name" || '.' || "name" || ' TO ROLE SYSADMIN_SIT REVOKE CURRENT GRANTS;
         ' AS grant_statement
        ,'B.Streams.LZ_BUILD.' || "schema_name" || '.' || "name"  AS ORDERING
    FROM ADMIN.CONTROL.CURRENT_STREAMS
    WHERE "database_name" = 'LZ_PROD'
    AND "schema_name" NOT IN ('BAAN')
    AND "schema_name" NOT LIKE '%DEV%'
    AND "stale" = 'false'
 UNION ALL
    SELECT
        'USE ROLE SecurityAdmin;
            GRANT OWNERSHIP ON STREAM ODS_BUILD.' || "schema_name" || '.' || "name" || ' TO ROLE SYSADMIN_SIT REVOKE CURRENT GRANTS;
         ' AS grant_statement
        ,'B.Streams.ODS_BUILD.' || "schema_name" || '.' || "name"  AS ORDERING
    FROM ADMIN.CONTROL.CURRENT_STREAMS
    WHERE "database_name" = 'ODS'
    AND "schema_name" NOT IN ('COMMON')
    AND "schema_name" NOT LIKE '%DEV%'
    AND "stale" = 'false'
UNION ALL
    SELECT
         'USE ROLE SecurityAdmin;GRANT OWNERSHIP ON ALL FILE FORMATS IN SCHEMA LZ_BUILD.CONTROL TO ROLE SYSADMIN_SIT REVOKE CURRENT GRANTS;'	AS grant_statement
        ,'C.FileFormats' as ORDERING
UNION ALL
	SELECT
    	 'USE ROLE SYSADMIN_SIT;'||LISTAGG('CREATE STAGE LZ_BUILD.'|| Schema_Name || '.'|| Schema_Name || '_STG;') WITHIN GROUP (ORDER BY Schema_Name)	AS grant_statement
		,'I'  as ORDERING
	FROM LZ_BUILD.Information_Schema.Schemata
	WHERE Schema_Name NOT IN ('INFORMATION_SCHEMA','CONTROL','PUBLIC')
)
SELECT Grant_Statement
FROM UNIONALL
ORDER BY Ordering;