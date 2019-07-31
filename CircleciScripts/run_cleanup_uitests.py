from cleanup_uitests import delete_aws_resources
from uitests_exceptions import *
from functions import runcommand
from traceback import print_exception
import argparse

arg_parser = argparse.ArgumentParser(description='Script to delete AWS Resources configured for the app')
arg_parser.add_argument('-n', '--appname', type=str, help='name of sample app to UI Test')
arg_parser.add_argument('-a', '--app_repo_root_directory', type=str, help='full path to cloned sample apps repo')
args = arg_parser.parse_args()


try:
    delete_aws_resources(app_repo_root_directory = args.app_repo_root_directory,
                         appname = args.appname)

except ConfigureAWSResourcesException as err:
    print(err.message)
    print_exception(type(err), err, err.__traceback__, chain=False)
    exit(1)

exit(0)
