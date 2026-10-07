# ### Logging wrapper to make logging to console and file easier by setting parameters and having it formatted

import sys
import logging
from include.Python.utils.logging.types.kind import LogKind
from tabulate import tabulate


class Logging:
    _logger = logging.getLogger('Application')

    def __init__(self, minLevel=LogKind.DEBUG.value, filename=None, debug=False):
        # disable root loggers from logging anything less than an ERROR or CRITICAL message, i.e. prevents third-party
        # libraries from being chatty with INFO messages, etc.

        self.debug = debug

        if len(self._logger.handlers) != 0:
            self._logger.handlers = []
        logging.getLogger().setLevel(40)

        #self._root_logger.propagate - False

        # don't create the logging handlers more than once

        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

        # create file handler which logs even debug messages
        if filename:
            fh = logging.FileHandler(filename)
            fh.setLevel(minLevel)
            fh.setFormatter(formatter)

            self._logger.propagate = False
            self._logger.setLevel(1)

            # add the handlers to logger
            self._logger.addHandler(fh)

        else:
            if (len(logging.getLogger("Application").handlers) == 0):
                # prevent the root log handler from also displaying the message
                self._logger.propagate = False
                self._logger.setLevel(minLevel)

                # create console handler with a higher log level
                logging.getLogger().hasHandlers()
                ch = logging.StreamHandler()

                # create formatter and add it to the handlers
                ch.setFormatter(formatter)
                self._logger.addHandler(ch)
                # add the handlers to logger if not quiet


    def log(self, logKind, class_name, module, message):
        try:
            if self.debug:
                formattedMessage = "%s :: %s :: %s" % (class_name, module, message)
            else:
                formattedMessage = message

            # if logKind == LogKind.DEBUG:
            #     self._logger.debug(formattedMessage)
            #     self._logger.log(logKind, formattedMessage)
            #     return
            # if logKind == LogKind.INFO:
            #     self._logger.info(formattedMessage)
            #     return
            # if logKind == LogKind.WARNING:
            #     self._logger.warning(formattedMessage)
            #     return
            # if logKind == LogKind.ERROR:
            #     self._logger.error(formattedMessage)
            #     return
            # if logKind == LogKind.FAIL:
            #     self._logger.critical(formattedMessage)
            #     return

            self._logger.log(logKind.value, formattedMessage)
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.error("logging :: log :: Exception %s ::  %s" % (e, msg))
            sys.exit(1)



    def sf_output(self, info, result):
        try:
            rows = []
            for l in result.fetchall():
                rows.append(list(l))
            column_names = [value[0] for value in result.description]
            formatted_result = tabulate(rows, headers=column_names)
            formattedMessage = "%s: \n%s\n" % (info, formatted_result)
            self._logger.log(LogKind.INFO.value, formattedMessage)

        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.error("Exception %s ::  %s" % (e, msg))
            sys.exit(1)
    
    def log_no_module(self, logKind, message):
        try:
            formattedMessage = "%s" % (message)

            # if logKind == LogKind.DEBUG:
            #     self._logger.debug(formattedMessage)
            #     self._logger.log(logKind, formattedMessage)
            #     return
            # if logKind == LogKind.INFO:
            #     self._logger.info(formattedMessage)
            #     return
            # if logKind == LogKind.WARNING:
            #     self._logger.warning(formattedMessage)
            #     return
            # if logKind == LogKind.ERROR:
            #     self._logger.error(formattedMessage)
            #     return
            # if logKind == LogKind.FAIL:
            #     self._logger.critical(formattedMessage)
            #     return

            self._logger.log(logKind.value, formattedMessage)
        except:
            e = sys.exc_info()[0]
            msg = sys.exc_info()[1]
            self._logger.error("logging :: log :: Exception %s ::  %s" % (e, msg))
            sys.exit(1)
