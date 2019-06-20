require "rails_helper"

RSpec.describe JobApplication, :type => :model do
	before(:each) do
		FactoryGirl.create :job_application_setting
	end

	after(:each) do
		JobApplicationSetting.delete_all
	end

  context "get new application" do
    it "returns 200 when new candidates are successfully fetched from GoogleSheet and synced to PushTalk" do
      VCR.use_cassette("push_candidates") do
	    	new_job_application = JobApplication.get_new_application
      	expect(new_job_application[:status]).eql? 200
	    end
    end
  end
end