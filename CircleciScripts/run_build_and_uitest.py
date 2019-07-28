from build_and_uitest import build_and_uitest
from uitests_exceptions import *
from traceback import print_exception
import argparse

arg_parser = argparse.ArgumentParser(description='Script to Build and UITest app')
arg_parser.add_argument('-n', '--appname', type=str, help='name of sample app to UI Test')
arg_parser.add_argument('-a', '--app_repo_root_directory', type=str, help='full path to cloned sample apps repo')
arg_parser.add_argument('-c', '--circleci_root_directory', type=str, help='full path to circleci root')
args = arg_parser.parse_args()


try:
    build_and_uitest(circleci_root_directory = args.circleci_root_directory,
                     appname = args.appname,
                     app_repo_root_directory=args.app_repo_root_directory)

except BuildAndUItestException as err:
    print(err.message)
    print_exception(type(err), err, err.__traceback__, chain=False)
    exit(1)

exit(0)