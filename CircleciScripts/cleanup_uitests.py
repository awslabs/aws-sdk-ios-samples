from functions import runcommand
from uitests_exceptions import *
from setup_mobile_sdk_dependencies import get_app_config_for
from shutil import rmtree
import os

## Requirements: aws-cli, npm, yarn, git cli tools

def delete_aws_resources(app_repo_root_directory, appname, path_to_cli_packages):

    app_config = get_app_config_for(appname=appname)
    if app_config == None:
        raise FetchAppConfigException(appname=appname)

    app_root_directory = "{0}/{1}".format(app_repo_root_directory, app_config.path)
    pathToCliRepo = app_root_directory + '/configure-aws-resources/amplify-cli'

    try:
        if path_to_cli_packages == None:
            path_to_cli_packages = pathToCliRepo + '/packages'
        os.chdir(path_to_cli_packages + '/amplify-ui-tests')
    except OSError as err:
        raise OSErrorDeleteResources(appname, [str(err)])

    delete_command = "npm run delete {0}".format(app_root_directory)

    print("Running delete_aws_resources... \n")
    runcommand(command = delete_command,
               exception_to_raise = CliDeleteResourcesException(appname))

    try:
        if os.path.isdir(pathToCliRepo):
            rmtree(pathToCliRepo)
    except OSError as err:
        raise OSErrorDeleteCliRepo(appname, [str(err)])
