import json
from glob import glob
import os
import re
import argparse

def token_replacer(environment, build_directory, config_file, file_name_pattern, remove_config=False):

    print('build_directory: ' + build_directory)
    print('environment: ' + environment )
    print('config_file:' + config_file)
    file_names = glob(build_directory + file_name_pattern)
    print('file_names:')
    print(file_names)
    with open(config_file) as f:
        config_data = json.load(f)
    # First read the contents of the script
    for file_name in file_names:
        print("Opening File: ")
        with open(file_name,'r') as source_file:
            print(file_name)
            content = source_file.read().strip()
            content = content[:-1] if content.endswith(';') else content
            content = re.sub((r'\<\<(.*?)\>\>').upper(),lambda x:config_data[environment.upper()][x.group(1).upper()], content)
            with open(file_name,'w') as destination_file:
                destination_file.write(content)
    if remove_config:
        os.remove(config_file)

def main():
    # define the command line arguments that are acceptable and environment variables that can be used in their place if set

    ### Required Arguments ###
    parser = argparse.ArgumentParser()

    parser.add_argument("--environment", "-e", help="The environment that is being substituted.", type=str)
    parser.add_argument("--build_directory", "-bd", help="The root folder location files being subtituted.", type=str)
    parser.add_argument("--config_file", "-cf", help="The JSON configuration file for replacing tokens.", type=str)
    parser.add_argument("--file_name_pattern", "-fnp", help="The matching pattern for the token replacment. Example: '/drop/*.py'", type=str)
    parser.add_argument("--remove_config", "-rc", help="Remove the config file from the directory", action="store_true" )


    args = parser.parse_args()
    environment = args.environment
    build_directory = args.build_directory
    config_file = args.config_file
    file_name_pattern = args.file_name_pattern

    if args.remove_config == 'None':
        remove_config = False
    else:
        remove_config = True

    token_replacer(environment, build_directory, config_file, file_name_pattern, remove_config)

if __name__ == "__main__":
    main()
