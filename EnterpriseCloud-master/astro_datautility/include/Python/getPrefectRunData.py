from pickle import TRUE
from urllib.parse import _ResultMixinStr
import prefect
from prefect.backend import FlowRunView, FlowView
import json
import pandas as pd
from datetime import datetime, timedelta, timezone
import include.Python.TELTools as TT
import os

RUN_TIME = datetime.now()
CURRENT_TIMESTAMP = str(RUN_TIME).replace(" ","_").replace(":","_").replace(".","_")
LZ_DB = os.environ["SNOWFLAKE_LZ"]
LZ_SCHEMA = "PREFECT"

def main():
    with open("/usr/local/airflow/include/Configuration/TelTools_Prefect.json", "r") as f:
        config = json.load(f)
        datasets = config.get('DataSets', {})
    
    # Pass the API Key for Prefect Connection by reading it from KeyVault
    prefect_api_key = TT.getAzureSecret("PREFECT-API-KEY").value
    assert prefect_api_key, "prefect_api_key returned nothing"
    client = prefect.Client(api_key=prefect_api_key)

    data,msg  = TT.readControlTable(LZ_DB,LZ_SCHEMA,None)
    if not data:
        raise Exception(f"Error while fetching Runtime Config from Control Table: {msg}")
    previous_date = datetime.strptime(data["curr_date"], "%Y-%m-%d %H:%M:%S.%f")
    previous_date = previous_date.replace(tzinfo=timezone.utc)
    prefect_time = datetime.now(tz=timezone.utc)

    # Logic to run for 10 min intervals
    prefect_time = prefect_time + timedelta(minutes=-1)
    pref_time = datetime.strftime(prefect_time, "%Y-%m-%dT%H:%M:%S.%f+00:00")
    current_date = previous_date + timedelta(minutes=1)
    curr_date = datetime.strftime(current_date, "%Y-%m-%dT%H:%M:%S.%f+00:00")
    Logging_date = datetime.strftime(previous_date, "%Y-%m-%d %H:%M:%S.%f")

    retries = 0
    while curr_date < pref_time and retries < 5:
        try:
            current_date = previous_date + timedelta(minutes=1)
            prev_date = datetime.strftime(previous_date, "%Y-%m-%dT%H:%M:%S.%f+00:00")
            curr_date = datetime.strftime(current_date, "%Y-%m-%dT%H:%M:%S.%f+00:00")
            file_date = datetime.strftime(current_date, "%Y-%m-%dT%H%M%S")

            print("Fetching Flows updated between " + prev_date + " & " + curr_date)
            # Build the Query for unloading data from Flow View
            flow_query_def = """
                query flow ($last_run: timestamptz, $curr_run: timestamptz) {
                    flow(where: {updated: {_gte: $last_run, _lte:$curr_run} }) {
                        id,
                        name,
                        description,
                        parameters,
                        run_config,
                        environment,
                        updated
                    }
                }
            """
            vars = {"last_run": prev_date, "curr_run": curr_date}
            flow_query = client.graphql(flow_query_def, variables=vars)

            # Write the JSON File for Flow Run View Data
            flow_results = flow_query.get("data", {}).get("flow")
            if flow_results:
                flow_config = datasets.get('FLOW', {})
                db = os.environ['SNOWFLAKE_LZ']
                schema = flow_config.get('SCHEMA')
                table_name = flow_config.get('TABLE')
                # converts prefect datatypes to standard python
                results_dict = json.loads(json.dumps(flow_query))
                file_name = f"Prefect_Flow_{file_date}.json"
                row_count = 1
                messages = TT.putSnowflakeDataFrame(db, schema, table_name, [results_dict], file_name, current_date, row_count)
                print(f"Uploaded {len(flow_results)} updated flows")

            print("Fetching Flow Runs for time between " + prev_date + " & " + curr_date)
            # Build the Query for unloading data from Flow Run View
            flow_run_query_def = """
                query flowRun ($last_run: timestamptz, $curr_run: timestamptz) {
                    flow_run(where: {updated: {_gte: $last_run, _lte: $curr_run}}) {
                        flow_id,
                                id,
                                name,
                                start_time,
                                end_time,
                                state,
                                state_message,
                                state_result,
                                state_start_time,
                                state_timestamp,
                                tenant_id,
                                times_resurrected,
                                updated,
                                version,
                                labels,
                                parameters
                    }
                }
            """
            vars = {"last_run": prev_date, "curr_run": curr_date}
            flow_runs_query = client.graphql(flow_run_query_def, variables=vars)

            # Write the JSON File for Flow Run View Data
            flow_run_results = flow_runs_query.get("data", {}).get("flow_run")
            if flow_run_results:
                flow_run_config = datasets.get('FLOW_RUN', {})
                db = os.environ['SNOWFLAKE_LZ']
                schema = flow_run_config.get('SCHEMA')
                table_name = flow_run_config.get('TABLE')
                # converts prefect datatypes to standard python
                results_dict = json.loads(json.dumps(flow_runs_query))
                file_name = f"PrefectFlowRun_{file_date}.json"
                row_count = 1
                messages = TT.putSnowflakeDataFrame(db, schema, table_name, [results_dict], file_name, current_date, row_count)
                print(f"Uploaded {len(flow_run_results)} updated Flow Runs")

            # Get logs for each flow run
            for flow_run in flow_run_results:
                flow_run_id = flow_run.id
                print(f"Fetching Logs from Flow Run {flow_run_id}")
                logs_query_def = """
                    query flowRun ($last_run: timestamptz, $curr_run: timestamptz, $id: uuid) {
                        flow_run(where: {id: {_eq: $id} })  { 
                            id,   
                            logs (where: {updated: {_gte: $last_run, _lte:$curr_run} }) {
                                message,
                                created
                            }
                        }
                    }
                """
                vars = {"last_run": prev_date, "curr_run": curr_date, "id": flow_run_id}
                logs_query = client.graphql(logs_query_def, variables=vars)

                log_results = logs_query.get("data", {}).get("flow_run")
                if log_results:
                    logs_config = datasets.get('LOGS', {})
                    db = os.environ['SNOWFLAKE_LZ']
                    schema = logs_config.get('SCHEMA')
                    table_name = logs_config.get('TABLE')
                    # converts prefect datatypes to standard python
                    results_dict = json.loads(json.dumps(logs_query))
                    file_name = f"PrefectFlowRun_{file_date}.json"
                    row_count = 1
                    messages = TT.putSnowflakeDataFrame(db, schema, table_name, [results_dict], file_name, current_date, row_count)

            previous_date = current_date

        except Exception as e:
            if (str(e)) == "prefect.exceptions.ClientError":
                print("Skipping the minute as it has some unprocessable values")
                previous_date = current_date
            else:
                print("Process Errored Out with Exception: " + str(e))
                retries += 1

    # Data to be written
    Logging_date = datetime.strftime(current_date, "%Y-%m-%d %H:%M:%S.%f")
    dictionary = {
        "curr_date": Logging_date,
    }
    EXTRACTION_END_TIME = datetime.now()
    
    load_control_table_status = TT.load_control_table(
        CURRENT_TIMESTAMP=CURRENT_TIMESTAMP,
        Incremental_Start_Value=str(data["curr_date"]),
        Incremental_End_Value=Logging_date,
        Extraction_Start_Time=str(RUN_TIME),
        Extraction_End_Time=str(EXTRACTION_END_TIME),
        table_name="curr_date",
        MAX_FILE_DATE=str(RUN_TIME),
        rows_loaded="na",
        schema=LZ_SCHEMA,
        db=LZ_DB
    )
    if load_control_table_status['status'] == False:
        raise Exception(f"Failed to update ControlTable: {load_control_table_status['message']}")
if __name__ == "__main__":
    main()
