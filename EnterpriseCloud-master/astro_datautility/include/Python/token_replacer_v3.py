import argparse
from jinja2 import Environment, FileSystemLoader
import json
import os
from jinja2 import environment
import logging 

from jinja2.environment import Template

def main():
	parser = argparse.ArgumentParser(description="Script that replaces tokens in files")
	parser.add_argument('-i', '--input_folder', type=str, help="Specify the input folder")
	parser.add_argument('-o', '--output_folder', type=str, help="Specify the output folder")
	parser.add_argument('-c', '--config', type=str, help='The config file containing the values for the tokens')
	parser.add_argument('-e', '--environment', type=str, help='Specify the build environment ex. DEV for Development')
	args = parser.parse_args()

	logging.basicConfig(level=logging.DEBUG, format='%(message)s')

	environment = args.environment
	input_folder = os.path.abspath(args.input_folder)
	config_file = args.config
	output_folder = args.output_folder

	logging.debug("Reading config file..")

	with open(config_file, 'r') as cf:
		config = json.load(cf)

	logging.debug("Setting template folder..")
	file_loader = FileSystemLoader(input_folder)

	logging.debug("Setting up jinja2 environment..")
	env = Environment(loader=file_loader, variable_start_string='<<', variable_end_string='>>')

	tokens = config[environment]

	print("tokens: {}".format(tokens))

	logging.debug("Replacing tokens in files:")

	#print(env.list_templates())

	for (directory_path, directory_names, file_names) in os.walk(input_folder):
		for file in file_names:
			#print("file: {}".format(file))
			#print("directory_path: {}".format(directory_path))
			#print("directory_names: {}".format(directory_names))

			file_full_path = os.path.join(directory_path, file)

			#print("file_full_path: {}".format(file_full_path))

			directory = os.path.basename(os.path.dirname(file_full_path))
			rel_path = "{}/{}".format(directory, file)

			#print("test: {}".format(rel_path))

			logging.debug("\t{}".format(file_full_path))
			template = env.get_template(rel_path)
			rendered_template = template.render(**tokens)

			#with open("{}/{}".format(output_folder, file), 'w') as output_file:
			output_file_path = "{}/{}/{}".format(output_folder, directory, file)

			if not os.path.exists(os.path.dirname(output_file_path)):
				os.makedirs(os.path.dirname(output_file_path))
			with open(output_file_path, 'w') as output_file:
				output_file.write(rendered_template)
				output_file.close()

if __name__ == '__main__':
	main()

#for (directory_path, directory_names, file_names) in os.walk(args.input_folder):
		#for file_name in file_names:
			#file_full_path = os.path.join(directory_path, file_name)