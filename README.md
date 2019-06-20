# README

This is an exercise application for Talkpush.

* Ruby version
2.5.1

* System dependencies
Credentials for Google Sheet is included here as credentials.json. This credential is under my account Marielyn Alvarado

* Configuration
Clone the project.
Run `bundle install` to install needed gems.

* Database creation
Create database.yml file with your database configuration for development and test. Note that this application uses postgres for database.
Run `bundle exec rake db:create` to create your databases.

* Database initialization
Run `bundle exec rake db:seed` to create the initial JobApplicationSetting data.

* Server
Run `bundle exec rails s` to start the server. The server is in Puma

* How to run the test suite
Run `bundle exec rspec spec/` to run the test cases which includes Feature and Model tests.

* Coverage
Check the tests coverage of the application in /coverage/index.html

* ...
