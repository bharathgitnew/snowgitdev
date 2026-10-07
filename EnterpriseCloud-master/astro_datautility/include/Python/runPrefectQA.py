import json
from runPrefectFlow import main as run_flow
from datetime import date

empty_json = """{
    "lz_to_ods": [],
    "ods_to_pub": [],
    "ods_to_common": [],
    "common_to_pub": [],
    "others": [
        {"version_group_id": "dummy", "parameters": "{'key': 'value'}"}
    ]
}"""


def main():
    file_path = "\\\\Telusdwappdev\\f$\\Shares\\Files\\TokyoElectron\\Python\\RuntimeConfig\\prefect.QA_Driver.json"
    with open(file_path, 'r') as f:
        manual_runs = json.loads(f.read())
    
    dbt_flows = {
        'lz_to_ods': "QA.DBT.LZ-ODS.CommandExecution",
        'ods_to_pub': "QA.DBT.ODS-PUB.CommandExecution",
        'ods_to_common': "QA.DBT.ODS-Common.CommandExecution",
        'common_to_pub': "QA.DBT.Common-PUB.CommandExecution"
    }
    
    for dbt_project, version_group_id in dbt_flows.items():
        print('\nStarting flow '+dbt_project)
        selection = ' '.join(manual_runs[dbt_project])
        if selection:
            parameters = f"{{'Command': 'dbt run --select {selection}'}}"
            run_flow(version_group_id, parameters)
    
    for flow in manual_runs['others']:
        version_group_id, parameters = flow.values()
        if version_group_id != 'dummy':
            print('\nStarting flow '+version_group_id)
            run_flow(version_group_id, parameters)

    if date.today().weekday() == 4:
        with open(file_path, 'w') as f:
            f.write(empty_json)


if __name__ == "__main__":
    main()