USE ROLE <<SYSADMIN>>;

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_DOCUMENTS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_documents]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ENTITY_DOCUMENTS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_AUDIT_ENTITY_DOCUMENTS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ENTITY_IMEC (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_AUDIT_ENTITY_IMEC]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ENTITY_ORDERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_AUDIT_ENTITY_ORDERS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ENTITY_REFERENCE_DATA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_AUDIT_ENTITY_REFERENCE_DATA]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ENTITY_REQUESTS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_AUDIT_ENTITY_REQUESTS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_IMEC (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_imec]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_MESSAGES (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_messages]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_ORDERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_orders]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_REFERENCE_DATA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_reference_data]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_AUDIT_REQUESTS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_audit_requests]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_BUSINESS_UNIT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_business_unit]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_CATEGORY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_category]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_CATEGORY_SITE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_category_site]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_CONFIDENCIAL_LEVEL (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_CONFIDENCIAL_LEVEL]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_COST_FORMULA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_COST_FORMULA]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_COUNTRIES (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_COUNTRIES]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_CURRENCY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_currency]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DEPARTMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_department]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DEPARTMENT_GEM_MAPPING (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_department_gem_mapping]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT_CATEGORY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document_category]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document_type]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT_TYPE_ORDER_STATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document_type_order_status]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT_TYPE_REQUEST_STATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document_type_request_status]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_DOCUMENT_TYPE_ROLE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_document_type_role]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_KPI (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_kpi]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_MESSAGE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_message]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_MESSAGE_CENTER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_message_center]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_MESSAGE_FUNCTIONALITY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_MESSAGE_FUNCTIONALITY]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_NEWS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_news]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_NEWS_LOG (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_news_log]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_ASSIGN_LOT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_assign_lot]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_ASSIGN_LOT_STATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_ORDER_ASSIGN_LOT_STATUS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_ASSIGN_LOT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_assign_lot_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_DOCUMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_document]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_DOCUMENT_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_ORDER_DOCUMENT_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_DOCUMENT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_document_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_FORMAT_ID_MANAGEMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_format_id_management]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE_CHECKBOX (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line_checkbox]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE_CHECKBOX_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line_checkbox_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE_WAFER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line_wafer]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_LINE_WAFER_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_line_wafer_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_LOT_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_lot_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_NOTES (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_notes]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_SHIPPING_FEEDBACK (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_shipping_feedback]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_STAKEHOLDERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_stakeholders]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_STAKEHOLDERS_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_stakeholders_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_STATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_ORDER_STATUS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_TAG (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_tag]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_TAG_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_tag_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_USING_BONDED_WAFER_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_ORDER_USING_BONDED_WAFER_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORDER_VERSIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_order_versions]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORGANIZATION (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_organization]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ORGANIZATION_GEM_MAPPING (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_organization_gem_mapping]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_PROCESS_AREAS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_process_areas]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_PROCESS_PARAMETER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_process_parameter]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_PROCESS_PARAMETER_VALUE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_process_parameter_value]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_PROJECT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_project]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_QUESTINIOR (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_questinior]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_RECIPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_recipe]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_RECIPE_NEEDED (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_recipe_needed]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_RECIPE_PARAMETER_VALUE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_recipe_parameter_value]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_RECIPE_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_RECIPE_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_DOCUMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_document]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_DOCUMENT_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_REQUEST_DOCUMENT_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_FORMAT_ID_MANAGEMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_format_id_management]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_PRIORITY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_REQUEST_PRIORITY]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_SHIPPING_WAFER_FEEDBACK (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_shipping_wafer_feedback]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_SHIPPING_WAFERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_shipping_wafers]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_STAKEHOLDERS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_stakeholders]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_UPDATE_LOG (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_update_log]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUEST_UPDATE_LOG_USER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_request_update_log_user]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_REQUESTSTATUS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_REQUESTSTATUS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ROLE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_role]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ROUTE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_route]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_ROUTE_DOCUMENT (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_route_document]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_SHIPPING_ADDRESS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_shipping_address]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_SITE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_site]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_SITE_COST (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_site_cost]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TAG (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tag]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tool]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL_AREA (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tool_area]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL_COST (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tool_cost]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL_PROCESS_AREAS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tool_process_areas]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL_TAGS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_tool_tags]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_TOOL_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_TOOL_TYPE]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_CONFIGURATION (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user_configuration]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_EMAIL (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user_email]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_EMAIL_NOTIFICATIONS (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_USER_EMAIL_NOTIFICATIONS]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_EMAIL_SITE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user_email_site]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_ROLE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user_role]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_USER_V3 (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_user_V3]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_WAFER_TYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_wafer_type]';

CREATE OR REPLACE TABLE <<LZ>>.GWS.GWS_WAFER_TYPE_COST (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[gws_wafer_type_cost]';
