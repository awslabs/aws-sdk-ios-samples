# git clone https://github.com/awslabs/aws-sdk-ios-samples.git
# rootDirectory=$(pwd)
# cd aws-sdk-ios-samples/S3TransferUtility-Sample/Swift/
# echo ${AWS_S3_TRANSFER_UTILITY_SAMPLE_APP_CONFIGURATION} | base64 --decode > awsconfiguration.json
# echo ${AWS_S3_TRANSFER_UTILITY_SAMPLE_APP_PODFILE} | base64 --decode > Podfile
# pod install
# xcodebuild -workspace S3TransferUtilitySampleSwift.xcworkspace -scheme "S3TransferUtilitySampleSwiftUITests" -destination "${destination}" test | tee $rootDirectory/raw_ui_test.log
# cd $rootDirectory
# rm -rf aws-sdk-ios-samples

# from functions import runcommand
#
# app_repo_root_directory = "/Users/edupp/Desktop/autotest"
# appname = "PhotoAlbum"
# circleci_root_directory = "/Users/edupp/Desktop"
# rn = runcommand(command="python3 run_setup_pods.py -n {0} -a {1}".format(appname, app_repo_root_directory))
# print(rn)
# rn = runcommand(command="python3 run_configure_aws_resources.py -n {0} -a {1}".format(appname, app_repo_root_directory))
# print(rn)
# rn = runcommand(command="python3 run_build_and_uitest.py -n {0} -a {1} -c {2}".format(appname, app_repo_root_directory, circleci_root_directory))
# print(rn)
#rn = runcommand(command="python3 run_cleanup_uitests.py -n {0} -a {1}".format(appname, app_repo_root_directory))
#print(rn)


