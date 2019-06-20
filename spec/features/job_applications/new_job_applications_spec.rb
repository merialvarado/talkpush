require 'rails_helper'

RSpec.feature "Job Application", :type => :feature do
	before(:each) do
		FactoryGirl.create :job_application_setting
	end

	after(:each) do
		JobApplicationSetting.delete_all
	end

	# Assumption 1: All the new rows are new candidates
	# Assumption 2: Response from Google Sheet and Talkpush API was recorded using VCR.
	# Assumption 3: Spreadsheet used is also a public spreadsheet under Marielyn Alvarado Google Account
  scenario "Sync new job applications" do
    visit "/job_applications"

    VCR.use_cassette("push_candidates") do
      click_link "Sync Job Applications to Talkpush"
    end

    expect(page).to have_text("Succesfully synced")
  end

  scenario "No new row to sync" do
    visit "/job_applications"

    VCR.use_cassette("push_candidates") do
      click_link "Sync Job Applications to Talkpush"
    end
    VCR.use_cassette("no_new_candidates") do
      click_link "Sync Job Applications to Talkpush"
    end
    expect(page).to have_text("There's NO NEW ROW found to be synced")
  end

  scenario "Duplicate Candidates" do
    visit "/job_applications"

    VCR.use_cassette("push_candidates") do
      click_link "Sync Job Applications to Talkpush"
    end

    JobApplicationSetting.last.update_attribute(:row_counter, 2)

    VCR.use_cassette("duplicate_candidates") do
      click_link "Sync Job Applications to Talkpush"
    end
    expect(page).to have_text("uccesfully synced 2 new applicant/s to Talkpush. Though the following rows from Google Sheet are not successfully synced: 2 - duplicated, 3 - duplicated")
  end
end