from functions import runcommand
from uitests_exceptions import *
from parse_config_uitests import config_uitests
from setup_pods import get_app_config_for
from shutil import rmtree
import re
import datetime
import os

def build_and_uitest(circleci_root_directory, appname, app_repo_root_directory):

    app_config = get_app_config_for(appname = appname)
    if app_config == None:
        raise FetchAppConfigException(appname = appname)

    logs_folder_name = config_uitests.logs_folder_name
    simulator_specification = config_uitests.simulator_specification
    retry_count = config_uitests.retry_count

    ## cd into app root directory
    app_root_directory = '{0}/{1}'.format(app_repo_root_directory, app_config.path)

    ## install pods
    try:
        os.chdir(app_root_directory)
        if os.path.exists('Podfile.lock'):
            os.remove('Podfile.lock')
    except OSError as err:
        raise RemovePodfileLockException(appname, [str(err)])

    try:
        logs_folder_path = circleci_root_directory + '/' + logs_folder_name
        if os.path.isdir(logs_folder_path):
            rmtree(logs_folder_path)
        os.mkdir(logs_folder_path)
    except OSError as err:
        raise SetUpLogFilesDirectoryException(appname, [str(err)])

    print("step: 1/2... Install Pods \n ")
    runcommand(command="pod --version; pod install",
               exception_to_raise = PodInstallException(appname))

    ## build app; run uitests and store logs
    raw_logfile_path = "{0}/{1}_raw.log".format(logs_folder_path, appname)
    consolidated_logfile_path = "{0}/{1}_summary.log".format(logs_folder_path, appname)
    derived_data_path = "{0}/{1}_xclogs".format(logs_folder_path, appname)

    print("step: 2/2... Run UITests and generate reports \n ")
    uitest_and_store_logs(appname = appname,
                          app_path = app_config.path,
                          simulator_specification = simulator_specification,
                          raw_logfile_path = raw_logfile_path,
                          consolidated_logfile_path = consolidated_logfile_path,
                          derived_data_path = derived_data_path)

    for retry_index in range(retry_count):

        failed_test_cases = get_failed_testcases_from_logs(raw_logfile_path = raw_logfile_path)

        for failed_test_case in failed_test_cases:

            print("Retry {0}: .... Testcase {1} \n".format(retry_index + 1, failed_test_case))

            raw_logfile_path = "{0}/{1}_retry{3}_{2}.log".format(logs_folder_path, appname,
                                                                failed_test_case.replace('/','_'),
                                                                retry_index + 1)
            derived_data_path = "{0}/{1}_retry{3}_{2}_xclogs".format(logs_folder_path, appname,
                                                                failed_test_case.replace('/','_'),
                                                                retry_index + 1)

            uitest_and_store_logs(appname=appname,
                                  app_path = app_config.path,
                                  simulator_specification=simulator_specification,
                                  raw_logfile_path=raw_logfile_path,
                                  consolidated_logfile_path=consolidated_logfile_path,
                                  derived_data_path = derived_data_path,
                                  only_testing = failed_test_case)

            ## if any testcase fails even after final retry, raise Exception
            testcases_failing_retry = get_failed_testcases_from_logs(raw_logfile_path=raw_logfile_path)
            if len(testcases_failing_retry) != 0 and retry_index + 1 == retry_count:
                raise BuildAndUItestFailException(appname, raw_logfile_path)


def uitest_and_store_logs(appname, app_path, simulator_specification,
                          raw_logfile_path, consolidated_logfile_path,
                          derived_data_path,
                          only_testing = None):

    ## It is expected that the sample app will have it's workspace named "<path(only letters)>.xcworkspace"
    ## and the scheme for UITesting is named "<path(only letters)>UITests", where <path> is configured
    ## in the ../Configuration/uitests_ios_config.json file

    app_path = app_path.replace('-','').replace('/','')
    only_testing_string = " "
    if only_testing != None:
        only_testing_string = " -only-testing:{0}UITests/{1}".format(app_path, only_testing)

    runcommand(command = "xcodebuild -workspace {0}.xcworkspace -scheme \"{0}UITests\" -destination \"{1}\" {2} -derivedDataPath \"{4}\" test | tee {3} | xcpretty".format(
                          app_path, simulator_specification,
                          only_testing_string, raw_logfile_path,
                          derived_data_path),
               exception_to_raise=BuildAndUItestFailException(appname, raw_logfile_path))

    consolidate_test_results(raw_logfile_path = raw_logfile_path,
                             consolidated_logfile_path = consolidated_logfile_path)

def consolidate_test_results(raw_logfile_path, consolidated_logfile_path):

    pattern = re.compile(r"^Test\s*(case|suite)\s*'.*'\s*(passed|failed|started)\s*on")

    with open(consolidated_logfile_path, "a+") as consolidated_logfile:
        consolidated_logfile.write("\n\n Results for UITests run on: {0} \n".format(str(datetime.datetime.now())))
        for i, line in enumerate(open(raw_logfile_path)):
            for match in re.finditer(pattern, line):
                consolidated_logfile.write(line)

def get_failed_testcases_from_logs(raw_logfile_path):

    failed_testcases = []
    pattern = re.compile(r"^Test\s*case\s*'(.*)\(\)'\s*failed\s*on.*$")
    for i, line in enumerate(open(raw_logfile_path)):
        for match in re.finditer(pattern, line):
            failed_testcases.append(match.groups()[0].replace('.','/'))
    return failed_testcases

# consolidate_test_results('/Users/edupp/Documents/EndToEnd/local/PhotoAlbum/raw.log',
#                          '/Users/edupp/Documents/EndToEnd/local/PhotoAlbum/consolidated.log')

# print(get_failed_testcases_from_logs('/Users/edupp/Documents/EndToEnd/local/PhotoAlbum/raw.log'))

# build_and_uitest('/Users/edupp/Documents/EndToEnd/local', '/Users/edupp/Documents/EndToEnd/local/aws-sdk-ios-samples/PhotoAlbum','PhotoAlbum','logs','platform=iOS Simulator,name=iPhone X,OS=12.4')