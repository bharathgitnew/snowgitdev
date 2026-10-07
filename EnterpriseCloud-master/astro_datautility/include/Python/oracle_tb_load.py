
from include.Python.TELTools import getSnowFlakeConn,getAzureSecret,putSnowflakeDataFrame,sendEmail
from datetime import date, datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from typing import Dict, Any
import io, requests, sys,json,os,calendar,time,urllib
from dataclasses import dataclass, asdict
import traceback
from typing import List, Dict, Any, Optional
from contextlib import contextmanager
from time import perf_counter
import pandas as pd
import pprint
from string import Template
from cryptography.fernet import Fernet




# Ref Docs:
# Authenticate REST client:  https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/authentication_oath.html
# Upload file -  https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/upload.html
# Run the data rule -  https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/fdmee_run_data_rule.html
# delete file - https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/delete_files.html
# execute bussiness rule - https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/rules.html
# error status codes - https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/status_codes.html



# audit table DDL: 
"""create or replace TABLE ORACLE_TB_LOAD_AUDIT (
	COMPANY_NAME VARCHAR(16777216),
	STEP_NAME VARCHAR(16777216),
	STEP_NUMBER VARCHAR(16777216),
	OK BOOLEAN,
	MESSAGE VARCHAR(16777216),
	ERROR VARCHAR(16777216),
	STEP_RETURN_DATA VARCHAR(16777216),
	STARTED_AT TIMESTAMP_NTZ(6),
	ENDED_AT TIMESTAMP_NTZ(6),
	RUN_ID VARCHAR(16777216),
	_FILENAME VARCHAR(16777216),
	_FILEDATE TIMESTAMP_NTZ(9),
	_UPLOADDATE TIMESTAMP_NTZ(9)
);"""    


api_call_datetimestamp = datetime.now()
CURRENT_TIMESTAMP = str(api_call_datetimestamp).replace(" ","_").replace(":","_").replace(".","_")

SNOWFLAKE_ENV = os.environ['SNOWFLAKE_ENV']
#all globals would go as env var todo
FISCAL_START_MONTH = 4           # April = 4 (Apr–Mar fiscal year)
WINDOW_START_DAY = 27            # close window starts on 27th of closing month
WINDOW_END_DAY = 5                  # close window ends on 5th of next month
TZ = ZoneInfo("America/Chicago")  
COMPANY_CODE_MAPPING = {"TEA":"3200",
                        "TEH":"3100",
                        "TTCA":"3300",
                        "TVC":"3400",
                        "TTAD":"3700"}

NEW_COLUMN_MAP = {
    "COMPANY_CODE": "Company Code",
    "FISCAL_YEAR": "Fiscal Year",
    "WBS_ELEMENT": "WBS Element",
    "AMOUNT": "Amount",
    "LEDGER_ACCOUNT": "Ledger Account",
    "SALES_CATEGORY": "Sales Category",
    "FISCAL_PERIOD": "Fiscal Period",
    "CUSTOMER": "Customer",
    "PROFIT_CENTER": "Profit Center",
}
source_db_map = {"DEV":"SILVER_DEV",
                 "SIT":"SILVER_SIT",
                 "QA":"SILVER_QA",
                 "PROD":"SILVER" }

SOURCE_DB , SOURCE_SCHEMA = source_db_map.get(SNOWFLAKE_ENV,"PROD"), 'TEH_FINANCE'
QUERY_TEMPLATE=Template(f"""
    SELECT 
        FISCAL_YEAR,
        FISCAL_PERIOD,
        COMPANY_CODE,
        PROFIT_CENTER ,
        SALES_CATEGORY,
        WBS_ELEMENT,
        CUSTOMER,
        LEDGER_ACCOUNT,
        AMOUNT
    FROM {SOURCE_DB}.{SOURCE_SCHEMA}.ORACLE_TB_LOAD_ENHANCED 
    WHERE FISCAL_PERIOD     = $fiscal_period
        AND FISCAL_YEAR     = $fiscal_year
        AND COMPANY_CODE    = $company_code;""")



urls = {
    "PROD": "https://planning-a502879.pbcs.us6.oraclecloud.com",
    "TEST": "https://planning-test-a502879.pbcs.us6.oraclecloud.com"
    }  
 
AUDIT_TABLE = "ORACLE_TB_LOAD_AUDIT_PROD"

#oracle app name
APPLICATION = 'TELPLAN'

#FIN_Clear TB params
CLEAR_TB_JOB = 'FIN_Clear TB Data'
CLEAR_TB_POLL_TIME = 60
CLEAR_TB_TIMEOUT_S = 120

#FIN_Aggregate params
FIN_AGGREGATE_JOB = 'FIN_Aggregate Cube by Sub'
FIN_AGGREGATE_POLL_TIME = 120
FIN_AGGREGATE_TIMEOUT_S = 300


#data load rule params
DATARULE_POLL_TIME = 60
DATARULE_TIMEOUT_S = 120

#oracle target folder location for file drops
INBOX_FOLDER = "inbox"
SAP_FOLDER = "TB_SAP"

#final result email sent to list
SEND_EMAILS_TO = {
    "PROD": [
        "varun.x.tiwari@us.tel.com",
        "brandon.swallow@us.tel.com",
        "david.greenwell@us.tel.com",
        "motoki.hikita@us.tel.com",
        "anirudh.thakkar@us.tel.com",
        "carlos.gardea@us.tel.com",
        "pritesh.x.gandhi@us.tel.com",
        "junichi.aso@tel.com",
        "Finance.Planning@us.tel.com",
        "aaron.maciej@us.tel.com",
        "brenda.leto@us.tel.com",
        "len.pickus@us.tel.com",
        "farooque.shaikh@us.tel.com"
    ],
    "TEST": [
        "brandon.swallow@us.tel.com",
        "trey.x.osborne@us.tel.com",
        "varun.x.tiwari@us.tel.com",
        "david.greenwell@us.tel.com",
        "anirudh.thakkar@us.tel.com",
    ],
}





@dataclass
class StepResult:
    company_name: str
    name: str
    ok: bool
    started_at: str
    ended_at: str
    message: str
    error: Optional[str]=None

@dataclass
class CompanyRunResult:
    company_name: str
    company_code: str
    fiscal_year: str
    fiscal_month: str
    ok: bool
    steps: List[StepResult]

def to_json_or_none(x):
    if x is None or (isinstance(x, float) and np.isnan(x)):
        return None
    return json.dumps(x, ensure_ascii=False, separators=(',', ':'), default=str)


def previous_month(year: int, month: int) -> tuple[int, int]:
    if month == 1:
        return year - 1, 12
    return year, month - 1

def get_fiscal_period(calendar_month: int) -> int:
    """
    Map calendar month (1-12) -> fiscal period (1-12).
    Example (Apr-Mar): Apr-1, May-2, ...., Sep-6, ..., Mar→12
    """
    if not 1 <= calendar_month <= 12:
        raise ValueError("Fiscal Month must be between 1 to 12")
    return ((calendar_month - FISCAL_START_MONTH) % 12) + 1


def get_fiscal_year(calendar_month: int, calendar_year: int) -> int:
    """
    Map calendar month + year-->fiscal year.
    FY starts April: Jan-Mar belong to previous FY.
    e.g. March 2026 --> FY2025, April 2026 --> FY2026
    """
    if calendar_month < FISCAL_START_MONTH:
        return calendar_year - 1
    return calendar_year

def fiscal_year_label(dt: date, fiscal_start_month: int = FISCAL_START_MONTH) -> str:
    """
    Return FY label like 'FY26'.
    Rule (Apr-Mar): if month >= 4, FY = year + 1; else FY = year.
    Example: Sep-2025 => FY26; Jan-2026 => FY26.
    """
    fy = dt.year + 1 if dt.month >= fiscal_start_month else dt.year
    return f"FY{fy % 100:02d}"

def get_closing_month(dt: datetime):
    if dt.day >= WINDOW_START_DAY:
        return dt.year,dt.month
    elif dt.day <= WINDOW_END_DAY:
        return previous_month(dt.year, dt.month)
    else:
        # Outside the 27–5 window, return previous month as most recent close
        return previous_month(dt.year, dt.month)
    
def encrypt_token(new_refresh_token: str, secret_key: str) -> str:
    encryption_key = secret_key.encode()
    cipher = Fernet(encryption_key)
    encrypted_bytes = cipher.encrypt(new_refresh_token.encode())
    return encrypted_bytes.decode()


def decrypt_token(old_refresh_token: str, secret_value: str) -> str:
    encryption_key = secret_value
    cipher = Fernet(encryption_key)
    decrypted_bytes = cipher.decrypt(old_refresh_token.encode())
    return decrypted_bytes.decode()

def validate_and_build_params(
        company_name: str,
        fiscal_month: str,
        fiscal_year: str,
        wbs_blank: str,
        company_code_mapping: Dict[str, str],
    )-> Dict[str, Any]:
    """
    Validates user inputs and returns a dict if no errors:
    Raises ValueError with all problems if any validation fails.
    """
    errors = []
    
    # company_name
    comp = (company_name or "").strip()
    if not comp:
        errors.append("COMPANY_NAME cannot be empty or null")
    elif comp not in COMPANY_CODE_MAPPING:
        allowed = ", ".join(sorted(COMPANY_CODE_MAPPING.keys()))
        errors.append(f"COMPANY_NAME: '{comp}' not found. Allowed values: [{allowed}].")

    
    # fiscal_month
    fm_raw = (fiscal_month or "").strip()
    if not fm_raw:
        errors.append("FISCAL_MONTH cannot be empty or null")
    elif not fm_raw.isdigit():
        errors.append(f"FISCAL_MONTH must be digits only (got '{fm_raw}').")
    else:
        fm = int(fm_raw)
        if not (1 <= fm <= 12):
            errors.append("FISCAL_MONTH must be in 1..12.")

    #  fiscal_year 
    fy_raw = (fiscal_year or "").strip()
    if not fy_raw:
        errors.append("FISCAL_YEAR cannot be empty or null")
    elif not fy_raw.isdigit():
        errors.append(f"FISCAL_YEAR must be digits only (got '{fy_raw}').")
    else:
        fy = int(fy_raw)
        if not (1900 <= fy <= 9999):
            errors.append("FISCAL_YEAR must be a 4-digit year between 1900 and 9999.")

    #  wbs_blank 
    wb_raw = (wbs_blank or "").strip()
    if not wb_raw:
        errors.append("WBS_BLANK cannot be empty or null")
    else:
        wb = wb_raw.upper()
        if wb not in {"Y", "N"}:
            errors.append("WBS_BLANK must be 'Y' or 'N'.")

    if errors:
        return {
            "ok": False,
            "status": f"Input validation failed:\n- " + "\n- ".join(errors),
            "data": None
            }
        #raise ValueError("Input validation failed:\n- " + "\n- ".join(errors))
    

    company_code = COMPANY_CODE_MAPPING[comp]
    fiscal_period = get_fiscal_period(fm)
    month_name = calendar.month_name[fm]
    month_short = month_name[:3]
    
    fy = get_fiscal_year(fm, fy)
    fiscal_label = f"FY{(fy + 1) % 100:02d}"

    data = {
        "company_name": comp.upper(), 
        "company_code": company_code,
        "fiscal_month": fm,
        "month_name": month_short,
        "fiscal_year": fy,
        "fiscal_label": fiscal_label.upper(),   # e.g, "FY26"
        "fiscal_period": fiscal_period, # e.g, 12 for Mar (Apr–Mar FY)
        "wbs_blank": wb.upper(),                # 'Y' or 'N'
    }

    return {
                "ok": True,
                "status": f"Successfully validated input Params",
                "data": data
            }

def query_snowflake(query):
    try:
        conn, messages = getSnowFlakeConn(SOURCE_DB, SOURCE_SCHEMA, [])
        if conn == "no connection":
            raise Exception(f"No connection to Snowflake: {messages}")

        with conn.cursor() as cur:
            cur.execute(query)
            result_df = cur.fetch_pandas_all()
        return {
                "ok": True,
                "status": f"Successfully read from snowflake: records {len(result_df)}",
                "data": result_df
            }
    except Exception as e:
        try:
            conn.close()
        except Exception:
            pass
        
        return { 
            "ok": False, 
            "status": f"Error reading from snowflake:{str(e)}", 
            }
    
def generate_file(df,company_code,month,fiscal_year,wbs_blank):
    try:
        filename = f'{company_code}_TB_SAP_{month}-{fiscal_year}.txt'
        buf = io.BytesIO()
        df = df.rename(columns=NEW_COLUMN_MAP, inplace=False)
        if wbs_blank == 'Y':
            df['WBS Element'] = ""
        if df.iloc[-1].isnull().all():
            df = df.iloc[:-1]
        #df = df.iloc[:10]
        #df.to_csv(filename, sep='|', index=False) #todo save file somewhere and read programmatically to upload further
        csv_text = df.to_csv(
            sep="|",
            index=False,
        )
        print(f"{len(df)=}")
        buf.write(csv_text.encode("utf-8"))
        buf.seek(0)
        return {
                    "ok": True,
                    "status": f"Successfully generated the file: {filename}",
                    "data": (filename,buf)
                }
    except Exception as e:
        return { 
            "ok": False, 
            "status": f"Error generating the file {filename}: {str(e)}", 
            }

def call_api(url,files=None,data=None,params=None,json_payload=None,headers=None,method='POST'):
    try:
        method=method.upper()
        
        if method == 'GET':
            resp = requests.get(url, params=params, headers=headers, timeout=120)
        elif method == 'POST':
            resp = requests.post(url, files=files, data=data, json=json_payload, headers=headers, timeout=120)
        elif method == 'DELETE':
            resp = requests.delete(url, headers=headers, timeout=120)            
        else:
            raise ValueError(f"Unsupported HTTP method: {method}")
        
        resp.raise_for_status()
        body = resp.json()
        return {
            "ok": True,
            "status": resp.status_code,
            "data": body
        }
    except (requests.Timeout, requests.ConnectionError) as e:
        return {
            "ok": False,
            "status": None,
            "error": str(e),
            "body": ""
        }
    except requests.HTTPError as e:
        status = resp.status_code if resp is not None else None
        body = resp.text if resp is not None else ""
        if body:
            body = body.replace('\r', '').replace('\n', ' ').strip()
        return {
            "ok": False,
            "status": status,
            "error": str(e),
            "body": body
        }

#this sould happen in sf db or somwhere else todo
# def save_refresh_token(path, token):
#     with open(path, "w", encoding="utf-8") as f:
#         f.write(token)
# def load_refresh_token(path):
#     try:
#         with open(path, "r", encoding="utf-8") as f:
#             return f.read().strip()
#     except FileNotFoundError:
#         return None

def retrieve_old_token(query,db,schema):
    try:
        conn, messages = getSnowFlakeConn(db, schema, [])
        if conn == "no connection":
            raise Exception(f"No connection to Snowflake: {messages}")

        with conn.cursor() as cur:
            cur.execute(query)
            result_df = cur.fetchone()
        return {
                "ok": True,
                "status": f"Successfully read from snowflake: records {len(result_df)}",
                "data": result_df
            }
    except Exception as e:
        try:
            conn.close()
        except Exception:
            pass
        
        return { 
            "ok": False, 
            "status": f"Error reading from snowflake:{str(e)}", 
            }
def retrieve_new_token(old_refresh_token):
    TENANT_BASE_URL = "https://idcs-9913457ea7ca4a358bbd8c1eb1ae0daa.identity.oraclecloud.com:443"
    CLIENT_ID = 'f565dab722fa4811a6e9c80dda150dda'
    headers = {
            "Content-Type": "application/x-www-form-urlencoded;charset=utf-8"
        }
    final_token_form = {
            "grant_type": "refresh_token",
            "client_id": CLIENT_ID,
            "refresh_token": old_refresh_token,
        }
    final_token_url = f"{TENANT_BASE_URL}/oauth2/v1/token"
    op = call_api(final_token_url,data=final_token_form,headers=headers,method='POST')
    if not op["ok"]:
        return {
            "ok": False,
            "status": op.get("status"),
            "error": "Failed retrieve_new_token",
            "body": op.get("body", ""),
        }
    resp = op['data']
    access_token = resp.get('access_token')
    refresh_token = resp.get('refresh_token')

    return {
                    "ok": True,
                    "status": f"Successfully generated the token",
                    "data": (access_token,refresh_token)
                }    
# def fetch_refresh_token(): #todo azurekeyvault
#         TENANT_BASE_URL = "https://idcs-9913457ea7ca4a358bbd8c1eb1ae0daa.identity.oraclecloud.com:443"
#         CLIENT_ID = 'c16dc5155b9c48e4b1c1fe13089a8dc4'

#         #refresh_token for prod
#         #REFRESH_TOKEN_QA for QA

#         reference_token_path = r'C:\Users\221291\Desktop\REFRESH_TOKEN_QA.txt'
#         refresh_token = load_refresh_token(reference_token_path)
        
#         final_token_url = f"{TENANT_BASE_URL}/oauth2/v1/token"
#         final_token_form = {
#             "grant_type": "refresh_token",
#             "client_id": CLIENT_ID,
#             "refresh_token": refresh_token,
#         }
#         op = call_api(final_token_url,data=final_token_form,headers=headers,method='POST')
#         if not op['ok']:
#             raise(op)
#         resp = op['data']
#         access_token = resp.get('access_token')
#         refresh_token = resp.get('refresh_token')
#         if refresh_token:
#             save_refresh_token(reference_token_path,refresh_token)

#         return refresh_token,access_token

def delete_folder_files(headers,inbox_folder,sap_folder):
    folder_prefix = f"{inbox_folder}/{sap_folder}/"
    
    GET_FILE_LIST_URL = f"{URL}/interop/rest/11.1.2.3.600/applicationsnapshots" #GET FILE LIST
    op = call_api(GET_FILE_LIST_URL,headers=headers,method="GET")
    if not op["ok"]:
        return {
            "ok": False,
            "status": op.get("status"),
            "error": "Failed to list files",
            "body": op.get("body", ""),
        }
    #if ok false read error and body
    resp = op["data"]
    files_to_delete = []
    for items in resp['items']:
        if items['name'].startswith(folder_prefix):
            _del_file = items['name'].replace(folder_prefix,'')
            if _del_file:
                files_to_delete.append(_del_file)

    if not files_to_delete:
        return {
            "ok": True,
            "status": 200,
            "data": {
                "folder": folder_prefix,
                "found": 0,
                "deleted": [],
                "failed": [],
                "skipped": [],
                "message": "No files to delete",
            },
        }

    results = []
    for _file in files_to_delete:
        backslash_path = f"{inbox_folder}\\{sap_folder}\\{_file}"
        encoded_target_file = urllib.parse.quote(backslash_path, safe="")  # -> inbox%5CTB_SAP%5Cfile
        DELETE_URL = f"{URL}/interop/rest/11.1.2.3.600/applicationsnapshots/{encoded_target_file}"
        
        del_op = call_api(DELETE_URL,headers=headers,method="DELETE")
        if del_op["ok"]:
            results.append({"file": _file, "ok": True, "status": del_op.get("status")})
        else:
            results.append({
                "file": _file,
                "ok": False,
                "status": del_op.get("status"),
                "error": del_op.get("error"),
                "body": del_op.get("body", ""),
            })
    
    deleted = [r for r in results if r["ok"]]
    failed = [r for r in results if not r["ok"]]

    overall_ok = len(failed) == 0
    overall_status = 200 if overall_ok else 207

    return {
        "ok": overall_ok,
        "status": overall_status,
        "data": {
            "folder": folder_prefix,
            "found": len(files_to_delete),
            "deleted": deleted,
            "failed": failed
        },
    }


def upload_file(access_token,file_name,file_object,inbox_folder,sap_folder):
    headers={"Authorization":f"Bearer {access_token}",
         "Content-Type": "application/octet-stream"}
    target_folder = f"{inbox_folder}/{sap_folder}"
    UPLOAD_FILE_URL = f"{URL}/interop/rest/11.1.2.3.600/applicationsnapshots/{file_name}/contents?extDirPath={target_folder}" #UPLOAD FILE
    files = {'file': (file_name, file_object, 'text/csv')}
    
    op = call_api(UPLOAD_FILE_URL,files=files,headers=headers,method="POST")
    
    if op['ok']:
        return {
            "ok": True,
            "status": 200,
            "data": op['data']
        }
    
    else:
        return {
            "ok": False,
            "status": op.get("status"),
            "error": f"Failed to Upload File {file_name}",
            "body": op.get("body", ""),
        }

def run_business_rule(headers,params,job_name,application,poll_time_s,timeout_s):
    # Oracle numeric codes for reference: https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/retrieve_job_status.html
    # -1=in progress; 0=success; 1=error; 2=cancel pending; 3=cancelled; 4=invalid param; INT_MAX=unknown
    INT_MAX = 2_147_483_647
    FAILURE_CODES = {1, 2, 3, 4, INT_MAX}
    RUN_JOB_URL = f'{URL}/HyperionPlanning/rest/v3/applications/{application}/jobs'
    prompt = {
        "v_Subs": params['company_name'],             
        "v_Periods": params['month_name'],                    
        "v_Scenario": "Actual",              
        "v_Version": "Working",               
        "v_Years": params['fiscal_label'],                    
        }
    data = {
        "jobType":"Rules",
        "jobName":job_name,
        "parameters":prompt
        }
    print(data)
    op = call_api(RUN_JOB_URL,json_payload = data,headers = headers,method = "POST")

    if not op['ok']:
       return {
            "ok": False,
            "status": op.get("status"),
            "error": f"Failed to run Job {job_name}",
            "body": op.get("body", ""),
        }
    
    job_resp = op['data']
    job_id = job_resp.get("jobId")
    if not job_id:
        return {
            "ok": False,
            "status": op.get("status"),
            "error": f"Job {job_name} started but no jobId found",
            "body": str(job_resp),
        }
    RETRIEVE_JOB_STATUS_URL = f'{URL}/HyperionPlanning/rest/v3/applications/{application}/jobs/{job_id}'

    deadline = time.time() + float(timeout_s)
    while True:
        op = call_api(RETRIEVE_JOB_STATUS_URL,headers=headers,method="GET")
        if not op['ok']:
            return {
                    "ok": False,
                    "status": op.get("status"),
                    "error": f"Failed to Retrieve Job Status for {job_name} (jobId={job_id}",
                    "body": op.get("body", ""),
                }
        
        resp = op['data']
        status_code = resp['status']
        
        if status_code == 0:
            return {"ok": True, "status": status_code, "data": resp}

        if status_code in FAILURE_CODES:
            msg = resp.get("details")
            return {
                "ok": False,
                "status": status_code,
                "error": f"Job {job_name} (jobId={job_id} FAILED (code={status_code})",
                "body": msg,
            }

        #still running (-1 or unknown)
        if time.time() > deadline:
            return {
                "ok": False,
                "status": 504,
                "error": f"Timed out after {timeout_s}s waiting for Job {job_name} (jobId={job_id})",
                "body": resp.get("descriptiveStatus") or "IN_PROGRESS",
            }

        time.sleep(poll_time_s)


def run_data_rule(headers,params,file_name,poll_time_s,timeout_s):
    # Oracle numeric codes for reference: https://docs.oracle.com/en/cloud/saas/enterprise-performance-management-common/prest/retrieve_job_status.html
    # -1=in progress; 0=success; 1=error; 2=cancel pending; 3=cancelled; 4=invalid param; INT_MAX=unknown
    FAILURE_CODES = {1, 2, 3, 4}
    RUN_DATA_RULE_URL = f"{URL}/aif/rest/jobs"
    
    job_name = f"{params['company_name']}_TB_SAP"
    start_period = f"{params['month_name']}-{params['fiscal_label']}"
    end_period = f"{params['month_name']}-{params['fiscal_label']}"

    payload = {
            "jobType":"DATARULE",
            "jobName":job_name,
            "startPeriod":start_period,
            "endPeriod":end_period,
            "importMode":"REPLACE",
            "exportMode":"STORE_DATA",
            "fileName":file_name
        }
    data = json.dumps(payload)
    op = call_api(RUN_DATA_RULE_URL,data = data,headers = headers,method = "POST")

    if not op['ok']:
       return {
            "ok": False,
            "status": op.get("status"),
            "error": f"Failed to run Data Rule {job_name}",
            "body": op.get("body", ""),
        }
    
    job_resp = op['data']
    job_id = job_resp.get("jobId")
    if not job_id:
        return {
            "ok": False,
            "status": op.get("status"),
            "error": f"Data Rule {job_name} started but no jobId found",
            "body": str(job_resp),
        }
    RETRIEVE_DATA_RULE_JOB_STATUS_URL =  f"{URL}/aif/rest/V1/jobs/{job_id}"

    deadline = time.time() + float(timeout_s)
    while True:
        op = call_api(RETRIEVE_DATA_RULE_JOB_STATUS_URL,headers=headers,method="GET")
        if not op['ok']:
            return {
                    "ok": False,
                    "status": op.get("status"),
                    "error": f"Failed to Retrieve Data Rule Status {job_name} (jobId={job_id})",
                    "body": op.get("body", ""),
                }
        
        resp = op['data']
        status_code = resp['status']
        
        if status_code == 0:
            return {
                    "ok": True, 
                    "status": status_code, 
                    "data": resp
                    }

        if status_code in FAILURE_CODES:
            return {
                "ok": False,
                "status": status_code,
                "error": f"Data Rule {job_name} (jobId={job_id}) failed (code={status_code}). Response: {op.get('data', '')}",
                "body": op.get("body", "")
            }

        #still running (-1 or unknown)
        if time.time() > deadline:
            return {
                "ok": False,
                "status": 504,
                "error": f"Timed out after {timeout_s}s waiting for Data Rule {job_name} (jobId={job_id})",
                "body": resp.get("jobStatus") or "IN_PROGRESS",
            }

        time.sleep(poll_time_s)
            
def get_generated_files(all_results):
        processed_files = []
        if all_results:
            for res in all_results:
                if res.get('step_name') == 'generate_file_result':
                    data = res.get("step_return_data",{})
                    processed_files.append(data)
        return processed_files

def rotate_refresh_token(db,schema,audit_table,env):
    SECRET_VALUE = getAzureSecret("ORACLE-EPBCS-TOKEN-ENCRYTION-KEY").value.strip()
    tab = f'{db}.{schema}.{audit_table}'
    query = f"""select top 1 step_return_data from {tab}
            where run_id = (select max(run_id ) from {tab} where ENV = '{env}' )
            and   step_name = 'fetch_refresh_token'
            and    ENV = '{env}';"""
    print(query)
    # read the last stored step_return_data (json str) from Snowflake
    _op = retrieve_old_token(query, db, schema)
    if not _op or not _op.get("ok"):
        return {"ok": False, "status": f"Failed while getting old token from Snowflake: {_op}"}
    
    rows = _op.get("data") or []
    if len(rows) == 0 or rows[0] in (None, ""):
        return {"ok": False, "status": "No previous STEP_RETURN_DATA found for latest run."}
    
    _rt = json.loads(rows[0])
    _old_refresh_token = _rt['refreshtoken']
    old_refresh_token = decrypt_token(_old_refresh_token, SECRET_VALUE)
    #call API to get the new access token and refresh token
    new_token_op = retrieve_new_token(old_refresh_token)
    if not new_token_op or not new_token_op.get("ok"):
        return {"ok": False, "status": f"Failed while calling for new token: {new_token_op}"}

    try:
        access_token, refresh_token = new_token_op["data"]
    except Exception as e:
        return {"ok": False, "status": f"Unexpected token response shape: {e}", "data": new_token_op.get("data")}
    encrypted_refresh_token = encrypt_token(refresh_token, SECRET_VALUE)
    return {"ok": True, "data": (access_token, encrypted_refresh_token)}


def run_tb_load(company_name :str, fiscal_month :str, fiscal_year :str, wbs_blank :str, refresh_token:str,access_token:str):
    print(URL)
    step_results = []  # list of tuples
    step_order = {"fetch_refresh_token":"01",
                  "validate_and_build_params":"02",
                  "query_snowflake":"03",
                  "generate_file":"04",
                  "delete_folder_files":"05",
                  "upload_file":"06",
                  "run_business_rule: FIN_Clear TB":"07",
                  "run_data_rule":"08",
                  "run_business_rule: FIN_Aggregate":"09"}
    
    def add_step(step_name,step_number, ok, message, error=None,step_return_data = None):
            step_results.append({
                "company_name": company_name,
                "step_name": step_name,
                "step_number": step_number,
                "ok": bool(ok),
                "message": str(message) if message is not None else "",
                "error": None if (error is None or str(error).strip() == "") else str(error),
                "step_return_data": step_return_data,  # must be JSON-serializable
                "started_at": start_time,
                "ended_at": datetime.now().isoformat(),
                "run_id": CURRENT_TIMESTAMP
            })

    
    
    # store refresh token for next run_id (each run_id has one refresh token)
    start_time = datetime.now().isoformat()
    token_details = {"refreshtoken":refresh_token}
    add_step("fetch_refresh_token",step_order.get('fetch_refresh_token'), True, f"Refresh_token generated succesfully: {refresh_token[:5]}",None,token_details)


    start_time = datetime.now().isoformat()
    try:
        param_result = validate_and_build_params(company_name, fiscal_month, fiscal_year, wbs_blank, COMPANY_CODE_MAPPING)
        if not param_result["ok"]:
            raise Exception(param_result["status"])
        params= param_result['data']
        add_step("validate_and_build_params",step_order.get('validate_and_build_params'), True, "Input Params Validated successfully")
    except Exception as e:
        err_msg = None
        if "param_result" in locals() and isinstance(param_result, dict) and "status" in param_result:
            err_msg = param_result["status"]
        else:
            err_msg = str(e)
        add_step("validate_and_build_params",step_order.get('validate_and_build_params'), False, "Input Params Validation Failed", err_msg)
        return step_results  
    

    print("Financial Closing Parameters")
    print("-" * 45)
    print(f"Company Name            : {params['company_name']}")
    print(f"Company Code            : {params['company_code']}")
    print(f"Fiscal Year             : {params['fiscal_year']}")
    print(f"Fiscal Month            : {params['month_name']}")
    print(f"Fiscal Period Number    : {params['fiscal_period']}")
    print(f"Fiscal Year Label       : {params['fiscal_label']}")
    print(f"WBS Blank Flag          : {params['wbs_blank']}")
    print("-" * 45)

    query = QUERY_TEMPLATE.substitute(params)
    
    # get snowflake TB data
    start_time = datetime.now().isoformat()
    try:
        print(f"Fetching data from Snowflake starts")
        sf_result = query_snowflake(query)
        if not sf_result['ok']:
            raise Exception(sf_result["status"])
        add_step("query_snowflake",step_order.get('query_snowflake'), True, sf_result["status"])
        op_df = sf_result["data"]
    except Exception as e:
        add_step("query_snowflake",step_order.get('query_snowflake'), False, "Fetching data from Snowflake failed", sf_result["status"])
        return step_results

    # generate the file object
    start_time = datetime.now().isoformat()
    try:
        print(f"File generation starts")
        generate_file_result = generate_file(op_df,params['company_code'],params['month_name'],params['fiscal_label'],params['wbs_blank'])
        if not generate_file_result['ok']:
            raise Exception(generate_file_result["status"]) 
        file_name,file_object = generate_file_result['data']
        file_details =  {"filename":file_name,"fileobject":file_object}
        add_step("generate_file_result",step_order.get('generate_file'), True, f"File generation Success: {file_name}",None,file_details)
    except Exception as e:
        add_step("generate_file_result",step_order.get('generate_file'), False, "File generation Failed", generate_file_result["status"])
        return step_results


    headers = {"Authorization":f"Bearer {access_token}"}
    
    # delete folder files
    try:
        print(f"Delete folder files starts")
        del_result = delete_folder_files(headers,INBOX_FOLDER,SAP_FOLDER)
        if not del_result['ok']:
            raise Exception(del_result)
        add_step("delete_folder_files",step_order.get('delete_folder_files'), True, f"Files Deletion SUCCESS: {del_result}")    
    except Exception as e:
        add_step("delete_folder_files", step_order.get('delete_folder_files'),False, "Files Deletion FAILED", del_result)
        return step_results
    
    # upload File
    try:
        print(f"Upload File starts for {file_name}")
        upload_result = upload_file(access_token,file_name,file_object,INBOX_FOLDER,SAP_FOLDER)
        if not upload_result['ok']:
            raise Exception(upload_result)
        add_step("upload_file",step_order.get('upload_file'), True, f"Upload File SUCCESS: {file_name} {upload_result}")    
    except Exception as e:
        add_step("upload_file",step_order.get('upload_file'), False, "Upload File FAILED", upload_result)
        return step_results

    # Clear TB
    try:
        print(f"Run Clear TB starts for {params['company_code']}")
        clear_tb_result = run_business_rule(headers,params,CLEAR_TB_JOB,APPLICATION,CLEAR_TB_POLL_TIME,CLEAR_TB_TIMEOUT_S)
        if not clear_tb_result['ok']:
            raise Exception(clear_tb_result)
        add_step("run_business_rule: FIN_Clear TB",step_order.get('run_business_rule: FIN_Clear TB'), True, f"Clear TB SUCCESS: {clear_tb_result}")    
    except Exception as e:
        add_step("run_business_rule: FIN_Clear TB",step_order.get('run_business_rule: FIN_Clear TB'), False, "Clear TB FAILED", clear_tb_result)
        return step_results

    # Data Rule
    try:
        print(f"Run Data Rule starts for {params['company_name']}")
        data_rule_result = run_data_rule(headers,params,file_name,DATARULE_POLL_TIME,DATARULE_TIMEOUT_S)
        if not data_rule_result['ok']:
            raise Exception(data_rule_result)
        add_step("run_data_rule",step_order.get('run_data_rule'), True, f"Data Rule SUCCESS: {data_rule_result}")    
    except Exception as e:
        add_step("run_data_rule",step_order.get('run_data_rule'), False, "Data Rule FAILED", data_rule_result)
        return step_results
    
    # Run Fin Aggregations (last step)
    try:
        print(f"Run FIN_Aggregate starts for {params['company_code']}")
        fin_aggr_result = run_business_rule(headers,params,FIN_AGGREGATE_JOB,APPLICATION,FIN_AGGREGATE_POLL_TIME,FIN_AGGREGATE_TIMEOUT_S)
        if not fin_aggr_result['ok']:
            raise Exception(fin_aggr_result)
        add_step("run_business_rule: FIN_Aggregate",step_order.get('run_business_rule: FIN_Aggregate'), True, f"FIN_Aggregate SUCCESS: {fin_aggr_result}")    
    except Exception as e:
        add_step("run_business_rule: FIN_Aggregate",step_order.get('run_business_rule: FIN_Aggregate'), False, "FIN_Aggregate FAILED", fin_aggr_result)
        return step_results
    
    return step_results


def main(company_name, fiscal_month, fiscal_year, env,wbs_blank):
    global URL 
    URL = urls.get(env, urls["TEST"])

    print(f"Running for environment: {env}")  
    
    all_results = []
    fileName = f'Oracle_TB_Load_Audit_{CURRENT_TIMESTAMP}_.csv'
    db,schema = os.environ["SNOWFLAKE_LZ"],"STATIC_OBJECTS"
    print("Retrieving new token starts...")
    
    _res = rotate_refresh_token(db,schema,AUDIT_TABLE,env)
    if not _res["ok"]:
        raise RuntimeError(_res["status"])
    access_token, refresh_token = _res["data"]
    print("Retrieving new token ends...")
    
    companies = (COMPANY_CODE_MAPPING.keys() if company_name == 'ALL' else [company_name])
    for company in companies:
        print(f'Running for Company - {company}')
        step_res = run_tb_load(company, fiscal_month, fiscal_year, wbs_blank,refresh_token,access_token)  # -> list[tuple]
        all_results.extend(step_res)

    final_audit_df = pd.DataFrame(all_results)
    final_audit_df["ENV"] = env
    processed_files = get_generated_files(all_results)
    
    final_audit_df['step_return_data'] = final_audit_df['step_return_data'].apply(to_json_or_none)
    sf_msg = putSnowflakeDataFrame(db, schema, AUDIT_TABLE, final_audit_df, fileName, api_call_datetimestamp, len(final_audit_df))

    if "FAIL_SIGNAL" in sf_msg:
            raise Exception(sf_msg)
    

    failed_df = final_audit_df.loc[~final_audit_df["ok"], ["company_name", "message", "error", "run_id"]]
    if len(failed_df) > 0:
        html_table = failed_df.to_html(index=False, border=1, justify="center")
        mail_msg = 'Failed for the below:'
    else:
        html_table = ''
        mail_msg = 'TB Load successfully completed.'

    send_email_to = SEND_EMAILS_TO.get(env, SEND_EMAILS_TO["TEST"])
    sendEmail(
                'BI.Production-Alert-no-reply@us.tel.com',
                to_email = send_email_to,
                cc=[''],
                subject =f'{env}: TB LOAD for {fiscal_month}-{fiscal_year} | Company: {company_name}',
                email_content=f'''
                <body>
                    <p>Hi Team,</p>
                    <p>Status for TB Load:</p>
                    <p>{mail_msg}</p>
                    {html_table}
                    <p>Thanks,<br>BI-Prod-Support<br></p>
                </body>
                ''',
                attachments = processed_files
                    )
    
    if len(failed_df) > 0:
        _failed = failed_df.to_dict(orient="records")
        raise Exception(f'TB Load process failed for {_failed}')

    print(mail_msg)



    

if __name__ == "__main__":
    args = sys.argv[1:]
    company_name:str = args[0]
    fiscal_month:str = args[1] 
    fiscal_year:str = args[2]
    env:str = args[3]
    # company_name = "TVC"
    # fiscal_month = '10'
    # fiscal_year = '2025'
    main(company_name, fiscal_month, fiscal_year,env, wbs_blank='Y')