-- RLS Company Security Based on CompanyName
USE ROLE SysAdmin;
USE DATABASE Admin;
USE SCHEMA AccessControl;

MERGE INTO Admin.AccessControl.LabParameter  TargetTable
USING (
        WITH ValidSourceRows AS
            (
                SELECT
                    Groups.GroupName
                    ,UserRequests.*
                FROM ODS.Sharepoint.UserRequests
                JOIN ODS.Sharepoint.Groups
                ON Groups.GroupId = UserRequests.GroupId
                WHERE 1=1
                AND (
                        (UserRequests.RequestStatus ilike 'Approved%')
                        OR
                        (UserRequests.RequestStatus ilike 'Admin Override')
                    )
                QUALIFY (ROW_NUMBER() OVER (Partition BY Groups.GroupId,UserRequests.EmployeeEMail ORDER BY IFNULL(UserRequests.CompletedDatetime,'1970-01-01') DESC)) = 1
            ),Inserts AS     -- Wizard Users
			(
				SELECT DISTINCT
					 LabDefinition.LabName 				AS LabName
					,UPPER(ValidSourceRows.EmployeeEmail) 	AS ParameterValue
				FROM ValidSourceRows
				JOIN Admin.AccessControl.LabDefinition
				 ON LabDefinition.LabName = REPLACE(ValidSourceRows.GroupName,'LAB_','')
				 AND LabDefinition.LabType = 'System'
				JOIN ODS.Common.Employee Employee
				 ON Employee.Security_UserId = UPPER(ValidSourceRows.EmployeeEmail)
				WHERE ValidSourceRows.RequestAction = 'Add'
				 AND ValidSourceRows.GroupName ilike 'LAB_%'
				 AND Employee.Security_UserId IS NOT NULL
            ), Deletes
            AS
            (
                    SELECT
                        DISTINCT
                         LabParameter.LabName 				AS LabName
                        ,LabParameter.ParameterValue     	AS ParameterValue
                    FROM Admin.AccessControl.LabParameter
                    JOIN Admin.AccessControl.LabDefinition
                    ON LabDefinition.LabName = LabParameter.LabName
                    AND LabDefinition.LabType = 'System'
                    WHERE LabParameter.ParameterName = 'User'
                    AND LabParameter.LabName <> 'AllLabs'
                    AND LabDefinition.LabName <> 'QAQC'
                EXCEPT
                    SELECT LabName,ParameterValue
                    FROM Inserts
            )
            SELECT
				 'Insert' 							AS SourceAction
				,'User' 							AS ParameterName
                ,*
            FROM Inserts
            UNION ALL
            SELECT
                 'Delete' 							AS SourceAction
                ,'User' 							AS ParameterName
                ,*
            FROM Deletes

) SourceTable
ON SourceTable.LabName = TargetTable.LabName
  AND SourceTable.ParameterName = TargetTable.ParameterName
  AND SourceTable.ParameterValue = TargetTable.ParameterValue
WHEN MATCHED AND SourceTable.SourceAction = 'Delete' THEN
    DELETE
WHEN NOT MATCHED THEN INSERT
    (
        LabName
        ,ParameterName
        ,ParameterValue
    )
VALUES
    (
         SourceTable.LabName
        ,SourceTable.ParameterName
        ,SourceTable.ParameterValue
    );