#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2016, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example shows how to authenticate using a service account.

require_relative '../dfareporting_utils'

def authenticate_using_service_account(impersonation_user_email,
    path_to_json_file)
  # Instantiate the API service object.
  service = DfareportingUtils::API_NAMESPACE::DfareportingService.new
  service.client_options.application_name = "Ruby service account sample"
  service.client_options.application_version = '1.0.0'

  # Generate an authorization object from the specified JSON file.
  File.open(path_to_json_file, 'r+') do |json|
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds({
      :json_key_io => json,
      :scope => DfareportingUtils::API_SCOPES
    })
  end

  # Configure impersonation.
  service.authorization.sub = impersonation_user_email

  return service
end

def get_userprofiles(service)
  # Get all user profiles.
  result = service.list_user_profiles()

  # Display results.
  result.items.each do |profile|
    puts 'User profile with ID %d and name "%s" was found for account %d.' %
        [profile.profile_id, profile.user_name, profile.account_id]
  end
end

if __FILE__ == $0
  # Retrieve command line arguments.
  args = DfareportingUtils.get_arguments(ARGV, :impersonation_user_email,
      :path_to_json_file)

  # Authenticate and initialize API service using service account.
  service = authenticate_using_service_account(args[:impersonation_user_email],
      args[:path_to_json_file])

  get_userprofiles(service)
end
