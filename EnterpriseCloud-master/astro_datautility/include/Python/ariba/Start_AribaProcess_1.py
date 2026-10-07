import warnings
import sys
import time
import os
from include.Python.ariba.common_functions import (
    Get_Ariba_Auth_Token, 
    Read_Update_Run_Time_Config, 
    Get_Ariba_Job_Filters, 
    Post_Ariba_Job_Requests
)
from include.Python.TELTools import getAzureSecret
warnings.filterwarnings('ignore')

connection_string = {
    'user' : os.getenv('SNOWFLAKE_USER'),
    'password' : os.getenv('SNOWFLAKE_SECRET'),
    'account' : os.getenv('SNOWFLAKE_ACCOUNT'),
    'warehouse' : os.getenv('SNOWFLAKE_WAREHOUSE'),
    'database' : os.getenv('SNOWFLAKE_LZ'),
    'role' : os.getenv('SNOWFLAKE_ROLE'),
    'schema' : 'ARIBA'
}

def main(realm_name : str):
    try:
        secret = realm_name.upper()
        secure_credentials = {
            'AribaJobPostingURL' : getAzureSecret(f'ARIBA-JOB-REQUEST-URL').value,
            'ApplicationKey' : getAzureSecret(f'ARIBA-API-KEY-{secret}').value,
            'Token' : Get_Ariba_Auth_Token(realm_name)
        }

        errors = []

        try:
            RunTimeConfig = Read_Update_Run_Time_Config(connection_string, 'read')
        except Exception as e:
            raise RuntimeError(f"Error reading run-time config: {e}")

        JobDetails = RunTimeConfig.get('JobData').get(realm_name, {})

        if not JobDetails:
            raise NotImplementedError(f"No Config {realm_name} found in Configs.")

        for view_name, job_content in JobDetails.items():

            if not job_content.get('Active', False):
                continue

            job_object = {
                "filters": Get_Ariba_Job_Filters(job_content)
            }

            view_name_to_run = job_content.get('ViewName')
            print(f'Posting for {view_name_to_run}')
            print(f'Filters for Reference ==> {job_object}')

            if job_object.get("filters"):

                post = Post_Ariba_Job_Requests(realm_name, view_name_to_run, job_object, secure_credentials)

                if 'Error' in post:
                    errors.append(post.get('Error'))
                    continue 

                elif post.get('job_id') is not None:
                    job_content.get('Jobs')[post.get('job_id')] = post.get('job_object')
                    print(f"Sucessfully Posted job with jobID : {post.get('job_id')}")
                    RunTimeConfig.update({
                        'JobData': {
                            realm_name: JobDetails
                        }
                    })

                    try:
                        Read_Update_Run_Time_Config(connection_string, 'update', RunTimeConfig)
                        print(f"Updated Job Configutation for {view_name_to_run}")

                    except Exception as e:
                        errors.append(f"Error updating run-time config after job post for {view_name_to_run}: {e}")
                        continue

                else:
                    raise ConnectionAbortedError(f'Unknown Error for the {view_name_to_run}')

                print("Entering Sleep as for 60 Seconds")
                time.sleep(60)
            
            else:
                print(f"Nothing to Post for {view_name_to_run}")

        if errors:
            for error in errors:
                print(error)
        else:
            print('All Jobs Posted Sucessfully!')

    except Exception as main_error:
        print(f"An error occurred: {main_error}")
        sys.exit(1)
    
if __name__ == "__main__":
    try:
        args = sys.argv[1:]
        Realm_Name:str = args[0]
        print("Extracting Data For: ConfigFileName: " + Realm_Name)
        main(Realm_Name)
    except IndexError:
        print("Realm name not provided. Please specify the realm name as an argument.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)
