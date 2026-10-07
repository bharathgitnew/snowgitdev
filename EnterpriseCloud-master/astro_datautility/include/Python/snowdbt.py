import os
import re
import argparse
import time
import hashlib
import json
import logging



def replace_vars_from_config(script, config_database, environment, build_number=''):
  if build_number == '' or build_number is None or len(build_number) == 0:
    usable_build_number = ''
    usable_db_prefix = ''
  else:
    usable_build_number = '_' + build_number
    usable_db_prefix = 'z_'
  with open(config_database) as f:
    database = json.load(f)
  if database[environment.upper()]['LZ']:
    database[environment.upper()]['LZ'] = usable_db_prefix + database[environment.upper()]['LZ'] + usable_build_number
  if database[environment.upper()]['LZ_EXT']:
    database[environment.upper()]['LZ_EXT'] = usable_db_prefix + database[environment.upper()]['LZ_EXT'] + usable_build_number
  if database[environment.upper()]['ODS']:
    database[environment.upper()]['ODS'] = usable_db_prefix + database[environment.upper()]['ODS'] + usable_build_number
  if database[environment.upper()]['COMMON']:
    database[environment.upper()]['COMMON'] = usable_db_prefix + database[environment.upper()]['COMMON'] + usable_build_number
  if database[environment.upper()]['EDW']:
    database[environment.upper()]['EDW'] = usable_db_prefix + database[environment.upper()]['EDW'] + usable_build_number
  if database[environment.upper()]['PUB']:
    database[environment.upper()]['PUB'] = usable_db_prefix + database[environment.upper()]['PUB'] + usable_build_number
  # First read the contents of the script
  with open(script,'r') as content_file:
    content = content_file.read().strip()
    content = content[:-1] if content.endswith(';') else content
    content = re.sub(r'\<\<(.*?)\>\>',lambda x:database[environment.upper()][x.group(1).upper()], content)
  return content


def main():
  parser = argparse.ArgumentParser(description="Script that replaces tokens in files")
  parser.add_argument('-s', '--script', type=str, help="Specify the profiles.yml script")
  parser.add_argument('-c', '--config_database', type=str, help="Specify the configuration file")
  parser.add_argument('-b', '--build_number', type=str, help='The build_number for the pipeline')
  parser.add_argument('-e', '--environment', type=str, help='Specify the build environment ex. DEV for Development')
  parser.add_argument('-p', '--output_path', type=str, help='Specify the output path to write the file')
  args = parser.parse_args()

  logging.basicConfig(level=logging.DEBUG, format='%(message)s')

  content=replace_vars_from_config( \
    script=args.script, \
    config_database=args.config_database, \
    environment=args.environment, \
    build_number=args.build_number \
    )
  with open(args.output_path,'w') as f:
    f.write(content)
    f.close()

if __name__ == '__main__':
	main()