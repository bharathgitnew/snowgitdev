import sys
import prefect
import include.Python.TELTools as TT
import ast
from datetime import datetime, timezone
import random
import os
import argparse
from dateutil import tz

def main(prefect_flow, parameters, scheduled_start_time=None, run_name=None):
    # Pass the API Key for Prefect Connection from Key Vault
    prefect_api_key = TT.getAzureSecret('PREFECT-API-KEY').value
    client = prefect.Client(api_key=prefect_api_key)
    if not scheduled_start_time:
        scheduled_start_time=None
    else:
        try:
            scheduled_start_time = datetime.fromisoformat(scheduled_start_time)
            scheduled_start_time = scheduled_start_time.replace(tzinfo=tz.tzutc())
            utcnow = datetime.now(timezone.utc)
            if scheduled_start_time > utcnow:
                local_dt = scheduled_start_time.astimezone(tz.tzlocal())
                print(f'Scheduling for {local_dt}.')
        except:
            scheduled_start_time=None
    if not run_name:
        pc_name = os.environ['COMPUTERNAME']
        num_tag = str(random.randint(1000, 9999))
        run_name = pc_name + '_' + num_tag
    else:
        run_name = run_name
    # create flow run from version_group_id
    print('Creating flow run...')
    flow_run_id = client.create_flow_run(version_group_id=prefect_flow, parameters=ast.literal_eval(parameters), scheduled_start_time=scheduled_start_time, run_name=run_name)
    print(f'Flow Run {run_name} created.')
    # Capture Flow Run State to keep track of the state of a flow (ex. If it has been submitted (scheduled), If it is running, if it failed, if it was successful. More info found here https://docs.prefect.io/core/concepts/states.html)
    print(f'Getting initial state for flow run {run_name}.')
    current_state = client.get_flow_run_state(flow_run_id)
    print(f'Flow run {flow_run_id} current state is {current_state}')
    link = f'https://cloud.prefect.io/tokyo-electron/flow-run/{flow_run_id}'
    print(f'Track the flow at {link}\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('prefect_flow', type=str)
    parser.add_argument('parameters', type=str)
    parser.add_argument('--scheduled', '-s', type=str)
    parser.add_argument('--name', '-n', type=str)
    args = parser.parse_args()

    prefect_flow = args.prefect_flow
    parameters = args.parameters
    scheduled_start_time = args.scheduled
    run_name = args.name

    print(f"Submitting Prefect flow: {prefect_flow}, parameters dict: {parameters}, scheduled_start_time: {scheduled_start_time}, Run Name: {run_name}")
    main(prefect_flow, parameters, scheduled_start_time, run_name)