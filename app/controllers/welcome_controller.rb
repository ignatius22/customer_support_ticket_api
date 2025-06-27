class WelcomeController < ApplicationController
  def welcome
    render json: { message: "Welcome to Customer Support Ticketing API" }
  end
end
