# ### Helper for Python argsparse to enhance with environment variable and default is neither is available

import os

def environ_or_required(key, default=None):
    """
    argsparser helper to check when the argument value isn't set in the command line, to attempt retrieving a value
     from environment variable.

     Parameters
     ----------
     key : str, required
        the environment variable to look for and retrieve value of
     default : int, optional
        if provided will use the value (can be an int or str) to set when no value is found for environment variable

     Returns
     -------
     dict
        The value retrieved from an environment variable value or default if used.
    """

    if default:
        return (
            {'default': os.environ.get(key)} if os.environ.get(key)
            else {'default': default}
        )
    else:
        return (
            {'default': os.environ.get(key)} if os.environ.get(key)
            else {'required': True}
        )