import fnmatch
from include.Python.TELTools import getAzureSecret, putSnowflakeDataFrame, readControlTable, loadControlTable
from datetime import datetime
import json
import os
import re
import requests
import io
import pandas as pd
import sys
from msal import ConfidentialClientApplication


api_call_datetimestamp = datetime.now()
LZ_DB = os.environ["SNOWFLAKE_LZ"]
RUN_TIME = (
    str(api_call_datetimestamp).replace(" ", "_").replace(":", "_").replace(".", "_")
)
CURRENT_TIMESTAMP = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
script_dir = os.path.dirname(__file__)
CONN_CONFIG_PATH = os.path.abspath(os.path.join(script_dir, "..", "Configuration", "TelTools_MSGraph.json"))

def getGraphToken(client_id, client_secret, tenant_id, oauth_url):
    authority = f"{oauth_url}/{tenant_id}"
    cca = ConfidentialClientApplication(
        client_id, authority=authority, client_credential=client_secret
    )
    scopes = ["https://graph.microsoft.com/.default"]

    try:
        result = cca.acquire_token_for_client(scopes=scopes)
        if "access_token" in result:
            access_token = result.get("access_token")
            return {
                "status": True,
                "message": "Access token generated successfully",
                "data": access_token,
            }
        else:
            return {
                "status": False,
                "message": f"Error generating token: {result}",
                "data": None,
            }
    except Exception as e:
        return {
            "status": False,
            "message": f"Error generating access token: {str(e)}",
            "data": None,
        }

def update_control_table(CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,sf_db,sf_schema,sf_table_name,
                       MAX_FILE_DATE,row_count):
    
    try:
        messages = loadControlTable(sf_db,sf_schema,CURRENT_TIMESTAMP,Incremental_Start_Value,Incremental_End_Value,Extraction_Start_Time,Extraction_End_Time,
                                       sf_table_name,MAX_FILE_DATE,row_count)
        status,status_msg= 1,f'TT.loadControlTable(): {messages}'
        
    except Exception as e:
        status,status_msg= 0,f'TT.loadControlTable(): {messages}'

    return status,status_msg

def buildGraphURL(
    base_url,
    resource_type,
    resource_id=None,
    subresource=None,
    extra_path=None,
    params=None,
):
    #final url: #{base_url}/{resource_type}/{resource_id}/{subresource}/{extra_path}?{key}={value}
    url = f"{base_url}/{resource_type}"

    if resource_id:
        url += f"/{resource_id}"
    if subresource:
        url += f"/{subresource}"
    if extra_path:
        url += f"/{extra_path}"
    if params:
        query_string = "&".join([f"{key}={value}" for key, value in params.items()])
        url += f"?{query_string}"
    
    return url


def requestGraphData(url, headers):
    try:
        df_final = []
        while url:
            response = requests.get(url, headers=headers)
            status_code = response.status_code
            if status_code == 200:
                msg = f"Successful API Call: {status_code}"
                json_load = response.json()
                df_final.extend(json_load["value"])
                # df_temp = pd.DataFrame(json_load['value'])
                # df_final = pd.concat([df_final, df_temp], ignore_index=True)
                url = json_load.get("@odata.nextLink")
            else:
                msg = f"Error: Unexpected status code {status_code}"
                return {"status": False, "message": msg, "data": None}
        return {"status": True, "message": msg, "data": df_final}
    except Exception as e:
        msg = f"Error requesting MS Graph API: {str(e)}"
        return {"status": False, "message": msg, "data": None}
    
def match_by_pattern(filename,filepattern):
    return fnmatch.fnmatch(filename, filepattern)

def load_config(config_file):
    """Load the configuration from a JSON file."""
    try:
        with open(config_file, "r", encoding="utf-8") as f:
            config = json.load(f)
        return {
            "status": True,
            "message": "Configuration loaded successfully",
            "data": config,
        }
    except Exception as e:
        return {
            "status": False,
            "message": f"Error loading configuration file: {e}",
            "data": None,
        }

def get_resource(config, resource_name, item_name=None):
    """
    Args:
        config (dict): The main configuration dictionary.
        resource_name (str): The name of the resource to fetch, like 'get_user' or 'get_group_members'.
        item_name (str, optional): The nested item to fetch within a resource (e.g., within 'get_list_items' fetch GOOD_CATCH_TRACKER).
    Returns:
        list of dict: The specified resource or item details.
    """
    resources = config.get("ms_graph").get("resources")
    resource = resources.get(resource_name)

    if item_name:
        resource = [item for item in resource if item.get("name") == item_name]

    return resource


def get_connectors(config):
    return tuple(
        config.get("ms_graph", {}).get("connectors", {}).get(key)
        for key in ["base_url", "tenant_id", "client_id", "oauth_url", "client_secret"]
    )


def get_api_resources(config):
    return tuple(
        config.get(key)
        for key in [
            "resource_type",
            "resource_id",
            "subresource",
            "extra_path",
            "params",
            "required_resource",
            "target_details",
            "handler",
            "filename",
            "sheet_no",
            "has_header"
        ]
    )


def post_to_snowflake(sf_db, sf_schema, sf_table, json_list, file_name, row_count):
    # file_config = file_uploader_json.get(cds_view)
    db = sf_db
    schema = sf_schema
    tableName = sf_table
    messages = [f"post_to_snowflake() method failed for {file_name}"]
    try:
        messages = putSnowflakeDataFrame(
            db,
            schema,
            tableName,
            json_list,
            file_name,
            api_call_datetimestamp,
            row_count,
        )
        if "FAIL_SIGNAL" in messages:
            return False, messages
        else:
            return True, messages
    except Exception as e:
        messages.append(e)
        return False, messages


def handle_file_download(
    section_name,
    resource_type,
    resource_id,
    subresource,
    extra_path,
    params,
    headers,
    base_url,
    filename,
    sheet_no,
    has_header,
    tgt_schema, tgt_table
):
    """Handles requests for downloading files. 
    It sends a request to retrieve the download link 
    and then uses this link to fetch the actual file data."""

    incremental_End_Value = '19000101'
    audit_log = []
    graph_endpoint = buildGraphURL(
        base_url, resource_type, resource_id, subresource, extra_path, params
    )
    api_result = requestGraphData(graph_endpoint, headers)
    # search from control
    # check if  incremental_field > end datetime
    # if true do below else exit
    if not api_result.get("status"):
        audit_log.append(
            {
                "name": section_name,
                "status": "FAIL",
                "message": api_result.get("message", "Unknown error from API."),
            }
        )
        return None, audit_log, None
    
    final_api_load = None
    #download_link = api_result["data"][0].get("@microsoft.graph.downloadUrl")
    section_lastModifiedDateTime = None
    for item in api_result["data"]:
        name = item["name"]
        if name==filename:
            section_lastModifiedDateTime = item["lastModifiedDateTime"]
            # Read control table
            runtimeConfig, _msg = readControlTable(LZ_DB, tgt_schema, tgt_table)
            if runtimeConfig:
                incremental_End_Value = runtimeConfig

            if section_lastModifiedDateTime > incremental_End_Value:
                download_link =  item["@microsoft.graph.downloadUrl"]
                if not download_link:
                    audit_log.append(
                        {
                            "name": section_name,
                            "status": "FAIL",
                            "message": "Download link missing in API response.",
                        }
                    )
                    return None, audit_log, None
                
                response = requests.get(download_link, headers=headers)

                if response.status_code != 200:
                    audit_log.append(
                        {
                            "name": section_name,
                            "status": "FAIL",
                            "message": f"File download failed: {response.reason}",
                        }
                    )
                    return None, audit_log, None
                try:
                    if '.xl' in name:
                        if sheet_no is None:
                            sheet_no = 0
                        if has_header == False: 
                            header_row = None
                        else:
                            header_row = 0
                        excel_data = io.BytesIO(response.content)
                        data_load = pd.read_excel(excel_data, sheet_name=sheet_no,header=header_row,dtype=str)   
                    else:
                        data_load = pd.read_csv(io.StringIO(response.content.decode('utf-8'))) 
                    
                    final_api_load = json.loads(data_load.to_json(orient='records')) 
                    #clean bad file the file headers
                    final_api_load = [
                        {key.replace("\n", ""): value for key, value in d.items()}
                        for d in final_api_load
                    ]
                    incremental_End_Value = section_lastModifiedDateTime
                    audit_log.append(
                        {
                            "name": section_name,
                            "status": "SUCCESS",
                            "message": "File downloaded and processed successfully.",
                        }
                    )
                    return final_api_load, audit_log,incremental_End_Value
                except Exception as e:
                    audit_log.append(
                        {
                            "name": section_name,
                            "status": "FAIL",
                            "message": f"Error processing file: {str(e)}",
                        }
                    )
                    return None, audit_log, None
            else:
                audit_log.append(
                    {
                        "name": section_name,
                        "status": "Success",
                        "message": f"No new file for: {section_name}. Last Timestamp for the file: {section_name} is {section_lastModifiedDateTime}",
                    }
                )
                return None, audit_log, None
    if final_api_load is None:
        audit_log.append(
            {
                "name": section_name,
                "status": "Success",
                "message": f"No Incoming file : {section_name}",
            }
        )
        return None, audit_log, None

def handle_file_download_by_pattern(
    section_name,
    resource_type,
    resource_id,
    subresource,
    extra_path,
    params,
    headers,
    base_url,
    filename,
    sheet_no,
    has_header,
    tgt_schema, tgt_table
):
    """Handles requests for downloading files. 
    It sends a request to retrieve the download link 
    and then uses this link to fetch the actual file data."""

    incremental_End_Value = '19000101'
    audit_log = []
    graph_endpoint = buildGraphURL(
        base_url, resource_type, resource_id, subresource, extra_path, params
    )
    api_result = requestGraphData(graph_endpoint, headers)
    # search from control
    # check if  incremental_field > end datetime
    # if true do below else exit
    if not api_result.get("status"):
        audit_log.append(
            {
                "name": section_name,
                "status": "FAIL",
                "message": api_result.get("message", "Unknown error from API."),
            }
        )
        return None, audit_log, None
    
    final_api_load = None
    #download_link = api_result["data"][0].get("@microsoft.graph.downloadUrl")
    section_lastModifiedDateTime = None
    matched_files=[]
    for item in api_result["data"]:
        name = item["name"]
        if fnmatch.fnmatch(name, filename):
            matched_files.append(item)

    if not matched_files:
        audit_log.append(
                        {
                            "name": section_name,
                            "status": "FAIL",
                            "message": f"No matched files exist",
                        }
                    )
        return None, audit_log, None
    matched_files.sort(key=lambda x:x.get("lastModifiedDateTime"), reverse=True)
    
    item= matched_files[0]
    print(item)
    section_lastModifiedDateTime = item["lastModifiedDateTime"]
    # Read control table
    runtimeConfig, _msg = readControlTable(LZ_DB, tgt_schema, tgt_table)
    if runtimeConfig:
        incremental_End_Value = runtimeConfig

    if section_lastModifiedDateTime > incremental_End_Value:
        download_link =  item["@microsoft.graph.downloadUrl"]
        if not download_link:
            audit_log.append(
                {
                    "name": section_name,
                    "status": "FAIL",
                    "message": "Download link missing in API response.",
                }
            )
            return None, audit_log, None
        
        response = requests.get(download_link, headers=headers)

        if response.status_code != 200:
            audit_log.append(
                {
                    "name": section_name,
                    "status": "FAIL",
                    "message": f"File download failed: {response.reason}",
                }
            )
            return None, audit_log, None
        try:
            if '.xl' in name:
                if sheet_no is None:
                    sheet_no = 0
                if has_header == False: 
                    header_row = None
                else:
                    header_row = 0
                excel_data = io.BytesIO(response.content)
                data_load = pd.read_excel(excel_data, sheet_name=sheet_no,header=header_row,dtype=str)   
            else:
                data_load = pd.read_csv(io.StringIO(response.content.decode('utf-8'))) 
            
            final_api_load = json.loads(data_load.to_json(orient='records')) 
            #clean bad file the file headers
            final_api_load = [
                {key.replace("\n", ""): value for key, value in d.items()}
                for d in final_api_load
            ]
            incremental_End_Value = section_lastModifiedDateTime
            audit_log.append(
                {
                    "name": section_name,
                    "status": "SUCCESS",
                    "message": "File downloaded and processed successfully.",
                }
            )
            return final_api_load, audit_log,incremental_End_Value
        except Exception as e:
            audit_log.append(
                {
                    "name": section_name,
                    "status": "FAIL",
                    "message": f"Error processing file: {str(e)}",
                }
            )
            return None, audit_log, None
    else:
        audit_log.append(
            {
                "name": section_name,
                "status": "Success",
                "message": f"No new file for: {section_name}. Last Timestamp for the file: {section_name} is {section_lastModifiedDateTime}",
            }
        )
        return None, audit_log, None
    if final_api_load is None:
        audit_log.append(
            {
                "name": section_name,
                "status": "Success",
                "message": f"No Incoming file : {section_name}",
            }
        )
        return None, audit_log, None
      
def handle_chained_call(
    section_name,
    resource_type,
    resource_id,
    subresource,
    extra_path,
    params,
    required_resource,
    headers,
    base_url,
):
    """The chained API call handler is used when multiple API calls need to 
        be performed sequentially. It uses the response from the first API call 
        to build or modify the request for the next API call."""
    
    audit_log = []
    final_api_load = []

    rr_resource_type = required_resource.get("resource_type")
    rr_resource_id = required_resource.get("resource_id")
    rr_subresource = required_resource.get("subresource")
    rr_extra_path = required_resource.get("extra_path")
    rr_params = required_resource.get("params")
    return_param = required_resource.get("return_param")

    print(f"Fetching required_resource for {section_name} to get {return_param}")

    graph_endpoint = buildGraphURL(
        base_url=base_url,
        resource_type=rr_resource_type,
        resource_id=rr_resource_id,
        subresource=rr_subresource,
        extra_path=rr_extra_path,
        params=rr_params,
    )

    rr_api_result = requestGraphData(graph_endpoint, headers)
    
    if rr_api_result["status"]:
        required_vals = [
            item.get(return_param)
            for item in rr_api_result["data"]
            if return_param in item
        ]

        for val in required_vals:
           
            graph_endpoint = buildGraphURL(
                base_url,
                resource_type,
                resource_id,
                subresource,
                extra_path,
                params,
            )

            graph_endpoint = re.sub(r"\{.*?\}", val, graph_endpoint)
            api_result = requestGraphData(graph_endpoint, headers)
            
            if api_result["status"]:
                if api_result["data"]:
                    required_val = f"{resource_type}_{return_param}"                
                for element in api_result["data"]:
                    element[required_val] = val

                final_api_load.extend(api_result["data"])
               
            else:
                final_api_load = None
                audit_log.append(
                    {
                        "name": section_name,
                        "status": "FAIL",
                        "message": f"Failed for handle_chained_call:{api_result['message']}",
                    }
                )
                break

        audit_log.append(
            {
                "name": section_name,
                "status": "SUCCESS",
                "message": api_result["message"],
            }
        )
    else:
        final_api_load = None
        audit_log.append(
            {
                "name": section_name,
                "status": "FAIL",
                "message": f"rr_api_result: {rr_api_result['message']}",
            }
        )

    return final_api_load, audit_log


def handle_simple_call(
    section_name,
    resource_type,
    resource_id,
    subresource,
    extra_path,
    params,
    headers,
    base_url,
):
    """The simple API call handler is used for single, 
    straightforward API requests and responses"""
    
    audit_log = []

    graph_endpoint = buildGraphURL(
        base_url, resource_type, resource_id, subresource, extra_path, params
    )

    api_result = requestGraphData(graph_endpoint, headers)

    if api_result["status"]:
        final_api_load = api_result["data"]
        audit_log.append(
            {
                "name": section_name,
                "status": "SUCCESS",
                "message": api_result["message"],
            }
        )
    else:
        final_api_load = None
        audit_log.append(
            {
                "name": section_name,
                "status": "FAIL",
                "message": f"Failed for handle_simple_call {api_result['message']}",
            }
        )

    return final_api_load, audit_log


def main(resource_name, specific_resource=None):
    # get config
    ms_config_result = load_config(
        CONN_CONFIG_PATH
    ) 
    if not ms_config_result["data"]:
        raise Exception("Failed to load Graph Config")
    print("MS Graph json config loaded successfully.")

    # get resources to be processed
    ms_config = ms_config_result["data"]
    resource = get_resource(ms_config, resource_name, specific_resource)
    
    base_url, tenant_id, client_id, oauth_url, client_secret = get_connectors(ms_config)
    client_secret = getAzureSecret(client_secret).value

    # get token
    token_result = getGraphToken(client_id, client_secret, tenant_id, oauth_url)
    if not token_result["status"]:
        raise Exception(f"Failed for getGraphToken: {token_result['message']}")
    print("Access Token generated.")
    headers = {"Authorization": f'Bearer {token_result["data"]}'}

    final_audit = []
    incremental_Start_Value = CURRENT_TIMESTAMP
    for section in resource:
        section_name = section.get("name")
        print(f"getMSGraphData starts for {section.get('name')}")
        (
            resource_type,
            resource_id,
            subresource,
            extra_path,
            params,
            required_resource,
            target_details,
            handler,
            filename,
            sheet_no,
            has_header
        ) = get_api_resources(section)
        tgt_schema, tgt_table = target_details["schema"], target_details["table"]

        if handler == "handle_file_download":
            print("Entering download url handler")
            extraction_Start_Time = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            final_api_load, msg,incremental_End_Value  = handle_file_download(
                section_name,
                resource_type,
                resource_id,
                subresource,
                extra_path,
                params,
                headers,
                base_url,
                filename,
                sheet_no,
                has_header,
                tgt_schema, tgt_table
            )
            extraction_End_Time = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
        elif handler == "handle_file_download_by_pattern":
            print("Entering download url handler")
            extraction_Start_Time = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
            final_api_load, msg,incremental_End_Value  = handle_file_download_by_pattern(
                section_name,
                resource_type,
                resource_id,
                subresource,
                extra_path,
                params,
                headers,
                base_url,
                filename,
                sheet_no,
                has_header,
                tgt_schema, tgt_table
            )
            extraction_End_Time = str(datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
        elif handler == "handle_chained_call":
            print("Entering required resource chained handler")
            final_api_load, msg = handle_chained_call(
                section_name,
                resource_type,
                resource_id,
                subresource,
                extra_path,
                params,
                required_resource,
                headers,
                base_url,
            )

        else:
            print("Entering normal handler")
            final_api_load, msg = handle_simple_call(
                section_name,
                resource_type,
                resource_id,
                subresource,
                extra_path,
                params,
                headers,
                base_url,
            )

        if final_api_load:
            print(f"API Handler Processing complete, preparing for Snowflake ingestion")
            json_list = final_api_load
            row_count = len(json_list)
            file_name = f"{tgt_table}-{RUN_TIME}.json"
        
            db_load_success, db_messages = post_to_snowflake(
                LZ_DB, tgt_schema, tgt_table, json_list, file_name, row_count
            )

            if db_load_success:
                print("Succesfully loaded in Snowflake")
                msg.append(
                    {"name": section_name, "status": "SUCCESS", "message": db_messages}
                )
                # load control table, for now only for  "handle_file_download":
                if handler == "handle_file_download":
                    control_table_status,control_table_status_msg= update_control_table(
                        CURRENT_TIMESTAMP,
                        incremental_Start_Value,
                        incremental_End_Value,
                        extraction_Start_Time,
                        extraction_End_Time,
                        LZ_DB,
                        tgt_schema,
                        tgt_table,
                        CURRENT_TIMESTAMP,
                        row_count)
                    if control_table_status ==0:
                        msg.append(
                            {"name": section_name, "status": "FAIL", "message": control_table_status_msg}
                        )
                if handler == "handle_file_download_by_pattern":
                    control_table_status,control_table_status_msg= update_control_table(
                        CURRENT_TIMESTAMP,
                        incremental_Start_Value,
                        incremental_End_Value,
                        extraction_Start_Time,
                        extraction_End_Time,
                        LZ_DB,
                        tgt_schema,
                        tgt_table,
                        CURRENT_TIMESTAMP,
                        row_count)
                    if control_table_status ==0:
                        msg.append(
                            {"name": section_name, "status": "FAIL", "message": control_table_status_msg}
                        )
            else:
                print("Failed to loaded in Snowflake")
                msg.append(
                    {"name": section_name, "status": "FAIL", "message": db_messages}
                )
        else:
            print(f"{handler} process : {msg}")
        
        final_audit.extend(msg)
        
    
    #pass_status = [stat for stat in msg if stat.get("status") == "PASS"]
    fail_status = [stat for stat in final_audit if stat.get("status") == "FAIL"]
    print(final_audit)
    if fail_status:
        raise Exception(f"getMSGraphData Failed: {fail_status}")
    
if __name__ == "__main__":
    args = sys.argv[1:]
    resource_name:str = args[0]
    specific_resource:str = args[1] if len(args) > 1 else None
    main(resource_name,specific_resource)
