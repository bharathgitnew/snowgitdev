----------------------------------------------
-- Create Warehouses
----------------------------------------------
SELECT '--- Warehouses ---';
USE ROLE sysadmin;
CREATE OR REPLACE WAREHOUSE ProcessDev_WH WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Loading and Processing Development Data Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE ProcessQA_WH WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Loading and Processing QA Data Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE ProcessSIT_WH WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Loading and Processing SIT Data Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE ProcessProd_WH WITH
WAREHOUSE_SIZE = 'SMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 6
COMMENT = 'Loading and Processing Production Data Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE Deploy_WH WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Deployment Work Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE Developer_WH WITH
WAREHOUSE_SIZE = 'SMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 10
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 8
COMMENT = 'Developer Work Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE Consumer_wh WITH
WAREHOUSE_SIZE = 'SMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 10
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Consumer Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE Import_File_wh WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'File Uploader Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE HVR_wh WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 5
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'Warehouse used by HVR CDC loading processes';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE EXT_wh WITH
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 4
COMMENT = 'External Stage Warehouse';

USE WAREHOUSE SystemMaintenance_WH;

CREATE OR REPLACE WAREHOUSE ThoughtSpot_WH WITH
WAREHOUSE_SIZE = 'SMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
MIN_CLUSTER_COUNT = 1
MAX_CLUSTER_COUNT = 2
SCALING_POLICY = 'STANDARD'
INITIALLY_SUSPENDED = TRUE
MAX_CONCURRENCY_LEVEL = 6
COMMENT = 'ThoughtSpot Warehouse';

USE WAREHOUSE SystemMaintenance_WH;
----------------------------------------------
-- Grant Access to Warehouses
----------------------------------------------
SELECT '--- Warehouse To Role ---';
Use Role SecurityAdmin;
Grant all on warehouse SystemMaintenance_WH to role SysAdmin;

Grant all on warehouse Process_WH to role SysAdmin_Dev;
Grant all on warehouse Process_WH to role SysAdmin_QA;
Grant all on warehouse Process_WH to role SysAdmin_SIT;
Grant all on warehouse Process_WH to role SysAdmin_Prod;

Grant all on warehouse ProcessDEV_WH to role SysAdmin_Dev;
Grant all on warehouse ProcessQA_WH to role SysAdmin_QA;
Grant all on warehouse ProcessSIT_WH to role SysAdmin_SIT;
Grant all on warehouse ProcessProd_WH to role SysAdmin_Prod;

Grant usage, monitor on warehouse Process_WH to role ProcessAdmin_Dev;
Grant usage, monitor on warehouse Process_WH to role ProcessAdmin_QA;
Grant usage, monitor on warehouse Process_WH to role ProcessAdmin_SIT;
Grant usage, monitor on warehouse Process_WH to role ProcessAdmin_Prod;

Grant usage, monitor on warehouse ProcessDEV_WH to role ProcessAdmin_Dev;
Grant usage, monitor on warehouse ProcessQA_WH to role ProcessAdmin_QA;
Grant usage, monitor on warehouse ProcessSIT_WH to role ProcessAdmin_SIT;
Grant usage, monitor on warehouse ProcessPROD_WH to role ProcessAdmin_Prod;

Grant all on warehouse Developer_WH to role SysAdmin_Dev;
Grant all on warehouse Developer_WH to role SysAdmin_QA;
Grant all on warehouse Developer_WH to role SysAdmin_SIT;
Grant all on warehouse Developer_WH to role SysAdmin_Prod;
Grant all on warehouse Developer_WH to role SecurityOfficer_Entitlements;

Grant all on warehouse Deploy_WH to role SysAdmin_Dev;
Grant all on warehouse Deploy_WH to role SysAdmin_QA;
Grant all on warehouse Deploy_WH to role SysAdmin_SIT;
Grant all on warehouse Deploy_WH to role SysAdmin_Prod;

Grant all on warehouse Deploy_WH to role SecurityOfficer_Entitlements;
Grant all on warehouse ProcessProd_WH to role SecurityOfficer_Entitlements;

Grant all on warehouse Consumer_wh to role Consumer_Dev;
Grant all on warehouse Consumer_wh to role Consumer_QA;
Grant all on warehouse Consumer_wh to role Consumer_SIT;
Grant all on warehouse Consumer_wh to role Consumer;
Grant all on warehouse ThoughtSpot_wh to role Consumer;

Grant all on warehouse Import_File_WH to role ProcessAdmin_Dev;
Grant all on warehouse Import_File_WH to role ProcessAdmin_QA;
Grant all on warehouse Import_File_WH to role ProcessAdmin_SIT;
Grant all on warehouse Import_File_WH to role ProcessAdmin_Prod;

Grant all on warehouse HVR_WH to role Processing_HVR;
Grant all on warehouse EXT_WH to role Processing_EXT;


/*
Grant all on warehouse adhoc_wh to role SysAdmin_Prod;
Grant usage, monitor on warehouse adhoc_wh to role Consumer;
Grant usage, monitor on warehouse adhoc_wh to role ProcessAdmin_Prod;

Grant all on warehouse ui_staging_wh to role SysAdmin_Prod;
Grant all on warehouse ui_staging_wh to role ProcessAdmin_Prod;

Grant all on warehouse etl_staging_wh to role SysAdmin_QA;
Grant usage, monitor on warehouse etl_staging_wh to role Consumer_Q;
Grant usage, monitor on warehouse etl_staging_wh to role ProcessAdmin_QA;

Grant all on warehouse vendo_wh to role SysAdmin_Dev;
Grant usage, monitor on warehouse vendo_wh to role Consumer_D;
Grant usage, monitor on warehouse vendo_wh to role ProcessAdmin_QA;

Grant all on warehouse DATA_LOAD_PROD_WH to role SysAdmin_Prod;

Grant all on warehouse BI_WH to role SysAdmin_Prod;
Grant usage, monitor on warehouse BI_WH to role Consumer;
Grant usage, monitor on warehouse BI_WH to role Consumer_Q;
Grant usage, monitor on warehouse BI_WH to role Consumer_D;

Grant all on warehouse Load_wh to role SysAdmin_Prod;
Grant all on warehouse Load_wh to role SysAdmin_QA;
Grant all on warehouse Load_wh to role SysAdmin_Dev;

Grant usage, monitor on warehouse Load_wh to role public;
Revoke MODIFY, OPERATE on warehouse Load_wh from role public;
