# ### Generic Connection Class that uses the Snowflake Python Connector to connect
import sys

from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine
from include.Python.utils.logging.logging import LogKind
import include.Python.utils.logging.logging as logging

class Connection():
    _engine = None
    _connection = None

    def __init__(self, _account, _user, _password, _database, _schema, _warehouse, _role, logger=logging.Logging()):
        """
        Initialize and connect to Snowflake (via SQL Alchemy connector). Use `getConnection()` method to retrieve the
        connection object that was created.

         Parameters
         ----------
         _account : str, required
            the Snowflake account to connect with
         _user : str, required
            the Snowflake user to connect with
         _password: str, required
            the Snowflake password to connect with
         _database: str, required
             the Snowflake database to connect with
         _schema: str, required
             the Snowflake schema to connect with
         _warehouse: str, required
             the Snowflake warehouse to connect with
         _role: str, required
             the Snowflake role to connect with
        """

        try:
            self._logger = logger
            self._engine = create_engine(
                URL(
                    account=_account,
                    user=_user,
                    password=_password,
                    database=_database,
                    schema=_schema,
                    warehouse=_warehouse,
                    role=_role
                )
            )

            self._connection = self._engine.connect()
            self._warehouse = _warehouse

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "init", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def getConnection(self):
        """Retrieve the connection object created when the class was initialized in the constructor

        Returns
        -------
        Connection
            the Connection object
        """
        try:
            return self._connection
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "getConnection", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def close(self):
        """Close the connection to Snowflake.
        """

        try:
            if self._connection:
                self._connection.close()
                self._engine.dispose()
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "close", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def resume_warehouse(self):
        """
        Resumes specified warehouse if suspended
        """
        try:
            result = self._connection.execute(
                        'ALTER WAREHOUSE {warehouse} RESUME IF SUSPENDED'.format(warehouse=self._warehouse)).fetchall()[0][0]
            self._logger.log(LogKind.INFO, "snowflake_sqlalchemy", "resume_warehouse", result)

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR,  "snowflake_sqlalchemy", "resume_warehouse", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def rollback(self):
        """
        Rollbacks the current transaction
        """
        try:
            result = self._connection.execute('ROLLBACK').fetchall()[0][0]
            self._logger.log(LogKind.INFO, "snowflake_sqlalchemy", "rollback", result)

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "rollback", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)


    def commit(self):
        """
        Commits an open transaction in the current session.
        """
        try:
            result = self._connection.execute('COMMIT').fetchall()[0][0]
            self._logger.log(LogKind.INFO, "snowflake_sqlalchemy", "commit", result)

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "commit", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

    def start_transaction(self, transaction_name):
        """Starts the file_upload transaction
        """
        try:
            self._logger.log(LogKind.INFO, "snowflake_sqlalchemy", "start_transaction",
                             'CREATING TRANSACTION {}'.format(transaction_name))
            result = self._connection.execute('START TRANSACTION NAME {}'.format(transaction_name)).fetchall()[0][0]
            self._logger.log(LogKind.INFO, "snowflake_sqlalchemy", "start_transaction", result)
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.log(LogKind.ERROR, "snowflake_sqlalchemy", "start_transaction", "Exception %s ::  %s" % (e, msg))
            sys.exit(1)

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

        file_format_data = self._connection.execute(
            "DESCRIBE FILE FORMAT {file_format}".format(file_format=file_format)).fetchall()
        file_format_dict = {}
        for t in file_format_data:
            file_format_dict[t[0]] = t[2].encode().decode('unicode_escape')

        return file_format_dict