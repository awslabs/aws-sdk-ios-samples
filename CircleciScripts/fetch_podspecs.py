from functions import runcommand, replacefiles
from parse_config_uitests import config_uitests
from uitests_exceptions import *
from shutil import copyfile, rmtree


def fetch_podspecs(appname, app_config, podspecs_directory):
    ## fetch podspecs and edit to remove tag and add branch_to_uitest

    podspec_files = []
    for podspec_name, podspec_config in vars(app_config.sdk).items():

        ## skip and use released version of sdk if branch_to_uitest == 'master'
        branch_to_uitest = config_uitests.default_sdk_branch_to_uitest
        podspec_url = config_uitests.default_podspec_file_source

        ## skip and use released version of sdk if branch_to_uitest == 'master'
        try:
            if podspec_config.branch_to_uitest == 'master':
                continue
            else:
                branch_to_uitest = podspec_config.branch_to_uitest
                podspec_url = podspec_config.podspec
        except AttributeError as err:
            if branch_to_uitest == 'master':
                continue

        podspec_repo_directory = '{0}/{1}'.format(podspecs_directory, podspec_name)
        runcommand(command = "git clone {0} {1}".format(podspec_url, podspec_repo_directory),
                   exception_to_raise = FetchRemotePodspecFileException(appname, podspec_name))

        try:
            src = "{0}/{1}.podspec".format(podspec_repo_directory, podspec_name)
            des = "{0}/{1}.podspec".format(podspecs_directory, podspec_name)
            copyfile(src, des)
        except IOError as err:
            raise FetchRemotePodspecFileException(appname, podspec_name, str(err))


        ## edit podspecs to remove :tag and change it to branch_to_uitest
        ## Also change version to 100.100.100 to distinguish local pods from released ones

        replaces = [
            {
                "match": r":tag[[:space:]]*=>[[:space:]]*.*}",
                "replace": r':branch => "[sdk_branch_to_uitest_placeholder]" }',
                "files": ["{0}.podspec".format(podspec_name)]
            },
            {
                "match": r":tag[[:space:]]*=>[[:space:]]*.*,",
                "replace": r':branch => "[sdk_branch_to_uitest_placeholder]" ,',
                "files": ["{0}.podspec".format(podspec_name)]
            },
            {
                "enclosemark": "double",
                "match": r"(s.version[[:space:]]*=[[:space:]]*')[0-9]+\.[0-9]+\.[0-9]+'",
                "replace": r"\1[version]'",
                "files": ["{0}.podspec".format(podspec_name)]
            }
        ]

        for replaceaction in replaces:
            replaceaction["replace"] = replaceaction["replace"].replace("[sdk_branch_to_uitest_placeholder]", branch_to_uitest.replace('/','\/')) # add escape character to branch names with / character
            replaceaction["replace"] = replaceaction["replace"].replace("[version]", "100.100.100")
        replacefiles(podspecs_directory, replaces)

        ## clean up
        try:
            os.chdir(podspecs_directory)
            if os.path.isdir(podspec_repo_directory):
                rmtree(podspec_repo_directory)
        except OSError as err:
            raise CleanupFetchPodspecsException(appname, podspec_name)

        podspec_files.append("{0}.podspec".format(podspec_name))

    return podspec_files