# from functions import runcommand
# from parse_config_uitests import config_uitests
# from setup_pods import setup_pods
# from uitests_exceptions import SetupPodsException, BuildAndUItestException, ConfigureAWSResourcesException
# from build_and_uitest import build_and_uitest
# from traceback import print_exception
# from configure_aws_resources import configure_aws_resources
#
# import argparse
#
# # arg_parser = argparse.ArgumentParser(description='Master Script to run uiTests on iOS sample apps')
# # arg_parser.add_argument('-c', '--circleci_root_directory', type=str, help='full path to circleci root')
# # arg_parser.add_argument('-a', '--app_repo_root_directory', type=str, help='full path to cloned sample apps repo')
# # args = arg_parser.parse_args()
#
# args = {'app_repo_root_directory': "/Users/edupp/Desktop/autotest",
#         'circleci_root_directory': "/Users/edupp/Desktop"}
#
#
# exitcode = 0
# for appname, app_config in vars(config_uitests.apps_to_uitest).items():
#
#     if appname == "S3TransferUtility":
#         continue
#     try:
#         cleanup_pod_repos = setup_pods(app_repo_root_directory = args['app_repo_root_directory'],
#                                        appname = appname,
#                                        app_config = app_config)
#
#     except SetupPodsException as err:
#         print(err.message)
#         print_exception(type(err), err, err.__traceback__, chain=False)
#         exitcode = 1
#         continue
#
#     configure_aws_resources(app_root_directory = '{0}/{1}'.format(args['app_repo_root_directory'], app_config.path),
#                             appname = appname,
#                             cli_resources = app_config.cli_resources)
#
#     app_root_directory = "{0}/{1}".format(args['app_repo_root_directory'], app_config.path)
#     try:
#         build_and_uitest(circleci_root_directory = args['circleci_root_directory'],
#                          app_root_directory = app_root_directory,
#                          appname = appname,
#                          logs_folder_name = config_uitests.logs_folder_name,
#                          simulator_specification = config_uitests.simulator_specification)
#
#     except BuildAndUItestException as err:
#         print(err.message)
#         print_exception(type(err), err, err.__traceback__, chain=False)
#         exitcode = 1
#         continue
#
#     ## clean up
#     for pod_repo in cleanup_pod_repos:
#         runcommand(command="pod repo remove {0}".format(pod_repo))
#
#     # try:
#     #     delete_aws_resources(app_root_directory = app_root_directory,
#     #                          appname = appname)
#     # except ConfigureAWSResourcesException as err:
#     #     print(err.message)
#     #     print_exception(type(err), err, err.__traceback__, chain=False)
#     #     exitcode = 1
#     #     continue
#
# exit(exitcode)
