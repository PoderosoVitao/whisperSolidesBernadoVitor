require "openai"
require "stringio"
require 'uri'
class OpenaiService
  API_URL = "https://api.openai.com/v1/audio/transcriptions"
  def transcribe(audio)
    uri = URI.parse(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
    form_data = {
      "file"  => audio,
      "model" => "whisper-1"
    }
    request.set_form(form_data, 'multipart/form-data')

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    response.body
  end
end
