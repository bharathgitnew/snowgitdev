USE ROLE <<PLATFORM_TEAM>>;

CREATE OR REPLACE TABLE <<LZ>>.TELQS.OSUSR_69G_ENGINEERONSITE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [outsystems].[dbo].[OSUSR_69G_ENGINEERONSITE]';

CREATE OR REPLACE TABLE <<LZ>>.TELQS.OSUSR_BN7_ADVANCEFILTERDATACONTRACTTYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [outsystems].[dbo].[OSUSR_BN7_ADVANCEFILTERDATACONTRACTTYPE]';

CREATE OR REPLACE TABLE <<LZ>>.TELQS.OSUSR_BN7_SQCPROCESSORDERPRICING (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [outsystems].[dbo].[OSUSR_BN7_SQCPROCESSORDERPRICING]';

CREATE OR REPLACE TABLE <<LZ>>.TELQS.OSUSR_BN7_VERSIONHISTORY (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [outsystems].[dbo].[OSUSR_BN7_VERSIONHISTORY]';

CREATE OR REPLACE TABLE <<LZ>>.TELQS.OSUSR_CZN_CONTRACTTYPE (
    _FILEDATE   TIMESTAMP_NTZ(9)     COMMENT 'File date without timezone',
    _FILENAME   VARCHAR(16777216)    COMMENT 'Name of the file',
    _UPLOADDATE VARCHAR(16777216)    COMMENT 'Date when the file was uploaded',
    JSONFIELD   VARIANT              COMMENT 'JSON payload from the source row'
)
COMMENT = 'Landing table for [outsystems].[dbo].[OSUSR_CZN_CONTRACTTYPE]';
