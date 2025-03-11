require "openai"
require "stringio"
require 'uri'
require 'streamio-ffmpeg'
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

  def cortar_audio(input_path, output_path, duracao = 10)
    movie = FFMPEG::Movie.new(input_path)
    if movie.duration > duracao
      begin
        movie.transcode(output_path, duration: duracao) do |progress|
          puts "Progresso: #{(progress * 100).round(2)}%"
        end
        puts "Áudio cortado com sucesso: #{output_path}"
        true
      rescue StandardError => e
        puts "Erro ao cortar áudio: #{e.message}"
      end
    else
      puts "O áudio já tem #{movie.duration} segundos, não foi necessário cortar."
      false
    end
  end
end
