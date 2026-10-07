# TO DEBUG SCRIPT, SET debug TO true
debug=True


import sys
import os
import errno
import argparse
from datetime import date, datetime
import time

import include.Python.utils.logging.logging as log
from include.Python.utils.file.file_utils import file_utils
from include.Python.utils.database.connections.snowflake.intricity_snowflake import Connection
from include.Python.utils.args.env_or_required_or_default import environ_or_required
from include.Python.utils.logging.types.kind import LogKind
from include.Python.utils.file.sf_buffered_writer import BufferedSnowflakeWriter

FILE = None
SNOWFLAKE_ACCOUNT = None
SNOWFLAKE_USERNAME = None
SNOWFLAKE_PASSWORD = None
SNOWFLAKE_WAREHOUSE_NAME = None
SNOWFLAKE_DATABASE_NAME = None
SNOWFLAKE_SCHEMA_NAME = None
SNOWFLAKE_ROLE_NAME = None
SNOWFLAKE_TABLE_NAME = None
SNOWFLAKE_FILE_FORMAT_NAME = None
SNOWFLAKE_STAGE_TYPE = None

# other constants
SNOWFLAKE_STAGE_NAME = None
ENCODING = None
DELIMITER = None
HEADER_ROWS = None
SNOWFLAKE_ON_ERROR = None
SNOWFLAKE_TRANSACTION_NAME = None
SNOWFLAKE_TRANSACTION = None
SNOWFLAKE_ERROR_TABLE = None
SPLIT_FILE_SIZE = None
SPLIT_FILE = None

def intricity_sfl_helper(FILE, SNOWFLAKE_ACCOUNT, SNOWFLAKE_USERNAME, SNOWFLAKE_PASSWORD, SNOWFLAKE_DATABASE_NAME,
                   SNOWFLAKE_SCHEMA_NAME, SNOWFLAKE_WAREHOUSE_NAME, SNOWFLAKE_ROLE_NAME, SNOWFLAKE_TABLE_NAME,
                   SNOWFLAKE_FILE_FORMAT_NAME, SNOWFLAKE_STAGE_TYPE, SNOWFLAKE_STAGE_NAME=None, ENCODING=None,
                   DELIMITER=None, HEADER_ROWS=0, SNOWFLAKE_ON_ERROR='CONTINUE',
                   SNOWFLAKE_TRANSACTION_NAME='FILE_UPLOAD',SNOWFLAKE_ERROR_TABLE='ERROR_TABLE', SPLIT_FILE_SIZE=100000000,
                   TRANSFORMATION_FILE=None, COPY_INTO=None, REMOVE_SPLIT_DIR=False, QUIET=False, LOG=False, PURGE=True,
                   ASYNCHRONOUS=True, SPLIT_FILE=False, ADDITIONAL_HEADERS=[], ADDITIONAL_CONTENT=[]):
    """
    Function that splits files into chunks of a set size (default 100mb), places them into a Snowflake stage,
    and loads the staged data into a table.
    Parameters
    ----------
    FILE: str, required. Path to file or directory containing files
    SNOWFLAKE_ACCOUNT: str, required. Snowflake account name
    SNOWFLAKE_USERNAME: str, required. Snowflake user name
    SNOWFLAKE_PASSWORD: str, required. Snowflake password
    SNOWFLAKE_DATABASE_NAME: str, required. Snowflake database
    SNOWFLAKE_SCHEMA_NAME: str, required. Snowflake schema
    SNOWFLAKE_WAREHOUSE_NAME: str, required. Snowflake warehouse
    SNOWFLAKE_ROLE_NAME: str, required. Snowflake role
    SNOWFLAKE_TABLE_NAME: str, required. Snowflake table to place file data in (ex: database.schema.tablename)
    SNOWFLAKE_FILE_FORMAT_NAME: str, required. File format of files to upload (ex: EXCEL.DEMO.DEMO)
    SNOWFLAKE_STAGE_TYPE: str, required. Stage type (ex. TABLE, NAMED, USER)
    SNOWFLAKE_STAGE_NAME: str, optional. Stage name if using a named or table stage
                                        (ex. database.schema.stagename) [default: None]"
    ENCODING: str, optional. Encoding for file to upload [default: None].
                             If not specified, read from Snowflake file format.
    DELIMITER: str, optional. Line delimiter of file to upload [default: None].
                              If not specified, read from Snowflake file format
    HEADER_ROWS: int, optional. Number of header rows to skip [default: 0]
    SNOWFLAKE_ON_ERROR: str, optional. Setting for 'Copy Into' command if an error is encountered. [default: CONTINUE]
    SNOWFLAKE_TRANSACTION_NAME: str, optional. Transaction name [default: FILE_UPLOAD]
    SNOWFLAKE_ERROR_TABLE: str, optional. Table to write errors to (e.g. database.schema.errortablename) [default: ERROR_TABLE]
    SPLIT_FILE_SIZE: int, optional. Size of split record files in bytes. [default: 100000000 (100 MB)]
    REMOVE_SPLIT_DIR: bool, optional. Removes split directory after load attempt [default: True]
    QUIET: bool, optional. Prevents output to console [default: False]
    LOG: bool, optional. Write output to log [default: False]
    PURGE: bool, optional. Purges files from stage if there is a successful load [default: True]
    ASYNCHRONOUS: bool, optional. Executes "COPY INTO" commands asynchronously [default: True]
    SPLIT_FILE: bool, optional. Enables splitting of source files [default: False]
    ADDITIONAL_HEADERS: str, optional. Adds additional content into COPY INTO statement using specified column name [default: None]
    ADDITIONAL_CONTENT: str, optional. Adds additional content into COPY INTO statement using specified column name [default: None]
    """
    sf_writer = None

    if QUIET:
        log_kind = LogKind.ERROR.value
    else:
        log_kind = LogKind.INFO.value

    # TO SET
    if debug:
        log_kind = LogKind.DEBUG.value

    # Sanity check beginning script to check if stage_name was not passed
    if (SNOWFLAKE_STAGE_TYPE.lower().strip() == 'named') and SNOWFLAKE_STAGE_NAME == None:
        log.Logging().log(LogKind.ERROR, 'snowflake_uploader', 'main',
                          'Selected "named" stage, but did not provide stage name. '
                          'Please provide an input for "--sf_stage_name"')
        #sys.exit(1)
        raise Exception('Selected "named" stage, but did not provide stage name. '
                          'Please provide an input for "--sf_stage_name"')

    try:
        """
        The block of code below does the following:
            1. Checks if passed --file argument is file or directory. If directory, places all file into list
            2. If neither file nor directory, passes error and exits
            3. Creates logger object
        """

        _file_utils = file_utils()

        if isinstance(FILE, list):
            FILES = FILE
            for f in FILES:
                FILE_NAME, FILE_EXT = os.path.splitext(_file_utils.basename(f)) #
                SPLIT_DIR_NAME = FILE_NAME + "_SPLIT"
                if LOG:
                    LOG_FILENAME = FILE_NAME + "_SF_UPLOAD_" + date.today().strftime("%m-%d-%Y") + ".log"
        elif _file_utils.isdir(FILE):
            FILES = [FILE + '\\' + f for f in os.listdir(FILE) if _file_utils.isfile(os.path.join(FILE, f))] # Gets list of all files in dir
            DIRNAME = _file_utils.basename(FILE) # Gets directory basename
            SPLIT_DIR_NAME = DIRNAME + "_SPLIT" # Uses directory basename to create split directory
            if LOG:
                LOG_FILENAME = DIRNAME + "_SF_UPLOAD_" + date.today().strftime("%m-%d-%Y") + ".log"
        elif _file_utils.isfile(FILE):
            FILES = [FILE] # Places file in list
            FILE_NAME, FILE_EXT = os.path.splitext(_file_utils.basename(FILE)) #
            SPLIT_DIR_NAME = FILE_NAME + "_SPLIT"
            if LOG:
                LOG_FILENAME = FILE_NAME + "_SF_UPLOAD_" + date.today().strftime("%m-%d-%Y") + ".log"
        else:
            raise FileNotFoundError(
                errno.ENOENT, os.strerror(errno.ENOENT), FILE)

        # Creating Logger, writing to log if --log parameter is passed

        if LOG:
            Logger = log.Logging(filename=LOG_FILENAME, minLevel=log_kind, debug=debug)
        else:
            Logger = log.Logging(minLevel=log_kind, debug=debug)

        # Checks if --transformations argument is passed.
        # If passed and exists, checks if data_map exists and sets variable
        if TRANSFORMATION_FILE != None:
            if os.path.exists(TRANSFORMATION_FILE)==False:
                raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), TRANSFORMATION_FILE)

            with open(TRANSFORMATION_FILE, "r") as f:
                transformations = json.load(f)

            if 'DATA_MAPPING' in transformations.keys():
                data_map = transformations['DATA_MAPPING']
            else:
                data_map = None
        else:
            transformations = None
            data_map = None

        # TODO: Change in future to take TXT rather than JSON–doesn't make much sense
        # Checks if --copy_into argument is passed
        # If passed and exists, extracts copy_into statement
        if COPY_INTO != None:
            if os.path.exists(COPY_INTO) == False:
                raise FileNotFoundError(
                    errno.ENOENT, os.strerror(errno.ENOENT), COPY_INTO)
            with open(COPY_INTO, "r") as f:
                copy_into_file = json.load(f)

            # Takes json values, converts to list, takes first value, then converts to str
            copy_into_statement = str(list(copy_into_file.values())[0])

            """
            if 'DATA_MAPPING' in transformations.keys():
                data_map = transformations['DATA_MAPPING']
            else:
                data_map = None
            """
        else:
            copy_into_file = None
            copy_into_statement = None

    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        log.Logging().log(LogKind.ERROR, 'snowflake_uploader', 'main', "Exception %s ::  %s" % (e, msg))
        #sys.exit(1)
        raise Exception(msg)

    try:
        """
        The block of code below does the following:
            1. Attempts to connect to SF Database
        """
        Logger.log(LogKind.INFO, 'snowflake_uploader', 'main', "Application started.")

        # CREATING CONNECTION
        Logger.log(LogKind.INFO, 'snowflake_uploader', 'main', "Connecting to Snowflake Database")
        connection = Connection(SNOWFLAKE_ACCOUNT, SNOWFLAKE_USERNAME, SNOWFLAKE_PASSWORD, SNOWFLAKE_DATABASE_NAME,
                            SNOWFLAKE_SCHEMA_NAME, SNOWFLAKE_WAREHOUSE_NAME, SNOWFLAKE_ROLE_NAME, logger=Logger)


    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        Logger.log(LogKind.ERROR, 'snowflake_uploader', 'main', "Exception %s ::  %s" % (e, msg))
        #sys.exit(1)
        raise Exception(msg)

    try:
        """
        The block of code below does the following:
            1. Resumes warehouse
            2. Starts transaction
        """
        # RESUMING WAREHOUSE
        Logger.log(LogKind.INFO, 'snowflake_uploader', 'main', "Resuming Warehouse {}".format(SNOWFLAKE_WAREHOUSE_NAME))
        connection.resume_warehouse()

        # STARTING TRANSACTION
        Logger.log(LogKind.INFO, 'snowflake_uploader', 'main', "Starting Transaction {}".format(SNOWFLAKE_TRANSACTION_NAME))
        connection.start_transaction(SNOWFLAKE_TRANSACTION_NAME)

    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        Logger.log(LogKind.ERROR, 'snowflake_uploader', 'main', "Exception %s ::  %s" % (e, msg))
        connection.close()
        #sys.exit(1)
        raise Exception(msg)


    try:

        """
        The block of code below does the following:
            1. Initializes sf_writer (BufferedSnowflakeWriter Class)
            2. Gets encoding and newline delimiter from SF_FILE_FORMAT description
            2. Uses sf_writer to split file(s) into smaller chunks of size SPLIT_FILE_SIZE
            3. Uploads split files into SF using 'upload' method in sf_writer
        """

        # Initializes sf_writer
        sf_writer = BufferedSnowflakeWriter(connection, SPLIT_DIR_NAME,
                                            salt=None, remove_split_dir=REMOVE_SPLIT_DIR, logger=Logger)

        # Gets encoding and delimiter from file format description on Snowflake
        file_format_info = sf_writer.get_file_format_info(SNOWFLAKE_FILE_FORMAT_NAME)

        # Done manually for security
        for key in file_format_info.keys():
            if file_format_info[key]=='NONE':
                file_format_info[key] = None
            if file_format_info[key]=='true':
                file_format_info[key] = True
            if file_format_info[key]=='false':
                file_format_info[key] = False

        # Checks if file is JSON
        if file_format_info['TYPE']=='JSON':
            FILE_IS_JSON = True
        else:
            FILE_IS_JSON = False
            if DELIMITER is not None:
                file_format_info['RECORD_DELIMITER'] = DELIMITER
            if ENCODING is not None:
                file_format_info['ENCODING'] = ENCODING

        if FILE_IS_JSON:

            # Copy into temp table for each json file
            for FILE in FILES:

                # Create temp table for copy into
                temp_table_name = SNOWFLAKE_TABLE_NAME + '_TEMP_' + str(int(time.time()))
                connection.execute_query("CREATE OR REPLACE TEMPORARY TABLE {temp_table} ( json_content variant )".format(temp_table=temp_table_name))

                # Insert Json conent into temp variant table
                sf_writer.upload_no_split(FILE, temp_table_name, SNOWFLAKE_STAGE_TYPE, SNOWFLAKE_STAGE_NAME, SNOWFLAKE_FILE_FORMAT_NAME,
                                    PURGE, SNOWFLAKE_ON_ERROR, data_mapping=data_map, copy_into_sql=copy_into_statement)
                sf_writer.create_error_table(table=temp_table_name, error_table=SNOWFLAKE_ERROR_TABLE)

                # Insert into final landing table from the temp table with additional content included
                LOCAL_FILE_DATE = time.localtime(os.path.getmtime(FILE))
                ADDITIONAL_CONTENT = ["'"+FILE+"'","'"+time.strftime('%m/%d/%Y %H:%M:%S', LOCAL_FILE_DATE)+"'","'"+datetime.now().strftime('%m/%d/%Y %H:%M:%S')+"'"]
                connection.execute_query("INSERT INTO {table} (SELECT {additional_content}json_content FROM {temp_table})".format(
                    table=SNOWFLAKE_TABLE_NAME,
                    additional_content=", ".join(ADDITIONAL_CONTENT) + ", ",
                    temp_table=temp_table_name
                ))
        elif not SPLIT_FILE:
            # Uploads file without splitting
            for FILE in FILES:
                LOCAL_FILE_DATE = time.localtime(os.path.getmtime(FILE))
                ADDITIONAL_CONTENT = ["METADATA$FILENAME","'"+time.strftime('%m/%d/%Y %H:%M:%S', LOCAL_FILE_DATE)+"'","'"+datetime.now().strftime('%m/%d/%Y %H:%M:%S')+"'"]
                sf_writer.upload_no_split(FILE, SNOWFLAKE_TABLE_NAME, SNOWFLAKE_STAGE_TYPE, SNOWFLAKE_STAGE_NAME,
                                    SNOWFLAKE_FILE_FORMAT_NAME, PURGE, SNOWFLAKE_ON_ERROR, data_mapping=data_map,
                                    copy_into_sql=copy_into_statement, additional_headers=ADDITIONAL_HEADERS,
                                    additional_content=ADDITIONAL_CONTENT, schema_name=SNOWFLAKE_SCHEMA_NAME)
                sf_writer.create_error_table(table=SNOWFLAKE_TABLE_NAME, error_table=SNOWFLAKE_ERROR_TABLE)
        else:
            # Splits each file in FILES list
            for FILE in FILES:
                LOCAL_FILE_DATE = time.localtime(os.path.getmtime(FILE))
                ADDITIONAL_CONTENT = ["METADATA$FILENAME","'"+time.strftime('%m/%d/%Y %H:%M:%S', LOCAL_FILE_DATE)+"'","'"+datetime.now().strftime('%m/%d/%Y %H:%M:%S')+"'"]
                Logger.log(LogKind.INFO, "snowflake-uploader", "main", "LOADING FILE {}".format(_file_utils.basename(FILE)))
                with _file_utils.open(FILE, 'r', newline=file_format_info['RECORD_DELIMITER'],
                                    encoding=file_format_info['ENCODING']) as f:

                    # Skipping line based on number of header rows
                    for row in range(HEADER_ROWS):
                        next(f)

                    sf_writer.write_file_data(f, newline=file_format_info['RECORD_DELIMITER'],
                                            encoding=file_format_info['ENCODING'], buffer_file_size=SPLIT_FILE_SIZE)


                # Uploads each of the split files to SF
                sf_writer.upload(SNOWFLAKE_TABLE_NAME, SNOWFLAKE_STAGE_TYPE, SNOWFLAKE_STAGE_NAME,
                                    SNOWFLAKE_FILE_FORMAT_NAME, PURGE, SNOWFLAKE_ON_ERROR, no_result=ASYNCHRONOUS, additional_headers=ADDITIONAL_HEADERS, additional_content=ADDITIONAL_CONTENT, schema_name=SNOWFLAKE_SCHEMA_NAME)
                sf_writer.create_error_table(table=SNOWFLAKE_TABLE_NAME, error_table=SNOWFLAKE_ERROR_TABLE)

        # Commits connection
        connection.commit()
        connection.close()

    except:
        e = sys.exc_info()[0]
        msg = sys.exc_info()[1]
        Logger.log(LogKind.ERROR, "snowflake-uploader", "main", "Exception %s ::  %s" % (e, msg))
        connection.rollback()
        connection.close()
        #sys.exit(1)
        raise Exception(msg)

    return sf_writer

def main():
    # define the command line arguments that are acceptable and environment variables that can be used in their place if set

    ### Required Arguments ###
    parser = argparse.ArgumentParser()

    parser.add_argument("--file", help="File(s) or Directory/Directories to Upload",
                        **environ_or_required('FILE'), type=str)
    parser.add_argument("--sf_account", help="Snowflake account name", **environ_or_required('SF_ACCOUNT'), type=str)
    parser.add_argument("--sf_username", help="Snowflake user name", **environ_or_required('SF_USERNAME'), type=str)
    parser.add_argument("--sf_password", help="Snowflake password (value provided should be KMS encrypted)",
                        **environ_or_required('SF_PASSWORD'), type=str)
    parser.add_argument("--sf_database", help="Snowflake database", **environ_or_required('SF_DATABASE'), type=str)
    parser.add_argument("--sf_warehouse", help="Snowflake warehouse", **environ_or_required('SF_WAREHOUSE'), type=str)
    parser.add_argument("--sf_role", help="Snowflake role", **environ_or_required('SF_ROLE'), type=str)
    parser.add_argument("--sf_schema", help="Snowflake schema", **environ_or_required('SF_SCHEMA'), type=str)
    parser.add_argument("--sf_table", help="Snowflake table to place file data in (ex: database.schema.tablename)",
                        **environ_or_required('SF_TABLE'), type=str)
    parser.add_argument("--sf_file_format", help="File format of files to upload (ex: EXCEL.DEMO.DEMO)",
                        **environ_or_required('SF_FILE_FORMAT'), type=str)
    parser.add_argument("--sf_stage_type", help="Stage type (e.g. TABLE, NAMED, USER)",
                        **environ_or_required('SF_STAGE_TYPE'), type=str)
    ### Optional Arguments ###
    parser.add_argument("--sf_stage_name", help="Stage name if using a named or table stage "
                                                "(ex. database.schema.stagename) [default: None]",
                        **environ_or_required('SF_STAGE_NAME', "None"), type=str)
    parser.add_argument("--encoding", help="Encoding for file to upload [default: None]. If not specified, "
                                           "read from Snowflake file format.",
                        **environ_or_required('ENCODING', "None"), type=str)
    parser.add_argument("--delimiter", help="Line delimiter of file to upload [default: None]. If not specified, "
                                           "read from Snowflake file format",
                        **environ_or_required('DELIMITER', "None"), type=str)
    parser.add_argument("--header_rows", help="Number of header rows to skip [default: 0]",
                        **environ_or_required('header_rows', "0"), type=int)
    parser.add_argument("--on_error", help=("Setting for 'Copy Into' command if an error is encountered. "
                                            "[default: CONTINUE]"), **environ_or_required('ON_ERROR', "CONTINUE"), type=str)
    parser.add_argument("--transaction_name", help=("Transaction name [default: FILE_UPLOAD]"),
                        **environ_or_required('TRANSACTION_NAME', "FILE_UPLOAD"), type=str)
    parser.add_argument("--error_table", help=("Table to write errors to (ex. database.schema.errortablename)"),
                        **environ_or_required('ERROR_TABLE', "ERROR_TABLE"), type=str)
    parser.add_argument("--no_purge", action="store_true",
                        help="Does not purge files from stage if there is a successful load")
    parser.add_argument("--remove_split_dir", action="store_true",
                        help="Removes split directory after load attempt")
    parser.add_argument("--log", action="store_true", help="Write output to log")
    parser.add_argument("--quiet", action="store_true", help="Prevents output to console")
    parser.add_argument("--synchronous", action="store_true", help="Prevents SQL statements from being executed "
                                                                   "asynchronously")
    parser.add_argument("--split_file_size",
                        help="Size of split record files in bytes. [default: 100000000 (100 MB)]",
                        **environ_or_required('SPLIT_FILE_SIZE', 100000000), type=int)
    parser.add_argument("--split_file", action="store_true", help="Enables splitting of source files")

    # get the values of the passed in arguments
    args = parser.parse_args()

    FILE = args.file
    SNOWFLAKE_ACCOUNT = args.sf_account
    SNOWFLAKE_USERNAME = args.sf_username
    SNOWFLAKE_PASSWORD = args.sf_password
    SNOWFLAKE_DATABASE_NAME = args.sf_database
    SNOWFLAKE_SCHEMA_NAME = args.sf_schema
    SNOWFLAKE_WAREHOUSE_NAME = args.sf_warehouse
    SNOWFLAKE_ROLE_NAME = args.sf_role
    SNOWFLAKE_TABLE_NAME = args.sf_table
    SNOWFLAKE_FILE_FORMAT_NAME = args.sf_file_format
    SNOWFLAKE_STAGE_TYPE = args.sf_stage_type.upper().strip()

    # Dealing with "None" string values
    if args.sf_stage_name == "None":
        SNOWFLAKE_STAGE_NAME = None
    else:
        SNOWFLAKE_STAGE_NAME = args.sf_stage_name

    if args.encoding == "None":
        ENCODING = None
    else:
        ENCODING = args.encoding

    if args.delimiter == "None":
        DELIMITER = None
    else:
        DELIMITER = args.delimiter

    HEADER_ROWS = args.header_rows
    SNOWFLAKE_ON_ERROR = args.on_error
    SNOWFLAKE_TRANSACTION_NAME = args.transaction_name
    SNOWFLAKE_ERROR_TABLE = args.error_table
    SPLIT_FILE_SIZE = args.split_file_size

    REMOVE_SPLIT_DIR = args.remove_split_dir
    QUIET = args.quiet
    LOG = args.log

    # Default is purge, so changing to False if --no_purge argument is passed
    if args.no_purge:
        PURGE = False
    else:
        PURGE = True

    if args.synchronous:
        ASYNCHRONOUS = False
    else:
        ASYNCHRONOUS= True

    if args.split_file:
        SPLIT_FILE = True
    else:
        SPLIT_FILE= False


    intricity_sfl_helper(FILE, SNOWFLAKE_ACCOUNT, SNOWFLAKE_USERNAME, SNOWFLAKE_PASSWORD, SNOWFLAKE_DATABASE_NAME,
                   SNOWFLAKE_SCHEMA_NAME, SNOWFLAKE_WAREHOUSE_NAME, SNOWFLAKE_ROLE_NAME, SNOWFLAKE_TABLE_NAME,
                   SNOWFLAKE_FILE_FORMAT_NAME, SNOWFLAKE_STAGE_TYPE, SNOWFLAKE_STAGE_NAME, ENCODING,
                   DELIMITER, HEADER_ROWS, SNOWFLAKE_ON_ERROR, SNOWFLAKE_TRANSACTION_NAME,
                   SNOWFLAKE_ERROR_TABLE, SPLIT_FILE_SIZE, REMOVE_SPLIT_DIR, QUIET, LOG, PURGE, ASYNCHRONOUS, SPLIT_FILE)


if __name__ == "__main__":
    main()
