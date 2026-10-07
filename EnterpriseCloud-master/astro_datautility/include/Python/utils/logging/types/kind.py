# ### LogKind ENUM

from enum import Enum


class LogKind(Enum):
    # match the integer values of the Python logging for compatibility
    DEBUG = 10
    INFO = 20
    WARNING = 30
    ERROR = 40
    FAIL = 50
