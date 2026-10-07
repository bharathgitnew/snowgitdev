import os, json, sys

def create_new_configs():
    directory = "F:\Shares\Files\TokyoElectron\Python\RuntimeConfig\crm_file"
    if not os.path.exists(directory):
        os.makedirs(directory)

        current_config = r"\\telusdwappprod\Shares\Files\TokyoElectron\Python\RuntimeConfig\crm.FILE_EXTRACTS.json"
        with open(current_config,"r",encoding='utf-8-sig') as f:
            crm_json = json.load(f,strict=False)

        for key,val in crm_json["RunData"].items():
            temp_dict = {}
            f_dict = {}    
            temp_dict[key] = val
            f_dict["RunData"] = temp_dict
            RUN_FILE = f"F:\Shares\Files\TokyoElectron\Python\RuntimeConfig\crm_file\crm.{key}.json"
            with open(RUN_FILE,'w',encoding='utf-8-sig') as fwrite:
                fwrite.write(json.dumps(f_dict, indent=4))


        last_default_run_file= "F:\Shares\Files\TokyoElectron\Python\RuntimeConfig\crm_file\crm.LastDefaultRun.json"
        lastrun_dict = {}
        lastrun_dict["LastDefaultRun"] = crm_json["LastDefaultRun"]
        with open(last_default_run_file,'w',encoding='utf-8-sig') as lwrite:
            lwrite.write(json.dumps(lastrun_dict, indent=4))
    else:
        print("folder created already, existing...")
       
    
    