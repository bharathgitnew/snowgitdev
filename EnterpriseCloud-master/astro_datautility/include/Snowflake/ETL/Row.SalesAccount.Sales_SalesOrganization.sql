USE ROLE <<SYSADMIN>>;
USE DATABASE <<Admin>>;
USE SCHEMA Entitlement;

MERGE INTO <<Admin>>.Entitlement.MaskingRowData AS TargetTable
USING (
       WITH
            SourceData AS
            (
                SELECT
                     UPPER(User_Email) AS EMail
                    ,TEL
                    ,TMEA
                FROM <<ODS>>.SALES_OPERATIONS.SALES_OPERATIONS_SECURITY
            )
            ,SourcePivot AS
            (
                SELECT EMail, ColumnName
                FROM SourceData
                UNPIVOT ( ValueColumn  -- UPPER CASE OF NAMES IS RESULTED
                    FOR ColumnName in (   TEL
                                           ,TMEA
                                       )
                        )
                WHERE IFNULL(ValueColumn,'No') = 'Yes'
            ),
            -- Set this table for the Table and Column information for this
           TargetTableInformation AS
          (
              SELECT
                 'SALES_OPERATIONS_SALES_CRM_SALES_ORGANIZATION' AS TableName
                ,'SALESORGANIZATION_ID' AS ColumnName
          )
          ,UndefinedUserPermissionList AS
          (
              SELECT
                 ValueTable.$1 AS VisibleValue
              FROM (VALUES
--                        ('AllValuesInTable')
--                         ('Yes'),('No')
                        ('NoAccessToCompanies')
                   ) ValueTable
              WHERE 1=2  --- Comment this out if Undefined Permissions is Used
          )
          ,Source0 AS     -- Granted Account Users
          (
              SELECT DISTINCT
                   UPPER(SourceRequests.EMail)                      AS UserId
                  ,SalesOrganization.SALES_ORGANIZATION_ID           AS VisibleValue
                FROM SourcePivot SourceRequests
                JOIN <<COMMON>>.DE_SALES_OPERATIONS.SALES_CRM_SALES_ORGANIZATION as SalesOrganization
                ON UPPER(SalesOrganization.SALES_ORGANIZATION) = UPPER(SourceRequests.ColumnName)
          )
            -- All Sources Of "AllValuesInTable" permission
          , AllValueSources AS
          (
              SELECT NULL UserId, NULL VisibleValue WHERE 1=2     -- THere are none of these
          )
            -- All Sources Of Specific Value permissions
          , SpecificSources AS
          (
              SELECT UserId, VisibleValue FROM Source0
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
            SELECT UserID FROM <<ADMIN>>.Security.Current_Snowflake_users
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
              SELECT MaskingRowData.UserId               AS UserId
                  ,MaskingRowData.VisibleValue           AS VisibleValue
              FROM <<Admin>>.Entitlement.MaskingRowData
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
                       MergeSource.UserId
                      ,TargetTableInformation.TableName
                      ,TargetTableInformation.ColumnName
                      ,MergeSource.VisibleValue
                      ,MergeSource.SourceAction
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
WHEN NOT MATCHED AND SourceTable.SourceAction = 'Insert' THEN INSERT
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