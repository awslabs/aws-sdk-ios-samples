# git clone https://github.com/awslabs/aws-sdk-ios-samples.git
# rootDirectory=$(pwd)
# cd aws-sdk-ios-samples/S3TransferUtility-Sample/Swift/
# echo ${AWS_S3_TRANSFER_UTILITY_SAMPLE_APP_CONFIGURATION} | base64 --decode > awsconfiguration.json
# echo ${AWS_S3_TRANSFER_UTILITY_SAMPLE_APP_PODFILE} | base64 --decode > Podfile
# pod install
# xcodebuild -workspace S3TransferUtilitySampleSwift.xcworkspace -scheme "S3TransferUtilitySampleSwiftUITests" -destination "${destination}" test | tee $rootDirectory/raw_ui_test.log
# cd $rootDirectory
# rm -rf aws-sdk-ios-samples
#

from functions import runcommand, replacefiles
import sys
import os
import glob
import ntpath

# - create directory
# - Fetch project
# - add awsconfig.json
# - install pods
# - build for testing
# - store test logs


# replaces = [
#     {
#         "match" : r":tag[[:space:]]*=>[[:space:]]*.*}",
#         "replace" : r':branch => "development" }',
#         "files" : [
#             "AWSS3.podspec"
#         ]
#     },
#     {
#         "match" : r":tag[[:space:]]*=>[[:space:]]*.*,",
#         "replace" : r':branch => "development" ,',
#         "files" : [
#             "AWSS3.podspec"
#         ]
#     }
# ]
#
# replacefiles('/Users/edupp/Desktop/', replaces)
# rn = runcommand(command = "gem install cocoapods")
# rn = runcommand(command = "pods repo list")
# if rn != 0:
#     print("unable to add local specs repo for app {0}".format())
#     exit(1)

# rn = runcommand(command="python3 run_uitests.py")

