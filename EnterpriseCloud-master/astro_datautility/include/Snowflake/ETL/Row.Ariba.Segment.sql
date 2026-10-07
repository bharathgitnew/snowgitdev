-- RLS Company Security Based on CompanyName
USE ROLE SecurityOfficer_Entitlements;
USE DATABASE Admin;
USE SCHEMA Entitlement;

MERGE INTO Admin.Entitlement.MaskingRowData AS TargetTable
USING (
       WITH
            -- Set this table for the Table and Column information for this
           TargetTableInformation AS
          (
              SELECT
                 'Ariba' AS TableName
                ,'Segment' AS ColumnName
          )
          ,UndefinedUserPermissionList AS
          (
              SELECT
                 ValueTable.$1 AS VisibleValue
              FROM (VALUES
                        ('AllValuesInTable')
--                         ('Yes'),('No')
                   ) ValueTable
              WHERE 1=2  --- Comment this out if Undefined Permissions is Used
          )
          ,Source0 AS     -- Sorcerer Service Accounts
          (
              SELECT
                   ValueTable.$1                AS UserId
                  ,'AllValuesInTable'           AS VisibleValue
              FROM (VALUES
                         ('SVC_THOUGHTSPOT')  -- Thought Spot
                   ) ValueTable
          )
          ,Source1 AS     -- Wizard Users
          (
              SELECT
                   Employee.Security_UserId          AS UserId
                  ,'AllValuesInTable'                AS VisibleValue
              FROM ODS.Common.Employee Employee
              JOIN (VALUES
                         ('151306')  -- Richard Turner
                        ,('007200')  -- Lawrence Smith
                        ,('950037')  -- Max Takahasi
                   ) ValueTable
              ON ValueTable.$1 = Employee.EmployeeId
              WHERE Employee.Security_UserId IS NOT NULL
          )
          , Source2 AS     -- Granted Wizard Users
          (
              SELECT DISTINCT
                   Employee.Security_UserId          AS UserId
                  ,DefinedUsers.Segment_Code               AS VisibleValue
              FROM ODS.Common.Employee Employee
              JOIN ODS.MDM.AribaSecurity DefinedUsers
               ON DefinedUsers.Employee_Id_Code = Employee.EmployeeId
              WHERE Employee.Security_UserId IS NOT NULL
          )
          ,Source3 AS     -- Architect Users
          (
              SELECT
                   Employee.UserId                  AS UserId
                  ,'AllValuesInTable'               AS VisibleValue
              FROM Admin.Security.System_Architects Employee
              WHERE CURRENT_DATE BETWEEN Employee.EffectiveDate AND Employee.ExpirationDate
          )

            -- All Sources Of "AllValuesInTable" permission
          , AllValueSources AS
          (
              SELECT UserId,VisibleValue FROM Source0      -- Sorcerer Service Accounts
              UNION
              SELECT UserId,VisibleValue FROM Source1      -- Wizard Users
              UNION
              SELECT UserId,VisibleValue FROM Source3      -- Architect Users
          )
            -- All Sources Of Specific Value permissions
          , SpecificSources AS
          (
              SELECT UserId,VisibleValue FROM Source2
          )

          ----------------------------------------------------------
          -----           Do Not Modify Below this line       ------
          ----------------------------------------------------------

            -- All Sources Of permissions (If All is given, Specifics are dropped)
          , DefinedSourceData AS
          (
              SELECT UserId,VisibleValue FROM AllValueSources    -- All Rows of AllValuesInTable
              UNION
              SELECT SpecificSources.UserId,SpecificSources.VisibleValue FROM SpecificSources     -- Rows for Users not in AllValuesInTable
                                                                        LEFT OUTER JOIN AllValueSources
                                                                        ON AllValueSources.UserId = SpecificSources.UserId
                                                                        WHERE AllValueSources.USerId IS NULL
          )
            -- All users in snowflake with out defined Permissions
          , UndefinedUserList AS
          (
            SELECT UserID FROM ADMIN.Security.Current_Snowflake_users
            MINUS
            SELECT UserId FROM DefinedSourceData
          )
          , UndefinedSourceData AS
          (
            SELECT UserID,VisibleValue
            FROM UndefinedUserList
            CROSS JOIN UndefinedUserPermissionList
          )
            -- Create Permission List  (adding Defined and Undefined Lists)
          , SourceMaskingData AS
          (
              SELECT UserId,VisibleValue FROM DefinedSourceData
              UNION
              SELECT UserId,VisibleValue FROM UndefinedSourceData
          )
          , CurrentMaskingData AS
          (
              SELECT UserId               AS UserId
                  ,VisibleValue           AS VisibleValue
              FROM Admin.Entitlement.MaskingRowData
              JOIN TargetTableInformation
              ON TargetTableInformation.TableName = MaskingRowData.TableName
              AND TargetTableInformation.ColumnName = MaskingRowData.ColumnName
          ), TargetsToDelete AS
          (
              SELECT UserId,VisibleValue FROM CurrentMaskingData
              MINUS
              SELECT UserId,VisibleValue FROM SourceMaskingData
          ), MergeSource AS
          (
              SELECT
                   UserId
                  ,VisibleValue
                  ,'Insert' AS SourceAction
              FROM SourceMaskingData
              UNION
              SELECT
                   UserId
                  ,VisibleValue
                  ,'Delete' AS SourceAction
              FROM TargetsToDelete
          )
          SELECT DISTINCT
                       UserId
                      ,TargetTableInformation.TableName
                      ,TargetTableInformation.ColumnName
                      ,VisibleValue
                      ,SourceAction
                  FROM MergeSource
                  CROSS JOIN TargetTableInformation
                  ORDER BY VisibleValue,UserId
) SourceTable
ON SourceTable.UserId = TargetTable.UserId
  AND SourceTable.TableName = TargetTable.TableName
  AND SourceTable.ColumnName = TargetTable.ColumnName
  AND SourceTable.VisibleValue = TargetTable.VisibleValue
WHEN MATCHED AND SourceTable.SourceAction = 'Delete' THEN
    DELETE
WHEN NOT MATCHED THEN INSERT
    (
        UserId
        ,TableName
        ,ColumnName
        ,VisibleValue
    )
VALUES
    (
        SourceTable.UserId
        ,SourceTable.TableName
        ,SourceTable.ColumnName
        ,SourceTable.VisibleValue
    );