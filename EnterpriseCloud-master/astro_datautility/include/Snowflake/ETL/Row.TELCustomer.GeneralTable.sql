
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
                 'TelCustomer' AS TableName
                ,'TableField' AS ColumnName
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
          ,Source0 AS
          (
              SELECT DISTINCT
                   UPPER(UserRequests.EmployeeEMail)              AS UserId
                  ,'AllValuesInTable'                AS VisibleValue
                FROM ODS.Sharepoint.UserRequests
                JOIN ODS.Sharepoint.Groups
                ON Groups.GroupID = UserRequests.GroupId
                WHERE Groups.GroupName IN ('TELCustomer')
                AND (
                        (UserRequests.RequestStatus ilike 'Approved%')
                        OR
                        (UserRequests.RequestStatus ilike 'Admin Override')
                    )
                QUALIFY (ROW_NUMBER() OVER (Partition BY UserRequests.EmployeeEMail ORDER BY IFNULL(UserRequests.CompletedDatetime,'1970-01-01') DESC)) = 1
          )
            -- All Sources Of "AllValuesInTable" permission
          , AllValueSources AS
          (
              SELECT UserId,VisibleValue FROM Source0      -- Sorcerer Service Accounts
          )
            -- All Sources Of Specific Value permissions
          , SpecificSources AS
          (
              SELECT UserId, VisibleValue FROM Source0 WHERE 1=2
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