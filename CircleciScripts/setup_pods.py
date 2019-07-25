from functions import runcommand, replacefiles
from fetch_podspecs import fetch_podspecs
from update_podfile import update_podfile
from uitests_exceptions import *
from shutil import rmtree
import os


def setup_pods(app_repo_root_directory, appname, app_config):

    current_directory = os.getcwd()

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


    podspec_files = fetch_podspecs(appname = appname,
                                   app_config = app_config,
                                   podspecs_directory = podspecs_directory)
    if len(podspec_files) == 0: ## testing all master branches; use released versions of SDKs
        return []


    ## setup private git repo for podspecs
    private_podspecs_git_repo_directory = '{0}/{1}_privatepodspecsrepo.git'.format(podspecs_directory, appname)
    private_podspecs_git_repo_clone_directory = '{0}/{1}_privatepodspecsrepo-clone'.format(podspecs_directory, appname)

    runcommand(command = "git init --bare {0}".format(private_podspecs_git_repo_directory),
               exception_to_raise = SetupPrivateGitForPodspecsException(appname))
    runcommand(command = "git clone {0} {1}".format(private_podspecs_git_repo_directory, private_podspecs_git_repo_clone_directory),
               exception_to_raise = SetupPrivateGitForPodspecsException(appname))

    try:
        os.chdir(private_podspecs_git_repo_clone_directory)
    except OSError as err:
        raise InvalidDirectoryException(appname = appname, message = str(err))

    runcommand(command = "touch readme.md", exception_to_raise = SetupPrivateGitForPodspecsException(appname))
    runcommand(command = "git add --all; git commit -m \"activating bare repo\"; git push origin master",
               exception_to_raise = SetupPrivateGitForPodspecsException(appname))

    try:
        os.chdir(podspecs_directory)
    except OSError as err:
        raise InvalidDirectoryException(appname = appname, message = str(err))

    runcommand(command = "pod setup > /dev/null", exception_to_raise = SetupMasterRepoPodsException(appname))

    #### add pod local repos
    private_podspecs_local_reponame = 'a_uitests_ios_specs_repo'
    private_podspecs_local_clone_reponame = 'b_uitests_ios_specs_repo'

    ####### remove if exists. Ignore if doesnt. Hence no exception handling
    runcommand(command = "pod repo remove {0}".format(private_podspecs_local_reponame))
    # runcommand(command = "pod repo remove {0}".format(private_podspecs_local_clone_reponame))

    runcommand(command = "pod repo add {0} {1}".format(private_podspecs_local_reponame, private_podspecs_git_repo_directory),
               exception_to_raise = AddLocalSpecsRepoException(appname))

    for podspec in podspec_files:
        podspec_path = "{0}/{1}".format(podspecs_directory, podspec)
        runcommand(command = "pod repo push --allow-warnings {0} {1}  > /dev/null".format(private_podspecs_local_reponame, podspec_path),
                   exception_to_raise = PodspecsValidateException(appname, podspec))

    #### Optional:: help cocoapods clone local repo using another localclonerepo pointing to same private git repo
    # runcommand(command = "cd ~/.cocoapods/repos; git clone {0} {1}".format(private_podspecs_git_repo_directory, private_podspecs_local_clone_reponame))

    ## update Podfile to add sources to local git
    update_podfile(private_podspecs_git_repo_directory = private_podspecs_git_repo_directory,
                   app_root_directory = app_root_directory,
                   appname = appname)

    return [private_podspecs_local_reponame, private_podspecs_local_clone_reponame]

