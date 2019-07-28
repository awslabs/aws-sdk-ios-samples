from functions import runcommand, replacefiles
from parse_config_uitests import config_uitests
from fetch_podspecs import fetch_podspecs
from update_podfile import update_podfile
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


    podspecs_directory = '{0}/uitests_ios_podspecs'.format(app_root_directory)

    if os.path.isdir(podspecs_directory):
        rmtree(podspecs_directory)

    try:
        os.mkdir(podspecs_directory)
        os.chdir(podspecs_directory)
    except OSError as err:
        os.chdir(current_directory)
        raise InvalidDirectoryException(appname = appname, message = str(err))

    ## setup private git repo for podspecs
    private_podspecs_git_repo_directory = '{0}/{1}_privatepodspecsrepo.git'.format(podspecs_directory, appname)
    private_podspecs_git_repo_clone_directory = '{0}/{1}_privatepodspecsrepo-clone'.format(podspecs_directory,
                                                                                           appname)

    print("step: 1/4... Initialize local specs repo \n ")

    runcommand(command="git init --bare {0}".format(private_podspecs_git_repo_directory),
               exception_to_raise=SetupPrivateGitForPodspecsException(appname))
    runcommand(command="git clone {0} {1}".format(private_podspecs_git_repo_directory,
                                                  private_podspecs_git_repo_clone_directory),
               exception_to_raise=SetupPrivateGitForPodspecsException(appname))

    try:
        os.chdir(private_podspecs_git_repo_clone_directory)
    except OSError as err:
        raise InvalidDirectoryException(appname=appname, message=str(err))

    print("step: 2/4 Fetching PodSpecs if required \n ")
    podspec_files = fetch_podspecs(appname = appname,
                                   app_config = app_config,
                                   private_podspecs_git_repo_clone_directory = private_podspecs_git_repo_clone_directory)
    if len(podspec_files) == 0: ## testing all master branches; use released versions of SDKs
        return []

    ## push fetched podspecs from private git clone repo to parent repo
    print("step: 3/4... Pushing replicated podspecs directory from clone to parent \n ")
    try:
        os.chdir(private_podspecs_git_repo_clone_directory)
    except OSError as err:
        raise InvalidDirectoryException(appname = appname, message = str(err))

    runcommand(command = "git add --all",
               exception_to_raise = PushPodspecsFromCloneToParentException(appname))
    runcommand(command = "git commit -m 'pushing replicated podspecs directory from clone to parent' --no-verify",
               exception_to_raise = PushPodspecsFromCloneToParentException(appname))
    runcommand(command = "git push origin master".format(),
               exception_to_raise = PushPodspecsFromCloneToParentException(appname))


    #### add pod local repos
    private_podspecs_local_reponame = 'a_uitests_ios_specs_repo'
    # private_podspecs_local_clone_reponame = 'b_uitests_ios_specs_repo'

    ####### remove if exists. Ignore if doesnt. Hence no exception handling
    runcommand(command = "pod repo remove {0}".format(private_podspecs_local_reponame))
    # runcommand(command = "pod repo remove {0}".format(private_podspecs_local_clone_reponame))

    runcommand(command = "pod repo add {0} {1}".format(private_podspecs_local_reponame, private_podspecs_git_repo_directory),
               exception_to_raise = AddLocalSpecsRepoException(appname))

    #### Optional:: help cocoapods clone local repo using another localclonerepo pointing to same private git repo
    # runcommand(command = "cd ~/.cocoapods/repos; git clone {0} {1}".format(private_podspecs_git_repo_directory, private_podspecs_local_clone_reponame))

    print("step: 4/4... Update Podfile to add local specs repo as source \n ")
    ## update Podfile to add sources to local git
    update_podfile(private_podspecs_git_repo_directory = private_podspecs_git_repo_directory,
                   app_root_directory = app_root_directory,
                   appname = appname)

def get_app_config_for(appname):
    for app_name, app_config in vars(config_uitests.apps_to_uitest).items():
        if app_name == appname:
            return app_config