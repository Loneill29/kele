require 'httparty'
require './lib/roadmap'

class Kele
  include HTTParty
  include Roadmap
  base_uri "https://www.bloc.io/api/v1"

  def initialize(email, password)
    response = self.class.post( "/sessions", body: { email: email, password: password } )
    #return error for invalid credentials
    if response.code == 404
      raise "Those credentials are invalid. Please try again."
    else
      @auth_token = response["auth_token"]
    end
  end

  def api_url(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end

  def get_me
    response = self.class.get(api_url("users/me"), headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get(api_url("/mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token })
    #only retrieve open time slots
    open = []
    JSON.parse(response.body).each do |time_slot|
      if time_slot["booked"].nil?
        open.push(time_slot)
      end
    end
    open
  end

  def get_messages(page = 0)
    #direct to first page or to a specific page
   if page > 0
     page_url = "/message_threads?page=#{page}"
   else
     page_url = "/message_threads"
   end
      response = self.class.get(page_url, headers: { "authorization" => @auth_token })
      @messages = JSON.parse(response.body)
  end

  def create_message(sender, recipient_id, token, subject, stripped_text)
    self.class.post(api_url("/messages"), body: { sender: sender, recipient_id: recipient_id, token: token, subject: subject, stripped_text: body })
  end
end
