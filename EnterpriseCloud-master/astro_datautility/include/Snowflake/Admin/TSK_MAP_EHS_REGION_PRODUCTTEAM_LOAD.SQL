create or replace task ADMIN.ENTITLEMENT.MAP_EHS_REGION_PRODUCTTEAM_LOAD
	warehouse=SYSTEMMAINTENANCE_WH
	schedule='USING CRON 0 21 * * * America/Chicago'
	COMMENT='Environment Health and Safety Entitlement Security Load'
	as CALL ADMIN.Entitlement.Map_EHS_Region_ProductTeam();