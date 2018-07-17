require 'httparty'
require 'json'
require 'kele/roadmap'

class Kele
    include HTTParty
    include Roadmap
    
    base_uri = 'https://www.bloc.io/api/v1'

    def initialize(email, password)
        options = {
            body: {
                email: email,
                password: password
            }
        }

        response = self.class.post(build_url('/sessions'), options)

        if response.success?
            @auth_token = response['auth_token']
        else
            raise "Authorization failed. Invalid email or password."
        end
    end

    def get_me
        response = self.class.get(build_url('/users/me'), headers: {"authorization" => @auth_token })
        JSON.parse(response.body)
    end

    def get_mentor_availability(mentor_id)
        available = []
        response = self.class.get(build_url('/mentors/'+"#{mentor_id}"+'/student_availability'), headers: {"authorization" => @auth_token })
        schedule = JSON.parse(response.body)
        schedule.each do |session|
            if session['booked'] == nil
                available.push(session)
            end
        end
        return available
    end

    private
    def build_url(endpoint)
        "https://www.bloc.io/api/v1#{endpoint}"
    end

end
