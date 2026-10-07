USE ROLE <<PLATFORM_TEAM>>;

create or replace table <<LZ>>.MONDAY.CUE_ORDER_TRACKING(
	_FILENAME VARCHAR(16777216),
	_FILEDATE TIMESTAMP_NTZ(9),
	_UPLOADDATE TIMESTAMP_NTZ(9),
	JSONFIELD VARIANT
);

INSERT INTO <<LZ>>.monday.controltable (
    TABLE_NAME,
    INCREMENTAL_START_VALUE,
    INCREMENTAL_END_VALUE,
    EXTRACTION_START_TIME,
    EXTRACTION_END_TIME,
    RUN_TIME,
    MAX_FILE_DATE,
    ROW_COUNT
)
VALUES (
    'CUE_ORDER_TRACKING',
    '1900-01-01T00:00:00Z',
    '1900-01-01T00:00:00Z',
    '1900-01-01 00:00:00',
    '1900-01-01 00:00:00',
    '1900-01-01 00:00:00',
    '1900-01-01T00:00:00Z',
    0
);

CREATE OR REPLACE TABLE <<BRONZE>>.TMEA_MANUFACTURING.MONDAY_CUE_ORDER_TRACKING (
    _FILEDATE                                                  TIMESTAMP_NTZ(9),
    _FILENAME                                                  VARCHAR,
    _AUDIT_LOG_ID                                              VARCHAR(128),
    _ROW_HASH                                                  VARCHAR(128),
    ITEM_ID                                                    VARCHAR,
    ITEM_NAME                                                  VARCHAR,
    CREATED_AT                                                 VARCHAR,
    UPDATED_AT                                                 VARCHAR,
    NAME                                                       VARCHAR,
    SUBITEMS                                                   VARCHAR,
    GOAL_TIMELINE_BEGINNING_FROM_RMA_RECEIPT_DATE              VARCHAR,
    STATUS                                                     VARCHAR,
    TMEA_SALES_ORDER_NUMBER                                    VARCHAR,
    TMEA_SERVICE_ORDER                                         VARCHAR,
    CUSTOMER                                                   VARCHAR,
    MATERIAL_PN                                                VARCHAR,
    SERIAL_NUMBER                                              VARCHAR,
    TOOL                                                       VARCHAR,
    PLATE_TYPE                                                 VARCHAR,
    SHORTAGE_PART_NUMBERS_QTY_AND_SHIP_DATE                    VARCHAR,
    RMA_REQUEST_DATE                                           VARCHAR,
    TIME_BETWEEN_RMA_REQUEST_AND_PART_ARRIVAL_AT_TMEA          VARCHAR,
    RMA_RECEIPT_DATE                                           VARCHAR,
    TIME_BETWEEN_PART_ARRIVAL_AND_QUOTE_ISSUANCE               VARCHAR,
    QUOTE_ISSUE_DATE                                           VARCHAR,
    TIME_BETWEEN_QUOTE_ISSUANCE_AND_PO_ISSUANCE                VARCHAR,
    PO_RECEIPT_DATE                                            VARCHAR,
    TIME_BETWEEN_PO_RECEIPT_AND_PARTS_AVAILABLE                VARCHAR,
    PARTS_AVAILABLE_DATE                                       VARCHAR,
    TIME_BETWEEN_PARTS_AVAILABLE_DATE_AND_REPAIR_START_DATE    VARCHAR,
    REPAIR_START_DATE                                          VARCHAR,
    BURN_IN_DATE                                               VARCHAR,
    TIME_TAKEN_TO_COMPLETE_REPAIR                              VARCHAR,
    PROCESS_OUT_DATE                                           VARCHAR,
    ACTUAL_COMPLETION_TIMELINE                                 VARCHAR,
    GOAL_COMPLETE_IN_NUMBER_OF_DAYS_OR_LESS                    VARCHAR,
    ACTUAL_DAYS_TAKEN_TO_COMPLETE                              VARCHAR,
    NON_STANDARD_REPAIR_REQUIRES_REQUOTE                       VARCHAR,
    TIMELINESS                                                 VARCHAR,
    INCLUDE_IN_THURSDAY_MEETING                                VARCHAR,
    CUSTOMER_PRICE                                             VARCHAR,
    TEL_COST                                                   VARCHAR,
    SUBITEM_ID                                                 VARCHAR,
    SUBITEM_NAME                                               VARCHAR,
    SUBITEM_CREATED_AT                                         VARCHAR,
    SUBITEM_UPDATED_AT                                         VARCHAR,
    SUBITEM_COLUMN_VALUES                                      VARIANT
);