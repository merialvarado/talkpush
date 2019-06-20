require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'open-uri'
require 'net/http'

class JobApplication
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
  TALKPUSH_API_KEY = "48530ba23eef6b45ffbc95d7c20a60b9"
  TALKPUSH_API_SECRET = "e2f724ba060f82ddf58923af494578a7"

  ## 
  # Fetch new candidates from Google Sheet and sync the candicates to Talkpush API
  # @return Integer the status of method, return 200 if okay
  # @return String the message
  # @return String the errors
  # 
  ##
  def self.get_new_application
    settings = JobApplicationSetting.first
    service = initialize_google_api

    row_counter = (settings.nil? || ( row_count = settings.row_counter).nil? ) ? 2 : row_count
    range = "Form Responses 2!A#{row_counter}:E"
    response = service.get_spreadsheet_values(settings.spreadsheet_id, range)

    return {status: 200, message: "There's NO NEW ROW found to be synced."} if response.values.nil? || response.values.empty?

    new_counter = row_counter
    sync_error = []
    response.values.each do |row|
      applicant_info = {timestamp: "", first_name: "", last_name: "", email: "", phone_num: ""}
      applicant_info[:timestamp] = row[0]
      applicant_info[:first_name] = row[1]
      applicant_info[:last_name] = row[2]
      applicant_info[:emai] = row[3]
      applicant_info[:phone_num] = row[4]

      resp_code, resp_error = self.push_candidates(settings.campaign_id, applicant_info)
      if resp_code.to_s != 200.to_s || !resp_error.blank?
        sync_error << "#{new_counter} - #{resp_error}"
      end

      new_counter += 1
    end

    settings.update_attribute(:row_counter, new_counter)
    return { status: 200, message: "Succesfully synced #{new_counter-row_counter} new applicant/s to Talkpush.", errors: sync_error }
  end

  ##
  # Post new candicate to Talkpush
  # @param [Integer] campaign ID
  # @param [Hash] Candidate Information with :first_name, :last_name, :email, :user_phone_number 
  # @return response code
  ##
  def self.push_candidates(campaign_id, applicant_info = {})
    talkpush_url = "https://my.talkpush.com/api/talkpush_services/campaigns/#{campaign_id}/campaign_invitations"
    uri = URI.parse(talkpush_url)
    request = Net::HTTP::Post.new(uri)
    request["Cache-Control"] = "no-cache"
    request["Content-Type"] = "application/json"
    request.body = {
      api_key: TALKPUSH_API_KEY, 
      api_secret: TALKPUSH_API_SECRET,
      campaign_invitation: {
        first_name: applicant_info[:first_name],
        last_name: applicant_info[:last_name],
        email: applicant_info[:email],
        user_phone_number: applicant_info[:phone_num]
      }
    }.to_json

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return response.code, JSON.parse(response.body)["error"].to_s
  end


  private
    ##
    # Initialize Google API
    ##
    def self.initialize_google_api
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = self.authorize
      return service
    end

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def self.authorize
      client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)

      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts 'Open the following URL in the browser and enter the ' \
        "resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end
end