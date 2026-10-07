import requests
import json
import base64
import include.Python.TELTools as TT
import sys

def main(pipelineID,branch):
    # Define the Azure DevOps organization and project
    ORGANIZATION_URL = 'https://dev.azure.com/tokyoelectron'
    PROJECT_NAME = 'EnterpriseDataWarehouse'

    # Define the pipeline ID and access token
    PIPELINE_ID = pipelineID
    PAT_TOKEN = TT.getAzureSecret("AZURE-DEVOPS-PIPELINES-PAT").value
    BRANCH = branch

    # Define the request URL and headers
    auth = str(base64.b64encode(bytes(':'+PAT_TOKEN, 'ascii')), 'ascii')
    url = f'{ORGANIZATION_URL}/{PROJECT_NAME}/_apis/pipelines/{PIPELINE_ID}/runs?api-version=6.0-preview.1'
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Basic {auth}'
    }

    # Define the request body
    body = {
        'resources': {
            'repositories': {
                'self': {
                    'refName': f'refs/heads/{BRANCH}'
                }
            }
        }
    }

    # Send the request to start the pipeline
    response = requests.post(url, headers=headers, data=json.dumps(body))

    # Print the response status code and content
    print(f'Response code: {response.status_code}')
    print(f'Response content: {response.content}')

if __name__ == "__main__":
    args = sys.argv[1:]
    pipelineID:str = args[0]
    branch:str = args[1].lower()
    print("pipelineID: " + pipelineID + ", branch: " + branch)
    main(pipelineID,branch)