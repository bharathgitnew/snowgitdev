import warnings
import sys
import os
from include.Python.ariba.common_functions import (
    Get_Ariba_Auth_Token, 
    Read_Update_Run_Time_Config, 
    Ariba_Check_Job_Status, 
    Post_Ariba_Job_Requests,
    Process_Ariba_Payload_And_Post_To_Snowflake, 
    Get_Ariba_Files,
    Convert_Date,
    Update_Config
)
from datetime import datetime
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

def main(realm_name: str):
    try:
        RunTimeConfig = Read_Update_Run_Time_Config(connection_string, 'read')
        JobDetails = RunTimeConfig.get('JobData').get(realm_name, {})
    except Exception as e:
        print(f"Error reading runtime config: {e}")
        sys.exit(1)

    secret = realm_name.upper()
    secure_credentials = {
        'AribaJobPostingURL': getAzureSecret('ARIBA-JOB-REQUEST-URL').value,
        'AribaJobResultsURL': getAzureSecret('ARIBA-JOB-RESULTS-URL').value,
        'ApplicationKey': getAzureSecret(f'ARIBA-API-KEY-{secret}').value,
        'Token': Get_Ariba_Auth_Token(realm_name)
    }

    Audit = []
    errors = []

    for view_name in list(JobDetails.keys()):
        job_content = JobDetails.get(view_name)

        if not job_content.get('Active', False):
            continue

        active_jobs = job_content.get('Jobs', {})
        max_complete_date = None
        status_alert = True

        for job_id in list(active_jobs.keys()):
            current_job = active_jobs.get(job_id)
            snowflake_table_name = job_content.get('SnowflakeTableName').upper()
            update_config_flag = False
            print(f"Checking Status of Job ==> {job_id}\nTable Name ==> {snowflake_table_name}")

            try:
                job_object = Ariba_Check_Job_Status(job_id, realm_name, secure_credentials)
                job_status = job_object.get('status')
                job_complete_date = job_object.get('completedDate', None)
                job_start_date = job_object.get('createdDate', None)
                number_of_records = job_object.get('totalNumOfRecords', None)
                number_of_files = job_object.get('totalNumOfFiles', None)

                print(f"Processing job status and loads for  ====> {view_name}")
                print(f"Current job ====> {job_id} : Status {job_status}")

                if job_status in ('expired', 'error', 'PythonError'):
                    active_jobs.pop(job_id, None)
                    job_object = {"filters": current_job.get("filters")}
                    view_name_to_run = job_content.get('ViewName')

                    print(f'Posting new Job for {view_name_to_run} as the Job has expired or errored')

                    try:
                        post = Post_Ariba_Job_Requests(realm_name, view_name_to_run, job_object, secure_credentials)

                        if post.get('job_id') is not None:
                            job_content.get('Jobs')[post.get('job_id')] = post.get('job_object')
                            update_config_flag = True

                        else:
                            errors.append(post.get('Error'))
                            print(f"Failed to post new job for {view_name_to_run}: {post.get('Error')}")

                    except Exception as e:
                        errors.append(f"Error posting new job for {view_name_to_run}: {str(e)}")
                        print(f"Exception in posting new job: {str(e)}")

                elif job_status == 'completedZeroRecords':
                    active_jobs.pop(job_id, None)

                elif job_status in ('pending', 'Inprogress', 'processing'):
                    Audit.append((snowflake_table_name, view_name, job_id, job_status, job_complete_date, job_start_date, number_of_records, number_of_files))

                elif job_status == 'completed':

                    try:
                        print(f"Processing Ariba Loads for {snowflake_table_name}")
                        Files = Get_Ariba_Files(job_id, realm_name, secure_credentials, job_object)
                        Process_Ariba_Payload_And_Post_To_Snowflake(connection_string, Files, realm_name, snowflake_table_name)

                        if job_complete_date:
                            job_complete_date = datetime.strptime(job_complete_date, '%Y-%m-%dT%H:%M:%SZ')
                            print(f"Job completed date: {job_complete_date}")

                            if not max_complete_date or job_complete_date > max_complete_date:
                                max_complete_date = job_complete_date

                        active_jobs.pop(job_id, None)
                        update_config_flag = True
                        status_alert = False

                    except Exception as e:
                        errors.append(f"Error processing job {job_id}: {str(e)}")
                        print(f"Error processing Ariba load for job {job_id}: {str(e)}")

                else:
                    print(f'Unknown Job status {job_status}')

                Audit.append((snowflake_table_name, view_name, job_id, job_status, job_complete_date, job_start_date, number_of_records, number_of_files))

            except Exception as e:
                errors.append(f"Error processing job {job_id} for view {view_name}: {str(e)}")
                print(f"Exception in processing job {job_id}: {str(e)}")

            if max_complete_date:
                job_content['LastSuccessfulEndDate'] = Convert_Date(max_complete_date, 'string')
                print(f"Updated Last Successful End Date for {view_name}: {job_content['LastSuccessfulEndDate']}")

            try:
                if update_config_flag:
                    Update_Config(connection_string, realm_name, JobDetails)
                    print(f"Job config updated for {view_name}")

            except Exception as e:
                errors.append(f"Error updating config for {realm_name}: {str(e)}")
                print(f"Error updating config: {str(e)}")

    if errors:
        print(f"Errors encountered: {errors}")

    if status_alert:
        print("Nothing to Do. Processing Jobs or No Jobs to Process")


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print("Please provide a realm name.")
        sys.exit(1)

    Realm_Name: str = args[0]
    print(f"Extracting Data For: ConfigFileName: {Realm_Name}")
    main(Realm_Name)
