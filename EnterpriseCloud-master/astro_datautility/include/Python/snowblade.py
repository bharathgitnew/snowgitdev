import os
import re
import argparse
import json
# from snowchange import replace_vars_from_config
from os.path import isfile, join

def snowblade(script_folder, config_database, environment, build_number, verbose):

    root_folder = os.path.abspath(script_folder)
    if not os.path.isdir(root_folder):
        raise ValueError("Invalid root folder: %s" % root_folder)

    all_scripts = get_all_scripts_recursively_snowblade(script_folder, verbose)
    for script_name in all_scripts:
        script = all_scripts[script_name]
        sql = replace_vars_from_config(script, config_database, environment, build_number)

        # overwrite the sql file
        with open(script['script_full_path'], 'w') as sql_file:
            sql_file.write(sql)

def get_all_scripts_recursively_snowblade(root_directory, verbose):
  all_files = dict()

  # Walk the entire directory structure recursively
  for (directory_path, directory_names, file_names) in os.walk(root_directory):
    for file_name in file_names:
      file_full_path = os.path.join(directory_path, file_name)

      script = dict()
      script['script_name'] = file_name
      script['script_full_path'] = file_full_path
      all_files[file_name] = script

  return all_files

def replace_vars_from_config(script, config_database, environment, build_number=''):
  if build_number == '':
    usable_build_number = ''
  else:
    usable_build_number = '_' + build_number
  with open(config_database) as f:
    database = json.load(f)
  # First read the contents of the script
  with open(script['script_full_path'],'r') as content_file:
    content = content_file.read().strip()
    # content = content[:-1] if content.endswith(';') else content
    content = re.sub(r'\<\<(.*?)\>\>',lambda x:database[environment.upper()][x.group(1).upper()] + usable_build_number, content)
  return content

if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog = 'python snowblade.py', description = 'Apply schema changes to a Snowflake account. Full readme at https://github.com/jamesweakley/snowblade', formatter_class = argparse.RawTextHelpFormatter)
    parser.add_argument('-f','--script-folder', type = str, default = ".", help = 'The root folder for the database change scripts')
    parser.add_argument('-cd', '--config-database', type = str, help = 'The JSON file for the configuration of the database environment (e.g. Config\database.json)')
    parser.add_argument('-e', '--environment', type = str, help = 'The Configuration Environment to use in the database name (e.g. QAa)')
    parser.add_argument('-b', '--build-number', type = str, default = '', help = 'The build number to use in the database name (e.g. 9999)')
    parser.add_argument('-v','--verbose', action='store_true')
    args = parser.parse_args()

    snowblade(args.script_folder, args.config_database, args.environment, args.build_number, args.verbose)