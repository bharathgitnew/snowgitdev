from pickle import TRUE
import sys
from urllib.parse import _ResultMixinStr
import prefect
from prefect.backend import FlowRunView
from prefect.backend import FlowView
import json
import os
import pandas as pd
from datetime import datetime
from datetime import timedelta
import math
import include.Python.TELTools as TT
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart
from smtplib import SMTP
import smtplib
from IPython.display import display,HTML

def main(Run_date:str):
    msg = EmailMessage()
    #Pass the API Key for Prefect Connection by reading it from KeyVault
    prefect_api_key=TT.getAzureSecret('PREFECT-API-KEY').value
    client=prefect.Client(api_key=prefect_api_key)
    if Run_date=="1900-01-01":
        Run_date=datetime.date(datetime.today())
    else:
        Run_date=datetime.strptime(Run_date,"%Y-%m-%d").date()
    today=datetime.strftime(Run_date,"%Y-%m-%dT%H:%M:%S.%f+00:00")
    GMXFlowName='DBT.Driver.GMX'
    APIFlowName='DBT.Driver.SAPAPI'
    GMXFlowRunStatus='False'
    APIFlowRunStatus='False'
    ProjectName = os.environ.get('snowflake_env')
    Labels="TELUSDWAPP"+ProjectName
#Extract GMX Flow Run State
    gmx_flow_run_query_def="""
            query flowRun ($today: timestamptz,$GMXFlowName: String,$Labels: jsonb) {
            flow_run (where: {  updated: {_gte: $today}
                                state: {_eq:"Success"}
                                labels: {_contains:$Labels}
                                flow: {name: {_eq:$GMXFlowName}}
                                }
                    )
                    {
                        state
                    }
            }
            """
    vars = {
                "today":today,
                "GMXFlowName":GMXFlowName,
                "Labels":Labels
            }
    gmx_flow_run_query=client.graphql(gmx_flow_run_query_def,variables=vars)
    GMXFlowRunStatus = gmx_flow_run_query.get("data", {}).get("flow_run")
    for GMXFlowRunStatus in GMXFlowRunStatus:
        GMXFlowRunStatus=GMXFlowRunStatus.state
#Extract API Flow Run State
    api_flow_run_query_def="""
            query flowRun ($today: timestamptz,$APIFlowName: String,$Labels: jsonb) {
            flow_run (where: {  updated: {_gte: $today}
                                state: {_eq:"Success"}
                                labels: {_contains:$Labels}
                                flow: {name: {_eq:$APIFlowName}}
                                }
                    )
                    {
                        state
                    }
            }
            """
    vars = {
                "today":today,
                "APIFlowName":APIFlowName,
                "Labels":Labels
            }
    api_flow_run_query=client.graphql(api_flow_run_query_def,variables=vars)
    APIFlowRunStatus = api_flow_run_query.get("data", {}).get("flow_run")
    for APIFlowRunStatus in APIFlowRunStatus:
        APIFlowRunStatus=APIFlowRunStatus.state
    To = "bi.prefect-alert@us.tel.com"
    Subject = Labels+": API & GMX Extraction Status"
    From = 'bi.prefect-alert@us.tel.com'
    CC='farooque.x.shaikh@us.tel.com'
    server = smtplib.SMTP('smtp.us.tel.com','25')
    if APIFlowRunStatus=="Success":
        APIFlowRunStatus="True"
        if GMXFlowRunStatus=="Success":
            content="Both API and GMX Extracts are successful for:" + str(Run_date)
        else:
            content="WARNING: API Extract is Successful but GMX Extract has not completed for:" + str(Run_date) +". We will continue processing DE_SAPH withouth GMX Data"
    else:
            APIFlowRunStatus="False"
            content="ERROR: API Extract is not Successful for:"+ str(Run_date) +". We will not proceed on the execution for DE_SAPH"
    return APIFlowRunStatus,From,To,CC,Subject,content

if __name__ == "__main__":
    main(Run_date)