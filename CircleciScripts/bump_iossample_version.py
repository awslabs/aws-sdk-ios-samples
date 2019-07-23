from functions import replacefiles
import sys
import os

root = '/Users/edupp/Desktop/autotest/PhotoAlbum/uitests_ios_podspecs'
newsdkversion = '100.100.100'
#s.version      = '2.14.0'

replaces = [
    {
        "enclosemark" : "double",
        "match" : r"(s.version[[:space:]]*=[[:space:]]*')[0-9]+\.[0-9]+\.[0-9]+'",
        "replace" : r"\1[version]'",
        "files" : [
            "AWSAppSync.podspec"
        ]       
    }
]
for replaceaction in replaces:
    replaceaction["replace"] = replaceaction["replace"].replace("[version]", newsdkversion)
replacefiles(root, replaces)
