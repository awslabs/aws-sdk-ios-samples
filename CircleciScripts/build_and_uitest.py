from functions import runcommand
from uitests_exceptions import *

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

    logfile_path = "{0}/{1}_{2}.log".format(circleci_root_directory, log_file_prefix, appname)

    ## It is expected that the sample app will have it's workspace named "<appname>.xcworkspace"
    ## and the scheme for UITesting is named "<appname>UITests", where <appname> is configured
    ## in the ../Configuration/uitests_ios_config.json file

    runcommand(command = "xcodebuild -workspace {0}.xcworkspace -scheme \"{0}UITests\" -destination \"{1}\" test | tee {2}".format(
                              appname, simulator_specification, logfile_path),
               exception_to_raise = BuildAndUItestFailException(appname, logfile_path))