require 'httparty'

class Kele
  include HTTParty
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
end
