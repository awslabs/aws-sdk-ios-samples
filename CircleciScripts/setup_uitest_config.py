import json
import argparse
import os
from shutil import copyfile
from uitests_exceptions import *


arg_parser = argparse.ArgumentParser(description='Utility Script to edit config to run uiTests')
arg_parser.add_argument('-c', '--cli_branch_to_uitest', nargs='?', type=str, help='Default cli branch to uitest')
arg_parser.add_argument('-p', '--default_podspec_file_source', nargs='?', type=str, help='Default directory to fetch podspecs')
arg_parser.add_argument('-s', '--default_sdk_branch_to_uitest', nargs='?', type=str, help='Default SDK branch to uitest')
arg_parser.add_argument('-l', '--logs_folder_name', nargs='?', type=str, help='folder name to store logs')
arg_parser.add_argument('-r', '--retry_count', nargs='?', type=int, help='number of times to retry failing uitests')
arg_parser.add_argument('-d', '--simulator_specification', nargs='?', type=str, help='simulator version')
args = arg_parser.parse_args()


path_to_uitests_ios_config_template = "../Configuration/uitests_ios_config_template.json"
path_to_uitests_ios_config = "../Configuration/uitests_ios_config.json"

try:
    copyfile(path_to_uitests_ios_config_template, path_to_uitests_ios_config)
except OSError as err:
    raise InvalidDirectorySetUpConfigException(message = [str(err)])

## Generate uitests_ios_config file from uitests_ios_config_template file

with open("../Configuration/uitests_ios_config_template.json", mode='r') as template_file:
    with open("../Configuration/uitests_ios_config.json", mode='r') as custom_file:
        config_uitests_template = json.load(template_file)
        config_uitests_custom = json.load(custom_file)
        for config_key, config_value in vars(args).items():
            if config_value != None:
                print('Setting ', config_key, ' to ', config_value, '\n' )
                config_uitests_custom[config_key] = config_value

with open("../Configuration/uitests_ios_config.json", mode='w') as f:
    json.dump(config_uitests_custom, f, indent = 4)
