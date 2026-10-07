import os
import re
import csv
import sys
from include.Python.utils.file.file_utils import file_utils
from include.Python.utils.logging.logging import LogKind
import include.Python.utils.logging.logging as logging
from time import sleep

class BufferedSnowflakeWriter:
    def __init__(self, connection, dirpath, salt=None, remove_split_dir=False, logger=logging.Logging()):
        try:
            self.connection = connection
            self.dirpath = dirpath
            self.buffers = []
            self.buffer_file = None
            self.buffer_writer = None
            self.current_file_index = 0
            self.is_full = False
            self.remove_split_dir = remove_split_dir
            self._logger = logger

            if salt:
                self.file_utils = file_utils(salt=salt)
            else:
                self.file_utils = file_utils()

            #########################
            #  commented out this code to prevent empty folders from being created
            #  original code did not expect a file timestamp, a folder is being created for every execution (10s of thousands)
            #  this would need to be refactored if fileuploader was ever configured to use the SPLIT feature
            #  recommend moving to pythong version of teltools (teltools.py) and using the direct write capability
            
            # if not self.file_utils.isdir(dirpath):
            #     os.mkdir(dirpath)

            # for f in os.listdir(dirpath):  # Remove any potential previous buffer files left from a failed write
            #     if re.search(dirpath + "*", f):
            #         self.file_utils.remove(os.path.join(dirpath, f))

            #############################
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "sf_buffered_writer", "init", "Exception %s ::  %s" % (e, msg))
            #sys.exit(1)
            raise Exception(msg)

    def get_file_format_info(self, file_format):
        """
        Gets file format from SnowFlake, and returns results as a dictionary. Fields could include:
            RECORD_DELIMITER
            FIELD_DELIMITER
            ENCODING
            SKIP_HEADER
            ESCAPE_UNENCLOSED_FIELD

        Parameters
        ----------
        file_format: str, required. Name of SF file format.

        Returns
        -------
        file_format_dict: Dictionary containing file format info.
        """

        file_format_data = self.connection.execute_query(
            "DESCRIBE FILE FORMAT {file_format}".format(file_format=file_format)).fetchall()
        file_format_dict = {}
        for t in file_format_data:
            file_format_dict[t[0]] = t[2].encode().decode('unicode_escape')

        return file_format_dict
        """
        return {'newline_delimiter': str(file_format_dict['RECORD_DELIMITER']),
                'field_delimiter': str(file_format_dict['FIELD_DELIMITER']),
                'encoding': str(file_format_dict['ENCODING']),
                'skip_header': str(file_format_dict['SKIP_HEADER']),
                'escape_char': str(file_format_dict['ESCAPE_UNENCLOSED_FIELD'])}
        """

    def write_file_data(self, data, newline, encoding,
                        buffer_file_size=100000000):
        """
        THIS IS TO BE USED AS THE DEFAULT FOR THE SNOWFLAKE-UPLOADER
        Writes data from a simple iterable object or generator into multiple files of a specified size

            Parameters
            ----------
             data : object, required
               Iterable object or generator with data
                :param data: object, required. Iterable object or generator with data
                :param newline: str, required. Delimiter for new line.
                :param encoding: str, required. File encoding.
                :param buffer_file_size: int, optional. Size of "buffer files" in bytes. Default: 100000000 (100mb)
            """

        try:
            for row in data:  # data can be a simple iterable object or a generator
                if self.buffer_file is None:  # If there is not an open buffer file
                    filename = "{dirpath}/{dirpath}_FILE_{file_index}.csv".format(dirpath=self.dirpath,
                                                                                  file_index=self.current_file_index)
                    self.buffers.append(filename)  # Add new buffer to list of buffers
                    self.buffer_file = self.file_utils.open(filename, 'a+',
                                                            newline=newline, encoding=encoding, exists=False)

                self.buffer_file.write(row)  # Write current row of data

                if os.fstat(self.buffer_file.fileno()).st_size >= buffer_file_size:
                    self.buffer_file.close()
                    self.current_file_index += 1
                    self.buffer_file = None
                    self.buffer_writer = None

            self.buffer_file.close()

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "sf_buffered_writer", "write_data", "Exception %s ::  %s" % (e, msg))
            #sys.exit(1)
            raise Exception(msg)

    def write_csv_data(self, data, encoding,
                       buffer_file_size=100000000,
                       field_delimiter=',',
                       doublequote=True,
                       escapechar=None,
                       lineterminator='\r\n',
                       quotechar='"',
                       quoting=csv.QUOTE_MINIMAL,
                       skipinitialspace=False,
                       strict=False
                       ):
        """
        THIS IS TO BE USED ONLY WHEN DEALING WITH EASILY DELIMITED FILES - NEEDS TESTING.
        Writes data from a simple iterable object or generator into multiple csv files of a specified size

            Parameters
            ----------
                :param data: object, required. Iterable object or generator with data
                :param encoding: str, required. File encoding.
                :param buffer_file_size: int, optional. Size of "buffer files" in bytes. Default: 100000000 (100mb)

            Parameters For csv.writer() object.
            See https://docs.python.org/3/library/csv.html#csv-fmt-params for Additional Descriptions.
            ------------------------------------------------------------------------------------------
                :param field_delimiter: str, optional. A one-character string used to separate fields.
                :param doublequote: bool, optional. Controls how instances of quotechar appearing inside a
                                    field should themselves be quoted.
                :param escapechar: str, optional. A one-character string used by the writer to escape the delimiter if
                                   quoting is set to QUOTE_NONE and the quotechar if doublequote is False.
                :param lineterminator: str, optional. The string used to terminate lines produced by the writer.
                :param quotechar: str, optional. A one-character string used to quote fields containing special
                                  characters, such as the delimiter or quotechar, or which contain new-line characters.
                :param quoting: obj, optional. Controls when quotes should be generated by the writer
                                and recognised by the reader.
                :param skipinitialspace: bool, optional. When True, whitespace immediately following the
                                        delimiter is ignored.
                :param strict: bool, optional. When True, raise exception Error on bad CSV input.

            """
        try:
            for row in data:  # data can be a simple iterable object or a generator
                if self.buffer_file is None:  # If there is not an open buffer file
                    filename = "{dirpath}/{dirpath}_FILE_{file_index}.csv".format(dirpath=self.dirpath,
                                                                                  file_index=self.current_file_index)
                    self.buffers.append(filename)  # Add new buffer to list of buffers
                    self.buffer_file = self.file_utils.open(filename, 'a+',
                                                            newline=lineterminator, encoding=encoding, exists=False)
                    self.buffer_writer = csv.writer(self.buffer_file,
                                                    delimiter=field_delimiter,
                                                    doublequote=doublequote,
                                                    escapechar=escapechar,
                                                    lineterminator=lineterminator,
                                                    quotechar=quotechar,
                                                    quoting=quoting,
                                                    skipinitialspace=skipinitialspace,
                                                    strict=strict
                                                    )

                self.buffer_writer.writerow(row.split(field_delimiter))  # Write current row of data

                if os.fstat(self.buffer_file.fileno()).st_size >= buffer_file_size:
                    self.buffer_file.close()
                    self.current_file_index += 1
                    self.buffer_file = None
                    self.buffer_writer = None

            self.buffer_file.close()

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "sf_buffered_writer", "write_csv_data", "Exception %s ::  %s" % (e, msg))
            #sys.exit(1)
            raise Exception(msg)

    def upload(self, table_name, stage_type, stage_name, file_format, purge_bool, on_error, data_mapping=None,
               copy_into_sql=None, no_result=True, filename_header=None):
        """
        Takes files in file buffer, and executes "Put" and "Copy-Into" statements to load the files into SnowFlake.
        Puts are typically standardized, while "Copy-Into" statements can be include data mappings, or could be
        replaced by custom "copy into" statements.

        Parameters
        ----------
        :param table_name: str, required. Name of table where the data should be copied to.
        :param stage_type: str, required. Type of stage where data should be put.
        :param stage_name: str, required. If named or table stage, stage name. Otherwise, pass None.
            See Also: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage.html
        :param file_format: str, required. Name of file format to be used for bulk loading.
            See Also: https://docs.snowflake.com/en/sql-reference/sql/create-file-format.html
        :param purge_bool: bool, required. Boolean that specifies whether to remove the data files from the stage
                          automatically after the data is loaded successfully.
        :param on_error: str, required. What should be done if an error is encountered.
            Permitted Values:
                CONTINUE
                SKIP_FILE
                SKIP_FILE_<num> (e.g. SKIP_FILE_10)
                SKIP_FILE_<num%> (e.g. SKIP_FILE_10%)
                ABORT_STATEMENT
        :param data_mapping: str, optional. Includes data mapping as part of copy-into if passed. Default None.
        :param copy_into_sql str, optional. Replaces automatically generated copy into sql if passed. Default none.
        :param no_result bool, optional. If true, allows for asynchronous execution of sql queries (supposedly faster).
        :param filename_header str, optional. If included, adds the filename in the COPY INTO statement using this as the column name. Default None.
        """

        try:
            if self.buffer_file is not None:  # Close the final buffer file if necessary
                self.buffer_file.close()
                self.buffer_file = None
                self.buffer_writer = None

            if stage_type == 'NAMED':
                staged_file_path = '@' + stage_name + "/" + table_name
            elif stage_type == 'TABLE':
                staged_file_path = '@%' + stage_name
            elif stage_type == 'USER':
                staged_file_path = '@~/'
            elif stage_type == 'DEFINED':
                staged_file_path = '@' + stage_name + "/"

            put_statements = []
            copy_into_statements = []

            for filename in self.buffers:
                # Creating put SQL, and adding to "put_statements"

                if stage_type == 'DEFINED':
                    split_name = filename.split('\\')
                    destination_directory = '\\'.join(split_name[4,-1])
                    put_sql = (
                    "PUT 'file://{file}' {staged_file_path}{path_name}".format(file=filename.replace('\\','/'), staged_file_path=staged_file_path, path_name=destination_directory)
                    )
                else:
                    destination_directory = ''
                    put_sql = (
                        "PUT 'file://{file}' {staged_file_path}".format(file=filename.replace('\\','/'), staged_file_path=staged_file_path)
                    )

                put_statements.append(put_sql)

                # Creating Copy-Into Statements – Appends to copy_into_statements at end of for loop
                if copy_into_sql is None:  # If no argument for copy_into_sql was passed, create copy into statement
                    if data_mapping is not None:  # Add data mappings if passed
                        columns = ", \n".join(list(data_mapping.keys()))
                        maps = ", \n".join(list(data_mapping.values()))
                        copy_into_statement = (
                            """
                            COPY INTO {table}
                                (
                                {columns}
                                )
                            FROM
                                (
                                SELECT {maps}
                                )
                            FROM '{staged_file_path}{path_name}'
                            FILE_FORMAT = '{file_format}'
                            ON_ERROR = {on_error}
                            PURGE = {purge_bool}
                            RETURN_FAILED_ONLY = TRUE
                            """
                        ).format(table=table_name,
                                 columns=columns,
                                 maps=maps,
                                 staged_file_path=staged_file_path+"/"+self.file_utils.basename(filename),
                                 path_name=destination_directory,
                                 file_format=file_format,
                                 purge_bool=purge_bool,
                                 on_error=on_error
                                 )
                    else:
                        # If no data mappings are not passed but filename_header is passed, add FILENAME into COPY INTO statement
                        if filename_header:
                            columns_query = (
                                "SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name='{table}' AND table_schema='{schema}' AND column_name not in ('{additional_headers}') ORDER BY ORDINAL_POSITION"
                            ).format(table=table_name.upper(), schema=schema_name.upper(), additional_headers="', '".join(additional_headers))
                            columns_result = self.connection.execute_query(columns_query)
                            
                            columns = ''
                            column_values  = ''
                            column_index = 1
                            for col in columns_result:
                                if columns != '':
                                    columns += ', '
                                    column_values += ', '
                                columns += col.get('column_name')
                                column_values += 't.$' + str(column_index)
                            
                            copy_into_statement = (
                                """
                                COPY INTO {table} 
                                    (
                                    {additional_headers}, {columns}
                                    )
                                FROM 
                                    (
                                    SELECT {additional_content}, {column_values} from '{staged_file_path}{path_name}'
                                    )
                                FILE_FORMAT = '{file_format}'
                                ON_ERROR = {on_error}
                                PURGE = {purge_bool}
                                RETURN_FAILED_ONLY = TRUE
                                """
                            ).format(table=table_name,
                                    additional_headers=', '.join(additional_headers),
                                    columns=columns,
                                    additional_content=', '.join(additional_content),
                                    column_values=column_values,
                                    staged_file_path=staged_file_path+"/"+self.file_utils.basename(filename),
                                    path_name=destination_directory,
                                    file_format=file_format,
                                    purge_bool=purge_bool,
                                    on_error=on_error
                                    )
                        else:
                            # If no data mappings are not passed, generate standard copy into statement.
                            copy_into_statement = (
                                """
                                COPY INTO {table}
                                FROM '{staged_file_path}{path_name}'
                                FILE_FORMAT = '{file_format}'
                                ON_ERROR = {on_error}
                                PURGE = {purge_bool}
                                RETURN_FAILED_ONLY = TRUE
                                """
                            ).format(table=table_name,
                                    staged_file_path=staged_file_path+"/"+self.file_utils.basename(filename),
                                    path_name=destination_directory,
                                    file_format=file_format,
                                    purge_bool=purge_bool,
                                    on_error=on_error
                                    )
                else:
                    # If copy into statement was passed, just adds it to copy_into_statements
                    copy_into_statement = copy_into_sql.format(
                        staged_file_path=staged_file_path+"/"+self.file_utils.basename(filename)
                    )

                copy_into_statements.append(copy_into_statement)

            # Executes puts
            for put in put_statements:
                put_result = self.connection.execute_query(put)
                self._logger.sf_output("PUT OUTPUT", put_result)

            # Executes copy intos.
            self.job_id_list = []
            self.job_result_list = []
            for copy_into in copy_into_statements:
                copy_into_result = self.connection.execute_query(copy_into, asynchronous=no_result)
                if no_result:
                    self.job_id_list.append(copy_into_result.get('queryId'))
                else:
                    self.job_id_list.append(copy_into_result.sfqid)
                    self._logger.sf_output("COPY_INTO OUTPUT", copy_into_result)
                self.job_result_list.append(copy_into_result)

            if no_result:
                copy_into_status = ['RUNNING']
                while 'RUNNING' in copy_into_status or 'QUEUED' in copy_into_status:
                    copy_into_status = [result[0] for result in self.connection.execute_query(
                    """
                    select EXECUTION_STATUS
                    from table(information_schema.query_history_by_session())
                    WHERE QUERY_ID in ({query_id_list});
                    """.format(query_id_list=(', '.join("'" + item + "'" for item in self.job_id_list)))
                    ).fetchall()]

                if 'FAILED_WITH_ERROR' in copy_into_status or 'FAILED_WITH_INCIDENT' in copy_into_status:
                    raise ValueError("There was a problem with one or more of the Copy-Into statements.")

            if self.remove_split_dir:
                try:
                    self.file_utils.remove(filename)
                    self.file_utils.remove(self.dirpath)
                except PermissionError:
                    self._logger.log(LogKind.ERROR, "sf_buffered_writer", "upload",
                                     "Exception PermissionError ::  Insufficient permissions to delete directory and/or files."
                                     )
            self.buffers = []

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "sf_buffered_writer", "upload", "Exception %s ::  %s" % (e, msg))
            #sys.exit(1)
            raise Exception(msg)

    def create_error_table(self, table, error_table="ERROR_TABLE"):
        """
        Creates an error table in Snowflake by running the SF "VALIDATE" function.

        Snowflake Documentation: Validates the files loaded in a past execution of the COPY INTO <table>
        command and returns all the errors encountered during the load, rather than just the first error.
        See Also: https://docs.snowflake.com/en/sql-reference/functions/validate.html

        Parameters
        ----------
        table str, required. Table where data was copied to
        error_table str, optional. Error table name
        """

        create_error_table_sql = """
                    CREATE TABLE IF NOT EXISTS {err_table}
                    (
                        ERROR VARCHAR(16777216),
                        FILE VARCHAR(16777216),
                        LINE NUMBER(18,0),
                        CHARACTER NUMBER(18,0),
                        BYTE_OFFSET NUMBER(18,0),
                        CATEGORY VARCHAR(16777216),
                        CODE NUMBER(18,0),
                        SQL_STATE VARCHAR(16777216),
                        COLUMN_NAME VARCHAR(16777216),
                        ROW_NUMBER NUMBER(18,0),
                        ROW_START_LINE NUMBER(18,0),
                        REJECTED_RECORD VARCHAR(16777216)

                    );
                    """.format(
            err_table=error_table)

        # Outputting result
        create_error_table_result = self.connection.execute_query(create_error_table_sql)
        self._logger.sf_output("CREATE ERROR TABLE OUTPUT", create_error_table_result)

        # Adds errors from each copy into statement.
        for job_id in self.job_id_list:
            populate_error_table_sql = """
                        Insert Into {err_table}
                        SELECT * FROM TABLE(VALIDATE({table}, job_id => '{job_id}'));
                        """.format(
                err_table=error_table,
                table=table,
                job_id=job_id
            )

            # Executes Copy-Into SQL
            populate_error_table_result = self.connection.execute_query(populate_error_table_sql)

            ### UNCOMMENT BELOW IF YOU WANT THE RESULT OF EACH INSERT TO BE WRITTEN TO CONSOLE ###
            # self._logger.sf_output("POPULATE ERROR TABLE OUTPUT", populate_error_table_result)

        self._logger.log(LogKind.INFO, "sf_buffered_writer",
                         "create_error_table", "Error Table {} Successfully Populated".format(error_table))

    def upload_no_split(self, filename, table_name, stage_type, stage_name, file_format, purge_bool, on_error, data_mapping=None,
               copy_into_sql=None, additional_headers=None, additional_content=None, schema_name=None):
        # TODO: Add proper documentation


        """Uploads data in buffer files to the SnowFlake database.
            Parameters
            ----------
             table_name : string, required
               Name of table to write data to
            """
        try:

            if stage_type == 'NAMED':
                staged_file_path = '@' + stage_name + "/" + table_name
            elif stage_type == 'TABLE':
                staged_file_path = '@%' + table_name
            elif stage_type == 'USER':
                staged_file_path = '@~'

            put_statements = []
            copy_into_statements = []

            put_sql = (
                "PUT 'file://{file}' {staged_file_path}".format(file=filename.replace('\\','/'), staged_file_path=staged_file_path)
            )
            put_statements.append(put_sql)
            destination_directory = ''
            if copy_into_sql == None:
                if data_mapping is not None:
                    columns = ", \n".join(list(data_mapping.keys()))
                    maps = ", \n".join(list(data_mapping.values()))
                    copy_into_statement = (
                        """
                        COPY INTO {table}
                            (
                            {columns}
                            )
                        FROM
                            (
                            SELECT {maps}
                            )
                        FROM {staged_file_path}
                        FILE_FORMAT = '{file_format}'
                        ON_ERROR = {on_error}
                        PURGE = {purge_bool}
                        RETURN_FAILED_ONLY = TRUE
                        """
                        ).format(table=table_name,
                             columns=columns,
                             maps=maps,
                             staged_file_path=staged_file_path,
                             file_format=file_format,
                             purge_bool=purge_bool,
                             on_error=on_error
                             )
                else:
                    # If no data mappings are not passed but additional_header is passed, add additional content into COPY INTO statement
                    if additional_headers:
                        columns_query = (
                            "SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name='{table}' AND table_schema='{schema}' AND column_name not in ('{additional_headers}') ORDER BY ORDINAL_POSITION"
                        ).format(table=table_name.upper(), schema=schema_name.upper(), additional_headers="', '".join(additional_headers))

                        columns_result = self.connection.execute_query(columns_query)
                        
                        columns = ''
                        column_values  = ''
                        column_index = 1
                        for col in columns_result:
                            if columns != '':
                                columns += ', '
                                column_values += ', '
                            #columns += col.get('column_name')
                            
                            columns += str(col[0])
                            column_values += '$' + str(column_index)
                            column_index += 1
                        
                        copy_into_statement = (
                            """
                            COPY INTO {table} 
                                (
                                {additional_headers}, {columns}
                                )
                            FROM 
                                (
                                SELECT {additional_content}, {column_values} from '{staged_file_path}{path_name}'
                                )
                            FILE_FORMAT = '{file_format}'
                            ON_ERROR = {on_error}
                            PURGE = {purge_bool}
                            RETURN_FAILED_ONLY = TRUE
                            """
                        ).format(table=table_name,
                                additional_headers=', '.join(additional_headers),
                                columns=columns,
                                additional_content=', '.join(additional_content),
                                column_values=column_values,
                                staged_file_path=staged_file_path+"/"+self.file_utils.basename(filename),
                                path_name=destination_directory,
                                file_format=file_format,
                                purge_bool=purge_bool,
                                on_error=on_error
                                )
                    else:
                        copy_into_statement = (
                            """
                            COPY INTO {table}
                            FROM {staged_file_path}
                            FILE_FORMAT = '{file_format}'
                            ON_ERROR = {on_error}
                            PURGE = {purge_bool}
                            RETURN_FAILED_ONLY = TRUE
                            """
                        ).format(table=table_name,
                                staged_file_path=staged_file_path,
                                file_format=file_format,
                                purge_bool=purge_bool,
                                on_error=on_error
                                )
            else:
                copy_into_statement = copy_into_sql.format(staged_file_path=staged_file_path)

            copy_into_statements.append(copy_into_statement)

            for put in put_statements:
                put_result = self.connection.execute_query(put)
                self._logger.sf_output("PUT OUTPUT", put_result)

                # Logging().log(LogKind.INFO, 'EXECUTING PUT', "UPLOAD", self.cursor.execute(put).fetchall())
            self.job_id_list = []
            self.job_result_list = []
            for copy_into in copy_into_statements:
                print(copy_into)
                copy_into_result = self.connection.execute_query(copy_into)
                self.job_id_list.append(copy_into_result.sfqid)
                self._logger.sf_output("COPY_INTO OUTPUT", copy_into_result)
                self.job_result_list.append(copy_into_result)


        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log_no_module(LogKind.ERROR, "Exception %s ::  %s" % (e, msg))
            #sys.exit(1)
            raise Exception(msg)