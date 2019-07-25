import os
from functions import runcommand
from uitests_exceptions import *
from shutil import rmtree, copyfile

## Requirements: aws-cli, npm, yarn, git cli tools

## Side Effects: If configure fails in a directory, the script cannot be re-run in the same directory
## delete should take path to project root?

def configure_aws_resources(app_root_directory, appname, cli_resources):

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

    rn = runcommand(command="git clone https://github.com/AaronZyLee/amplify-cli -b dev",
                    exception_to_raise = GitCloneCliException(appname))

    try:
        os.chdir(pathToCliRepo)
    except OSError as err:
        raise OSErrorConfigureResources(appname, [str(err)])


    rn = runcommand(command = "npm run setup-dev",
                    exception_to_raise = CliSetupDevException(appname))

    ## todo: change to take custom schema

    try:
        os.chdir(app_root_directory + '/configure-aws-resources/amplify-cli/packages/amplify-ui-tests')
        targetSchemaPath = app_root_directory + '/configure-aws-resources/amplify-cli/packages/amplify-ui-tests/schemas/simple_model.graphql'
        if os.path.exists(targetSchemaPath):
            os.remove(targetSchemaPath)
        copyfile(app_root_directory + '/simple_model.graphql', targetSchemaPath)

    except OSError as err:
        raise OSErrorConfigureResources(appname, [str(err)])

    configure_command = "npm run config {0} ios {1}".format(app_root_directory, " ".join(cli_resources))

    rn = runcommand(command = configure_command,
                    exception_to_raise = CliConfigException(appname))



def delete_aws_resources(app_root_directory, appname):

    pathToCliRepo = app_root_directory + '/configure-aws-resources/amplify-cli'

    try:
        os.chdir(app_root_directory + '/configure-aws-resources/amplify-cli/packages/amplify-ui-tests')
    except OSError as err:
        raise OSErrorDeleteResources(appname, [str(err)])

    configure_command = "npm run delete {0}".format(app_root_directory)

    rn = runcommand(command = configure_command,
                    exception_to_raise = CliDeleteResourcesException(appname))

    try:
        if os.path.isdir(pathToCliRepo):
            rmtree(pathToCliRepo)
    except OSError as err:
        raise OSErrorDeleteCliRepo(appname, [str(err)])



# configure_aws_resources('/Users/edupp/Desktop/autotest/PhotoAlbum', 'PhotoAlbum', ['auth', 'storage', 'api'])
# delete_aws_resources('/Users/edupp/Desktop/autotest/PhotoAlbum', 'PhotoAlbum')