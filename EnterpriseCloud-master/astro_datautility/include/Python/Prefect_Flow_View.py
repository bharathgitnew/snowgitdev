import prefect
from prefect.backend import FlowRunView
from prefect.backend import FlowView
import json
import os
import pandas as pd
from datetime import datetime
from datetime import timedelta
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
import json
import pandas as pd
#Pass the API Key for Prefect Connection
client=prefect.Client(api_key=os.getenv('PREFECT_API_KEY'))
#Build The Run Times to Pull Data
i=1
while i<400:
    current_date=datetime.today()
    previous_date=current_date - timedelta(days=i+1)
    current_date=current_date-timedelta(days=i)
    prev_date = datetime.strftime(previous_date,"%Y-%m-%dT%H:%M:%S.%f+00:00")
    curr_date=datetime.strftime(current_date,"%Y-%m-%dT%H:%M:%S.%f+00:00")
#Build the Query for unloading data from Flow View
    flow_query_def="""
    query flow ($last_run: timestamptz,$curr_run: timestamptz) {
    flow(where: {updated: {_gte: $last_run,_lte:$curr_run}}) {
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
    vars = {
        "last_run":prev_date,
        "curr_run":curr_date
    }
    flow_query=client.graphql(flow_query_def,variables=vars)
#Write the JSON File for Flow Run View Data
    results = flow_query.get("data", {}).get("flow")
    json_object = json.dumps(flow_query, indent = 7)
#Build List to Validate Record Count
    flow_master_list=[]
    for results in results:
        list1=[results.id,results.name,results.description,results.parameters,results.run_config,results.environment]
        flow_master_list.append(list1)
    if len(flow_master_list)>0:
        with open("F:\Shares\Files\Prefect\Prefect_Flow_"+str(i)+".json", "w") as outfile:
            outfile.write(json_object)
    i+=1