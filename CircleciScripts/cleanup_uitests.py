from functions import runcommand
from uitests_exceptions import *
from setup_pods import get_app_config_for
from shutil import rmtree
import os

## Requirements: aws-cli, npm, yarn, git cli tools

def delete_aws_resources(app_repo_root_directory, appname):

    app_config = get_app_config_for(appname=appname)
    if app_config == None:
        raise FetchAppConfigException(appname=appname)

    app_root_directory = "{0}/{1}".format(app_repo_root_directory, app_config.path)
    pathToCliRepo = app_root_directory + '/configure-aws-resources/amplify-cli'

    try:
        os.chdir(app_root_directory + '/configure-aws-resources/amplify-cli/packages/amplify-ui-tests')
    except OSError as err:
        raise OSErrorDeleteResources(appname, [str(err)])

    configure_command = "npm run delete {0}".format(app_root_directory)

    print("Running delete_aws_resources... \n")
    runcommand(command = configure_command,
               exception_to_raise = CliDeleteResourcesException(appname))

    try:
        if os.path.isdir(pathToCliRepo):
            rmtree(pathToCliRepo)
    except OSError as err:
        raise OSErrorDeleteCliRepo(appname, [str(err)])

# delete_aws_resources('/Users/edupp/Desktop/autotest/PhotoAlbum', 'PhotoAlbum')