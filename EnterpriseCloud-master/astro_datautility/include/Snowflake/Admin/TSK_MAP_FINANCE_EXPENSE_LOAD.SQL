create or replace task ADMIN.ENTITLEMENT.MAP_FINANCE_EXPENSE_LOAD
	warehouse=SYSTEMMAINTENANCE_WH
	schedule='USING CRON 0 21 * * * America/Chicago'
	COMMENT='Finance_Expense Entitlement Security Load'
	as CALL ADMIN.Entitlement.Map_Finance_Expense();