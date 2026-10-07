USE ROLE <<SYSADMIN>>;

CREATE OR REPLACE TABLE <<LZ>>.GWS.BK_GWS_COST_FORMULA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[BK_gws_COST_FORMULA]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.BK_GWS_SITE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[BK_gws_site]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.BK_GWS_USER_UV (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[BK_gws_user_UV]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.BKR_GWS_ORDER_LOT_LINE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[BKR_gws_order_lot_line]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GEM_EMPLOYEE_GWS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gem_employee_gws]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_BUDGET (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_budget]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_COMPANY_ADDRESS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_company_address]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_CONFIDENCIAL_LEVEL (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_CONFIDENCIAL_LEVEL]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_FACTORY_BU_DEPARTMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_factory_bu_department]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_IMEC_DOCUMENT_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_IMEC_DOCUMENT_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_IMEC_STATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_IMEC_STATUS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_INTEGRATOR (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_integrator]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_LITHO_MASKSET (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_litho_maskset]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_NO_OF_WAFER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_no_of_wafer]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_ASSIGN_LOT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_assign_lot]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_ASSIGN_LOT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_assign_lot_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_DOCUMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_document]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_DOCUMENT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_document_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_FORMAT_ID_MANAGEMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_format_id_management]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_LOT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_lot]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_LOT_LINE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_lot_line]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_LOT_LINE_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_lot_line_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_LOT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_lot_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_NOTES (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_notes]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_NOTES_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_notes_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_SHIPPING_FEEDBACK (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_shipping_feedback]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_STAKEHOLDERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_stakeholders]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_STAKEHOLDERS_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_stakeholders_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_TAG (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_tag]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_TAG_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_tag_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_ORDER_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_order_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_PROJECT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_project]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_REPORT_DATA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_report_data]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_REQUEST_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_request_type]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_SHIPPER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_shipper]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.IMEC_WAFER_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[imec_wafer_type]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.OLD_USERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[OLD_Users]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.V_GEM_EMPLOYEE_GWS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[v_gem_employee_gws]';
