import sys
import prefect
import include.Python.TELTools as TT
import ast

def main(prefect_flow):
     #Pass the API Key for Prefect Connection from Key Vault
    prefect_api_key=TT.getAzureSecret('PREFECT-API-KEY').value
    client=prefect.Client(api_key=prefect_api_key)
    # create flow run from version_group_id
    print('Cancelling flow run...')
    status = client.cancel_flow_run(flow_run_id=prefect_flow)
    print('Flow Run Status:'+ status)


if __name__ == "__main__":
    args = sys.argv[1:]
    prefect_flow:str = args[0]
    print("Cancelling Prefect flow: " + prefect_flow)
    # set vars, call main
    main(prefect_flow)