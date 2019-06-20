class CreateJobApplicationSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :job_application_settings do |t|
      t.integer :row_counter
      t.text :spreadsheet_id
      t.integer :campaign_id

      t.timestamps
    end
  end
end
