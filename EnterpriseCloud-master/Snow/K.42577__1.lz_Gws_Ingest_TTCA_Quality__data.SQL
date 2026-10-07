USE ROLE <<SYSADMIN>>;

CREATE OR REPLACE TABLE <<LZ>>.GWS.BK_GWS_ORDER_LOT_LINE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [TEL_GWS].[dbo].[BK_gws_order_lot_line]';


CREATE OR REPLACE TABLE <<LZ>>.GWS.CONTROLTABLE (
	RUN_TIME                VARCHAR(16777216) COMMENT 'Identifier/timestamp of the extraction run; bronze models read MAX(RUN_TIME) to pick the latest load for a table',
	INCREMENTAL_START_VALUE VARCHAR(16777216) COMMENT 'Low watermark of the incremental window - the value extraction started from (exclusive prior high watermark)',
	INCREMENTAL_END_VALUE   VARCHAR(16777216) COMMENT 'High watermark of the incremental window - the latest value extracted in this run; becomes the next run''s start value',
	EXTRACTION_START_TIME   VARCHAR(16777216) COMMENT 'Wall-clock time the extraction for this table began',
	EXTRACTION_END_TIME     VARCHAR(16777216) COMMENT 'Wall-clock time the extraction for this table completed',
	TABLE_NAME              VARCHAR(16777216) COMMENT 'Source/target table this control row belongs to; bronze models filter on TABLE_NAME ILIKE %<table>%',
	MAX_FILE_DATE           VARCHAR(16777216) COMMENT 'Maximum _FILEDATE produced by this load; aligns with the _FILEDATE column on the landing tables',
	ROW_COUNT               VARCHAR(16777216) COMMENT 'Number of rows extracted/loaded for this table in this run'
)
COMMENT = 'Control/audit table tracking each incremental extraction run per source table (watermarks, timing, file date, and row counts) that drives incremental bronze loads';