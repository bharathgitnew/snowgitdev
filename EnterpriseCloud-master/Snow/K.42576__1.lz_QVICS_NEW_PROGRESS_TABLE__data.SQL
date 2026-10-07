USE ROLE <<SYSADMIN>>;

CREATE OR REPLACE TABLE <<LZ>>.QVICS.V_PARMANENTMEASURE_PROGRESSES (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [QVICS_c].[dbo].[v_ParmanentMeasure_Progresses]';
