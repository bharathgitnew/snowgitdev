# ### Generic Connection Class that uses the Snowflake Python Connector to connect

import snowflake.connector
import sys
from include.Python.utils.file.file_utils import file_utils
from include.Python.utils.logging.logging import Logging, LogKind
from snowflake.connector.cursor import SnowflakeCursor


class Connection():
    _connection = None
    _cursor = None

    def __init__(
            self,
            account: str,
            user: str,
            password: str,
            database: str = None,
            schema: str = None,
            warehouse: str = None,
            role: str = None,
            autocommit: bool = None,
            salt=None,
            **kwargs
    ):
        """
        Initialize and connect to Snowflake. Use `getConnection()` method to retrieve the
        connection object that was created.

        Args:
            - account (str): snowflake account name, see snowflake connector
                 package documentation for details
            - user (str): user name used to authenticate
            - password (str): password used to authenticate
            - database (str, optional): name of the default database to use
            - schema (int, optional): name of the default schema to use
            - warehouse (str, optional): name of the default warehouse to use
            - role (str, optional): name of the default role to use
            - autocommit (bool, optional): set to True to autocommit, defaults to None, which takes
                snowflake AUTOCOMMIT parameter
            - salt (str, optional): if needs to work with encrypted SQL files, provide the salt to use for decryption
        """

        try:
            self.account = account
            self.user = user
            self.password = password
            self.database = database
            self.schema = schema
            self.role = role
            self.warehouse = warehouse
            self.autocommit = autocommit
            self.salt = salt

            # initialize file_utils class
            self.file_utils = file_utils(salt=salt)

            # build the connection parameter dictionary
            # we will remove `None` values next
            _connect_params = {
                "account": self.account,
                "user": self.user,
                "password": self.password,
                "database": self.database,
                "schema": self.schema,
                "role": self.role,
                "warehouse": self.warehouse,
                "autocommit": self.autocommit#,
                #"authenticator": "externalbrowser"
            }
            # filter out unset values
            _connect_params = {
                _param: _value
                for (_param, _value) in _connect_params.items()
                if _value is not None
            }

            self._connection = snowflake.connector.connect(**_connect_params)
        except Exception as e:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "snowflake_intricity", "init", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def getConnection(self):
        """Retrieve the connection object (which was created when the class was initialized in constructor)

        Returns
        -------
        Connection
            the Connection object
        """
        try:
            return self._connection
        except Exception as e:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "snowflake_intricity", "getConection", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def close(self):
        """Close the connection to Snowflake.
        """

        try:
            if self._connection:
                self._connection.close()
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "snowflake_intricity", "close", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def set_autocommit(self, value: bool = True):
        """Toggle the autocommit value set during constructor initialize.

        Args:
            - value (bool, required): true to enable, false to disable
        """
        self.autocommit = value

    def get_autocommit(self):
        """Retrieve current autocommit value.

        Returns
            - bool: true if enabled, false if disabled
        """
        return self.autocommit

    def cursor(self):
        """Retrieves the most current cursor.

        Args:
            - None

        Returns:
            - Cursor (Cursor) - the current cursor
        """
        return self._cursor

    def execute_query(self, query):
        """Executes the query against the database

        Args:
            - query (str, required): the SQL query to execute against the database

        Returns:
            - Cursor (Cursor) - the current cursor

        Raises:
            - ValueError: if query parameter is None or a blank string
            - DatabaseError: if exception occurs when executing the query
        """
        if not query:
            raise ValueError("A SQL query must be provided")

        try:
            self._cursor = self._connection.cursor().execute(query)
            return self.cursor()
        except Exception as e:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "snowflake_intricity", "execute_query", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def stream_has_data(self, stream, return_as_cursor=False):
        """Checks if stream has data

        Args:
            - stream (str, required): the stream name to check
            - return_as_cursor (bool, optional): if set to true, will return result as cursor, otherwise as boolean

        Returns:
            - bool - true if stream has data, false if it does not if return_as_cursor not set to true (default to false)
            - Cursor (Cursor) - the current cursor if return_as_cursor set to true (default to false)
        """
        if not stream:
            raise ValueError("A stream name must be provided")

        try:
            self._cursor = self.execute_query("select system$stream_has_data(\'%s\');" % stream)
            if return_as_cursor:
                return self.cursor()
            else:
                return bool(self.cursor().fetchone()[0])
        except Exception as e:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            Logging().log(LogKind.ERROR, "snowflake_intricity", "stream_has_data", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def execute_sqlfile(self, sqlfile, print_result=False, result_to_dict=False, decrypt=False):
        """Executes one or more queries from a SQL file against the database

        Args:
            - sqlfile (str, required): file containing sql script to execute against database
            - print_result (bool, optional): to see result of each executed sql query, set to true
            - result_to_dict (bool, optional): to capture result of executed sql query as dict on return, set to true
            - decrypt (bool, optional): if file is encrypted, set to true to decrypt

        Returns:
            - Cursor (Cursor) - the current cursor
            - Cursor, Dict - both the cursor and dict if result_to_dict was set to true

        Raises:
            - ValueError: if query parameter is None or a blank string
            - DatabaseError: if exception occurs when executing the query
        """
        if not sqlfile:
            raise ValueError("A file containing SQL script must be provided")

        try:
            _result_dict = []
            _sqlfile = self.file_utils.open(sqlfile, 'r', encoding='utf-8', decrypt=decrypt)
            if _sqlfile:
                with _sqlfile as f:
                    i = 0
                    try:
                        for _cursor in self._connection.execute_stream(f):
                            self._cursor = _cursor

                            if not isinstance(self._cursor, SnowflakeCursor):
                                if print_result:
                                    i += 1
                                    print("Error %d: %s" % (i, self._cursor))
                                    #Logging().log(LogKind.ERROR, "snowflake_intricity", "execute_sqlfile", "Error %d: %s" % (i, self._cursor))
                                if result_to_dict:
                                    _result_dict.append(self._cursor)
                                break # Don't continue processing files if an error occurred
                            else:
                                for executed in self._cursor:
                                    if print_result:
                                        i += 1
                                        #Logging().log(LogKind.INFO, "snowflake_intricity", "execute_sqlfile",
                                        #            "Result %d: %s" % (i, executed))
                                        print("Result %d: %s" % (i, executed))
                                    if result_to_dict:
                                        _result_dict.append(executed)
                    except:
                        e = sys.exc_info()[0]
                        msg = sys.exc_info()[1]
                        #Logging().log(LogKind.ERROR, "snowflake_intricity", "execute_sqlfile", "Exception %s ::  %s" % (e, msg))
                        print("Exception %s ::  %s" % (e, msg))
                        self._cursor = None
                        sys.exit(1)

                if result_to_dict:
                    return self._cursor, _result_dict
                else:
                    return self._cursor
            else:
                raise ValueError("%s :: file not found." % sqlfile)
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            #Logging().log(LogKind.ERROR, "snowflake_intricity", "execute_sqlfile", "Exception %s ::  %s" % (e, msg))
            print("Exception %s ::  %s" % (e, msg))
            sys.exit(1)
