USE ROLE SYSADMIN;

CREATE ROW ACCESS POLICY IF NOT EXISTS ADMIN.Policies.TelCustomerGeneralTable
AS (RowId VARCHAR(16777216))
RETURNS BOOLEAN ->
	CASE
		WHEN 1=1 THEN true
		ELSE false
	END
;

ALTER ROW ACCESS POLICY ADMIN.Policies.TelCustomerGeneralTable
SET BODY ->
    CASE
--	WHEN 1=1 then true
        -- Service Accounts / Roles
    WHEN CURRENT_USER() IN ('SVC_PREFECT')                                                  THEN true -- ETL and Data movement
    WHEN CURRENT_USER() IN ('SVC_THOUGHTSPOT')                                              THEN true -- Thoughtspot Metadata Robot
    WHEN CURRENT_USER() IN ('SVC_UIPATH')                                                   THEN true -- UIPath Metadata Robot
    WHEN CURRENT_ROLE() IN ('SECUREDATAADMIN')                                              THEN true -- Standard Security User
    WHEN CURRENT_ROLE() IN ('ARCHITECT')                                                   THEN true -- System Architects

        -- User Specific
    WHEN CURRENT_USER() IN (SELECT UserId FROM ADMIN.Entitlement.MaskingRowData WHERE TableName = 'TelCustomer' AND ColumnName =  'TableField' AND VisibleValue = 'AllValuesInTable' ) THEN true

	ELSE false
	END
;


-- Secure the TELCustomer.Action_Request_Form_History Table by its Existance
ALTER TABLE TELCustomer.Action_Request_Form_History     ADD ROW ACCESS POLICY ADMIN.Policies.TelCustomerGeneralTable ON (ACTION_REQUEST_REVISION_NUMBER);

-- Secure the TELCustomer.Purchase_Order_Change_Order Table by its Existance
ALTER TABLE TELCustomer.Purchase_Order_Change_Order ADD ROW ACCESS POLICY ADMIN.Policies.TelCustomerGeneralTable ON (Purchase_Order_Line_Id);

-- Secure the TELCustomer.Quote_Request_Form_History Table by its Existance
ALTER TABLE TELCustomer.Quote_Request_Form_History ADD ROW ACCESS POLICY ADMIN.Policies.TelCustomerGeneralTable ON (TEL_Quote_Id);
