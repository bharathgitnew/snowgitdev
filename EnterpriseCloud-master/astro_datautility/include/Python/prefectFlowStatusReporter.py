from pickle import TRUE
from urllib.parse import _ResultMixinStr
import prefect
from prefect.backend import FlowRunView, FlowView
import json
import pandas as pd
from datetime import datetime, timedelta, timezone
import include.Python.TELTools as TT
import os
import sys
import pytz

ENV = os.environ["SNOWFLAKE_ENV"]
email_body_template = """
                <html>
                <body>
                    <p>Hi Team,</p>
                    {msg}
                    <p>Thanks,<br>BI-Prod-Support<br></p>
                </body>
                </html>
                """

current_time = datetime.utcnow()

timezone = pytz.timezone("America/Chicago")
local_time = datetime.now(timezone)
local_time = local_time.strftime("%Y-%m-%d %H:%M:%S %z")

def query_flow_runs(flow_name, client):
    try:
        msg = ""
        flow_query = """query flowByName($name: String!) {
                                flow_run(where: {flow: {name: {_eq: $name}}}) {
                                    id
                                    name
                                    start_time
                                    end_time
                                    state
                                    state_message
                                    state_timestamp
                                    updated
                                    labels
                                    parameters
                                }
                                }"""

        vars = {"name": flow_name}
        query_op = client.graphql(flow_query, variables=vars)
        if not query_op or "data" not in query_op or not query_op["data"]["flow_run"]:
            prod_runs = []
            print("No data returned from the query.")
        else:
            print("Query successfully returned data.")
            results_dict = json.loads(json.dumps(query_op))
            prod_runs = [
                flow
                for flow in results_dict["data"]["flow_run"]
                if "TELUSDWAPPPROD" in flow["labels"]
            ]

        return prod_runs
    except Exception as e:
        raise (f"Failed to query flow runs for {flow_name}: {e}")


def check_flow(prod_runs, flow_name):
    print(f"Checking flow::: {flow_name}")
    try:
        triggered_today = False
        for run in prod_runs:
            start_time = datetime.fromisoformat(run["state_timestamp"])
            state = run["state"]
            if start_time.date() == current_time.date():
                start_time_central = start_time.astimezone(timezone)
                start_time_central = start_time_central.strftime("%Y-%m-%d %H:%M:%S %z")

                message = f"""{flow_name} succesfully triggered today at {start_time_central}.\n\nRun ID: {run['id']}\n\nFlow State: {state}\n\nmetadata: {run}"""
                html_msg = f"""{flow_name} succesfully triggered today at {start_time_central}.<br><br>Run ID: {run['id']}<br><br>Flow State: {state}<br><br>metadata:<br>{run}"""
                triggered_today = True
                print(message)
                if ENV.upper() == "PROD":
                    TT.sendEmail(
                        "BI.Production-Alert-no-reply@us.tel.com",
                        subject=f"Alert: {flow_name} - {state}",
                        email_content=email_body_template.format(msg=html_msg),
                    )
                break
        if not triggered_today:
            message = f"{flow_name} did not trigger as of {local_time}."
            print(message)
            # send a FAIL EMAIL
            if ENV.upper() == "PROD":
                TT.sendEmail(
                    "BI.Production-Alert-no-reply@us.tel.com",
                    subject=f"Alert: {flow_name} - PENDING",
                    email_content=email_body_template.format(msg=message),
                )

    except Exception as e:
        raise (f"Error checking flow trigger status for {flow_name}: {e}")


def main(flow_name):
    prefect_api_key = TT.getAzureSecret("PREFECT-API-KEY").value
    assert prefect_api_key, "prefect_api_key returned nothing"

    client = prefect.Client(api_key=prefect_api_key)

    prod_runs = query_flow_runs(flow_name, client)
    assert prod_runs, "query_flow_runs returned nothing"

    check_flow(prod_runs, flow_name)

    print("Flow run status check completed.")


if __name__ == "__main__":
    args = sys.argv[1:]
    flow_name = args[0]
    main(flow_name)
