import json
import argparse

arg_parser = argparse.ArgumentParser(description='Utility Script to edit config to run uiTests')
arg_parser.add_argument('-c', '--cli_branch_to_uitest', nargs='?', default='master', type=str, help='Default cli branch to uitest')
arg_parser.add_argument('-s', '--default_sdk_branch_to_uitest', nargs='?', default='develop', type=str, help='Default SDK branch to uitest')
arg_parser.add_argument('-l', '--logs_folder_name', nargs='?', default='uitest_ios', type=str, help='folder name to store logs')
arg_parser.add_argument('-p', '--default_podspec_file_source', nargs='?', default='https://github.com/aws-amplify/aws-sdk-ios', type=str, help='Default directory to fetch podspecs')
arg_parser.add_argument('-d', '--simulator_specification', nargs='?', default='platform=iOS Simulator,name=iPhone X,OS=12.2', type=str, help='simulator version')
arg_parser.add_argument('-r', '--retry_count', nargs='?', default=0, type=int, help='number of times to retry failing uitests')
args = arg_parser.parse_args()

## Enables editting the uitests_ios_config json file from circleCI

with open("../Configuration/uitests_ios_config.json", mode='r') as f:
    config_uitests = json.load(f)
    config_uitests['cli_branch_to_uitest'] = args.cli_branch_to_uitest
    config_uitests['default_sdk_branch_to_uitest'] = args.default_sdk_branch_to_uitest
    config_uitests['logs_folder_name'] = args.logs_folder_name
    config_uitests['default_podspec_file_source'] = args.default_podspec_file_source
    config_uitests['simulator_specification'] = args.simulator_specification
    config_uitests['retry_count'] = args.retry_count

with open("../Configuration/uitests_ios_config.json", mode='w') as f:
    json.dump(config_uitests, f, indent = 4)
