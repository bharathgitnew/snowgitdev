USE ROLE SECURITYADMIN;
SHOW USERS;
INSERT OVERWRITE INTO Admin.Security.Current_Snowflake_Users (UserId)
SELECT "name" FROM TABLE(result_scan(last_query_id()))  WHERE "disabled" = false;
