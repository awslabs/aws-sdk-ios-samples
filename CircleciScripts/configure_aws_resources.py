from functions import runcommand
from uitests_exceptions import *
from setup_mobile_sdk_dependencies import get_app_config_for
from shutil import rmtree, copyfile
import os

## Requirements: aws-cli, npm, yarn, git cli tools

def configure_aws_resources(app_repo_root_directory, appname, path_to_cli_packages):

    app_config = get_app_config_for(appname=appname)
    if app_config == None:
        raise FetchAppConfigException(appname=appname)

    app_root_directory = "{0}/{1}".format(app_repo_root_directory, app_config.path)
    cli_resources = app_config.cli_resources


    if path_to_cli_packages == None:

        pathToCliRepo = app_root_directory + '/configure-aws-resources/amplify-cli'

        try:
            if os.path.isdir(app_root_directory + '/configure-aws-resources'):
                rmtree(app_root_directory + '/configure-aws-resources')

            os.mkdir(app_root_directory + '/configure-aws-resources')
            os.chdir(app_root_directory + '/configure-aws-resources')
            if os.path.isdir(pathToCliRepo):
                rmtree(pathToCliRepo)

        except OSError as err:
            raise OSErrorConfigureResources(appname, [str(err)])

        print("step: 1/3... Cloning amplify-cli repo \n ")
        runcommand(command="git clone https://github.com/aws-amplify/amplify-cli.git -b integtest --depth 1",
                   exception_to_raise = GitCloneCliException(appname))

        try:
            os.chdir(pathToCliRepo)
        except OSError as err:
            raise OSErrorConfigureResources(appname, [str(err)])

        print("step: 2/3... Run setup-dev \n ")
        runcommand(command = "npm run setup-dev",
                   exception_to_raise = CliSetupDevException(appname))

    ## Skip re-building CLI packages in case of a valid path_to_cli_packages

    try:
        if path_to_cli_packages == None:
            path_to_cli_packages = app_root_directory + '/configure-aws-resources/amplify-cli/packages'
        os.chdir(path_to_cli_packages + '/amplify-ui-tests')
        if 'api' in cli_resources:
            targetSchemaPath = path_to_cli_packages + '/amplify-ui-tests/schemas/simple_model.graphql'
            if os.path.exists(targetSchemaPath):
                os.remove(targetSchemaPath)
            copyfile(app_root_directory + '/simple_model.graphql', targetSchemaPath)
    except OSError as err:
        raise OSErrorConfigureResources(appname, [str(err)])

    print("step: 3/3... config resources \n ")
    configure_command = "npm run config {0} ios {1}".format(app_root_directory, " ".join(cli_resources))

    runcommand(command = configure_command,
               exception_to_raise = CliConfigException(appname))

