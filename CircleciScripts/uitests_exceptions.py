import sys
import os

## todo: use arrays to propogate

### setup uitest config exceptions
class SetupUITestConfigException(Exception):
    def __init__(self, message=None):
        self.message = self.construct_error_message_setup_config(message)

    def construct_error_message_setup_config(self, message):
        localmessage = ["...Unable generate uitests_ios_config file required to run UITests.Exit.. "]
        if message == None:
            return localmessage
        else: return localmessage.extend(message)


class InvalidDirectorySetUpConfigException(SetupUITestConfigException):
    def __init__(self, message):
        localmessage = ["...Unable to find config file template required for UITests."]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(InvalidDirectorySetUpConfigException, self).__init__(message = message)


### setup pods exceptions
class SetupPodsException(Exception):
    def __init__(self, appname, message=None):
        self.appname = appname
        self.message = self.construct_error_message_setup_pods(message)

    def construct_error_message_setup_pods(self, message):
        localmessage = ["...Unable to setup pods required for {0} app. Skipping.... ".format(self.appname)]
        if message == None:
            return localmessage
        else: return localmessage.extend(message)


class InvalidDirectoryException(SetupPodsException):
    def __init__(self, appname, message):
        localmessage = ["...Unable to find required directory for {0} app...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(InvalidDirectoryException, self).__init__(appname, message = message)


class FetchAppConfigException(SetupPodsException):
    def __init__(self, appname):
        message = ["... Unable to setup private git for podspecs for app {0}...".format(appname)]
        super(FetchAppConfigException, self).__init__(appname, message = message)

class SetupPrivateGitForPodspecsException(SetupPodsException):
    def __init__(self, appname):
        message = ["... Unable to setup private git for podspecs for app {0}...".format(appname)]
        super(SetupPrivateGitForPodspecsException, self).__init__(appname, message = message)

class PushPodspecsFromCloneToParentException(SetupPodsException):
    def __init__(self, appname):
        message = ["... Unable to push clone private repo to parent for app {0}...".format(appname)]
        super(PushPodspecsFromCloneToParentException, self).__init__(appname, message = message)


class SetupMasterRepoPodsException(SetupPodsException):
    def __init__(self, appname):
        message = ["...Unable to setup master pod repo for app {0}...".format(appname)]
        super(SetupMasterRepoPodsException, self).__init__(appname, message = message)


class AddLocalSpecsRepoException(SetupPodsException):
    def __init__(self, appname):
        message = ["...Unable to add local specs repo for app {0}...".format(appname)]
        super(AddLocalSpecsRepoException, self).__init__(appname, message = message)


class PodspecsValidateException(SetupPodsException):
    def __init__(self, appname, podspec):
        message = ["...{0} required for {1} app, could not validate...".format(podspec, appname)]
        super(PodspecsValidateException, self).__init__(appname, message = message)


class UpdatePodfileException(SetupPodsException):
    def __init__(self, appname, podspec):
        message = ["...Unable to edit the Podfile. Check if it exists in app root for {0}...".format(appname)]
        super(UpdatePodfileException, self).__init__(appname, message = message)


### fetch podspecs exceptions
class FetchPodspecsException(SetupPodsException):
    def __init__(self, appname, message=None):
        self.appname = appname
        self.message = self.construct_error_message_fetch_podspecs(message)
        super(FetchPodspecsException, self).__init__(appname, message=self.message)

    def construct_error_message_fetch_podspecs(self, message):
        localmessage = ["...Failed to populate podspecs directory with updated podspecs for {0} app...".format(self.appname)]
        if message == None:
            return localmessage
        else: return localmessage.extend(message)


class FetchRemotePodSourceException(FetchPodspecsException):
    def __init__(self, appname, podspec, message=None):
        localmessage = ["...Unable to fetch {0} source for app {1}. check source url and retry...".format(podspec, appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(FetchRemotePodSourceException, self).__init__(appname, message = message)


class CleanupFetchPodspecsException(FetchPodspecsException):
    def __init__(self, appname, podspec):
        message = ["...Unable to fetch {0}.podpsec for app {1}. check source url and retry...".format(podspec, appname)]
        super(CleanupFetchPodspecsException, self).__init__(appname, message = message)




### Build and uitest exceptions

class BuildAndUItestException(Exception):
    def __init__(self, appname, message=None):
        self.appname = appname
        self.message = self.construct_error_message_build_and_uitest(message)

    def construct_error_message_build_and_uitest(self, message):
        localmessage = ["...Unable to build and test {0} app. Skipping.... ".format(self.appname)]
        if message == None:
            return localmessage
        else: return localmessage.extend(message)

class RemovePodfileLockException(BuildAndUItestException):
    def __init__(self, appname, message=None):
        localmessage = ["...Unable to delete Podfile.lock for {0} app...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(RemovePodfileLockException, self).__init__(appname, message = message)

class SetUpLogFilesDirectoryException(BuildAndUItestException):
    def __init__(self, appname, message=None):
        localmessage = ["...Unable to delete Podfile.lock for {0} app...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(SetUpLogFilesDirectoryException, self).__init__(appname, message = message)

class PodInstallException(BuildAndUItestException):
    def __init__(self, appname):
        message = ["...Failed to install pods for app {0}. Skip...".format(appname)]
        super(PodInstallException, self).__init__(appname, message = message)

class BuildAndUItestFailException(BuildAndUItestException):
    def __init__(self, appname, logfile_path):
        message = ["...xcodebuild & test failed for app {0}. Check logs at {1}. Skip...".format(appname, logfile_path)]
        super(BuildAndUItestFailException, self).__init__(appname, message = message)


### Configure AWS Resources Excepitons

class ConfigureAWSResourcesException(Exception):
    def __init__(self, appname, message=None):
        self.appname = appname
        self.message = self.construct_error_message_build_and_uitest(message)

    def construct_error_message_build_and_uitest(self, message):
        localmessage = ["...Unable to Configure AWS Resources needed for {0} app. Skipping.... ".format(self.appname)]
        if message == None:
            return localmessage
        else: return localmessage.extend(message)

class OSErrorConfigureResources(ConfigureAWSResourcesException):
    def __init__(self, appname, message=None):
        localmessage = ["...Unable to replace api schema for app {0}...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(OSErrorConfigureResources, self).__init__(appname, message = message)

class GitCloneCliException(ConfigureAWSResourcesException):
    def __init__(self, appname):
        message = ["...Failed to clone amplify-cli repo for app {0}. Skip...".format(appname)]
        super(GitCloneCliException, self).__init__(appname, message = message)

class CliSetupDevException(ConfigureAWSResourcesException):
    def __init__(self, appname):
        message = ["...Failed to run npm setup-dev for app {0}. Skip...".format(appname)]
        super(CliSetupDevException, self).__init__(appname, message = message)

class CliConfigException(ConfigureAWSResourcesException):
    def __init__(self, appname):
        message = ["...Failed to run npm config to create AWS Resources for app {0}. Skip...".format(appname)]
        super(CliConfigException, self).__init__(appname, message = message)

class OSErrorDeleteResources(ConfigureAWSResourcesException):
    def __init__(self, appname, message=None):
        localmessage = ["...Failed to navigate to cli delete resources script for app {0}. Skip...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(OSErrorDeleteResources, self).__init__(appname, message = message)

class CliDeleteResourcesException(ConfigureAWSResourcesException):
    def __init__(self, appname):
        message = ["...Failed to run npm delete to bring down AWS Resources for app {0}. Skip...".format(appname)]
        super(CliDeleteResourcesException, self).__init__(appname, message = message)

class OSErrorDeleteCliRepo(ConfigureAWSResourcesException):
    def __init__(self, appname, message=None):
        localmessage = ["...Failed to delete the cloned amplify-cli repo for app {0}. Skip...".format(appname)]
        if message != None:
            message = localmessage.extend(message)
        else: message = localmessage
        super(OSErrorDeleteCliRepo, self).__init__(appname, message = message)
