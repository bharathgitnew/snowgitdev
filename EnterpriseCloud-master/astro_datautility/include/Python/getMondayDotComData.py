import sys
import datetime
import logging
import requests
import os
import pandas as pd
import time
from include.Python.TELTools import putSnowflakeDataFrame, getAzureSecret

# For Monday API Errors
class MondayAPIError(Exception):
    """Custom exception for Monday API errors."""
    pass

# Data Extraction Failed Error
class DataExtractionFailed(Exception):
    """Custom exception for Failure of Extract."""
    pass

# Get Current Time Stamp
def get_current_timestamp():
	CURRENT_TIMESTAMP = str(datetime.datetime.now()).replace(" ","_").replace(":","_").replace(".","_")
	return CURRENT_TIMESTAMP

# Method to extract workplace-board data from the API
def get_workspace(apiUrl,headers):
	workspace = pd.DataFrame()
	board_list = []
	logging.debug("Calling MONDAY API...")
	query = '{ boards (limit: 10000) { id name description updated_at workspace {id name created_at} } }'
	data = {'query' : query}
	response = requests.post(url=apiUrl, json=data, headers=headers)
	logging.debug("Processing response...")
	status_code = response.status_code
	if status_code == 200:
		if list([response.json()][0].keys())[0] != 'errors':
			logging.debug("{}: Successful API call with No Complexity Error".format(status_code))
			workspace = pd.json_normalize(response.json(), record_path=['data', 'boards'])       
			workspace = workspace.loc[workspace['name'].str[:8] != "Subitems"]
			workspace = workspace.reset_index(drop=True)
			workspace['workspace.id'] = workspace['workspace.id'].astype('Int64', errors= 'ignore')
			workspace = workspace[['workspace.id', 'workspace.name', 'workspace.created_at', 'name', 'id', 'description', 'updated_at']]
			board_list = workspace['id'].to_list()
		else:
			logging.debug("{}: Successful API call with Complexity Error".format(status_code))
			print("{}: Successful API call with Complexity Error".format(status_code))
			workspace = None 
			board_list = None
	else:
		logging.error("API Error status code: {}".format(status_code))
		print("API Error status code: {}".format(status_code))
		raise MondayAPIError("API Error status code: {}".format(status_code))
	
	return workspace, board_list

# Method to extract workplace-board data from the API
# Get the board_list using get_workspace()[1]
def get_items(apiUrl,board_list,headers):
	items= pd.DataFrame()
	for b in board_list:
		logging.debug("Calling MONDAY API...")
		query = "{ account_id : account {acc_id: id} complexity {before query after reset_in_x_seconds} boards (ids: "+ str(b) + " ) {name id items_page (limit: 500) {items {id name updated_at column_values {column {title} type text} group {title} } } } }"
		data = {'query' : query}
		response = requests.post(url=apiUrl, json=data, headers=headers)
		logging.debug("Processing response...")
		status_code = response.status_code
		if status_code == 200:
			if list([response.json()][0].keys())[0] != 'errors':
				d = pd.json_normalize(response.json(), record_path=['data', 'boards', 'items_page', 'items', 'column_values'],
									meta = [['data', 'account_id'],
											['data', 'boards', 'id'], ['data', 'boards', 'name'], 
				
											['data', 'boards', 'items_page', 'items', 'id'], ['data', 'boards', 'items_page', 'items', 'name'],
											['data', 'boards', 'items_page', 'items', 'updated_at'],
											['data', 'boards', 'items_page', 'items', 'group', 'title']]
										)
				if response.json().get('data').get('boards'):
					d['account_id'] = d['data.account_id'].apply(lambda x: x.get('acc_id') if isinstance(x, dict) else x)
				items = pd.concat([items, d], axis=0)
				items = items.reset_index(drop=True)
				#checking complexity budget
				limit_remaining = int(response.json()['data']['complexity']['after'])
				time_remaining = int(response.json()['data']['complexity']['reset_in_x_seconds'])
				if limit_remaining < 500000:
					time.sleep(time_remaining+1)
				else:
					pass
			else:
				logging.debug("{}: Successful API call with Complexity Error".format(status_code))
				print("{}: Successful API call with Complexity Error".format(status_code))
				return None
		else:
			logging.error("API Error status code: {}".format(status_code))
			print("API Error status code: {}".format(status_code))
			raise MondayAPIError("API Error status code: {}".format(status_code))
		
	items = items[['column.title', 'type', 'text', 'account_id', 'data.boards.id', 'data.boards.name', 'data.boards.items_page.items.id', 'data.boards.items_page.items.name', 'data.boards.items_page.items.updated_at', 'data.boards.items_page.items.group.title']]
	return items

# Method to extract board-item-subitem relationship data from the API
# Get the board_items_dict using get_items()
def get_subitemID(apiUrl,board_items_dict,headers):
	subitemID= pd.DataFrame()
	for (i,b) in board_items_dict.items():
		logging.debug("Calling MONDAY API...")
		query = "{ account_id : account{acc_id: id} complexity {before query after reset_in_x_seconds} boards (ids: "+ str(b) + " ) {name id items_page (limit: 500, query_params: {ids: ["+ str(i) +"]}) {items {id subitems {id updated_at}} } }}"
		data = {'query' : query}
		response = requests.post(url=apiUrl, json=data, headers=headers)
		logging.debug("Processing response...")
		status_code = response.status_code
		if status_code == 200:
			if list([response.json()][0].keys())[0] != 'errors':
				d = pd.json_normalize(response.json(), record_path=['data', 'boards', 'items_page', 'items', 'subitems'],
							meta = [['data', 'account_id'],
									['data', 'boards', 'id'],
									['data', 'boards', 'items_page', 'items', 'id']])
				if response.json().get('data').get('boards'):
					d['account_id'] = d['data.account_id'].apply(lambda x: x.get('acc_id') if isinstance(x, dict) else x)
				subitemID = pd.concat([subitemID, d], axis=0)
				subitemID = subitemID.reset_index(drop=True)
				#checking complexity budget
				limit_remaining = int(response.json()['data']['complexity']['after'])
				time_remaining = int(response.json()['data']['complexity']['reset_in_x_seconds'])
				if limit_remaining < 500000:
					time.sleep(time_remaining+1)
				else:
					pass
			else:
				logging.debug("{}: Successful API call with Complexity Error".format(status_code))
				print("{}: Successful API call with Complexity Error".format(status_code))
				return None
		else:
			logging.error("API Error status code: {}".format(status_code))
			print("API Error status code: {}".format(status_code))
			raise MondayAPIError("API Error status code: {}".format(status_code))
		
	subitemID = subitemID[['account_id', 'data.boards.id', 'data.boards.items_page.items.id', 'id', 'updated_at']]
	return subitemID

# Method to extract board-item-subitems data from the API
# Get the board_items_dict2 using get_subitemID()
def get_subitems(apiUrl,board_items_dict2,headers):
	sub_items= pd.DataFrame()
	for (i,b) in board_items_dict2.items():
		logging.debug("Calling MONDAY API...")
		query = "{ account_id : account{acc_id: id} complexity {before query after reset_in_x_seconds} boards (ids: "+ str(b) + " ) {name id items_page (limit: 500, query_params: {ids: ["+ str(i) +"]}) {items {id name subitems {id name updated_at column_values {column {title} type text}}} } }}"
		data = {'query' : query}
		response = requests.post(url=apiUrl, json=data, headers=headers)
		logging.debug("Processing response...")
		status_code = response.status_code
		if status_code == 200:
			if list([response.json()][0].keys())[0] != 'errors':
				d = pd.json_normalize(response.json(), record_path=['data', 'boards', 'items_page', 'items', 'subitems', 'column_values'],
							meta = [['data', 'account_id'],
									['data', 'boards', 'id'], ['data', 'boards', 'name'],
									['data', 'boards', 'items_page', 'items', 'id'], ['data', 'boards', 'items_page', 'items', 'name'],
									['data', 'boards', 'items_page', 'items', 'subitems', 'id'],
				
									['data', 'boards', 'items_page', 'items', 'subitems', 'name'],
									['data', 'boards', 'items_page', 'items', 'subitems', 'updated_at']])
				
				if response.json().get('data').get('boards'):
					d['account_id'] = d['data.account_id'].apply(lambda x: x.get('acc_id') if isinstance(x, dict) else x)
					
				sub_items = pd.concat([sub_items, d], axis=0)
				sub_items = sub_items.reset_index(drop=True)
				#checking complexity budget
				limit_remaining = int(response.json()['data']['complexity']['after'])
				time_remaining = int(response.json()['data']['complexity']['reset_in_x_seconds'])
				if limit_remaining < 500000:
					time.sleep(time_remaining+1)
				else:
					pass
			else:
				logging.debug("{}: Successful API call with Complexity Error".format(status_code))
				print("{}: Successful API call with Complexity Error".format(status_code))
				return None
			
		else:
			logging.error("API Error status code: {}".format(status_code))
			print("API Error status code: {}".format(status_code))
			raise MondayAPIError("API Error status code: {}".format(status_code))
		
	sub_items = sub_items[['column.title', 'type', 'text', 'account_id', 'data.boards.id', 'data.boards.name', 'data.boards.items_page.items.id', 'data.boards.items_page.items.name', 'data.boards.items_page.items.subitems.id', 'data.boards.items_page.items.subitems.name', 'data.boards.items_page.items.subitems.updated_at']]
	return sub_items

#Method to Write data to Shared Folder
def write_results(data,file_type, timestamp):
	database = os.getenv('SNOWFLAKE_LZ')
	schema = 'MONDAY'
	file_date = datetime.datetime.strptime(timestamp, '%Y-%m-%d_%H_%M_%S_%f')
	# FILE_OUT_LOCATION='F:\\Shares\\Files\\MONDAY\\'
	logging.debug("Writing to file...")
	File_Name='MONDAY_{}_{}.csv'.format(file_type, timestamp)
	number_of_rows=len(data)
	size_of_list_bytes=sys.getsizeof(data)
	Bytes_to_gb_denominator=(1024*1024*1024)
	size_of_list_gb=int(size_of_list_bytes/Bytes_to_gb_denominator)

	if(size_of_list_gb)>1:
		size_per_Record=int(size_of_list_bytes/number_of_rows)
		number_of_chunks=int(1000000/size_per_Record)
		list_df = []
		for i in range(0,number_of_rows,number_of_chunks):
			x=i
			list_df.append(data[x:x+number_of_chunks])
		file_value=1	
		for d in list_df:
			File_Name='MONDAY_{}_'.format(file_type)+str(file_value)+'_{}.csv'.format(timestamp)
			d.columns = range(len(d.columns))
			d.replace("", None, inplace=True)
			messages = putSnowflakeDataFrame(
				db = database,
				schema = schema,
				tableName = file_type,
				df = d,
				fileName = File_Name,
				fileDate = file_date
			)
			# d.to_csv(File_Name)
			print(messages)
			if "FAIL_SIGNAL" in messages:
				raise ConnectionAbortedError(f'Write to Snowflake Failed for {File_Name}')
			
			file_value = file_value+1
	else:
		data.columns = range(len(data.columns))
		data.replace("", None, inplace=True) 
		messages =putSnowflakeDataFrame(
				db = database,
				schema = schema,
				tableName = file_type,
				df = data,
				fileName = File_Name,
				fileDate = file_date
			)
		print(messages)
		# data.to_csv(File_Name, index=False)
		if "FAIL_SIGNAL" in messages:
			raise ConnectionAbortedError(f'Write to Snowflake Failed for {File_Name}')
		
#Main Function to execute the extracts
def main():

	# For Errors 
	Errors = []
	# Board Lists 
	board_list = ['4811102084', '3946712305', '3679695583','5042162499']
	# API Keys and API Url From Azure-Key Vault
	apiKey = getAzureSecret('MONDAY-API-KEY').value
	apiUrl = getAzureSecret('MONDAY-API-URL').value
	headers = {"Authorization" : apiKey}
	print("Starting to fetch data from API...")

	# Get Workspace-Board Data and Post it to table WORKSPACE.
	try:
		file_type = 'WORKSPACE'
		workspace = get_workspace(apiUrl,headers)
		workspace_table = workspace[0]
		if workspace_table is not None:
			current_timestamp = get_current_timestamp()
			logging.debug("Writing {} results..".format(file_type))
			write_results(workspace_table, file_type, current_timestamp)
			logging.debug("Done.")
			print(f"Task Complete! Data written to table MONDAY.{file_type}")
		else:
			print(f"Task Complete with Complexity Error Today's Quota Exceeded")

	except (ConnectionAbortedError, MondayAPIError, Exception) as e:
		if isinstance(e, ConnectionAbortedError):
			Errors.append(f"Failed to Write File {file_type} :: {str(e)}")
		elif isinstance(e, MondayAPIError):
			Errors.append(str(e))
		else:
			Errors.append(f"An Unknown Error occurred for {file_type} :: {str(e)}")
		items = None

	time.sleep(60)

	# Get Board-Items Data and Post it to table ITEMS
	try : 
		file_type = 'ITEMS'
		items = get_items(apiUrl,board_list,headers)
		if items is not None:
			# Create a board-item dict to get subitems ids
			board_items_dict = dict(zip(items['data.boards.items_page.items.id'], items['data.boards.id']))
			current_timestamp = get_current_timestamp()
			logging.debug("Writing {} results..".format(file_type))
			write_results(items, file_type, current_timestamp)
			logging.debug("Done.")
			print(f"Task Complete! Data written to table MONDAY.{file_type}")
		else:
			board_items_dict = None
			print(f"Task Complete with Complexity Error Today's Quota Exceeded")

	except (ConnectionAbortedError, MondayAPIError, Exception) as e:
		if isinstance(e, ConnectionAbortedError):
			Errors.append(f"Failed to Write File {file_type} :: {str(e)}")
		elif isinstance(e, MondayAPIError):
			Errors.append(str(e))
		else:
			Errors.append(f"An Unknown Error occurred for {file_type} :: {str(e)}")
		board_items_dict = None

	time.sleep(60)

	# Get Board-Items-Subitems IDS and Post it to table SUBITEMSID
	try:
		file_type = 'SUBITEMSID'
		if board_items_dict is not None:	
			subitems_id = get_subitemID(apiUrl,board_items_dict,headers)
			# Create a Board-Items dict for items those have subitems
			board_items_dict2 = dict(zip(subitems_id['data.boards.items_page.items.id'], subitems_id['data.boards.id']))
			current_timestamp = get_current_timestamp()
			logging.debug("Writing {} results..".format(file_type))
			write_results(subitems_id, file_type, current_timestamp)
			logging.debug("Done.")
			print(f"Task Complete! Data written to table MONDAY.{file_type}")
		else:
			board_items_dict2 = None

	except (ConnectionAbortedError, MondayAPIError, Exception) as e:
		if isinstance(e, ConnectionAbortedError):
			Errors.append(f"Failed to Write File {file_type} :: {str(e)}")
		elif isinstance(e, MondayAPIError):
			Errors.append(str(e))
		else:
			Errors.append(f"An Unknown Error occurred for {file_type} :: {str(e)}")
		board_items_dict2 = None

	time.sleep(60)

	# Get Board-Items-Subitems data
	try:
		file_type = 'SUBITEMS'
		if board_items_dict2 is not None:
			subitems = get_subitems(apiUrl,board_items_dict2,headers)
			current_timestamp = get_current_timestamp()
			logging.debug("Writing {} results..".format(file_type))
			write_results(subitems, file_type, current_timestamp)
			logging.debug("Done.")
			print(f"Task Complete! Data written to table MONDAY.{file_type}")

	except (ConnectionAbortedError, MondayAPIError, Exception) as e:
		if isinstance(e, ConnectionAbortedError):
			Errors.append(f"Failed to Write File {file_type} :: {str(e)}")
		elif isinstance(e, MondayAPIError):
			Errors.append(str(e))
		else:
			Errors.append(f"An Unknown Error occurred for {file_type} :: {str(e)}")

	if Errors:
		print('Data Extraction Failed due to ')
		print('\n'.join(Errors))
		raise DataExtractionFailed("Monday.com Data Extraction Failed")
	else:
		print('Data Extraction Sucessfull!!! ')

if __name__ == "__main__":
    main()