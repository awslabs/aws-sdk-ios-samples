from uitests_exceptions import *
from os import remove, rename
import re

## edit Podfile to add path to pod source for a given pod

def update_podfile(appname, app_root_directory, pod_name, pod_source_path):

    podfile_path = "{0}/Podfile".format(app_root_directory)
    podfile_copy_path = "{0}/Podfile_copy".format(app_root_directory)

    pattern = re.compile("pod\s+'\s*" + pod_name + "\s*'.*$")
    sub = "pod '{0}', :path => '{1}'".format(pod_name, pod_source_path)

    with open(podfile_copy_path, 'w+') as new_podfile:
        with open(podfile_path) as old_podfile:
            for line in old_podfile:
                new_podfile.write(re.sub(pattern, sub, line))

    # Remove original file
    remove(podfile_path)

    # Rename new file
    rename(podfile_copy_path, podfile_path)
