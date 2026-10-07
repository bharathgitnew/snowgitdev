import requests
import warnings
import base64
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame, compact_dict
import json
from datetime import datetime, timedelta
import snowflake.connector as snow
import io
import zipfile
warnings.filterwarnings('ignore')
import os


def Get_Ariba_Auth_Token(realm : str):

    try:
        OAuthURL = getAzureSecret('ARIBA-OAUTH-URL').value
        OAuthClientId = getAzureSecret(f'ARIBA-OAUTH-CLIENT-ID-{realm.upper()}').value
        OAuthClientSecret = getAzureSecret(f'ARIBA-OAUTH-CLIENT-SECRET-{realm.upper()}').value

    except Exception as e :
        raise ValueError(f'Fetching Credentials from Key-Vault, Exception : {str(e)}')
  
    try:
        OAuthToken = f"{OAuthClientId}:{OAuthClientSecret}"
        Base64Encoded =  base64.b64encode(OAuthToken.encode('utf-8')).decode('utf-8')

        headers = {
            'Authorization': f'Basic {Base64Encoded}',
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        body = {
            'grant_type': 'openapi_2lo'
        }

        response = requests.post(OAuthURL, headers=headers, data=body)

        if response.status_code == 200:
            token =  response.json().get('access_token', None)

            if token:
                return token
            
            else:
                raise ValueError('Access token not found in response.')

        else:
            raise ConnectionAbortedError(f'Failed to generate Access Token => Status Code {response.status_code}')
        
    except Exception as e:
        print(f"Failed to get Auth Token from AuthURL ==> {OAuthURL}")

def Read_Update_Run_Time_Config(snowflake_credentials: dict, method: str, content: dict = None):
    try:
        conn = snow.connect(
                **snowflake_credentials
            )

        cursor = conn.cursor()

    except Exception as e:
        print(f"Failed to connecto to SnowFlake ==> {str(e)}")

    if method == 'update':
        try:
            truncate_query = "TRUNCATE TABLE RUNTIMECONFIG"
            cursor.execute(truncate_query)
            
            json_data = json.dumps(content).replace("'", "\\'")
            insert_query = f"""
                INSERT INTO RUNTIMECONFIG (CONFIG)
                SELECT PARSE_JSON('{json_data}')
            """
            cursor.execute(insert_query)
            conn.commit()

        except Exception as e:
            print(f"An error in updating Run-time config: {e}")

        finally:
            cursor.close()
            conn.close()

    elif method == 'read':
        try:
            fetch_query = "SELECT CONFIG FROM RUNTIMECONFIG"
            cursor.execute(fetch_query)
            result = cursor.fetchone()
            if result:
                config_data = json.loads(result[0])
                return config_data
            else:
                print("No configuration found.")
                return None
            
        except Exception as e:
            print(f"An error occurred: {e}")

        finally:
            cursor.close()
            conn.close()

    else:
        raise ConnectionAbortedError(f"Unknown method '{method}'. Please use 'read' or 'update'.")


def Convert_Date(date, date_format: str = "datetime"):

    if isinstance(date, datetime):
        parsed_date = date

    elif isinstance(date, str):
        if date.endswith('Z'):
            date = date.rstrip("Z")

        try:
            parsed_date = datetime.strptime(date, "%Y-%m-%dT%H:%M:%S")
            
        except ValueError as e:
            raise ValueError(f"Invalid date format: {e}")
        
    else:
        raise TypeError("Date must be either a string or a datetime object")

    if date_format == "datetime":
        return parsed_date  
    
    elif date_format == "string":
        return parsed_date.strftime('%Y-%m-%dT00:00:00Z') 
    
    else:
        raise ValueError("Invalid type specified. Use 'datetime' or 'string'.")
    

def Get_Ariba_Job_Filters(job_content : dict):
    
    start_date = Convert_Date(job_content.get('LastSuccessfulEndDate'))

    end_date = datetime.now()

    for job_name, job_data in job_content.get('Jobs', {}).items():

        job_date = Convert_Date(job_data.get('filters').get('updatedDateTo'))

        if job_date > start_date:
            start_date = job_date

        days_behind = (datetime.now() - start_date).days

        if days_behind == 0:
            continue
        elif days_behind > 30:
            end_date = start_date + timedelta(days=30)
        elif days_behind > 7:
            end_date = start_date + timedelta(days=7)
        else:
            end_date = datetime.now()

    if (end_date - start_date).days:
        print(f"Number of days Behind =====> {(end_date - start_date).days}")

        return {
                "updatedDateFrom": Convert_Date(start_date,'string'),
                "updatedDateTo": Convert_Date(end_date,'string')
            }
    
    else:
        return {}


def Post_Ariba_Job_Requests(realm : str, view_name : str, job_object : dict, secure_credentials : dict):

    request_parameters = {'realm': realm}
    request_headers = {
        'accept': 'application/json',
        'Authorization': f"Bearer {secure_credentials.get('Token')}",
        'apiKey': secure_credentials.get('ApplicationKey'),
        'content-type': 'application/json'
    }

    request_body = {
        'viewTemplateName': view_name,
    }

    filters = job_object.get('filters')

    request_body['filters'] = filters
    
    # Ariba Rate Limits (Per Realm) : 1/second, 2/minute, 8/hour, 40/day

    try:
        response = requests.post(secure_credentials.get('AribaJobPostingURL'), json=request_body, headers=request_headers, params=request_parameters)
        response.raise_for_status()  

    except requests.exceptions.RequestException as e:
        return {
            'job_id': None,
            'job_object': job_object,
            'Error': f"API Call Failed for => {response.status_code}\nError Details: {str(e)}\nView Name: {view_name}\nRealm: {realm}"
        }

    result = response.json()

    job_object.update({
        'status': result.get('status'),
        'createdDate': result.get('createdDate')
    })

    return {
        'job_id': result.get('jobId'),
        'job_object': job_object
    }


def Ariba_Check_Job_Status(job_id : str, realm_name : str, secure_credentials: dict):
    base_url = secure_credentials.get('AribaJobResultsURL')
    job_url = f"{base_url}/{job_id}"

    request_parameters = {'realm': realm_name}

    request_headers = {
        'accept': 'application/json',
        'Authorization': f"Bearer {secure_credentials.get('Token')}",
        'apiKey': secure_credentials.get('ApplicationKey'),
        'content-type': 'application/json'
    }

    try:
        response = requests.get(job_url, headers=request_headers, params=request_parameters)
        response.raise_for_status()
        result = response.json()
        return result
    
    except requests.exceptions.RequestException as e:
        return {
            'status': 'PythonError',
            'error' :  str(e)
        }
    

def Get_Ariba_Files(job_id : str, realm_name : str, secure_credentials : dict, job_object : dict):
    files_content = []

    request_parameters = {'realm': realm_name}
    request_headers = {
        'Authorization': f"Bearer {secure_credentials.get('Token')}",
        'apiKey': secure_credentials.get('ApplicationKey')
    }

    files = job_object.get('files',[])
    job_complete_date = job_object.get('completedDate',None)

    for file in files:
    
        job_url = f"{secure_credentials.get('AribaJobResultsURL')}/{job_id}/files/{file}"

        try:
            response = requests.get(job_url, headers=request_headers, params=request_parameters) 
            response.raise_for_status()
            if response.status_code == 200:
                    files_content.append((response.content,job_complete_date)) 
                
        except requests.exceptions.RequestException as e:
            raise ConnectionAbortedError(f"Failed to Fetch file Content ==> {str(e)}")

    print(f"sucessfully Fetched files for current Load with jobId : {job_id}")
    return files_content 


def Process_Ariba_Payload_And_Post_To_Snowflake(snowflake_connection : str, file_list : str, realm_name: str, table_name : str):

    for file,extract_timestamp in file_list:
        memory_zip = io.BytesIO()
        memory_zip.write(file)

        with zipfile.ZipFile(memory_zip, 'r') as zip_ref:
            files = zip_ref.namelist()
            for file in files:
                contents = zip_ref.read(file).decode('utf-8')
                payload = json.loads(contents)
                data = [{k: str(v) for k, v in compact_dict(d).items()} for d in payload]
                database = os.getenv('SNOWFLAKE_LZ')
                snowflake_file_name = f'{table_name.title()}.{realm_name}.json'

                print(f"Processing Ariba Load for {len(payload)} Number of Records")
                
                putSnowflakeDataFrame(
                    database, 
                    'ARIBA', 
                    table_name,
                    data,
                    snowflake_file_name,
                    extract_timestamp
                )

        memory_zip.flush()
        memory_zip.seek(0)
        memory_zip.close()


def Update_Config(connection_string, realm_name, JobDetails):

    RunTimeConfig = {
        'JobData': {realm_name: JobDetails}
    }
    try:
        Read_Update_Run_Time_Config(connection_string, 'update', RunTimeConfig)
    except Exception as e:
        raise ConnectionAbortedError(f"Error updating run-time config: {e}")