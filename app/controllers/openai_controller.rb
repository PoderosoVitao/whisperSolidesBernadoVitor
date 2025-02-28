require "net/http"

class OpenaiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def forward
    audio_binario = params["audioName"]

    # re-escreve o conteudo de um arquivo .opus para um novo arquivo .ogg
    if audio_binario.respond_to?(:original_filename) && File.extname(audio_binario.original_filename) == ".opus"
      temp_file = Tempfile.new([ "converted", ".ogg" ], binmode: true)
      temp_file.write(audio_binario.read)
      temp_file.rewind
      audio_binario = temp_file
    end

    service_openai = ::OpenaiService.new()
    transcricao = service_openai.transcribe(audio_binario)

    render json: { transcription: transcricao }
  end
end
