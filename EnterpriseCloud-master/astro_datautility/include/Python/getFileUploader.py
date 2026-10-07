import json
import glob
import os
import sys
from airflow.exceptions import AirflowRescheduleException
import pandas as pd
from datetime import datetime
import yaml
import warnings

#add your file import here from python folder
script_dir = os.path.dirname( __file__ )
mymodule_dir = os.path.join( script_dir, '..', 'Python')
sys.path.append( mymodule_dir )
import include.Python.TELTools as TT


def main(ConfigFileName):
    error_cnt = 0
    upload_cnt = 0
    with open(ConfigFileName) as config_file:
        data = json.load(config_file)

    for config in data.values():
        SNOWFLAKE_DATABASE_NAME = os.environ['SNOWFLAKE_LZ'] # database not needed in config, will always use LZ
        SNOWFLAKE_SCHEMA_NAME = config["SNOWFLAKE_SCHEMA_NAME"]
        SNOWFLAKE_TABLE_NAME = config["SNOWFLAKE_TABLE_NAME"]
        FILE = config["FILE"] # file name pattern to search for
        DELIMETER = config.get("DELIMETER", ",") # optional parameter to separate columns, defaults to comma
        HEADER_ROW = config.get("HEADER_ROW", 1) # optional parameter to specify location of header, defaults to 1 (first row)
        ENCODING = config.get("ENCODING", "utf-8") # optional parameter to handleencodings other than utf-8
        IGNORE_HEADER = config.get("IGNORE_HEADER", False) # optional parameter to ignore file headers and use SF columns instead

        if glob.glob(FILE):
            FILES = glob.glob(FILE)
            print("File patern matched: " + ', '.join(FILES))
            for file in FILES:
                try:
                    fileDate = datetime.fromtimestamp(os.path.getmtime(file)) # gets the last modified date of file
                    ext = file.split('.')[-1].lower()
                    header = HEADER_ROW - 1 if HEADER_ROW > 0 else None # shifts header parameter to start at 0 instead of 1 or leaves it blank
                    if ext in ('csv', 'tsv', 'txt'):
                        df = pd.read_csv(file, delimiter=DELIMETER, header=header, dtype=str, encoding=ENCODING)
                    elif ext == 'html':
                        HTML_INDEX = config.get("HTML_INDEX", 0)
                        html_tables = pd.read_html(file, header=header)
                        if html_tables and isinstance(html_tables, list):
                            df = html_tables[HTML_INDEX]
                    elif ext == 'json':
                        df = pd.read_json(file, encoding=ENCODING)
                    elif ext == 'xlsx':
                        df = pd.read_excel(file, header=header, dtype=str)
                    elif ext in ('yml', 'yaml'):
                        with open(file, 'r') as f:
                            contents = yaml.safe_load(f)
                        df = pd.DataFrame(contents, dtype=str)
                    else:
                        warnings.warn(f'Nothing to do. Unknown file type: {ext}', stacklevel=2)
                        continue
                    
                    if IGNORE_HEADER:
                        df.columns = list(range(len(df.columns)))
                    
                    messages = TT.putSnowflakeDataFrame(
                        db=SNOWFLAKE_DATABASE_NAME, 
                        schema=SNOWFLAKE_SCHEMA_NAME, 
                        tableName=SNOWFLAKE_TABLE_NAME, 
                        df=df, 
                        fileName=file, 
                        fileDate=fileDate
                    )
                    print('\n'.join(messages))
                    if 'FAIL_SIGNAL' in messages:
                        error_cnt += 1
                    else:
                        upload_cnt += 1
                        os.remove(file.replace('\\','/'))

                except PermissionError:
                    e = sys.exc_info()[0]
                    msg = sys.exc_info()[1]
                    print(e, msg)
                    error_cnt += 1
                except:
                    e = sys.exc_info()[0]
                    msg = sys.exc_info()[1]
                    print(e, msg)
                    error_cnt += 1
                    raise AirflowRescheduleException(message=str(msg))
        else:
            message = "No files found: " + FILE
            print(message)
    if error_cnt > 0:
        raise Exception(f'{error_cnt} files failed.') 
    else:
        print(f'Uploaded {upload_cnt} file(s)')


if __name__ == "__main__":
    args = sys.argv[1:]
    ConfigFileName:str = args[0]
    print("ConfigFileName: " + ConfigFileName)
    
    # set vars, call main
    main(ConfigFileName)