from parse_config_uitests import config_uitests
from fetch_pod_sources import fetch_pod_sources
from uitests_exceptions import *
from shutil import rmtree
import os


def setup_pods(app_repo_root_directory, appname):

    current_directory = os.getcwd()
    app_config = get_app_config_for(appname = appname)
    if app_config == None:
        raise FetchAppConfigException(appname = appname)

    ## cd into app root directory
    app_root_directory = '{0}/{1}'.format(app_repo_root_directory, app_config.path)
    try:
        os.chdir(app_root_directory)
    except OSError as err:
        os.chdir(current_directory)
        raise InvalidDirectoryException(appname = appname, message = str(err))


    pod_sources_directory = '{0}/uitests_pod_sources'.format(app_root_directory)

    if os.path.isdir(pod_sources_directory):
        rmtree(pod_sources_directory)

    try:
        os.mkdir(pod_sources_directory)
        os.chdir(pod_sources_directory)
    except OSError as err:
        os.chdir(current_directory)
        raise InvalidDirectoryException(appname = appname, message = str(err))

    print("step: 1/1 Fetching Pod Sources and updating podfile with local path to pod source \n ")
    fetch_pod_sources(appname = appname,
                      app_config = app_config,
                      pod_sources_directory = pod_sources_directory,
                      app_root_directory = app_root_directory)

def get_app_config_for(appname):
    for app_name, app_config in vars(config_uitests.apps_to_uitest).items():
        if app_name == appname:
            return app_config