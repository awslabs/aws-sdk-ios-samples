from functions import runcommand
from parse_config_uitests import config_uitests
from uitests_exceptions import *
from update_podfile import update_podfile


def fetch_pod_sources(appname, app_config, pod_sources_directory, app_root_directory):

    ## fetch pod sources into pod_sources_directory

    branch_to_uitest = config_uitests.default_sdk_branch_to_uitest
    pod_url = config_uitests.default_podspec_file_source
    default_source_path = pod_sources_directory + '/default'

    sources_dict = { pod_url + '-' + branch_to_uitest:  default_source_path}

    if branch_to_uitest != 'master':
        runcommand(command="git clone {0} -b {1} --depth 1 default".format(pod_url, branch_to_uitest),
                   exception_to_raise=FetchRemotePodSourceException(appname, 'default'))

    for pod_name, pod_config in vars(app_config.sdk).items():

        ## skip and use released version of sdk if branch_to_uitest == 'master'

        try:
            if pod_config.branch_to_uitest == 'master':
                continue
            else:
                branch_to_uitest = pod_config.branch_to_uitest
                pod_url = pod_config.podspec
                source_hash = pod_url + '-' + branch_to_uitest
                source_path = pod_sources_directory + '/' + pod_name
                if not (source_hash in sources_dict):
                    runcommand(command="git clone {0} -b {1} --depth 1 {2}".format(pod_url,
                                                                         branch_to_uitest,
                                                                         pod_name),
                               exception_to_raise=FetchRemotePodSourceException(appname, pod_name))
                    sources_dict[source_hash] = source_path

                update_podfile(appname = appname,
                               app_root_directory = app_root_directory,
                               pod_name = pod_name,
                               pod_source_path = sources_dict[source_hash])

        except AttributeError as err:
            if config_uitests.default_sdk_branch_to_uitest != 'master':
                update_podfile(appname = appname,
                               app_root_directory = app_root_directory,
                               pod_name = pod_name,
                               pod_source_path = default_source_path)
