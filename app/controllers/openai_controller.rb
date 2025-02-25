require "net/http"

class OpenaiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def forward
    audio_binario = params["audioName"]
    service_openai = ::OpenaiService.new()
    transcricao = service_openai.transcribe(audio_binario)

    render json: { transcription: transcricao }
  end
end
