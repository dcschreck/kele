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
        response = self.class.get(build_url('/mentors/' + "#{mentor_id}" + '/student_availability'), headers: {"authorization" => @auth_token })
        schedule = JSON.parse(response.body)
        schedule.each do |session|
            if session['booked'] == nil
                available.push(session)
            end
        end
        return available
    end

    def get_messages(page = nil)
        if page != nil
            response = self.class.get(build_url('/message_threads'), headers: {"authorization" => @auth_token}, body: {page: page})
        else
            response = self.class.get(build_url('/message_threads'), headers: {"authorization" => @auth_token})
        end
        JSON.parse(response.body)
    end

    def create_message(sender, recipient_id, token = nil, subject = nil, stripped_text)
        message_options = {
            sender: sender,
            recipient_id: recipient_id,
            token: token,
            subject: subject,
            stripped_text: stripped_text
        }

        response = self.class.post(build_url('/messages'), headers: {"authorization" => @auth_token}, body: message_options)
        if response.success?
            p "Message sent"
        else
            p "Message not sent"
        end
    end

    private
    def build_url(endpoint)
        "https://www.bloc.io/api/v1#{endpoint}"
    end

end
