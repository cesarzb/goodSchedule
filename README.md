# README

This is API-only Ruby on Rails application, 
which is going to help students set up the best possible 
school schedule based on the available options.
Authentication - jwt gem.
Tests and documentation - rswag gem.
Database - PostgreSQL.

First clone the repository to you local machine, 
then use the following commands:

bundle install

rails db:create

rails db:migrate

rails s

To access documentation go to

http://localhost:3000/api-docs

To run the test suite use command

rspec