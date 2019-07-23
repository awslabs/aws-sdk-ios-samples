from uitests_exceptions import UpdatePodfileException

## edit Podfile to add local git repo for private specs
## Also add default cocoapods repo to use released versions of SDKs


def update_podfile(private_podspecs_git_repo_directory, app_root_directory, appname):

    released_pods_source = "source 'https://github.com/CocoaPods/Specs'"
    private_pods_source = "source '{0}'".format(private_podspecs_git_repo_directory)

    try:
        prependline("{0}/Podfile".format(app_root_directory), released_pods_source)
        prependline("{0}/Podfile".format(app_root_directory), private_pods_source)
    except:
        raise UpdatePodfileException(appname)

def prependline(file, line):
    with open(file, 'r+') as f:
        oldcontent = f.read()
        f.seek(0, 0)
        f.write(line.rstrip('\r\n') + '\n' + oldcontent) ## remove any form of line endings platform independent trim
