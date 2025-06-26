# config/initializers/apollo_upload.rb
require 'apollo_upload_server'

Rails.application.config.middleware.use ApolloUploadServer::Middleware
