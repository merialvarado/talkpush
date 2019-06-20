class JobApplicationsController < ApplicationController
	def index

	end

	def new_applications
		sync_applications = JobApplication.get_new_application
		if sync_applications[:status] == 200
			success_message = sync_applications[:message]
			success_message << " Though the following rows from Google Sheet are not successfully synced: " + sync_applications[:errors].join(", ") unless sync_applications[:errors].blank? 
			
			redirect_to job_applications_path, notice: success_message
		else
			redirect_to job_applications_path, alert: "There's an error encountered while syncing Job Applications to Pushtalk."
		end
	end
end
