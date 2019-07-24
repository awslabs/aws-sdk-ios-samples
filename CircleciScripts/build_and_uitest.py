from functions import runcommand
from uitests_exceptions import *
import re
import datetime

import os


def build_and_uitest(circleci_root_directory, app_root_directory, appname, log_file_prefix, simulator_specification):

    ## install pods
    try:
        os.chdir(app_root_directory)
        if os.path.exists('Podfile.lock'):
            os.remove('Podfile.lock')
    except OSError as err:
        raise RemovePodfileLockException(appname, [str(err)])

    runcommand(command="pod install --repo-update",
               exception_to_raise = PodInstallException)

    ## build app; run uitests and store logs
    raw_logfile_path = "{0}/{1}_{2}_raw.log".format(circleci_root_directory, log_file_prefix, appname)
    consolidated_logfile_path = "{0}/{1}_{2}_summary.log".format(circleci_root_directory, log_file_prefix, appname)

    uitest_and_store_logs(appname = appname, simulator_specification = simulator_specification,
                          raw_logfile_path = raw_logfile_path,
                          consolidated_logfile_path = consolidated_logfile_path)

    failed_test_cases = get_failed_testcases_from_logs(raw_logfile_path = raw_logfile_path)

    for failed_test_case in failed_test_cases:
        raw_logfile_path = "{0}/{1}_{2}_retry_{3}.log".format(circleci_root_directory,
                                                              log_file_prefix, appname,
                                                              failed_test_case.replace('/','_'))

        uitest_and_store_logs(appname=appname, simulator_specification=simulator_specification,
                              raw_logfile_path=raw_logfile_path,
                              consolidated_logfile_path=consolidated_logfile_path,
                              only_testing = failed_test_case)


def uitest_and_store_logs(appname, simulator_specification,
                          raw_logfile_path, consolidated_logfile_path,
                          only_testing = None):

    ## It is expected that the sample app will have it's workspace named "<appname>.xcworkspace"
    ## and the scheme for UITesting is named "<appname>UITests", where <appname> is configured
    ## in the ../Configuration/uitests_ios_config.json file

    only_testing_string = " "
    if only_testing != None:
        only_testing_string = " -only-testing:{0}UITests/{1}".format(appname, only_testing)

    runcommand(command = "xcodebuild -workspace {0}.xcworkspace -scheme \"{0}UITests\" -destination \"{1}\" {2} test | tee {3}".format(
                          appname, simulator_specification, only_testing_string, raw_logfile_path),
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

# build_and_uitest('/Users/edupp/Desktop', '/Users/edupp/Desktop/autotest/PhotoAlbum','PhotoAlbum','testinglogs','platform=iOS Simulator,name=iPhone X,OS=12.4')